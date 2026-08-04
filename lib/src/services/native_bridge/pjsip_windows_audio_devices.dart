part of '../pjsip_service.dart';

/// Windows 版 PJSIP 的音频设备枚举函数。
///
/// 这里不能直接复用 ffigen 生成的 [pjmedia_aud_dev_info]：PJSIP 在 Windows
/// 下将设备名称缓冲区定义为 128 字节，而 macOS/Linux 默认为 64 字节。当前绑定
/// 在 macOS 上生成，因此固定成了 64 字节；如果 Windows 继续使用该结构，名称后面
/// 的通道数、采样率和驱动名称都会发生 ABI 错位。
typedef _PjsuaEnumWindowsAudioDevicesC =
    ffi.Int Function(
      ffi.Pointer<_WindowsPjmediaAudioDeviceInfo>,
      ffi.Pointer<ffi.UnsignedInt>,
    );
typedef _PjsuaEnumWindowsAudioDevicesDart =
    int Function(
      ffi.Pointer<_WindowsPjmediaAudioDeviceInfo>,
      ffi.Pointer<ffi.UnsignedInt>,
    );

/// 与 Windows PJSIP 2.17 `pjmedia_aud_dev_info` 完全一致的 FFI 结构。
///
/// 只在 Windows 枚举声卡时使用。不要把生成绑定中的公共结构直接改成 128 字节，
/// 否则 macOS/Linux 会反向发生布局错位。
final class _WindowsPjmediaAudioDeviceInfo extends ffi.Struct {
  @ffi.Int32()
  external int id;

  @ffi.Array.multi([128])
  external ffi.Array<ffi.Char> name;

  @ffi.UnsignedInt()
  external int inputCount;

  @ffi.UnsignedInt()
  external int outputCount;

  @ffi.UnsignedInt()
  external int defaultSamplesPerSec;

  @ffi.Array.multi([32])
  external ffi.Array<ffi.Char> driver;

  @ffi.UnsignedInt()
  external int caps;

  @ffi.UnsignedInt()
  external int routes;

  @ffi.UnsignedInt()
  external int extFormatCount;

  @ffi.Array.multi([8])
  external ffi.Array<pjmedia_format> extFormats;
}
