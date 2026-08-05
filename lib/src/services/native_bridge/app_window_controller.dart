import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

/// 统一管理桌面端主窗口的生命周期和交互行为。
///
/// 这个类主要负责三件事：
/// 1. 创建并显示主窗口；
/// 2. 用户点击关闭按钮时将窗口隐藏到系统托盘；
/// 3. 收到来电时恢复窗口并提醒用户。
///
/// `with WindowListener` 表示该类可以监听窗口关闭等系统窗口事件。
class AppWindowController with WindowListener {
  /// 创建窗口控制器。
  ///
  /// 构造函数本身不执行初始化；应用启动后仍需调用 [initializeMainWindow]，
  /// 需要“关闭到托盘”功能时还要调用 [attachCloseToTrayBehavior]。
  AppWindowController();

  /// 用户可以把窗口缩小到的最小尺寸，避免界面内容被过度挤压。
  static const Size minimumSize = Size(920, 620);

  /// Flutter 与 macOS/Windows 原生窗口代码通信所使用的通道。
  static const _attentionChannel = MethodChannel('voip_desk/window_attention');

  /// 用于延迟取消“窗口置顶”的计时器。
  Timer? _attentionResetTimer;

  /// 记录关闭事件监听是否已经添加，防止重复添加监听器。
  bool _closeToTrayAttached = false;

