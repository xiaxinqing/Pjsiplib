import 'dart:ffi' as ffi;
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart';

typedef PjsipGetVersionC = ffi.Pointer<Utf8> Function();
typedef PjsipGetVersionDart = ffi.Pointer<Utf8> Function();

void testPjsip() {
  // 1. 加载库
  // 动态库由各桌面平台放在应用可执行文件的搜索目录中。
  final libraryName = Platform.isWindows
      ? 'pjsip.dll'
      : Platform.isLinux
      ? 'libpjsip.so'
      : 'libpjsip.dylib';
  final dylib = ffi.DynamicLibrary.open(libraryName);

  // 2. 绑定函数 (以 pj_get_version 为例)
  final pjGetVersion = dylib
      .lookupFunction<PjsipGetVersionC, PjsipGetVersionDart>('pj_get_version');

  // 3. 调用并打印
  final version = pjGetVersion().toDartString();
  // ignore: avoid_print
  print('PJSIP 编译成功！版本号为: $version');
}
