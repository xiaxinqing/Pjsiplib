part of '../pjsip_service.dart';

const String _seatEnvironmentStorageKey = 'veserve_seat_environment_v1';
const String _audioPreferencesStorageKey = 'veserve_audio_preferences_v1';

class _PersistedAudioPreferences {
  const _PersistedAudioPreferences({
    required this.allowInCallAudioDeviceSwitch,
    required this.incomingRingtoneEnabled,
    required this.outgoingRingbackEnabled,
    required this.callEndedSoundEnabled,
    required this.dialpadKeySoundEnabled,
    required this.microphoneVolume,
    required this.speakerVolume,
  });

  final bool allowInCallAudioDeviceSwitch;
  final bool incomingRingtoneEnabled;
  final bool outgoingRingbackEnabled;
  final bool callEndedSoundEnabled;
  final bool dialpadKeySoundEnabled;
  final int microphoneVolume;
  final int speakerVolume;

  Map<String, Object?> toJson() {
    return {
      'version': 1,
      'allowInCallAudioDeviceSwitch': allowInCallAudioDeviceSwitch,
      'incomingRingtoneEnabled': incomingRingtoneEnabled,
      'outgoingRingbackEnabled': outgoingRingbackEnabled,
      'callEndedSoundEnabled': callEndedSoundEnabled,
      'dialpadKeySoundEnabled': dialpadKeySoundEnabled,
      'microphoneVolume': microphoneVolume,
      'speakerVolume': speakerVolume,
    };
  }

  static _PersistedAudioPreferences fromJson(Map<String, Object?> json) {
    int volumeFromJson(String key) {
      final raw = json[key];
      if (raw is int) return raw.clamp(0, 100).toInt();
      if (raw is num) return raw.round().clamp(0, 100).toInt();
      return 100;
    }

    return _PersistedAudioPreferences(
      allowInCallAudioDeviceSwitch:
          json['allowInCallAudioDeviceSwitch'] as bool? ?? true,
      incomingRingtoneEnabled: json['incomingRingtoneEnabled'] as bool? ?? true,
      outgoingRingbackEnabled: json['outgoingRingbackEnabled'] as bool? ?? true,
      callEndedSoundEnabled: json['callEndedSoundEnabled'] as bool? ?? true,
      dialpadKeySoundEnabled: json['dialpadKeySoundEnabled'] as bool? ?? true,
      microphoneVolume: volumeFromJson('microphoneVolume'),
      speakerVolume: volumeFromJson('speakerVolume'),
    );
  }
}

class _PersistedSeatEnvironment {
  const _PersistedSeatEnvironment({
    required this.lines,
    required this.defaultLineKey,
  });

  final List<_PersistedSipLine> lines;
  final String? defaultLineKey;

  Map<String, Object?> toJson() {
    return {
      'version': 1,
      'defaultLineKey': defaultLineKey,
      'lines': lines.map((line) => line.toJson()).toList(),
    };
  }

  static _PersistedSeatEnvironment fromJson(Map<String, Object?> json) {
    final rawLines = json['lines'];
    return _PersistedSeatEnvironment(
      defaultLineKey: json['defaultLineKey'] as String?,
      lines: rawLines is List
          ? rawLines
                .whereType<Map>()
                .map(
                  (line) => _PersistedSipLine.fromJson(
                    Map<String, Object?>.from(line),
                  ),
                )
                .where((line) => line.isValid)
                .toList()
          : const [],
    );
  }
}

class _PersistedSipLine {
  const _PersistedSipLine({
    required this.lineName,
    required this.username,
    required this.authUsername,
    required this.sipDisplayName,
    required this.outboundProxy,
    required this.password,
    required this.host,
    required this.transport,
    required this.mediaSecurity,
    required this.iceConfig,
    required this.turnConfig,
    required this.ipv6Enabled,
    required this.registrationEnabled,
  });

  final String lineName;
  final String username;
  final String authUsername;
  final String sipDisplayName;
  final String outboundProxy;
  final String password;
  final String host;
  final SipTransport transport;
  final MediaSecurityConfig mediaSecurity;
  final IceConfig iceConfig;
  final TurnConfig turnConfig;
  final bool ipv6Enabled;
  final bool registrationEnabled;

  bool get isValid => username.isNotEmpty && host.isNotEmpty;