  /// 判断应用当前是否运行在受支持的桌面平台。
  static bool get isDesktop =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  /// 初始化并显示应用的主窗口。
  ///
  /// 此方法只在桌面端生效。它会先初始化 `window_manager`，再设置窗口尺寸、
  /// 最小尺寸、标题栏样式和居中显示，最后显示窗口并让它获得键盘焦点。
  static Future<void> initializeMainWindow() async {
    if (!isDesktop) return;

    await windowManager.ensureInitialized();

    // macOS 隐藏标题栏后仍会保留左上角的“红黄绿”窗口按钮；
    // Windows/Linux 若使用相同设置，系统窗口按钮也会被隐藏，因此保持普通标题栏。
    final titleBarStyle = Platform.isMacOS
        ? TitleBarStyle.hidden
        : TitleBarStyle.normal;

    // 根据不同系统选择更合适的首次启动尺寸。
    final initialSize = Platform.isMacOS
        ? const Size(1180, 740)
        : const Size(1080, 700);

    final options = WindowOptions(
      size: initialSize,
      minimumSize: minimumSize,
      center: true,
      title: 'VPhone',
      titleBarStyle: titleBarStyle,
    );

    // 等待原生窗口准备完成后再显示，可避免启动过程中出现空白窗口或闪烁。
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  /// 启用“点击关闭按钮时隐藏到系统托盘”的行为。
  ///
  /// [setPreventClose] 会阻止操作系统直接销毁窗口；真正的关闭事件随后由
  /// [onWindowClose] 接收，并改为执行隐藏窗口。重复调用此方法不会重复监听。
  Future<void> attachCloseToTrayBehavior() async {
    if (!isDesktop || _closeToTrayAttached) return;

    _closeToTrayAttached = true;
    windowManager.addListener(this);
    await _safeWindowCall(() => windowManager.setPreventClose(true));
    debugPrint('Window close-to-tray behavior attached.');
  }

  /// 移除“关闭到托盘”的窗口事件监听。
  ///
  /// 常用于控制器不再使用或应用准备退出时，避免遗留无效的事件监听器。
  void detachCloseToTrayBehavior() {
    if (!isDesktop || !_closeToTrayAttached) return;

    _closeToTrayAttached = false;
    windowManager.removeListener(this);
  }

  /// 当用户点击系统窗口的关闭按钮时触发。
  ///
  /// 回调本身不能使用 `await`，所以用 [unawaited] 启动异步隐藏操作，并明确表示
  /// 这里是有意不等待它完成，而不是忘记处理返回的 `Future`。
  @override
  void onWindowClose() {
    debugPrint(
      'Window close requested; hiding to tray if prevent-close is on.',
    );
    unawaited(_hideWindowInsteadOfClosing());
  }

  /// 收到来电时唤醒窗口并吸引用户注意。
  ///
  /// 执行顺序是：恢复并聚焦窗口、处理 macOS 跨桌面空间显示、请求系统提醒，
  /// 最后短暂将窗口置顶。非桌面平台会直接返回。
  Future<void> notifyIncomingCall() async {
    if (!isDesktop) return;

    await _restoreAndFocus();
    if (Platform.isMacOS) {
      // window_manager 可以在当前 macOS 桌面空间中恢复并聚焦窗口，
      // 但不能可靠地跨桌面空间调出窗口，所以交给 AppKit 完成最后一步。
      await _safePlatformCall('presentIncomingCallWindow');
    }
    await _requestUserAttention();
    await _pulseAlwaysOnTop();
  }

  /// 在来电接听、拒绝或结束后清除窗口提醒状态。
  ///
  /// 这里会取消尚未触发的计时器、撤销窗口置顶，并通知原生平台停止提醒。
  Future<void> clearIncomingCallAttention() async {
    if (!isDesktop) return;

    _attentionResetTimer?.cancel();
    _attentionResetTimer = null;
    await _safeWindowCall(() => windowManager.setAlwaysOnTop(false));
    await _safePlatformCall('clearAttention');
  }

  /// 如果窗口已最小化就先恢复，然后显示窗口并让它获得焦点。
  ///
  /// 所有 `window_manager` 调用都放在 [_safeWindowCall] 中，避免插件不可用时
  /// 直接导致应用崩溃。
  Future<void> _restoreAndFocus() async {
    await _safeWindowCall(() async {
      if (await windowManager.isMinimized()) {
        await windowManager.restore();
      }
      await windowManager.show();
      await windowManager.focus();
    });
  }

  /// 将一次“关闭窗口”请求转换成“隐藏到系统托盘”。
  ///
  /// 只有已经通过 [setPreventClose] 阻止真正关闭时才隐藏窗口；隐藏前会取消
  /// 窗口置顶，防止下次打开时仍保持在其他应用上方。
  Future<void> _hideWindowInsteadOfClosing() async {
    if (!isDesktop) return;

    await _safeWindowCall(() async {
      final preventClose = await windowManager.isPreventClose();
      debugPrint('Window hide-to-tray preventClose=$preventClose');
      if (!preventClose) return;
      await windowManager.setAlwaysOnTop(false);
      await windowManager.hide();
      debugPrint('Window hidden to tray.');
    });
  }

  /// 请求操作系统用闪烁任务栏、弹跳 Dock 图标等方式提醒用户。
  ///
  /// 具体效果由各平台的原生实现决定。
  Future<void> _requestUserAttention() async {
    await _safePlatformCall('requestAttention');
  }

  /// 将窗口临时置顶两秒，然后自动恢复为普通窗口。
  ///
  /// 每次调用都会先取消旧计时器，避免连续来电产生多个计时器，导致较早的
  /// 计时器提前取消新一次来电的置顶状态。
  Future<void> _pulseAlwaysOnTop() async {
    await _safeWindowCall(() => windowManager.setAlwaysOnTop(true));
    _attentionResetTimer?.cancel();
    _attentionResetTimer = Timer(const Duration(seconds: 2), () {
      unawaited(_safeWindowCall(() => windowManager.setAlwaysOnTop(false)));
    });
  }

  /// 安全地调用指定的原生窗口提醒方法。
  ///
  /// [method] 是 MethodChannel 中注册的方法名。插件不存在或原生调用失败时，
  /// 此方法会忽略/记录异常，让窗口提醒失败不会影响通话主流程。
  Future<void> _safePlatformCall(String method) async {
    try {
      await _attentionChannel.invokeMethod<void>(method);
    } on MissingPluginException {
      // Linux 当前只依赖窗口的恢复与聚焦，不一定注册了原生提醒插件。
    } on PlatformException catch (error) {
      debugPrint('Window attention "$method" failed: ${error.message}');
    }
  }

  /// 安全执行一次 `window_manager` 异步操作。
  ///
  /// [action] 是调用者传入的具体窗口操作。统一捕获插件相关异常后，调用者无需
  /// 在每个窗口函数中重复编写相同的 `try/catch`。
  Future<void> _safeWindowCall(Future<void> Function() action) async {
    try {
      await action();
    } on MissingPluginException {
      // Widget 测试或不受支持的桌面环境可能没有注册 window_manager 插件。
    } on PlatformException catch (error) {
      debugPrint('Window manager call failed: ${error.message}');
    }
  }
}
