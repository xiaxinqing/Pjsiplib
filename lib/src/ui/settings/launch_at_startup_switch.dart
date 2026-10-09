import 'dart:async';

import 'package:flutter/material.dart';

import '../../localization/build_context_l10n.dart';
import '../../services/native_bridge/app_launch_at_startup_controller.dart';

/// 设置弹窗自己管这个开关，刷新时不用依赖弹窗下面的首页。
class LaunchAtStartupSwitch extends StatefulWidget {
  const LaunchAtStartupSwitch({
    super.key,
    this.controller = const AppLaunchAtStartupController(),
    this.layoutBuilder,
  });

  final AppLaunchAtStartupController controller;
  final Widget Function(Widget startup, Widget? startMinimized)? layoutBuilder;

  @override
  State<LaunchAtStartupSwitch> createState() => _LaunchAtStartupSwitchState();
}

class _LaunchAtStartupSwitchState extends State<LaunchAtStartupSwitch> {
  late final AppLifecycleListener _lifecycle;
  LaunchAtStartupStatus? _status;
  bool _busy = false;
  bool _failed = false;
  bool _refreshPending = false;
  bool _startMinimized = false;
  bool _preferenceLoaded = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(_refresh()));
    unawaited(_refresh());
  }

  Future<void> _refresh() async {
    if (_busy) {
      // 用户从系统设置切回来时，上一笔操作可能还没结束，等它结束再查一次。
      _refreshPending = true;
      return;
    }
    await _perform(widget.controller.readStatus);
  }

  Future<void> _perform(
    Future<LaunchAtStartupStatus> Function() operation,
  ) async {
    if (_busy || !mounted) return;
    setState(() {
      _busy = true;
      _failed = false;
      _preferenceLoaded = false;
    });
    try {
      final status = await operation();
      if (mounted) setState(() => _status = status);
      final minimized = await widget.controller.readStartMinimized();
      if (mounted) {
        setState(() {
          _startMinimized = minimized;
          _preferenceLoaded = true;
        });
      }
    } catch (error) {
      debugPrint('Launch at startup failed: $error');
      // 注册可能只完成了一半，报错后也要重新读取，不能盲目回到旧状态。
      LaunchAtStartupStatus? actual;
      try {
        actual = await widget.controller.readStatus();
      } catch (_) {
        // 连查询也失败时显示重试，不把未知状态伪装成“关闭”。
      }
      if (mounted) {
        setState(() {
          _status = actual;
          _failed = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        if (_refreshPending) {
          _refreshPending = false;
          unawaited(_refresh());
        }
      }
    }
  }

  Future<void> _openSettings() async {
    try {
      await widget.controller.openSystemSettings();
    } catch (error) {
      debugPrint('Could not open login items: $error');
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final startup = _buildStartupControl(context);
    // 等系统确认开启后才展示子选项，待批准也不算真正开启。
    final minimized = _status == LaunchAtStartupStatus.enabled
        ? Semantics(
            label: context.l10n.settingsStartMinimized,
            child: Switch.adaptive(
              value: _startMinimized,
              onChanged: _busy || !_preferenceLoaded
                  ? null
                  : (value) => _perform(() async {
                      await widget.controller.setStartMinimized(value);
                      return widget.controller.readStatus();
                    }),
            ),
          )
        : null;
    return widget.layoutBuilder?.call(startup, minimized) ?? startup;
  }

  Widget _buildStartupControl(BuildContext context) {
    final l10n = context.l10n;
    if (_status == LaunchAtStartupStatus.unsupported) {
      return Text(l10n.commonUnavailable);
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_busy)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (_status == LaunchAtStartupStatus.requiresApproval) ...[
            Text(l10n.settingsStartupNeedsApproval, textAlign: TextAlign.end),
            Wrap(
              alignment: WrapAlignment.end,
              children: [
                TextButton(
                  onPressed: _openSettings,
                  child: Text(l10n.settingsStartupOpenSettings),
                ),
                TextButton(
                  onPressed: () =>
                      _perform(() => widget.controller.setEnabled(false)),
                  child: Text(l10n.commonCancel),
                ),
              ],
            ),
          ] else if (_status != null)
            Semantics(
              label: l10n.settingsLaunchAtLogin,
              child: Switch.adaptive(
                value: _status == LaunchAtStartupStatus.enabled,
                onChanged: (value) =>
                    _perform(() => widget.controller.setEnabled(value)),
              ),
            ),
          if (_failed) ...[
            Text(
              l10n.settingsStartupFailed,
              textAlign: TextAlign.end,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            TextButton(
              onPressed: _busy ? null : _refresh,
              child: Text(l10n.settingsStartupRetry),
            ),
          ],
        ],
      ),
    );
  }
}
