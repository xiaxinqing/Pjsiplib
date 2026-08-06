import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:restart_app/restart_app.dart';

import '../../../utils/toast_util.dart';
import 'app_window_controller.dart';

class AppRestartController {
  const AppRestartController._();

  static const AppRestartController instance = AppRestartController._();

  /// 拉起新的桌面应用实例。
  ///
  /// 调用方必须先完成 PJSIP 停止和数据库写入排空。macOS 的重启插件会在
  /// 新实例启动后请求 AppKit 终止旧实例，但 VPhone 自身还会拦截退出事件
  /// 执行异步清理。为避免两套退出协商偶发互相等待，确认新实例启动成功后
  /// 直接结束已完成清理的旧进程。
  Future<bool> restartApplication() async {
    if (!AppWindowController.isDesktop) {
      ToastUtil.showWarning('当前平台暂不支持应用重启');
      return false;
    }

    try {
      debugPrint('Application restart requested.');
      final result = await Restart.restartApp(
        mode: RestartMode.process,
        forceKill: true,
      );
      if (result.success) {
        if (Platform.isMacOS) {
          debugPrint(
            'New macOS application instance started; terminating the cleaned '
            'old process.',
          );
          exit(0);
        }
        return true;
      }

      final message = result.message ?? result.code ?? '未知原因';
      debugPrint('Application restart rejected: $message');
      ToastUtil.showError('重启应用失败，请手动退出后重新打开');
      return false;
    } on MissingPluginException {
      ToastUtil.showError('当前运行环境不支持应用重启');
      return false;
    } on PlatformException catch (error) {
      debugPrint('Application restart failed: ${error.message}');
      ToastUtil.showError('重启应用失败，请手动退出后重新打开');
      return false;
    }
  }
}
