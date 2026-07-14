part of '../pjsip_service.dart';

typedef _PjmediaAudDevRefreshC = ffi.Int Function();
typedef _PjmediaAudDevRefreshDart = int Function();

/// 音频模块的运行时状态。
///
/// 这些字段不放进 `PjsipUIState`，因为它们不是 UI 需要观察的数据，而是服务内部
/// 的工作状态：timer、上一次设备快照、用户偏好的设备签名、PJSIP 动态函数指针。
/// UI state 应该保持可序列化/可展示；runtime state 则留在 service 内部。
class _PjsipAudioRuntime {
  /// PJSIP 底层刷新音频驱动设备列表的函数。
  ///
  /// 生成的 FFI bindings 里不一定包含这个函数，所以启动时手动 lookup。
  /// 如果动态库没有导出，值为 null，后续只做 `pjsua_enum_aud_devs` 枚举缓存。
  _PjmediaAudDevRefreshDart? pjmediaAudDevRefresh;

  /// 没有通话时的设备轮询间隔。
  Duration idlePollInterval = const Duration(seconds: 1);

  /// 通话中的设备轮询间隔。通话中用户更在意耳机插拔，所以通常比空闲时更快。
  Duration inCallPollInterval = const Duration(seconds: 1);

  /// 设备变化防抖时间。
  ///
  /// 蓝牙耳机连接/断开时，CoreAudio 会连续产生多轮设备变化。防抖可以等它稍微
  /// 稳定一点再刷新 UI 和触发自动切换。
  Duration changeDebounceInterval = const Duration(milliseconds: 250);

  /// 通话电平刷新间隔，用来驱动麦克风/扬声器电平条。
  Duration levelPollInterval = const Duration(milliseconds: 500);

  /// 切换设备后，重复重连 conference bridge 的补偿时间点。
  ///
  /// 设备刚切换时声卡可能还没 ready，立即重连不一定成功；延迟补偿能覆盖蓝牙
  /// profile 切换、CoreAudio 端点重建等短暂过渡期。
  List<Duration> bridgeReconnectRetryDelays = const [
    Duration(milliseconds: 150),
    Duration(milliseconds: 500),
    Duration(milliseconds: 1200),
    Duration(milliseconds: 2500),
  ];

  Timer? levelTimer;
  Timer? devicePollTimer;
  Timer? deviceChangeDebounceTimer;
  Timer? speakerTestTimer;
  final List<Timer> bridgeReconnectTimers = <Timer>[];

  /// 上一次“可用设备列表”的快照签名，用于判断设备是否真的发生变化。
  String? lastDeviceSnapshot;
  int? speakerTestPlayerId;
  int? speakerTestPlayerPort;
  int? microphoneTestRecorderId;
  int? microphoneTestRecorderPort;

  /// 手动模式下，用户选择的输入设备签名。
  ///
  /// 不只存 ID，是因为 PJSIP 设备 ID 在耳机插拔后可能被重排或复用。
  String? preferredCaptureDeviceSignature;

  /// 手动模式下，用户选择的输出设备签名。
  String? preferredPlaybackDeviceSignature;

  /// 当前真正应用到 PJSIP 的输入设备签名，用来发现 ID 复用。
  String? activeCaptureDeviceSignature;

  /// 当前真正应用到 PJSIP 的输出设备签名，用来发现 ID 复用。
  String? activePlaybackDeviceSignature;
}

/// 音频设备枚举、切换、静音、电平监测和轻量热插拔轮询。
///
/// 这个 extension 可以理解成“给 `PjsipService` 增加一组音频能力”。
/// Dart 的 extension 不能自己保存字段，所以真正需要保存的运行时变量都放在
/// `PjsipService._audio` 这个 `_PjsipAudioRuntime` 对象里。
///
/// 这个文件主要做 5 件事：
///
/// 1. 从 PJSIP 枚举麦克风/扬声器设备。
/// 2. 过滤掉不适合通话的虚拟设备、聚合设备、方向错误设备。
/// 3. 根据自动/手动策略调用 `pjsua_set_snd_dev` 切换设备。
/// 4. 用轻量轮询监听耳机插拔和蓝牙设备变化。
/// 5. 通话中切换设备后，重新连接 PJSIP conference bridge，恢复声音路径。
///
/// 这里刻意把“原始设备列表”和“通话可用设备列表”分开：
///
/// - 原始列表来自 PJSIP/CoreAudio 的底层枚举，可能包含 BlackHole、Teams
///   Audio、Aggregate Device、DisplayPort 显示器音频，甚至把某些输出设备暴露成
///   input_count > 0 的端点。它们对排查问题有价值，所以仍然完整打印日志。
/// - 通话可用列表用于 UI 下拉框和自动选择策略，会过滤掉明显不适合作为 VoIP
///   通话设备的“幽灵设备”。这避免用户选到虚拟声卡、聚合设备或错误方向的端点。
extension PjsipAudioDeviceOperations on PjsipService {
  /// 空闲状态下多久检查一次音频设备变化。
  ///
  /// 这个 getter 暴露给 service 使用，也方便你在调试时直接改值。
  /// 空闲时可以设慢一点，例如 2-3 秒；开发阶段为了体验也可以保持 1 秒。
  Duration get audioDeviceIdlePollInterval => _audio.idlePollInterval;

  /// 修改空闲状态设备轮询间隔。
  set audioDeviceIdlePollInterval(Duration value) {
    _audio.idlePollInterval = value;
  }

  /// 通话中多久检查一次音频设备变化。
  ///
  /// 通话中用户插拔耳机时希望尽快恢复声音，所以通常比空闲时更短。
  Duration get audioDeviceInCallPollInterval => _audio.inCallPollInterval;

  /// 修改通话中的设备轮询间隔。
  set audioDeviceInCallPollInterval(Duration value) {
    _audio.inCallPollInterval = value;
  }

  /// 设备变化防抖间隔。
  ///
  /// 例如蓝牙耳机连接时，系统可能连续报告多次变化：
  /// 先出现低质量通话 profile，再出现稳定输入/输出端点。防抖就是等变化停一小会儿
  /// 再真正刷新设备和自动切换。
  Duration get audioDeviceChangeDebounceInterval =>
      _audio.changeDebounceInterval;

  /// 修改设备变化防抖间隔。
  set audioDeviceChangeDebounceInterval(Duration value) {
    _audio.changeDebounceInterval = value;
  }

  /// 麦克风/扬声器电平条刷新间隔。
  ///
  /// 这不是设备热插拔检测，而是通话中 UI 上音量条的刷新频率。
  Duration get audioLevelPollInterval => _audio.levelPollInterval;

  /// 修改音频电平刷新间隔。
  set audioLevelPollInterval(Duration value) {
    _audio.levelPollInterval = value;
  }

  /// 设备切换后，重连音频桥的延迟重试时间表。
  ///
  /// PJSIP 切换声卡成功，不代表系统声卡立刻 ready。尤其蓝牙耳机切换 profile 时，
  /// 可能需要几百毫秒到几秒。这里配置多次补偿重连，提升通话中恢复声音的概率。
  List<Duration> get audioBridgeReconnectRetryDelays =>
      _audio.bridgeReconnectRetryDelays;

  /// 修改设备切换后的音频桥重连重试时间表。
  set audioBridgeReconnectRetryDelays(List<Duration> value) {
    _audio.bridgeReconnectRetryDelays = value;
  }

  /// 初始化音频模块需要的 PJSIP 动态函数。
  ///
  /// `pjsua_enum_aud_devs` 可以枚举设备，但有些平台上设备热插拔后，底层驱动列表
  /// 需要先调用 `pjmedia_aud_dev_refresh` 才会更新。因为生成的 FFI bindings 里
  /// 可能没有这个函数，所以这里用动态库手动查找。
  ///
  /// 如果查找失败，不让 App 崩溃；后续仍然可以枚举 PJSIP 当前缓存里的设备。
  void _setupAudioRuntime(ffi.DynamicLibrary dylib) {
    try {
      _audio.pjmediaAudDevRefresh = dylib
          .lookupFunction<_PjmediaAudDevRefreshC, _PjmediaAudDevRefreshDart>(
            'pjmedia_aud_dev_refresh',
          );
    } catch (_) {
      _audio.pjmediaAudDevRefresh = null;
    }
  }

  Future<void> refreshAudioDevices() => _refreshAudioDevices(
    reason: '手动刷新',
    logResult: true,
    allowAutomaticSwitch: true,
  );