  Map<String, Object?> toJson() {
    return {
      // lineName 是本地备注名，只用于 UI 展示；不会参与 SIP 注册。
      'lineName': lineName,
      'username': username,
      // authUsername 只用于 SIP Digest 鉴权；为空时注册逻辑会回退到 username。
      'authUsername': authUsername,
      // sipDisplayName 会写入 SIP From 显示名；和本地 lineName 独立保存。
      'sipDisplayName': sipDisplayName,
      // outboundProxy 是账号级 Route 代理，注册/呼叫请求都会先经过它。
      'outboundProxy': outboundProxy,
      'password': password,
      'host': host,
      'transport': transport.name,
      // 媒体加密是账号级配置：信令传输和 RTP/SRTP 是否加密是两件事。
      'mediaSecurity': {'mode': mediaSecurity.mode.storageKey},
      // STUN 可独立保存；ICE 开关只控制是否生成 ICE 候选。
      'ice': {'enabled': iceConfig.enabled, 'stunServer': iceConfig.stunServer},
      'turn': {
        'enabled': turnConfig.enabled,
        'server': turnConfig.server,
        'username': turnConfig.username,
        'password': turnConfig.password,
        'transport': turnConfig.transport.storageKey,
      },
      // IPv6 是账号级网络策略；默认关闭用于减少 SDP 候选，降低 UDP INVITE 过大风险。
      'ipv6Enabled': ipv6Enabled,
      'registrationEnabled': registrationEnabled,
    };
  }

  static _PersistedSipLine fromJson(Map<String, Object?> json) {
    final transportName = json['transport'] as String?;
    final transport = SipTransport.values.firstWhere(
      (transport) => transport.name == transportName,
      orElse: () => SipTransport.udp,
    );
    final rawMediaSecurity = json['mediaSecurity'];
    final mediaSecurityJson = rawMediaSecurity is Map
        ? Map<String, Object?>.from(rawMediaSecurity)
        : const <String, Object?>{};
    final rawIce = json['ice'];
    final iceJson = rawIce is Map
        ? Map<String, Object?>.from(rawIce)
        : const <String, Object?>{};
    final rawTurn = json['turn'];
    final turnJson = rawTurn is Map
        ? Map<String, Object?>.from(rawTurn)
        : const <String, Object?>{};
    final turnTransportName = turnJson['transport'] as String?;
    return _PersistedSipLine(
      lineName: (json['lineName'] as String?)?.trim() ?? '',
      username: (json['username'] as String?)?.trim() ?? '',
      authUsername: (json['authUsername'] as String?)?.trim() ?? '',
      sipDisplayName: (json['sipDisplayName'] as String?)?.trim() ?? '',
      outboundProxy: (json['outboundProxy'] as String?)?.trim() ?? '',
      password: json['password'] as String? ?? '',
      host: (json['host'] as String?)?.trim() ?? '',
      transport: transport,
      mediaSecurity: MediaSecurityConfig(
        mode: _mediaEncryptionFromStorage(
          mediaSecurityJson['mode'] as String?,
          transport,
        ),
      ),
      iceConfig: IceConfig(
        enabled: iceJson['enabled'] as bool? ?? false,
        stunServer: (iceJson['stunServer'] as String?)?.trim() ?? '',
      ),
      turnConfig: TurnConfig(
        enabled: turnJson['enabled'] as bool? ?? false,
        server: (turnJson['server'] as String?)?.trim() ?? '',
        username: turnJson['username'] as String? ?? '',
        password: turnJson['password'] as String? ?? '',
        transport: TurnTransport.values.firstWhere(
          (transport) => transport.storageKey == turnTransportName,
          orElse: () => TurnTransport.udp,
        ),
      ),
      ipv6Enabled: json['ipv6Enabled'] as bool? ?? false,
      registrationEnabled: json['registrationEnabled'] as bool? ?? true,
    );
  }

  static MediaEncryptionMode _mediaEncryptionFromStorage(
    String? storageKey,
    SipTransport transport,
  ) {
    if (storageKey == null || storageKey.isEmpty) {
      // 兼容旧版本保存的数据：以前 TLS 线路注册时默认启用基础 DTLS-SRTP。
      return transport == SipTransport.tls
          ? MediaEncryptionMode.dtlsSrtp
          : MediaEncryptionMode.none;
    }
    return MediaEncryptionMode.values.firstWhere(
      (mode) => mode.storageKey == storageKey,
      orElse: () => MediaEncryptionMode.none,
    );
  }
}

