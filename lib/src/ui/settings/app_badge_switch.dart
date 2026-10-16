import 'dart:async';

import 'package:flutter/material.dart';

import '../../localization/build_context_l10n.dart';
import '../../services/native_bridge/app_badge_controller.dart';

/// 弹窗自己刷新开关，不依赖背后首页的 setState。
class AppBadgeSwitch extends StatefulWidget {
  const AppBadgeSwitch({super.key, this.controller});

  final AppBadgeController? controller;

  @override
  State<AppBadgeSwitch> createState() => _AppBadgeSwitchState();
}

class _AppBadgeSwitchState extends State<AppBadgeSwitch> {
  late final AppBadgeController _controller;
  bool? _enabled;
  bool? _supported;
  bool _busy = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AppBadgeController.instance;
    unawaited(_perform(_controller.readSettings));
  }

  Future<void> _perform(Future<AppBadgeSettings> Function() action) async {
    if (_busy || !mounted) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final settings = await action();
      if (!mounted) return;
      setState(() {
        _enabled = settings.enabled;
        _supported = settings.supported;
      });
    } catch (error) {
      debugPrint('更新角标设置失败: $error');
      if (!mounted) return;
      setState(() {
        // 偏好可能已保存，但系统角标更新失败；显示已保存值，并提示重试同步。
        _enabled = _controller.enabled;
        _supported = _controller.isSupported;
        _failed = true;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_supported == false)
            Text(l10n.settingsAppBadgeUnsupported, textAlign: TextAlign.end)
          else if (_enabled != null)
            Semantics(
              label: l10n.settingsAppBadge,
              child: Switch.adaptive(
                value: _enabled!,
                onChanged: _busy
                    ? null
                    : (value) => _perform(() => _controller.setEnabled(value)),
              ),
            )
          else if (_busy)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          if (_failed) ...[
            Text(
              l10n.settingsAppBadgeFailed,
              textAlign: TextAlign.end,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => _perform(_controller.readSettings),
              child: Text(l10n.settingsStartupRetry),
            ),
          ],
        ],
      ),
    );
  }
}