  /// 开启或关闭“自动选择音频设备”。
  ///
  /// 自动模式下，策略会优先选择耳机/蓝牙设备，其次选择系统默认设备。
  /// 手动模式下，会记住用户当前选中的设备签名；之后热插拔导致 ID 变化时，会尽量
  /// 根据签名找回同一台设备。
  ///
  /// UI 上切换“自动/手动”时会调用这个方法。
  Future<void> setAutomaticAudioDeviceSelection(bool enabled) async {
    if (!_uiState.isInitialized) return;

    if (enabled) {
      // 回到自动模式时清空手动偏好，让策略重新按“耳机优先、系统默认兜底”选择。
      _audio.preferredCaptureDeviceSignature = null;
      _audio.preferredPlaybackDeviceSignature = null;
      _uiState = _uiState.copyWith(
        audioDeviceMode: PjsipAudioDeviceMode.automatic,
        audioDeviceStatus: '自动选择设备：优先耳机，其次系统默认',
      );
      await _refreshAudioDevices(
        reason: '启用自动选择',
        logResult: true,
        allowAutomaticSwitch: true,
      );
      return;
    }

    // 切到手动模式时不只记设备 ID，还记签名。热插拔后 ID 可能变化，但签名更稳定。
    _audio.preferredCaptureDeviceSignature = _deviceSignatureById(
      _uiState.captureDevices,
      _uiState.selectedCaptureDeviceId,
    );
    _audio.preferredPlaybackDeviceSignature = _deviceSignatureById(
      _uiState.playbackDevices,
      _uiState.selectedPlaybackDeviceId,
    );
    _uiState = _uiState.copyWith(
      audioDeviceMode: PjsipAudioDeviceMode.manual,
      audioDeviceStatus: '手动选择设备',
    );
    _addLog('🎧 已切换为手动音频设备选择');
  }

  /// 设置是否允许“通话中自动切换新设备”。
  ///
  /// 这属于产品策略：
  ///
  /// - 关闭时：通话中尽量不因为新耳机插入而抢切，避免用户突然听不到声音。
  /// - 开启时：通话中也允许检测、刷新底层设备、自动切到耳机或回退默认设备。
  ///
  /// 目前你在体验热插拔，所以打开它会更接近“插上耳机自动用耳机”的效果。
  void setAllowInCallAudioDeviceSwitch(bool enabled) {
    if (_uiState.allowInCallAudioDeviceSwitch == enabled) return;
    _uiState = _uiState.copyWith(
      allowInCallAudioDeviceSwitch: enabled,
      audioDeviceStatus: enabled ? '实验模式：通话中检测并自动切换新设备' : '通话中保持当前设备；设备丢失时自动回退',
    );
    _addLog(enabled ? '🎧 已开启通话中自动检测/切换音频设备' : '🎧 已关闭通话中自动检测/切换音频设备');
  }

  /// 切换 PJSIP 当前使用的输入/输出设备。
  ///
  /// 这是音频切换的核心入口，最终会调用 PJSIP 的：
  ///
  /// `pjsua_set_snd_dev(captureId, playbackId)`
  ///
  /// 参数说明：
  ///
  /// - `captureDeviceId`：麦克风设备 ID，不传则沿用当前或 UI 选择。
  /// - `playbackDeviceId`：扬声器设备 ID，不传则沿用当前或 UI 选择。
  /// - `markManual`：是否认为这是用户手动选择。自动策略调用时会传 false。
  /// - `reason`：日志里展示为什么切换。
  /// - `forceReapply`：即使 ID 没变，也强制重新应用。用于处理 PJSIP ID 复用。
  ///
  /// 初学时可以把它理解成：Flutter UI/自动策略都只是在决定 ID，真正让 PJSIP
  /// 使用哪个麦克风和扬声器，是这个函数完成的。
  Future<void> setAudioDevices({
    int? captureDeviceId,
    int? playbackDeviceId,
    bool markManual = true,
    String reason = '用户选择',
    bool forceReapply = false,
  }) {
    if (!_uiState.isInitialized) {
      _addLog('⚠️ PJSIP 尚未初始化，无法切换音频设备');
      return Future.value();
    }

    return Future<void>(() {
      using((Arena arena) {
        // 先读取 PJSIP 当前声卡设置。调用方可以只传输入或只传输出，另一侧沿用当前值。
        final current = _currentSoundDeviceIds(arena);
        final captureId =
            captureDeviceId ??
            _uiState.selectedCaptureDeviceId ??
            current.captureId ??
            pjsua_snd_dev_id.PJSUA_SND_DEFAULT_CAPTURE_DEV.value;
        final playbackId =
            playbackDeviceId ??
            _uiState.selectedPlaybackDeviceId ??
            current.playbackId ??
            pjsua_snd_dev_id.PJSUA_SND_DEFAULT_PLAYBACK_DEV.value;

        // 有些场景看起来“设备 ID 没变”，但我们仍然需要更新 UI 状态或重连音频桥。
        // 例如手动重新选择默认设备，或者 PJSIP 当前就是 -1/-2 但通话桥需要补偿恢复。
        if (!forceReapply &&
            captureId == current.captureId &&
            playbackId == current.playbackId) {
          final selectedSystemDefaults =
              captureId ==
                  pjsua_snd_dev_id.PJSUA_SND_DEFAULT_CAPTURE_DEV.value &&
              playbackId ==
                  pjsua_snd_dev_id.PJSUA_SND_DEFAULT_PLAYBACK_DEV.value;
          _uiState = _uiState.copyWith(
            selectedCaptureDeviceId: captureId,
            selectedPlaybackDeviceId: playbackId,
            audioDeviceMode: selectedSystemDefaults
                ? PjsipAudioDeviceMode.automatic
                : markManual
                ? PjsipAudioDeviceMode.manual
                : _uiState.audioDeviceMode,
            audioDeviceStatus: markManual && selectedSystemDefaults
                ? '使用系统默认音频设备'
                : markManual
                ? '手动选择设备'
                : _uiState.audioDeviceStatus,
          );
          if (markManual && selectedSystemDefaults) {
            _audio.preferredCaptureDeviceSignature = null;
            _audio.preferredPlaybackDeviceSignature = null;
          } else if (markManual) {
            _rememberManualAudioDevices(captureId, playbackId);
          }
          _rememberActiveAudioDevices(captureId, playbackId);
          _scheduleAudioBridgeReconnectAfterDeviceSwitch(
            '当前设备重新应用: capture=$captureId, playback=$playbackId',
          );
          return;
        }

        // 真正告诉 PJSIP 切换输入/输出设备。这里的 ID 可以是真实设备 ID，
        // 也可以是 PJSUA_SND_DEFAULT_CAPTURE_DEV/PJSUA_SND_DEFAULT_PLAYBACK_DEV。
        final status = _bindings.pjsua_set_snd_dev(captureId, playbackId);
        if (status != 0) {
          _addLog(
            '❌ 切换音频设备失败: capture=$captureId, playback=$playbackId, pj_status=$status',
          );
          return;
        }

        // 用户手动选择系统默认时，本质上还是让系统策略接管，所以 UI 模式回到自动。
        final selectedSystemDefaults =
            captureId == pjsua_snd_dev_id.PJSUA_SND_DEFAULT_CAPTURE_DEV.value &&
            playbackId == pjsua_snd_dev_id.PJSUA_SND_DEFAULT_PLAYBACK_DEV.value;
        final nextMode = markManual && !selectedSystemDefaults
            ? PjsipAudioDeviceMode.manual
            : (selectedSystemDefaults
                  ? PjsipAudioDeviceMode.automatic
                  : _uiState.audioDeviceMode);
        _uiState = _uiState.copyWith(
          selectedCaptureDeviceId: captureId,
          selectedPlaybackDeviceId: playbackId,
          audioDeviceMode: nextMode,
          audioDeviceStatus: markManual && selectedSystemDefaults
              ? '使用系统默认音频设备'
              : (markManual ? '手动选择设备' : reason),
        );
        if (markManual && selectedSystemDefaults) {
          _audio.preferredCaptureDeviceSignature = null;
          _audio.preferredPlaybackDeviceSignature = null;
        } else if (markManual) {
          _rememberManualAudioDevices(captureId, playbackId);
        }
        _rememberActiveAudioDevices(captureId, playbackId);
        _scheduleAudioBridgeReconnectAfterDeviceSwitch(
          'capture=$captureId, playback=$playbackId',
        );
        _addLog(
          '✅ 音频设备已切换: capture=$captureId, playback=$playbackId ($reason)',
        );
      });
    });
  }

  /// 设置本地麦克风静音。
  ///
  /// PJSIP conference bridge 里，本地声卡和远端通话是两个端口。
  /// 静音不是“关闭设备”，而是断开或恢复 bridge 中的音频连接。
  void setMicrophoneMuted(bool muted) {
    if (_uiState.isMicrophoneMuted == muted) return;
    _uiState = _uiState.copyWith(isMicrophoneMuted: muted);
    _applyAudioMuteState();
    _addLog(muted ? '🔇 麦克风已静音' : '🎙️ 麦克风已恢复');
  }