extension PjsipPersistenceOperations on PjsipService {
  Future<void> _loadAudioPreferences() async {
    try {
      final stored = await _secureStorage.read(
        key: _audioPreferencesStorageKey,
      );
      if (_isDisposed || stored == null || stored.isEmpty) return;
      final decoded = jsonDecode(stored);
      if (decoded is! Map) return;
      final preferences = _PersistedAudioPreferences.fromJson(
        Map<String, Object?>.from(decoded),
      );
      _uiState = _uiState.copyWith(
        allowInCallAudioDeviceSwitch: preferences.allowInCallAudioDeviceSwitch,
        incomingRingtoneEnabled: preferences.incomingRingtoneEnabled,
        outgoingRingbackEnabled: preferences.outgoingRingbackEnabled,
        callEndedSoundEnabled: preferences.callEndedSoundEnabled,
        dialpadKeySoundEnabled: preferences.dialpadKeySoundEnabled,
        microphoneVolume: preferences.microphoneVolume,
        speakerVolume: preferences.speakerVolume,
      );
      _applyAudioVolumeState();
      _syncCallProgressSounds();
      _scheduleDialpadKeySoundWarmup();
    } catch (error) {
      _addLog('⚠️ 读取音效偏好失败: $error');
    }
  }

  Future<void> _persistAudioPreferences() async {
    _audio.audioPreferencesDebounceTimer?.cancel();
    _audio.audioPreferencesDebounceTimer = null;
    final preferences = _PersistedAudioPreferences(
      allowInCallAudioDeviceSwitch: _uiState.allowInCallAudioDeviceSwitch,
      incomingRingtoneEnabled: _uiState.incomingRingtoneEnabled,
      outgoingRingbackEnabled: _uiState.outgoingRingbackEnabled,
      callEndedSoundEnabled: _uiState.callEndedSoundEnabled,
      dialpadKeySoundEnabled: _uiState.dialpadKeySoundEnabled,
      microphoneVolume: _uiState.microphoneVolume,
      speakerVolume: _uiState.speakerVolume,
    );
    final payload = jsonEncode(preferences.toJson());
    final previousWrite = _audio.audioPreferencesWrite ?? Future<void>.value();
    final nextWrite = previousWrite.catchError((_) {}).then((_) {
      return _secureStorage.write(
        key: _audioPreferencesStorageKey,
        value: payload,
      );
    });
    _audio.audioPreferencesWrite = nextWrite;
    try {
      await nextWrite;
    } catch (error) {
      _addLog('⚠️ 保存音效偏好失败: $error');
    }
  }

  void _scheduleAudioPreferencesPersist() {
    _audio.audioPreferencesDebounceTimer?.cancel();
    _audio.audioPreferencesDebounceTimer = Timer(
      _audioVolumePersistDebounce,
      () {
        _audio.audioPreferencesDebounceTimer = null;
        unawaited(_persistAudioPreferences());
      },
    );
  }

  Future<void> _loadCachedAgent() async {
    if (_isDisposed) return;
    _seatRestoreInProgress = true;
    var shouldPersistAfterRestore = false;
    try {
      final stored = await _readSeatEnvironmentPayload();
      if (_isDisposed || stored == null || stored.isEmpty) {
        _uiState = _uiState.copyWith(
          seatEnvironmentState: SeatEnvironmentState.ready,
        );
        return;
      }

      final decoded = _decodeSeatEnvironmentPayload(stored);
      if (decoded == null) {
        _uiState = _uiState.copyWith(
          seatEnvironmentState: SeatEnvironmentState.ready,
        );
        return;
      }

      final environment = _PersistedSeatEnvironment.fromJson(decoded);
      if (environment.lines.isEmpty) {
        _uiState = _uiState.copyWith(
          seatEnvironmentState: SeatEnvironmentState.ready,
        );
        return;
      }

      _preferredDefaultLineKey = environment.defaultLineKey;
      _showRestoringSeatEnvironment(environment);
      _addLog('🧩 正在恢复上次坐席环境: ${environment.lines.length} 条线路');

      for (final line in environment.lines) {
        if (_isDisposed) return;
        await register(
          lineName: line.lineName,
          username: line.username,
          authUsername: line.authUsername,
          sipDisplayName: line.sipDisplayName,
          outboundProxy: line.outboundProxy,
          password: line.password,
          host: line.host,
          transport: line.transport,
          mediaSecurity: line.mediaSecurity,
          iceConfig: line.iceConfig,
          turnConfig: line.turnConfig,
          ipv6Enabled: line.ipv6Enabled,
          registrationEnabled: line.registrationEnabled,
          fromRestore: true,
        );
      }

      _applyPreferredDefaultAccount();
      _addLog('✅ 坐席环境恢复完成');
      shouldPersistAfterRestore = true;
    } catch (error) {
      _uiState = _uiState.copyWith(
        seatEnvironmentState: SeatEnvironmentState.ready,
      );
      _addLog('❌ 恢复坐席环境失败: $error');
    } finally {
      _seatRestoreInProgress = false;
      if (!_isDisposed &&
          _uiState.seatEnvironmentState != SeatEnvironmentState.ready) {
        _uiState = _uiState.copyWith(
          seatEnvironmentState: SeatEnvironmentState.ready,
        );
      }
      if (shouldPersistAfterRestore) {
        unawaited(_persistSeatEnvironment());
      }
    }
  }

