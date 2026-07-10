import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

typedef PjsipGetVersionC = ffi.Pointer<Utf8> Function();
typedef PjsipGetVersionDart = ffi.Pointer<Utf8> Function();

void testPjsip() {
  // 1. 加载库
  // macOS 上，库会被打包到 Frameworks 目录下
  final dylib = ffi.DynamicLibrary.open('libpjsip.dylib');

  // 2. 绑定函数 (以 pj_get_version 为例)
  final pjGetVersion = dylib
      .lookupFunction<PjsipGetVersionC, PjsipGetVersionDart>('pj_get_version');

  // 3. 调用并打印
  final version = pjGetVersion().toDartString();
  print('PJSIP 编译成功！版本号为: $version');
}