  /// 设置本地扬声器静音。
  ///
  /// 和麦克风静音一样，这里不会销毁播放设备，只是控制远端声音是否连接到本地声卡。
  void setSpeakerMuted(bool muted) {
    if (_uiState.isSpeakerMuted == muted) return;
    _uiState = _uiState.copyWith(isSpeakerMuted: muted);
    _applyAudioMuteState();
    _addLog(muted ? '🔈 扬声器已静音' : '🔊 扬声器已恢复');
  }

  /// 播放一段短测试音到当前 PJSIP 播放设备。
  ///
  /// 这里没有使用 Flutter 的系统提示音，因为系统提示音只走 macOS 当前默认输出，
  /// 不一定等于 PJSIP 当前选择的 playback device。我们用 PJSIP file player：
  ///
  /// 1. 生成一个短 WAV 文件。
  /// 2. `pjsua_player_create` 把 WAV 加入 conference bridge。
  /// 3. `pjsua_player_get_conf_port` 拿到 player 的 bridge 端口。
  /// 4. `pjsua_conf_connect(playerPort, 0)` 播放到本地声卡端口。
  /// 5. 播放一小段时间后断开并销毁 player。
  ///
  /// 这样用户点“测试扬声器”时，听到的就是 PJSIP 当前输出设备，而不是系统默认声卡。
  Future<void> testSpeakerOutput() async {
    if (!_uiState.isInitialized) {
      _addLog('⚠️ 请先初始化 PJSIP，再测试扬声器');
      return;
    }

    _stopSpeakerTestPlayer();
    _uiState = _uiState.copyWith(isSpeakerTesting: true, speakerLevel: 210);
    final wavFile = await _ensureSpeakerTestWavFile();
    using((Arena arena) {
      final filename = arena<pj_str_t>();
      final path = wavFile.path.toNativeUtf8(allocator: arena);
      _pjStr(filename.ref, path);

      final playerId = arena<pjsua_player_id>();
      // 注意：不要使用 PJMEDIA_FILE_NO_LOOP。短音频播放完成后，PJSIP 可能已经把
      // player 标记为不可销毁状态，Dart Timer 再调用 destroy 会触发原生 assert。
      // 这里让文件循环播放，然后由我们在固定时间主动断开并销毁。
      const loopPlayback = 0;
      final status = _bindings.pjsua_player_create(
        filename,
        loopPlayback,
        playerId,
      );
      if (status != 0) {
        _uiState = _uiState.copyWith(isSpeakerTesting: false, speakerLevel: 0);
        _addLog('❌ 扬声器测试音创建失败: pj_status=$status');
        return;
      }

      final playerPort = _bindings.pjsua_player_get_conf_port(playerId.value);
      if (playerPort < 0) {
        _bindings.pjsua_player_destroy(playerId.value);
        _uiState = _uiState.copyWith(isSpeakerTesting: false, speakerLevel: 0);
        _addLog('❌ 扬声器测试音端口获取失败');
        return;
      }

      final connectStatus = _bindings.pjsua_conf_connect(playerPort, 0);
      if (connectStatus != 0) {
        _bindings.pjsua_player_destroy(playerId.value);
        _uiState = _uiState.copyWith(isSpeakerTesting: false, speakerLevel: 0);
        _addLog('❌ 扬声器测试音连接失败: pj_status=$connectStatus');
        return;
      }

      _audio.speakerTestPlayerId = playerId.value;
      _audio.speakerTestPlayerPort = playerPort;
      _addLog('🔊 正在播放扬声器测试音');
      _audio.speakerTestTimer = Timer(
        const Duration(milliseconds: 750),
        _stopSpeakerTestPlayer,
      );
    });
  }

  /// 开启或关闭麦克风测试。
  ///
  /// 没有通话时，只读取 PJSIP 0 号声卡端口不一定会有变化，因为 conference bridge
  /// 里没有任何“接收端”消费麦克风数据，底层可能不会持续拉取输入帧。
  ///
  /// 所以测试时会创建一个临时 WAV recorder，并执行：
  ///
  /// `pjsua_conf_connect(0, recorderPort)`
  ///
  /// 这相当于把“本地麦克风”接到“临时录音器”。录音器只是为了让 PJSIP 真正采集
  /// 麦克风流，UI 读取 recorder 端口和声卡端口的电平后展示百分比。停止测试时会
  /// 断开连接并销毁 recorder。
  Future<void> setMicrophoneTesting(bool enabled) async {
    if (!_uiState.isInitialized) {
      _addLog('⚠️ 请先初始化 PJSIP，再测试麦克风');
      return;
    }

    if (!enabled) {
      _stopMicrophoneTestRecorder();
      _uiState = _uiState.copyWith(
        isMicrophoneTesting: false,
        microphoneLevel: 0,
      );
      _addLog('🎙️ 麦克风测试已停止');
      return;
    }

    await setAudioDevices(
      captureDeviceId: _uiState.selectedCaptureDeviceId,
      playbackDeviceId: _uiState.selectedPlaybackDeviceId,
      markManual: false,
      reason: '麦克风测试：打开当前音频设备',
      forceReapply: true,
    );

    _stopMicrophoneTestRecorder();
    final wavFile = await _prepareMicrophoneTestWavFile();
    using((Arena arena) {
      final filename = arena<pj_str_t>();
      final path = wavFile.path.toNativeUtf8(allocator: arena);
      _pjStr(filename.ref, path);

      final recorderId = arena<pjsua_recorder_id>();
      final status = _bindings.pjsua_recorder_create(
        filename,
        0,
        ffi.nullptr,
        0,
        0,
        recorderId,
      );
      if (status != 0) {
        _uiState = _uiState.copyWith(
          isMicrophoneTesting: false,
          microphoneLevel: 0,
        );
        _addLog('❌ 麦克风测试录音器创建失败: pj_status=$status');
        return;
      }

      final recorderPort = _bindings.pjsua_recorder_get_conf_port(
        recorderId.value,
      );
      if (recorderPort < 0) {
        _bindings.pjsua_recorder_destroy(recorderId.value);
        _uiState = _uiState.copyWith(
          isMicrophoneTesting: false,
          microphoneLevel: 0,
        );
        _addLog('❌ 麦克风测试录音端口获取失败');
        return;
      }

      final connectStatus = _bindings.pjsua_conf_connect(0, recorderPort);
      if (connectStatus != 0) {
        _bindings.pjsua_recorder_destroy(recorderId.value);
        _uiState = _uiState.copyWith(
          isMicrophoneTesting: false,
          microphoneLevel: 0,
        );
        _addLog('❌ 麦克风测试音频连接失败: pj_status=$connectStatus');
        return;
      }

      _audio.microphoneTestRecorderId = recorderId.value;
      _audio.microphoneTestRecorderPort = recorderPort;
      _uiState = _uiState.copyWith(
        isMicrophoneTesting: true,
        microphoneLevel: 0,
      );
      _startAudioLevelTimer();
      _addLog('🎙️ 麦克风测试已开始，请对着麦克风说话');
    });
  }

  /// 一键修复当前音频路径。
  ///
  /// 用户听不到声音时，不一定知道是设备列表过期、设备 ID 复用，还是 conference
  /// bridge 没连上。这个方法做一组低风险恢复动作：
  ///
  /// - 刷新设备列表。
  /// - 强制重新应用当前输入/输出设备。
  /// - 通话中重新连接音频桥。
  ///
  /// 它不会改变用户选择，除非当前设备已经不可用，刷新流程里的策略会负责回退。
  Future<void> repairAudioPath() async {
    if (!_uiState.isInitialized) {
      _addLog('⚠️ 请先初始化 PJSIP，再修复音频');
      return;
    }

    await _refreshAudioDevices(
      reason: '修复音频',
      logResult: true,
      allowAutomaticSwitch: true,
    );
    await setAudioDevices(
      captureDeviceId: _uiState.selectedCaptureDeviceId,
      playbackDeviceId: _uiState.selectedPlaybackDeviceId,
      markManual: false,
      reason: '修复音频：重新应用当前设备',
      forceReapply: true,
    );
    _scheduleAudioBridgeReconnectAfterDeviceSwitch('修复音频');
    _addLog('🛠️ 音频修复流程已执行');
  }