  Future<void> _persistSeatEnvironment() async {
    // 重启电话服务时会临时注销账号并清空 UI 账号列表。此时 PJSIP 的注销回调
    // 可能晚于 stop() 到达，不能让这些临时状态覆盖已经保存好的真实坐席配置。
    if (_isDisposed ||
        _seatRestoreInProgress ||
        _uiState.isPhoneServiceRestarting) {
      return;
    }
    _seatPersistQueue = _seatPersistQueue.then((_) {
      if (_isDisposed ||
          _seatRestoreInProgress ||
          _uiState.isPhoneServiceRestarting) {
        return Future<void>.value();
      }
      return _persistSeatEnvironmentNow();
    });
    return _seatPersistQueue;
  }

  Future<void> _persistSeatEnvironmentNow() async {
    try {
      final accounts = _uiState.accounts.values.toList()
        ..sort((a, b) => a.lineLabel.compareTo(b.lineLabel));
      final environment = _PersistedSeatEnvironment(
        defaultLineKey: _preferredDefaultLineKey ?? _currentDefaultLineKey(),
        lines: [
          for (final account in accounts)
            _PersistedSipLine(
              lineName: account.lineName,
              username: account.username,
              authUsername: account.authUsername,
              sipDisplayName: account.sipDisplayName,
              outboundProxy: account.outboundProxy,
              password: account.password,
              host: account.host,
              transport: account.transport,
              mediaSecurity: account.mediaSecurity,
              iceConfig: account.iceConfig,
              turnConfig: account.turnConfig,
              ipv6Enabled: account.ipv6Enabled,
              registrationEnabled: account.registrationEnabled,
            ),
        ],
      );
      await _writeSeatEnvironmentPayload(jsonEncode(environment.toJson()));
    } catch (error) {
      _addLog('❌ 保存坐席环境失败: $error');
    }
  }

  void _showRestoringSeatEnvironment(_PersistedSeatEnvironment environment) {
    var nextPlaceholderId = -1;
    final accounts = <int, SipAccountInfo>{};
    int? defaultAccountId;

    for (final line in environment.lines) {
      final normalizedHost = _normalizeSipHost(line.host, line.transport);
      final account = SipAccountInfo(
        accId: nextPlaceholderId,
        lineName: line.lineName,
        username: line.username,
        authUsername: line.authUsername,
        sipDisplayName: line.sipDisplayName,
        outboundProxy: line.outboundProxy,
        password: line.password,
        host: normalizedHost,
        transport: line.transport,
        mediaSecurity: line.mediaSecurity,
        iceConfig: line.iceConfig,
        turnConfig: line.turnConfig,
        ipv6Enabled: line.ipv6Enabled,
        registrationStatus: line.registrationEnabled ? null : 0,
        registrationStatusText: line.registrationEnabled ? '恢复中' : '已暂停',
        registrationExpires: line.registrationEnabled ? null : 0,
        registrationEnabled: line.registrationEnabled,
        registrationActionInProgress: line.registrationEnabled,
      );
      accounts[account.accId] = account;
      if (environment.defaultLineKey ==
          _lineKey(account.username, account.host)) {
        defaultAccountId = account.accId;
      }
      nextPlaceholderId--;
    }

    final defaultAccount = defaultAccountId == null
        ? null
        : accounts[defaultAccountId];
    _uiState = _uiState.copyWith(
      accounts: accounts,
      defaultAccountId: defaultAccountId,
      accId: defaultAccount?.accId ?? -1,
      host: defaultAccount?.host ?? '',
      seatEnvironmentState: SeatEnvironmentState.restoring,
    );
  }

