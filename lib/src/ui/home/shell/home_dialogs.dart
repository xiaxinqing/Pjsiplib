part of '../../../../main.dart';

/// 首页弹窗入口：统一承接账号编辑和设置抽屉，避免各页面直接管理弹窗状态。
extension _HomeDialogs on _MyHomePageState {
  /// 打开新增账号弹窗。
  Future<void> _showAddAccountDialog(
    PjsipUIState uiState,
    PjsipService service,
  ) {
    return _showAccountDialog(uiState, service);
  }

  /// 打开编辑账号弹窗，并把当前账号信息传入表单。
  Future<void> _showEditAccountDialog(
    PjsipUIState uiState,
    PjsipService service,
    SipAccountInfo account,
  ) {
    return _showAccountDialog(uiState, service, account: account);
  }

  /// 复用账号表单弹窗，按是否传入账号区分新增或编辑。
  Future<void> _showAccountDialog(
    PjsipUIState uiState,
    PjsipService service, {
    SipAccountInfo? account,
  }) {
    if (account == null &&
        uiState.accounts.length >= PjsipService.maxAccountCount) {
      ToastUtil.showWarning(
        context.l10n.accountLimitReached(PjsipService.maxAccountCount),
      );
      return Future<void>.value();
    }
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) => AddAccountDialog(
        service: service,
        isNetworkAvailable: uiState.isNetworkAvailable,
        account: account,
      ),
    );
  }

  /// 打开设置抽屉。
  ///
  /// 设置页的选中分组只保存在弹窗内部，避免音频测试等服务状态更新时触发首页重建，
  /// 导致用户看到设置页“自己跳页”。
  void _openSettingsDrawer({int tabIndex = _settingsAccountIndex}) {
    if (tabIndex == _settingsAudioIndex) {
      unawaited(
        ref
            .read(pjsipServiceProvider.notifier)
            .checkMicrophonePermission(reason: '打开音频设置'),
      );
    }
    var selectedIndex = tabIndex;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, _) {
            final uiState = ref.watch(pjsipServiceProvider);
            final service = ref.read(pjsipServiceProvider.notifier);
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return _buildSettingsDialog(
                  uiState,
                  service,
                  selectedIndex: selectedIndex,
                  onSelected: (index) {
                    setDialogState(() => selectedIndex = index);
                    if (index == _settingsAudioIndex) {
                      unawaited(
                        service.checkMicrophonePermission(reason: '切换到音频设置'),
                      );
                    }
                  },
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      if (!mounted) return;
      ref.read(pjsipServiceProvider.notifier).cancelAudioTests();
    });
  }
}