  /// 刷新音频设备列表，并根据需要执行自动切换。
  ///
  /// 这个函数会被三类场景调用：
  ///
  /// 1. 用户手动点击“刷新设备”。
  /// 2. 轮询发现设备变化后自动调用。
  /// 3. 切换自动模式时立即重新评估设备。
  ///
  /// `logResult` 控制是否打印详细设备日志；轮询时一般不打印，真正检测到变化后才打印。
  /// `allowAutomaticSwitch` 控制刷新后是否允许策略自动调用 `setAudioDevices`。
  Future<void> _refreshAudioDevices({
    required String reason,
    required bool logResult,
    required bool allowAutomaticSwitch,
  }) {
    if (!_uiState.isInitialized) {
      if (logResult) _addLog('⚠️ 请先初始化 PJSIP，再刷新音频设备');
      return Future.value();
    }

    return Future<void>(() {
      // 顺序很重要：先让底层音频驱动刷新，再枚举 PJSIP 看到的设备列表。
      _refreshAudioDriverListIfSafe(reason: reason, logResult: logResult);
      final snapshot = using(_readAudioDeviceSnapshot);
      if (snapshot == null) return;

      // 记录快照签名，避免下一次轮询把同一批设备误判为新变化。
      _audio.lastDeviceSnapshot = snapshot.signature;
      _uiState = _uiState.copyWith(
        captureDevices: snapshot.captureDevices,
        playbackDevices: snapshot.playbackDevices,
        selectedCaptureDeviceId: snapshot.currentCaptureId,
        selectedPlaybackDeviceId: snapshot.currentPlaybackId,
      );

      if (logResult) {
        _addLog(
          '🎧 音频设备已刷新: 可用麦克风=${snapshot.captureDevices.length}/原始${snapshot.rawCaptureDevices.length}, '
          '可用扬声器=${snapshot.playbackDevices.length}/原始${snapshot.rawPlaybackDevices.length}',
        );
        _logAudioDeviceDetails(snapshot);
      }

      // 自动策略和 ID 映射兜底互斥：如果策略已经安排切换，就不再额外强制 reapply，
      // 避免一次设备变化触发两次 set_snd_dev。
      final didScheduleSwitch = allowAutomaticSwitch
          ? _applyAudioDevicePolicy(reason: reason)
          : false;
      final didReapplyMapping = didScheduleSwitch
          ? false
          : _reapplyAudioDevicesIfIdMappingChanged(snapshot, reason);
      if (!didScheduleSwitch &&
          !didReapplyMapping &&
          _uiState.calls.values.any((call) => call.isConnected)) {
        // 有时设备列表变化但当前选择仍可用，例如蓝牙 profile 内部变化。通话中仍补一次
        // conference bridge 重连，让媒体路径跟上底层声卡变化。
        _scheduleAudioBridgeReconnectAfterDeviceSwitch('设备列表刷新兜底: $reason');
      }
    });
  }

  /// 从 PJSIP 读取当前音频设备快照。
  ///
  /// 返回值同时包含 raw 列表和过滤后的列表：raw 用来诊断，filtered 用来 UI/策略。
  _AudioDeviceSnapshot? _readAudioDeviceSnapshot(Arena arena) {
    const maxDevices = 64;
    final devices = arena<pjmedia_aud_dev_info>(maxDevices);
    final count = arena<ffi.UnsignedInt>();
    count.value = maxDevices;

    final status = _bindings.pjsua_enum_aud_devs(devices, count);
    if (status != 0) {
      _addLog('❌ 枚举音频设备失败: pj_status=$status');
      return null;
    }

    // PJSIP 默认设备 -1/-2 不一定出现在枚举列表中，所以这里手动补进去。
    // 大厂软电话一般也会提供“系统默认”选项，让 App 跟随系统声音设置变化。
    final rawCaptureDevices = <PjsipAudioDevice>[
      const PjsipAudioDevice(
        id: -1,
        name: '系统默认麦克风',
        driver: 'default',
        inputCount: 1,
        outputCount: 0,
        defaultSampleRate: 0,
      ),
    ];
    final rawPlaybackDevices = <PjsipAudioDevice>[
      const PjsipAudioDevice(
        id: -2,
        name: '系统默认扬声器',
        driver: 'default',
        inputCount: 0,
        outputCount: 1,
        defaultSampleRate: 0,
      ),
    ];

    for (var i = 0; i < count.value; i++) {
      final info = devices[i];
      final device = PjsipAudioDevice(
        id: info.id,
        name: _nativeCharArrayToString(info.name, 64),
        driver: _nativeCharArrayToString(info.driver, 32),
        inputCount: info.input_count,
        outputCount: info.output_count,
        defaultSampleRate: info.default_samples_per_sec,
      );
      if (device.canCapture) rawCaptureDevices.add(device);
      if (device.canPlayback) rawPlaybackDevices.add(device);
    }

    // UI 和自动策略只使用过滤后的通话设备；日志仍然使用 raw* 列表。
    final captureDevices = rawCaptureDevices
        .where(_isUsableCaptureDevice)
        .toList(growable: false);
    final playbackDevices = rawPlaybackDevices
        .where(_isUsablePlaybackDevice)
        .toList(growable: false);

    final current = _currentSoundDeviceIds(arena);
    return _AudioDeviceSnapshot(
      rawCaptureDevices: rawCaptureDevices,
      rawPlaybackDevices: rawPlaybackDevices,
      captureDevices: captureDevices,
      playbackDevices: playbackDevices,
      currentCaptureId: current.captureId,
      currentPlaybackId: current.playbackId,
    );
  }

  /// 输入设备过滤规则。
  ///
  /// PJSIP/CoreAudio 的 input_count 只能说明“这个底层端点可以被打开为输入”，
  /// 不能说明它适合给用户当麦克风。例如显示器、MacBook 扬声器、某些 Aggregate
  /// Device 也可能带 input channel。这里按产品语义收敛成软电话可选麦克风：
  ///
  /// - 保留“系统默认麦克风”，让用户可以跟随系统设置。
  /// - 排除虚拟/聚合设备：BlackHole、Teams Audio、VPAU Aggregate 等。
  /// - 排除明显是播放端的名称：扬声器、speaker、DisplayPort/HDMI/显示器。
  /// - 其他具备输入能力的真实设备保留，比如蓝牙耳机、内置麦克风、iPhone 麦克风。
  bool _isUsableCaptureDevice(PjsipAudioDevice device) {
    if (device.isSystemDefault) return true;
    if (device.looksLikeVirtualDevice) return false;
    if (device.looksLikePlaybackOnlyName) return false;
    return device.canCapture;
  }

  /// 输出设备过滤规则。
  ///
  /// 输出侧保留更宽一些：MacBook 扬声器、蓝牙耳机、显示器输出都可能是合理选择。
  /// 但虚拟/聚合设备默认不进入通话选择列表，避免把通话音频送进录音/转发工具。
  bool _isUsablePlaybackDevice(PjsipAudioDevice device) {
    if (device.isSystemDefault) return true;
    if (device.looksLikeVirtualDevice) return false;
    if (device.looksLikeCaptureOnlyName && !device.canPlayback) return false;
    return device.canPlayback;
  }

  /// 如果安全，则刷新 PJSIP 底层音频驱动设备列表。
  ///
  /// `pjmedia_aud_dev_refresh` 会让 PJMEDIA 重新扫描声卡设备。它对热插拔很有帮助，
  /// 但通话中频繁刷新底层设备也可能带来短暂扰动。所以这里用
  /// `allowInCallAudioDeviceSwitch` 做保护：默认通话中不刷新，用户开启实验开关后才刷新。
  void _refreshAudioDriverListIfSafe({
    required String reason,
    required bool logResult,
  }) {
    final refresh = _audio.pjmediaAudDevRefresh;
    if (refresh == null) {
      if (logResult) _addLog('🎧 当前 PJSIP 动态库未导出音频驱动刷新 API');
      return;
    }

    // 默认情况下，通话中不主动刷新底层驱动列表，降低对当前媒体设备的扰动。
    // 用户打开“通话中自动检测/切换”后才允许刷新并尝试自动切换。
    if (_uiState.calls.isNotEmpty && !_uiState.allowInCallAudioDeviceSwitch) {
      if (logResult) {
        _addLog('🎧 通话中跳过底层音频驱动刷新，仅枚举当前设备缓存');
      }
      return;
    }

    final status = refresh();
    if (status == 0) {
      if (logResult) _addLog('🎧 已刷新底层音频驱动设备列表 ($reason)');
    } else if (logResult) {
      _addLog('⚠️ 刷新底层音频驱动设备列表失败: pj_status=$status');
    }
  }

