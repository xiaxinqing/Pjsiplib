part of '../../../main.dart';

/// 统一线路展示顺序：默认外呼线路置顶，其余线路保持添加顺序。
///
/// 注册、暂停或异常状态只改变视觉状态，不参与排序，避免状态回调导致列表跳动。
List<SipAccountInfo> _orderedAccountsForDisplay(PjsipUIState uiState) {
  final accounts = uiState.accounts.values.toList(growable: false);
  final defaultAccountId = uiState.defaultAccountId;
  if (defaultAccountId == null) return accounts;

  final defaultAccount = uiState.accounts[defaultAccountId];
  if (defaultAccount == null) return accounts;

  return <SipAccountInfo>[
    defaultAccount,
    for (final account in accounts)
      if (account.accId != defaultAccountId) account,
  ];
}

extension _HomeHelpers on _MyHomePageState {
  CallInfo? _primaryCall(PjsipUIState uiState) {
    // 未接听来电是高优先级事件，不能被用户之前点选的“查看中”通话挡住。
    for (final call in uiState.calls.values) {
      if (call.isIncoming) return call;
    }
    final focusedId = _focusedCallDetailId;
    if (focusedId != null && uiState.calls[focusedId] != null) {
      return uiState.calls[focusedId];
    }
    if (uiState.activeCall != null) return uiState.activeCall;
    final calls = uiState.calls.values.toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    for (final call in calls) {
      if (call.isConnected && !call.isOnHold && !call.isRemoteOnHold) {
        return call;
      }
    }
    for (final call in calls) {
      if (uiState.isInConference(call.callId)) return call;
    }
    return calls.isEmpty ? null : calls.first;
  }

  String _deviceLabelById(List<PjsipAudioDevice> devices, int? id) {
    if (id == null) return '未选择';
    for (final device in devices) {
      if (device.id == id) return device.name;
    }
    return '设备不可用';
  }

  String _displayRemote(String remoteUri) {
    final sipIndex = remoteUri.indexOf('sip:');
    var value = sipIndex >= 0 ? remoteUri.substring(sipIndex + 4) : remoteUri;
    final atIndex = value.indexOf('@');
    if (atIndex > 0) value = value.substring(0, atIndex);
    final semicolonIndex = value.indexOf(';');
    if (semicolonIndex > 0) value = value.substring(0, semicolonIndex);
    return value.replaceAll('<', '').replaceAll('>', '');
  }

  String _avatarText(String remoteUri) {
    final value = _displayRemote(remoteUri).trim();
    if (value.isEmpty) return '?';
    return value.characters.first.toUpperCase();
  }

  Widget _buildTooltipText(
    String value, {
    TextStyle? style,
    int maxLines = 1,
    TextAlign? textAlign,
  }) {
    // 桌面端长文本会被省略号截断；Tooltip 让鼠标悬停时能看到完整内容，
    // 移动端也可通过长按查看，交互成本比弹窗详情更低。
    return Tooltip(
      message: value,
      waitDuration: const Duration(milliseconds: 350),
      child: Text(
        value,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        style: style,
      ),
    );
  }
}

extension _IncomingCallSnapshot on PjsipUIState {
  Set<int> get _ringingCallIds {
    return calls.values
        .where((call) => call.isIncoming && !call.isConnected)
        .map((call) => call.callId)
        .toSet();
  }
}
