part of '../../../main.dart';

extension _HomeHelpers on _MyHomePageState {
  CallInfo? _primaryCall(PjsipUIState uiState) {
    if (uiState.activeCall != null) return uiState.activeCall;
    for (final call in uiState.calls.values) {
      if (call.isIncoming) return call;
    }
    return uiState.calls.values.isEmpty ? null : uiState.calls.values.first;
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