  /// 执行自动音频策略，并在需要时安排设备切换。
  ///
  /// 注意这里的返回值表示“是否已经安排了一次切换”，不是“切换是否已经完成”。
  /// 因为实际切换通过 `unawaited(setAudioDevices(...))` 异步执行。
  ///
  /// 为什么要返回 bool？
  /// 设备变化后还有一个 ID 映射兜底逻辑，如果自动策略已经要切换，就不再跑兜底，
  /// 避免同一次变化触发两次设备切换。
  bool _applyAudioDevicePolicy({required String reason}) {
    final hasAnyCall = _uiState.calls.isNotEmpty;
    final choice = PjsipAudioDevicePolicy.choose(
      captureDevices: _uiState.captureDevices,
      playbackDevices: _uiState.playbackDevices,
      currentCaptureId: _uiState.selectedCaptureDeviceId,
      currentPlaybackId: _uiState.selectedPlaybackDeviceId,
      mode: _uiState.audioDeviceMode,
      preferredCaptureSignature: _audio.preferredCaptureDeviceSignature,
      preferredPlaybackSignature: _audio.preferredPlaybackDeviceSignature,
      hasAnyCall: hasAnyCall,
      allowInCallAutomaticSwitch: _uiState.allowInCallAudioDeviceSwitch,
    );

    _uiState = _uiState.copyWith(audioDeviceStatus: choice.status);
    if (!choice.shouldSwitch) return false;

    // 这里不 await，是为了让刷新流程先结束，实际切换作为一个独立异步任务执行。
    // 这样 UI 不会被设备枚举和 set_snd_dev 串在一起阻塞。
    unawaited(
      setAudioDevices(
        captureDeviceId: choice.captureDeviceId,
        playbackDeviceId: choice.playbackDeviceId,
        markManual: false,
        reason: '$reason：${choice.status}',
      ),
    );
    return true;
  }

  /// 原始设备诊断日志。
  ///
  /// usable 表示是否进入 UI/自动选择；headset 和 pairedExternal 表示自动策略为何
  /// 可能优先选它。即使 usable=false 也会打印，方便和 macOS 系统设置对照。
  void _logAudioDeviceDetails(_AudioDeviceSnapshot snapshot) {
    _addLog(
      '🎧 当前 PJSIP 设备: capture=${snapshot.currentCaptureId}, '
      'playback=${snapshot.currentPlaybackId}',
    );
    for (final device in snapshot.rawCaptureDevices) {
      final paired = PjsipAudioDevicePolicy.looksLikePairedExternalForLog(
        device,
        snapshot.rawPlaybackDevices,
      );
      final usable = _isUsableCaptureDevice(device);
      _addLog(
        '🎙️ 输入设备: id=${device.id}, name=${device.name}, '
        'driver=${device.driver}, input=${device.inputCount}, '
        'output=${device.outputCount}, rate=${device.defaultSampleRate}, '
        'usable=$usable, headset=${device.looksLikeHeadset}, pairedExternal=$paired, '
        'signature=${device.signature}',
      );
    }
    for (final device in snapshot.rawPlaybackDevices) {
      final paired = PjsipAudioDevicePolicy.looksLikePairedExternalForLog(
        device,
        snapshot.rawCaptureDevices,
      );
      final usable = _isUsablePlaybackDevice(device);
      _addLog(
        '🔊 输出设备: id=${device.id}, name=${device.name}, '
        'driver=${device.driver}, input=${device.inputCount}, '
        'output=${device.outputCount}, rate=${device.defaultSampleRate}, '
        'usable=$usable, headset=${device.looksLikeHeadset}, pairedExternal=$paired, '
        'signature=${device.signature}',
      );
    }
  }

  /// 启动轻量设备热插拔轮询。
  ///
  /// 桌面端要监听有线耳机和蓝牙耳机插拔，最理想是接入系统原生事件。
  /// 当前开发阶段用轮询实现：每隔一段时间读一次设备快照，发现签名变化后再刷新。
  ///
  /// 如果 timer 已经存在，说明轮询已经启动，直接返回，避免重复开多个 timer。
  void _startAudioDeviceMonitoring() {
    if (_audio.devicePollTimer != null) return;
    _scheduleNextAudioDevicePoll();
  }

  /// 安排下一次设备轮询。
  ///
  /// 这里没有用 `Timer.periodic`，而是每次轮询结束后再安排下一次。
  /// 好处是：如果一次设备枚举稍慢，不会出现多个轮询任务重叠执行。
  void _scheduleNextAudioDevicePoll() {
    if (!_uiState.isInitialized || _isDisposed) return;
    final interval = _uiState.calls.isEmpty
        ? audioDeviceIdlePollInterval
        : audioDeviceInCallPollInterval;
    _audio.devicePollTimer = Timer(interval, _pollAudioDevicesOnce);
  }

  /// 执行一次设备轮询。
  ///
  /// 流程是：
  ///
  /// 1. 刷新底层驱动列表。
  /// 2. 枚举当前设备快照。
  /// 3. 和上一次快照签名比较。
  /// 4. 如果变化了，不马上处理，而是启动防抖 timer。
  /// 5. 最后安排下一次轮询。
  void _pollAudioDevicesOnce() {
    _audio.devicePollTimer = null;
    if (!_uiState.isInitialized || _isDisposed) return;

    _refreshAudioDriverListIfSafe(reason: '设备轮询', logResult: false);
    final snapshot = using(_readAudioDeviceSnapshot);
    if (snapshot == null) {
      _scheduleNextAudioDevicePoll();
      return;
    }

    // 首次轮询只建立基线，不触发“设备变化”。否则启动后会误认为设备发生变化。
    if (_audio.lastDeviceSnapshot == null) {
      _audio.lastDeviceSnapshot = snapshot.signature;
      _scheduleNextAudioDevicePoll();
      return;
    }
    if (_audio.lastDeviceSnapshot != snapshot.signature) {
      _audio.lastDeviceSnapshot = snapshot.signature;
      _audio.deviceChangeDebounceTimer?.cancel();
      // 连续变化只保留最后一次处理。蓝牙耳机连接时经常会先出现低采样率端点，
      // 再出现稳定的输入/输出端点。
      _audio.deviceChangeDebounceTimer = Timer(
        audioDeviceChangeDebounceInterval,
        () => _handleAudioDeviceChanged(),
      );
    }

    _scheduleNextAudioDevicePoll();
  }

  /// 防抖结束后真正处理设备变化。
  ///
  /// 这里会刷新设备列表、打印日志，并允许自动策略切换设备。
  /// 例如耳机拔掉后，它会重新枚举设备，然后策略通常会回退到系统默认 -1/-2。
  void _handleAudioDeviceChanged() {
    if (!_uiState.isInitialized || _isDisposed) return;
    unawaited(
      _refreshAudioDevices(
        reason: '设备变化',
        logResult: true,
        allowAutomaticSwitch: true,
      ),
    );
  }

  /// 停止设备热插拔轮询。
  ///
  /// 引擎关闭或 Notifier dispose 时必须调用，避免 timer 继续访问已经销毁的 PJSIP。
  void _stopAudioDeviceMonitoring() {
    _audio.devicePollTimer?.cancel();
    _audio.devicePollTimer = null;
    _audio.deviceChangeDebounceTimer?.cancel();
    _audio.deviceChangeDebounceTimer = null;
    _audio.lastDeviceSnapshot = null;
  }

  /// 检查 PJSIP 设备 ID 是否被系统重排或复用了，如有必要则强制重新应用。
  ///
  /// 初学时这里可能最绕：为什么 ID 一样还要重新应用？
  ///
  /// 因为 CoreAudio 热插拔后，PJSIP 看到的数字 ID 可能仍然是 0/1，但 0/1 指向的
  /// 设备已经变了。我们用设备 signature 判断“ID 背后的设备”是否还是原来的。
  ///
  /// 如果发现 ID 映射变了，就调用 `setAudioDevices(... forceReapply: true)`，
  /// 让 PJSIP 重新打开当前设备，避免页面显示对了但实际声卡路径没恢复。
  bool _reapplyAudioDevicesIfIdMappingChanged(
    _AudioDeviceSnapshot snapshot,
    String reason,
  ) {
    final captureId = snapshot.currentCaptureId;
    final playbackId = snapshot.currentPlaybackId;
    if (captureId == null || playbackId == null) return false;

    final captureSignature = _deviceSignatureById(
      snapshot.captureDevices,
      captureId,
    );
    final playbackSignature = _deviceSignatureById(
      snapshot.playbackDevices,
      playbackId,
    );
    if (captureSignature == null || playbackSignature == null) return false;

    // PJSIP/CoreAudio 热插拔后可能复用同一个数字 ID，但这个 ID 指向的设备已经变了。
    // 例如之前 0/1 是蓝牙，拔掉后 0/1 变成 MacBook。签名不同就说明需要强制重应用。
    final mappingChanged =
        (_audio.activeCaptureDeviceSignature != null &&
            _audio.activeCaptureDeviceSignature != captureSignature) ||
        (_audio.activePlaybackDeviceSignature != null &&
            _audio.activePlaybackDeviceSignature != playbackSignature);
    if (!mappingChanged) return false;

    _addLog(
      '🎧 音频设备 ID 映射变化，强制重新应用: '
      'capture=$captureId, playback=$playbackId',
    );
    unawaited(
      setAudioDevices(
        captureDeviceId: captureId,
        playbackDeviceId: playbackId,
        markManual: false,
        reason: '$reason：设备 ID 映射变化',
        forceReapply: true,
      ),
    );
    return true;
  }