  Future<String?> _readSeatEnvironmentPayload() async {
    final fallback = _macOsDevelopmentFallbackFile();
    try {
      final secureValue = await _secureStorage.read(
        key: _seatEnvironmentStorageKey,
      );
      if (secureValue != null && secureValue.isNotEmpty) {
        return secureValue;
      }
      return _readMacOsDevelopmentFallback(fallback);
    } catch (error) {
      if (fallback == null) rethrow;
      return _readMacOsDevelopmentFallback(fallback);
    }
  }

  Future<void> _writeSeatEnvironmentPayload(String value) async {
    try {
      await _secureStorage.write(key: _seatEnvironmentStorageKey, value: value);
    } catch (error) {
      final fallback = _macOsDevelopmentFallbackFile();
      if (fallback == null) rethrow;
      await fallback.parent.create(recursive: true);
      final tempFile = File('${fallback.path}.tmp');
      await tempFile.writeAsString(value, flush: true);
      if (fallback.existsSync()) {
        await fallback.delete();
      }
      await tempFile.rename(fallback.path);
      if (!_loggedMacOsFallbackWrite) {
        _loggedMacOsFallbackWrite = true;
        _addLog('⚠️ macOS Keychain 不可用，已使用本地开发配置保存坐席环境');
      }
    }
  }

  Future<String?> _readMacOsDevelopmentFallback(File? fallback) async {
    if (fallback == null || !fallback.existsSync()) return null;
    if (!_loggedMacOsFallbackRead) {
      _loggedMacOsFallbackRead = true;
      _addLog('⚠️ macOS Keychain 不可用，使用本地开发配置恢复坐席环境');
    }
    return fallback.readAsString();
  }

  Map<String, Object?>? _decodeSeatEnvironmentPayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      return decoded is Map ? Map<String, Object?>.from(decoded) : null;
    } on FormatException {
      final repaired = _balancedJsonPrefix(payload);
      if (repaired == null || repaired == payload) rethrow;
      final decoded = jsonDecode(repaired);
      if (decoded is! Map) return null;
      _addLog('⚠️ 坐席环境配置存在尾部脏数据，已自动修复');
      return Map<String, Object?>.from(decoded);
    }
  }

  String? _balancedJsonPrefix(String payload) {
    var depth = 0;
    var inString = false;
    var escaping = false;
    for (var i = 0; i < payload.length; i++) {
      final char = payload.codeUnitAt(i);
      if (inString) {
        if (escaping) {
          escaping = false;
        } else if (char == 0x5C) {
          escaping = true;
        } else if (char == 0x22) {
          inString = false;
        }
        continue;
      }
      if (char == 0x22) {
        inString = true;
      } else if (char == 0x7B || char == 0x5B) {
        depth++;
      } else if (char == 0x7D || char == 0x5D) {
        depth--;
        if (depth == 0) {
          return payload.substring(0, i + 1);
        }
      }
    }
    return null;
  }

  File? _macOsDevelopmentFallbackFile() {
    if (!Platform.isMacOS) return null;
    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) return null;
    return File(
      '$home/Library/Application Support/$appStorageDirectoryName/seat_environment_dev.json',
    );
  }

  String? _currentDefaultLineKey() {
    final account = _uiState.defaultAccount;
    return account == null ? null : _lineKey(account.username, account.host);
  }

  String _lineKey(String username, String host) {
    return '${username.trim()}@${_sipHostIdentityKey(host)}';
  }

  void _applyPreferredDefaultAccount() {
    final preferredKey = _preferredDefaultLineKey;
    if (preferredKey == null) return;
    for (final account in _uiState.accounts.values) {
      if (_lineKey(account.username, account.host) != preferredKey) continue;
      if (!account.isRegistered) return;
      if (_uiState.defaultAccountId == account.accId) return;
      setDefaultAccount(account.accId);
      return;
    }
  }
}
