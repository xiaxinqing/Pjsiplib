import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:restart_app/restart_app.dart';

import '../../../utils/toast_util.dart';
import 'app_window_controller.dart';

class AppRestartController {
  const AppRestartController._();

  static const AppRestartController instance = AppRestartController._();

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
      if (result.success) return true;

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