  /// 设备切换后安排 conference bridge 重连。
  ///
  /// PJSIP 的声卡设备和通话媒体之间通过 conference bridge 连接。
  /// `pjsua_set_snd_dev` 切换声卡后，旧连接有时不会完全自动恢复，所以这里会：
  ///
  /// 1. 立即重连一次。
  /// 2. 再按 `audioBridgeReconnectRetryDelays` 延迟补偿几次。
  ///
  /// 这样能覆盖蓝牙耳机切换 profile 时那段“设备已出现但还不可用”的过渡期。
  void _scheduleAudioBridgeReconnectAfterDeviceSwitch(String detail) {
    _cancelPendingAudioBridgeReconnects();
    // 先立即恢复一次，让大多数切换快速生效；后面的 timer 是为了覆盖设备尚未 ready。
    _reconnectAudioBridgeAfterDeviceSwitch('立即重连: $detail');
    if (!_uiState.calls.values.any((call) => call.isConnected)) return;

    for (final delay in audioBridgeReconnectRetryDelays) {
      late final Timer timer;
      timer = Timer(delay, () {
        _audio.bridgeReconnectTimers.remove(timer);
        _reconnectAudioBridgeAfterDeviceSwitch(
          '延迟${delay.inMilliseconds}ms重连: $detail',
        );
      });
      _audio.bridgeReconnectTimers.add(timer);
    }
  }

  /// 取消尚未执行的音频桥重连 timer。
  ///
  /// 每次新设备切换前都会先取消旧重试，避免上一次切换遗留的 timer 又把 bridge
  /// 按旧原因重连一遍。
  void _cancelPendingAudioBridgeReconnects() {
    for (final timer in _audio.bridgeReconnectTimers) {
      timer.cancel();
    }
    _audio.bridgeReconnectTimers.clear();
  }

  /// 对当前已接通通话执行一次音频桥重连。
  ///
  /// 这个函数本身不直接 connect/disconnect，它收集当前连接中的 call，然后调用
  /// `_applyAudioMuteState`。真正的连接规则都集中在那里：静音、会议、activeCall
  /// 都会一起考虑。
  void _reconnectAudioBridgeAfterDeviceSwitch(String reason) {
    if (!_uiState.isInitialized) return;
    final connectedCallIds = _uiState.calls.values
        .where((call) => call.isConnected)
        .map((call) => call.callId)
        .toList();
    if (connectedCallIds.isEmpty) return;

    final slots = <String>[];
    for (final callId in connectedCallIds) {
      final slot = _getConferenceSlot(callId);
      slots.add('call=$callId slot=${slot ?? 'none'}');
    }
    // 真正的重连逻辑在 _applyAudioMuteState：先断开旧连接，再按当前静音/会议状态连接。
    _applyAudioMuteState();
    _addLog('🎧 设备切换后重连音频桥: $reason, ${slots.join(', ')}');
  }

  /// 记住用户手动选择的设备签名。
  ///
  /// 手动模式下，用户期待“下次还是用我选的那个设备”。设备 ID 不稳定，所以这里
  /// 存 signature，后续刷新设备时可以按 signature 找回。
  void _rememberManualAudioDevices(int captureId, int playbackId) {
    _audio.preferredCaptureDeviceSignature = _deviceSignatureById(
      _uiState.captureDevices,
      captureId,
    );
    _audio.preferredPlaybackDeviceSignature = _deviceSignatureById(
      _uiState.playbackDevices,
      playbackId,
    );
  }

  /// 记住当前实际应用到 PJSIP 的设备签名。
  ///
  /// 这和手动偏好不同：手动偏好是“用户想要什么”，active 签名是“PJSIP 当前实际
  /// 使用的 ID 背后是什么设备”。后者用于发现 ID 复用。
  void _rememberActiveAudioDevices(int captureId, int playbackId) {
    _audio.activeCaptureDeviceSignature = _deviceSignatureById(
      _uiState.captureDevices,
      captureId,
    );
    _audio.activePlaybackDeviceSignature = _deviceSignatureById(
      _uiState.playbackDevices,
      playbackId,
    );
  }

  /// 根据设备 ID 查找设备签名。
  ///
  /// 找不到时返回 null，说明当前 ID 不在过滤后的可用设备列表中。
  String? _deviceSignatureById(List<PjsipAudioDevice> devices, int? id) {
    if (id == null) return null;
    for (final device in devices) {
      if (device.id == id) return device.signature;
    }
    return null;
  }

  /// 读取 PJSIP 当前正在使用的输入/输出设备 ID。
  ///
  /// 对应 PJSIP API：`pjsua_get_snd_dev`。
  /// 返回 null 表示读取失败，调用方会再用 UI 状态或系统默认兜底。
  ({int? captureId, int? playbackId}) _currentSoundDeviceIds(Arena arena) {
    final capture = arena<ffi.Int>();
    final playback = arena<ffi.Int>();
    final status = _bindings.pjsua_get_snd_dev(capture, playback);
    if (status != 0) return (captureId: null, playbackId: null);
    return (captureId: capture.value, playbackId: playback.value);
  }

  /// 把 PJSIP C 结构里的固定长度 char 数组转成 Dart 字符串。
  ///
  /// PJSIP 的设备名/驱动名是 C char 数组，以 0 结尾。Dart 不能直接当字符串用，
  /// 所以这里逐字节读取，遇到 0 停止，再按 UTF-8 解码。
  String _nativeCharArrayToString(ffi.Array<ffi.Char> chars, int maxLength) {
    final bytes = <int>[];
    for (var i = 0; i < maxLength; i++) {
      final value = chars[i];
      if (value == 0) break;
      bytes.add(value & 0xff);
    }
    return utf8.decode(bytes, allowMalformed: true).trim();
  }

  /// 按当前 UI 状态重新应用 PJSIP conference bridge 连接。
  ///
  /// PJSIP 里通话媒体不是直接自动送到扬声器的，而是进入 conference bridge：
  ///
  /// - port 0：本地声卡端口。
  /// - call slot：某一路通话的媒体端口。
  ///
  /// 要听见对方，需要连接 `call slot -> 0`。
  /// 要让对方听见你，需要连接 `0 -> call slot`。
  ///
  /// 所以麦克风静音就是不连接 `0 -> slot`；扬声器静音就是不连接 `slot -> 0`。
  void _applyAudioMuteState() {
    for (final entry in _uiState.calls.entries) {
      final callId = entry.key;
      final call = entry.value;
      if (!call.isConnected || call.isOnHold || call.isRemoteOnHold) continue;
      final slot = _getConferenceSlot(callId);
      if (slot == null) continue;

      // PJSIP conference bridge 中，0 通常是本地声卡端口，call slot 是远端媒体端口。
      // 重新应用时先断开两边，再按当前状态重新连接，避免重复连接或旧路径残留。
      _bindings.pjsua_conf_disconnect(0, slot);
      _bindings.pjsua_conf_disconnect(slot, 0);

      final shouldUseLocalAudio =
          (_uiState.isConferenceActive &&
              _uiState.conferenceCallIds.contains(callId)) ||
          _uiState.activeCallId == callId;
      if (!shouldUseLocalAudio) continue;

      if (!_uiState.isMicrophoneMuted) {
        _bindings.pjsua_conf_connect(0, slot);
      }
      if (!_uiState.isSpeakerMuted) {
        _bindings.pjsua_conf_connect(slot, 0);
      }
    }
  }

