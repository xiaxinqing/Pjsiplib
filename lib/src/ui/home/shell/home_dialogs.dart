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

  /// 打开设置抽屉，并同步当前选中的设置分组。
  void _openSettingsDrawer({int tabIndex = 0}) {
    if (_settingsTabIndex != tabIndex) {
      _update(() => _settingsTabIndex = tabIndex);
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
                    if (_settingsTabIndex != index && mounted) {
                      _update(() => _settingsTabIndex = index);
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
