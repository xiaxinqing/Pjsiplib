part of '../../main.dart';

extension _HomeSidebar on _MyHomePageState {
  Widget _buildSidebar(PjsipUIState uiState) {
    return Container(
      width: 236,
      color: _sidebarBackground,
      padding: const EdgeInsets.fromLTRB(14, 54, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _textPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phone_in_talk, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'VoIP Desk',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildConnectionPill(uiState),
          const SizedBox(height: 18),
          _buildNavItem(
            icon: Icons.dialpad,
            label: '拨号',
            section: _WorkspaceSection.dialpad,
          ),
          _buildNavItem(
            icon: Icons.call,
            label: '当前通话',
            section: _WorkspaceSection.calls,
            badge: uiState.calls.isEmpty ? null : '${uiState.calls.length}',
          ),
          _buildNavItem(
            icon: Icons.contacts,
            label: '联系人',
            section: _WorkspaceSection.contacts,
          ),
          _buildNavItem(
            icon: Icons.history,
            label: '通话记录',
            section: _WorkspaceSection.history,
          ),
          const Spacer(),
          _buildLineStatusPanel(uiState),
          const SizedBox(height: 12),
          _buildAudioMiniStatus(uiState),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            icon: const Icon(Icons.settings),
            label: const Text('设置'),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionPill(PjsipUIState uiState) {
    final isRegistered = uiState.hasRegisteredAccount;
    final color = !uiState.isNetworkAvailable
        ? Colors.orange.shade700
        : isRegistered
        ? _brandGreen
        : Theme.of(context).colorScheme.outline;
    final label = !uiState.isNetworkAvailable
        ? '网络不可用'
        : isRegistered
        ? '电话线路已连接'
        : uiState.isInitialized
        ? '等待账号连接'
        : '未连接';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _softBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineStatusPanel(PjsipUIState uiState) {
    final accounts = uiState.accounts.values.toList();
    if (accounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '线路',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          for (final account in accounts.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 9,
                    color: account.isRegistered
                        ? _brandGreen
                        : Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      account.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (uiState.defaultAccountId == account.accId)
                    const Icon(Icons.outbound, size: 14),
                ],
              ),
            ),
          if (accounts.length > 3)
            Text(
              '+${accounts.length - 3} 条线路',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required _WorkspaceSection section,
    String? badge,
  }) {
    final selected = _section == section;
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? _hoverPanel : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _selectSection(section),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? _textPrimary : _textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: _textPrimary,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    constraints: const BoxConstraints(minWidth: 24),
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioMiniStatus(PjsipUIState uiState) {
    final mic = _deviceLabelById(
      uiState.captureDevices,
      uiState.selectedCaptureDeviceId,
    );
    final speaker = _deviceLabelById(
      uiState.playbackDevices,
      uiState.selectedPlaybackDeviceId,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTinyDeviceLine(Icons.mic, mic),
          const SizedBox(height: 8),
          _buildTinyDeviceLine(Icons.volume_up, speaker),
        ],
      ),
    );
  }

  Widget _buildTinyDeviceLine(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