  /// 启动通话电平监测。
  ///
  /// 这个 timer 周期性调用 `pjsua_conf_get_signal_level(0, tx, rx)`。
  /// 它不是音频设备切换的一部分，只是为了 UI 上显示麦克风/扬声器活跃度。
  void _startAudioLevelTimer() {
    if (_audio.levelTimer != null) return;
    _audio.levelTimer = Timer.periodic(audioLevelPollInterval, (_) {
      if (!_uiState.isInitialized) return;
      final hasConnectedCall = _uiState.calls.values.any(
        (call) => call.isConnected,
      );
      final shouldReadMicrophoneLevel =
          hasConnectedCall || _uiState.isMicrophoneTesting;
      final shouldReadSpeakerLevel =
          hasConnectedCall || _uiState.isSpeakerTesting;
      if (!shouldReadMicrophoneLevel && !shouldReadSpeakerLevel) {
        if (_uiState.microphoneLevel != 0 || _uiState.speakerLevel != 0) {
          _uiState = _uiState.copyWith(microphoneLevel: 0, speakerLevel: 0);
        }
        return;
      }

      using((Arena arena) {
        // port 0 是本地声卡端口。tx/rx 可以粗略反映麦克风输入和扬声器输出活跃度。
        final tx = arena<ffi.UnsignedInt>();
        final rx = arena<ffi.UnsignedInt>();
        final status = _bindings.pjsua_conf_get_signal_level(0, tx, rx);
        if (status != 0) return;
        var microphoneLevel = tx.value;
        final recorderPort = _audio.microphoneTestRecorderPort;
        if (_uiState.isMicrophoneTesting &&
            recorderPort != null &&
            recorderPort >= 0) {
          final recorderTx = arena<ffi.UnsignedInt>();
          final recorderRx = arena<ffi.UnsignedInt>();
          final recorderStatus = _bindings.pjsua_conf_get_signal_level(
            recorderPort,
            recorderTx,
            recorderRx,
          );
          if (recorderStatus == 0) {
            microphoneLevel = math.max(
              microphoneLevel,
              math.max(recorderTx.value, recorderRx.value),
            );
          }
        }
        final fallbackSpeakerLevel = _uiState.isSpeakerTesting ? 210 : 0;
        _uiState = _uiState.copyWith(
          microphoneLevel:
              shouldReadMicrophoneLevel && !_uiState.isMicrophoneMuted
              ? microphoneLevel
              : 0,
          speakerLevel: shouldReadSpeakerLevel && !_uiState.isSpeakerMuted
              ? math.max(rx.value, fallbackSpeakerLevel)
              : 0,
        );
      });
    });
  }

  /// 停止通话电平监测。
  ///
  /// 没有通话或服务销毁时停止，避免无意义刷新 UI。
  void _stopAudioLevelTimer() {
    _audio.levelTimer?.cancel();
    _audio.levelTimer = null;
  }

  void _stopMicrophoneTestRecorder() {
    final recorderId = _audio.microphoneTestRecorderId;
    final recorderPort = _audio.microphoneTestRecorderPort;
    _audio.microphoneTestRecorderId = null;
    _audio.microphoneTestRecorderPort = null;

    if (!_uiState.isInitialized || recorderId == null) return;
    if (recorderPort != null && recorderPort >= 0) {
      _bindings.pjsua_conf_disconnect(0, recorderPort);
    }
    _bindings.pjsua_recorder_destroy(recorderId);
  }

  void _stopSpeakerTestPlayer() {
    _audio.speakerTestTimer?.cancel();
    _audio.speakerTestTimer = null;

    final playerId = _audio.speakerTestPlayerId;
    final playerPort = _audio.speakerTestPlayerPort;
    _audio.speakerTestPlayerId = null;
    _audio.speakerTestPlayerPort = null;

    if (!_uiState.isInitialized || playerId == null) return;
    if (playerPort != null && playerPort >= 0) {
      _bindings.pjsua_conf_disconnect(playerPort, 0);
    }
    _bindings.pjsua_player_destroy(playerId);
    _uiState = _uiState.copyWith(isSpeakerTesting: false, speakerLevel: 0);
  }

  Future<File> _prepareMicrophoneTestWavFile() async {
    final file = File('${Directory.systemTemp.path}/pjsip_microphone_test.wav');
    if (await file.exists()) {
      await file.delete();
    }
    return file;
  }

  Future<File> _ensureSpeakerTestWavFile() async {
    final file = File('${Directory.systemTemp.path}/pjsip_speaker_test.wav');
    if (await file.exists()) return file;
    await file.writeAsBytes(_speakerTestWavBytes(), flush: true);
    return file;
  }

  List<int> _speakerTestWavBytes() {
    const sampleRate = 16000;
    const durationMs = 650;
    const frequency = 880.0;
    const channels = 1;
    const bitsPerSample = 16;
    final sampleCount = sampleRate * durationMs ~/ 1000;
    final dataSize = sampleCount * channels * bitsPerSample ~/ 8;
    final bytes = <int>[];

    void addAscii(String value) => bytes.addAll(value.codeUnits);

    void addUint16(int value) {
      bytes.add(value & 0xff);
      bytes.add((value >> 8) & 0xff);
    }

    void addUint32(int value) {
      bytes.add(value & 0xff);
      bytes.add((value >> 8) & 0xff);
      bytes.add((value >> 16) & 0xff);
      bytes.add((value >> 24) & 0xff);
    }

    addAscii('RIFF');
    addUint32(36 + dataSize);
    addAscii('WAVE');
    addAscii('fmt ');
    addUint32(16);
    addUint16(1);
    addUint16(channels);
    addUint32(sampleRate);
    addUint32(sampleRate * channels * bitsPerSample ~/ 8);
    addUint16(channels * bitsPerSample ~/ 8);
    addUint16(bitsPerSample);
    addAscii('data');
    addUint32(dataSize);

    for (var i = 0; i < sampleCount; i++) {
      final fadeIn = (i / (sampleRate * 0.04)).clamp(0.0, 1.0);
      final fadeOut = ((sampleCount - i) / (sampleRate * 0.08)).clamp(0.0, 1.0);
      final envelope = math.min(fadeIn, fadeOut);
      final sample =
          math.sin(2 * math.pi * frequency * i / sampleRate) * 0.35 * envelope;
      final pcm = (sample * 32767).round();
      addUint16(pcm & 0xffff);
    }
    return bytes;
  }
}

class _AudioDeviceSnapshot {
  /// PJSIP/CoreAudio 原始输入端点，包含虚拟设备、聚合设备等诊断信息。
  final List<PjsipAudioDevice> rawCaptureDevices;

  /// PJSIP/CoreAudio 原始输出端点，包含虚拟设备、显示器音频等诊断信息。
  final List<PjsipAudioDevice> rawPlaybackDevices;

  /// 过滤后的通话输入设备，用于 UI 下拉框和自动选择策略。
  final List<PjsipAudioDevice> captureDevices;

  /// 过滤后的通话输出设备，用于 UI 下拉框和自动选择策略。
  final List<PjsipAudioDevice> playbackDevices;

  /// 当前 PJSIP 正在使用的输入设备 ID。
  final int? currentCaptureId;

  /// 当前 PJSIP 正在使用的输出设备 ID。
  final int? currentPlaybackId;

  const _AudioDeviceSnapshot({
    required this.rawCaptureDevices,
    required this.rawPlaybackDevices,
    required this.captureDevices,
    required this.playbackDevices,
    required this.currentCaptureId,
    required this.currentPlaybackId,
  });

  String get signature {
    // 快照签名只关心“可用通话设备”，并排除系统默认伪设备。系统默认一直存在，
    // 如果把它放进签名，反而无法判断真实设备是否变化。
    final capture =
        captureDevices
            .where((device) => !device.isSystemDefault)
            .map((device) => 'c:${device.signature}:${device.id}')
            .toList()
          ..sort();
    final playback =
        playbackDevices
            .where((device) => !device.isSystemDefault)
            .map((device) => 'p:${device.signature}:${device.id}')
            .toList()
          ..sort();
    return [...capture, ...playback].join('|');
  }
}

/// 自动选择策略的结果。
///
/// 策略层只负责“应该选谁、要不要切、状态文案是什么”，真正调用 PJSIP 切换设备
/// 留给 `setAudioDevices`，这样决策和副作用分开。
class PjsipAudioDeviceChoice {
  /// 策略建议使用的输入设备 ID。
  final int captureDeviceId;

  /// 策略建议使用的输出设备 ID。
  final int playbackDeviceId;

  /// 当前设备和策略结果不一致时才需要切换。
  final bool shouldSwitch;

  /// 给 UI/日志展示的策略说明。
  final String status;

  const PjsipAudioDeviceChoice({
    required this.captureDeviceId,
    required this.playbackDeviceId,
    required this.shouldSwitch,
    required this.status,
  });
}

/// 音频设备自动选择策略。
///
/// 这部分尽量保持纯函数：输入设备列表、当前选择、用户偏好和通话状态，输出一个
/// `PjsipAudioDeviceChoice`。这样后续可以独立写单元测试，也更容易调整产品策略。
class PjsipAudioDevicePolicy {
  const PjsipAudioDevicePolicy._();

  /// 日志用：暴露 pairedExternal 判断，便于解释“gaoyuan 这种名字如何被识别”。
  static bool looksLikePairedExternalForLog(
    PjsipAudioDevice device,
    List<PjsipAudioDevice> peerDevices,
  ) => _looksLikePairedExternalDevice(device, peerDevices);

