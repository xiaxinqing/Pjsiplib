part of '../pjsip_service.dart';

/// 音频设备选择模式。
///
/// 自动模式由策略决定使用耳机、系统默认或内置设备；手动模式尊重用户选择，
/// 只有设备不可用时才回退。
enum PjsipAudioDeviceMode { automatic, manual }

/// PJSIP 枚举出来的一条音频设备信息。
///
/// 注意：这里描述的是 PJSIP/CoreAudio 看到的“底层音频端点”，不一定等同于
/// macOS 系统设置里展示的设备。比如一个蓝牙耳机可能出现多个端点，虚拟声卡也
/// 可能同时有输入和输出能力，所以后面会通过一组 `looksLike...` 规则做过滤。
class PjsipAudioDevice {
  /// PJSIP 设备 ID。传给 `pjsua_set_snd_dev` 时使用。
  ///
  /// 约定：`-1` 表示系统默认输入，`-2` 表示系统默认输出。
  final int id;

  /// 设备名称，来自底层音频驱动，例如 `MacBook Pro麦克风`、`gaoyuan`。
  final String name;

  /// 驱动名称，例如 macOS 上常见的 `core audio`。
  final String driver;

  /// 输入通道数量。大于 0 表示理论上可以作为采集设备。
  final int inputCount;

  /// 输出通道数量。大于 0 表示理论上可以作为播放设备。
  final int outputCount;

  /// 设备默认采样率。日志诊断时很有用，比如蓝牙通话模式常见 16000Hz。
  final int defaultSampleRate;

  const PjsipAudioDevice({
    required this.id,
    required this.name,
    required this.driver,
    required this.inputCount,
    required this.outputCount,
    required this.defaultSampleRate,
  });

  bool get canCapture => inputCount > 0;

  bool get canPlayback => outputCount > 0;

  /// 用于跨刷新识别“同一个设备”的轻量签名。
  ///
  /// PJSIP 的设备 ID 在热插拔后可能复用或变化，所以不能只靠 ID 记住用户选择。
  String get signature => '$driver::$name::$inputCount::$outputCount';

  /// 我们手动补充的系统默认设备，不是底层枚举出来的真实端点。
  bool get isSystemDefault => id == -1 || id == -2;

  /// 明确带耳机/蓝牙/USB 语义的设备。用户自定义蓝牙名称可能不会命中，
  /// 这类设备再由 pairedExternal 规则识别。
  bool get looksLikeHeadset {
    if (isSystemDefault) return false;
    final value = '$name $driver'.toLowerCase();
    return value.contains('headphone') ||
        value.contains('headset') ||
        value.contains('earphone') ||
        value.contains('earbud') ||
        value.contains('airpods') ||
        value.contains('bluetooth') ||
        value.contains('bluez') ||
        value.contains('usb') ||
        value.contains('耳机') ||
        value.contains('蓝牙');
  }

  /// 虚拟/聚合设备通常用于录音、转发或其他 App 内部桥接，不适合作为默认
  /// 软电话输入/输出。保留在原始日志中，但默认不进入通话设备列表。
  bool get looksLikeVirtualDevice {
    final value = '$name $driver'.toLowerCase();
    return value.contains('blackhole') ||
        value.contains('microsoft teams audio') ||
        value.contains('vpauaggregateaudiodevice') ||
        value.contains('zoomaudio') ||
        value.contains('aggregate') ||
        value.contains('virtual') ||
        value.contains('multi-output') ||
        value.contains('虚拟');
  }

  /// 内置设备可以给用户选择，但不会被“同名输入+输出”规则误判为外接耳机。
  bool get looksLikeBuiltInDevice {
    final value = name.toLowerCase();
    return value.contains('macbook') ||
        value.contains('built-in') ||
        value.contains('内建') ||
        value.contains('内置');
  }

  /// 显示器/HDMI/DisplayPort 音频可作为输出，但不应出现在麦克风列表，也不应
  /// 被自动策略当作耳机优先选择。
  bool get looksLikeDisplayAudioDevice {
    final value = name.toLowerCase();
    return value.contains('displayport') ||
        value.contains('hdmi') ||
        value.contains('monitor') ||
        value.contains('显示器') ||
        RegExp(r'^[a-z]{1,4}\d{3,}').hasMatch(value);
  }

  /// 名称明显是播放设备，用于清理 CoreAudio 中错误暴露到输入侧的端点。
  bool get looksLikePlaybackOnlyName {
    final value = name.toLowerCase();
    return value.contains('speaker') ||
        value.contains('扬声器') ||
        looksLikeDisplayAudioDevice;
  }

  /// 名称明显是采集设备。当前主要用于避免把纯麦克风误放到输出侧。
  bool get looksLikeCaptureOnlyName {
    final value = name.toLowerCase();
    return value.contains('microphone') ||
        value.contains('麦克风') ||
        value.contains('mic');
  }

  /// 下拉框展示文案，把名称、驱动、输入/输出能力拼在一起。
  String get label {
    final io = [
      if (canCapture) '输入$inputCount',
      if (canPlayback) '输出$outputCount',
    ].join('/');
    final source = driver.isEmpty ? io : '$driver · $io';
    return source.isEmpty ? name : '$name ($source)';
  }
}