  /// 根据当前设备列表和产品策略，决定下一步应该使用哪一组输入/输出设备。
  ///
  /// 参数可以这样理解：
  ///
  /// - `captureDevices`：当前可用于通话的麦克风列表。
  /// - `playbackDevices`：当前可用于通话的扬声器列表。
  /// - `currentCaptureId/currentPlaybackId`：PJSIP 当前正在用的设备。
  /// - `mode`：自动还是手动。
  /// - `preferred*Signature`：手动模式下用户之前选过的设备签名。
  /// - `hasAnyCall`：是否正在通话。
  /// - `allowInCallAutomaticSwitch`：通话中是否允许自动抢切新设备。
  ///
  /// 返回值不会直接改 PJSIP，只告诉调用方“建议切到哪、是否需要切、怎么描述”。
  static PjsipAudioDeviceChoice choose({
    required List<PjsipAudioDevice> captureDevices,
    required List<PjsipAudioDevice> playbackDevices,
    required int? currentCaptureId,
    required int? currentPlaybackId,
    required PjsipAudioDeviceMode mode,
    required String? preferredCaptureSignature,
    required String? preferredPlaybackSignature,
    required bool hasAnyCall,
    required bool allowInCallAutomaticSwitch,
  }) {
    // 先分别为输入/输出计算自动模式下的最佳兜底设备。
    // 自动选择不是简单选第一个，而是：明确耳机 > 同名外接设备 > 系统默认 > 列表首项。
    final fallbackCapture = _bestAutomaticDevice(
      primaryDevices: captureDevices,
      peerDevices: playbackDevices,
    );
    final fallbackPlayback = _bestAutomaticDevice(
      primaryDevices: playbackDevices,
      peerDevices: captureDevices,
    );
    final captureAvailable = _isAvailable(captureDevices, currentCaptureId);
    final playbackAvailable = _isAvailable(playbackDevices, currentPlaybackId);

    if (mode == PjsipAudioDeviceMode.manual) {
      // 手动模式优先按签名找回用户选过的设备。设备 ID 可能变化，但签名更稳定。
      final preferredCapture = _findBySignature(
        captureDevices,
        preferredCaptureSignature,
      );
      final preferredPlayback = _findBySignature(
        playbackDevices,
        preferredPlaybackSignature,
      );
      final capture =
          preferredCapture ?? (captureAvailable ? null : fallbackCapture);
      final playback =
          preferredPlayback ?? (playbackAvailable ? null : fallbackPlayback);
      // 手动设备还在，就继续用当前 ID；手动设备不在了，才回退到自动最佳设备。
      final nextCaptureId =
          capture?.id ?? currentCaptureId ?? fallbackCapture.id;
      final nextPlaybackId =
          playback?.id ?? currentPlaybackId ?? fallbackPlayback.id;
      final shouldSwitch =
          nextCaptureId != currentCaptureId ||
          nextPlaybackId != currentPlaybackId;

      return PjsipAudioDeviceChoice(
        captureDeviceId: nextCaptureId,
        playbackDeviceId: nextPlaybackId,
        shouldSwitch:
            shouldSwitch &&
            (!hasAnyCall || !captureAvailable || !playbackAvailable),
        status: preferredCapture == null || preferredPlayback == null
            ? '手动设备不可用，已准备回退到可用设备'
            : '手动选择设备',
      );
    }

    // 通话中默认不因为新耳机插入而抢切。大厂软电话通常会避免通话中突然切走
    // 声音；只有当前设备不可用时才自动回退。实验开关打开后允许自动切新设备。
    if (hasAnyCall &&
        !allowInCallAutomaticSwitch &&
        captureAvailable &&
        playbackAvailable) {
      return PjsipAudioDeviceChoice(
        captureDeviceId: currentCaptureId ?? fallbackCapture.id,
        playbackDeviceId: currentPlaybackId ?? fallbackPlayback.id,
        shouldSwitch: false,
        status: '通话中保持当前设备；设备丢失时自动回退',
      );
    }

    final keepCurrentInCall =
        hasAnyCall &&
        !allowInCallAutomaticSwitch &&
        captureAvailable &&
        playbackAvailable;
    final nextCaptureId = keepCurrentInCall
        ? currentCaptureId!
        : fallbackCapture.id;
    final nextPlaybackId = keepCurrentInCall
        ? currentPlaybackId!
        : fallbackPlayback.id;
    final shouldSwitch =
        nextCaptureId != currentCaptureId ||
        nextPlaybackId != currentPlaybackId;
    // status 只是 UI/日志文案，不参与选择逻辑。这里根据最终 fallback 的类型给用户
    // 一个容易理解的解释。
    final usingExternal =
        fallbackCapture.looksLikeHeadset ||
        fallbackPlayback.looksLikeHeadset ||
        _looksLikePairedExternalDevice(fallbackCapture, playbackDevices) ||
        _looksLikePairedExternalDevice(fallbackPlayback, captureDevices);
    final usingBuiltIn =
        fallbackCapture.looksLikeBuiltInDevice ||
        fallbackPlayback.looksLikeBuiltInDevice;

    return PjsipAudioDeviceChoice(
      captureDeviceId: nextCaptureId,
      playbackDeviceId: nextPlaybackId,
      shouldSwitch: shouldSwitch,
      status: usingExternal
          ? '自动选择设备：已优先使用耳机/蓝牙设备'
          : usingBuiltIn
          ? '自动选择设备：已切到内置麦克风/扬声器'
          : '自动选择设备：使用系统默认设备',
    );
  }

  /// 判断某个设备 ID 当前是否仍在可用设备列表里。
  ///
  /// 耳机拔掉后，之前的 ID 会从列表中消失；这时策略必须回退到其他设备。
  static bool _isAvailable(List<PjsipAudioDevice> devices, int? id) {
    if (id == null) return false;
    return devices.any((device) => device.id == id);
  }

  static PjsipAudioDevice _bestAutomaticDevice({
    required List<PjsipAudioDevice> primaryDevices,
    required List<PjsipAudioDevice> peerDevices,
  }) {
    // primaryDevices 是当前要选择的一侧：选择输入时它是麦克风列表，选择输出时
    // 它是扬声器列表。peerDevices 是另一侧，用来判断“同名输入+输出”。
    //
    // 这个函数会被调用两次：一次选麦克风，一次选扬声器。

    // 优先选择名称明确带耳机/蓝牙/USB 语义的设备。
    for (final device in primaryDevices) {
      if (device.looksLikeHeadset) return device;
    }
    // 其次选择“同名输入 + 输出”的外接设备。很多蓝牙耳机在 CoreAudio 里只显示
    // 用户命名（例如 gaoyuan），不带 bluetooth/headset 关键词。
    for (final device in primaryDevices) {
      if (_looksLikePairedExternalDevice(device, peerDevices)) return device;
    }
    // 最后回到系统默认，让 macOS 自己决定路由。通话中蓝牙断开后，实测
    // pjsua_set_snd_dev(-1/-2) 比显式切 MacBook 具体 ID 更接近用户手动恢复路径。
    for (final device in primaryDevices) {
      if (device.isSystemDefault) return device;
    }
    return primaryDevices.first;
  }

  static bool _looksLikePairedExternalDevice(
    PjsipAudioDevice device,
    List<PjsipAudioDevice> peerDevices,
  ) {
    // paired external 的直觉是：如果一个名字同时出现在输入和输出列表里，它很可能
    // 是同一套外接设备，例如蓝牙耳机、USB 会议设备。
    //
    // 但这个规则有误判风险，所以先排除系统默认、虚拟设备、内置设备、显示器音频。
    // 排除后才进行同名匹配。

    // 同名配对不是充分条件：BlackHole、Teams Audio、显示器音频、内置设备也可能
    // 同时有输入/输出端点，所以必须先排除这些不适合自动优先的类型。
    if (device.isSystemDefault ||
        device.looksLikeVirtualDevice ||
        device.looksLikeBuiltInDevice ||
        device.looksLikeDisplayAudioDevice) {
      return false;
    }
    final name = _normalizedName(device.name);
    if (name.isEmpty) return false;
    return peerDevices.any((peer) {
      if (peer.isSystemDefault ||
          peer.looksLikeVirtualDevice ||
          peer.looksLikeBuiltInDevice ||
          peer.looksLikeDisplayAudioDevice) {
        return false;
      }
      // 例如蓝牙耳机名叫 gaoyuan：输入列表里有 gaoyuan，输出列表里也有 gaoyuan，
      // 且它不是内置/虚拟/显示器设备，就会被认为是“成对外接设备”。
      return _normalizedName(peer.name) == name;
    });
  }

  /// 名称比较前先小写、压缩空白，减少大小写和多余空格导致的误判。
  static String _normalizedName(String name) {
    return name.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// 按签名找设备。
  ///
  /// 手动选择时我们保存 signature，而不是保存 ID。刷新后用 signature 找回同一设备。
  /// 如果找不到，说明设备已经不可用，需要走回退策略。
  static PjsipAudioDevice? _findBySignature(
    List<PjsipAudioDevice> devices,
    String? signature,
  ) {
    if (signature == null) return null;
    for (final device in devices) {
      if (device.signature == signature) return device;
    }
    return null;
  }
}
