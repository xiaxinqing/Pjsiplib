part of '../../../main.dart';

class AddAccountDialog extends StatefulWidget {
  const AddAccountDialog({
    super.key,
    required this.service,
    required this.isNetworkAvailable,
    this.account,
  });

  final PjsipService service;
  final bool isNetworkAvailable;
  final SipAccountInfo? account;

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  static const _defaultStunServer = 'stun.l.google.com:19302';
  static const _debugUsername = '6523';
  static const _debugPassword = 'veserve888';
  static const _debugHost = '139.59.100.15';

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _lineNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _authUsernameController;
  late final TextEditingController _sipDisplayNameController;
  late final TextEditingController _outboundProxyController;
  late final TextEditingController _passwordController;
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late final TextEditingController _stunServerController;
  late final TextEditingController _turnServerController;
  late final TextEditingController _turnUsernameController;
  late final TextEditingController _turnPasswordController;
  var _hidePassword = true;
  var _hideTurnPassword = true;
  var _selectedTransport = SipTransport.udp;
  var _selectedMediaEncryption = MediaEncryptionMode.none;
  var _iceEnabled = false;
  var _stunEnabled = true;
  var _turnEnabled = false;
  var _ipv6Enabled = false;
  var _selectedTurnTransport = TurnTransport.udp;
  var _advancedExpanded = false;

  bool get _isEditing => widget.account != null;

  bool get _usesUdpWithIce =>
      _selectedTransport == SipTransport.udp && _iceEnabled;

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    _lineNameController = TextEditingController(text: account?.lineName ?? '');
    _usernameController = TextEditingController(
      text: account?.username ?? (kDebugMode ? _debugUsername : ''),
    );
    _authUsernameController = TextEditingController(
      text: account?.authUsername ?? '',
    );
    _sipDisplayNameController = TextEditingController(
      text: account?.sipDisplayName ?? '',
    );
    _outboundProxyController = TextEditingController(
      text: account?.outboundProxy ?? '',
    );
    _passwordController = TextEditingController(
      text: account?.password ?? (kDebugMode ? _debugPassword : ''),
    );
    final hostParts = _splitHostAndPort(
      account?.host ?? (kDebugMode ? _debugHost : ''),
    );
    _hostController = TextEditingController(text: hostParts.host);
    _portController = TextEditingController(text: hostParts.port);
    _stunServerController = TextEditingController(
      text: account == null ? _defaultStunServer : account.iceConfig.stunServer,
    );
    _turnServerController = TextEditingController(
      text: account?.turnConfig.server ?? '',
    );
    _turnUsernameController = TextEditingController(
      text: account?.turnConfig.username ?? '',
    );
    _turnPasswordController = TextEditingController(
      text: account?.turnConfig.password ?? '',
    );
    _selectedTransport = account?.transport ?? SipTransport.udp;
    _selectedMediaEncryption =
        account?.mediaSecurity.mode ?? MediaEncryptionMode.none;
    // UDP 携带 ICE 时 SDP 会明显变大，部分网络或 Asterisk 前置链路会丢弃
    // UDP 分片，表现成“客户端发出 INVITE，但服务端没有任何反应”。
    // 所以新建线路默认不主动打开 ICE；需要复杂 NAT 穿透时由用户显式开启。
    _iceEnabled = account?.iceConfig.enabled ?? false;
    // 与旧版本保持一致，STUN 默认开启；遇到特定服务端兼容问题时可单独关闭。
    _stunEnabled = account?.iceConfig.stunEnabled ?? true;
    _turnEnabled = account?.turnConfig.enabled ?? false;
    _ipv6Enabled = account?.ipv6Enabled ?? false;
    _selectedTurnTransport = account?.turnConfig.transport ?? TurnTransport.udp;
    // 编辑已有线路时，如果高级网络配置不是默认值，直接展开，避免用户错过。
    _advancedExpanded =
        (account?.authUsername.trim().isNotEmpty ?? false) ||
        (account?.sipDisplayName.trim().isNotEmpty ?? false) ||
        (account?.outboundProxy.trim().isNotEmpty ?? false) ||
        (account != null &&
            account.mediaSecurity.mode != MediaEncryptionMode.none) ||
        account?.turnConfig.enabled == true ||
        account?.ipv6Enabled == true ||
        account?.iceConfig.enabled == false ||
        account?.iceConfig.stunEnabled == false ||
        (account != null &&
            account.iceConfig.stunServer.trim().isNotEmpty &&
            account.iceConfig.stunServer.trim() != _defaultStunServer);
  }

  @override
  void dispose() {
    _lineNameController.dispose();
    _usernameController.dispose();
    _authUsernameController.dispose();
    _sipDisplayNameController.dispose();
    _outboundProxyController.dispose();
    _passwordController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _stunServerController.dispose();
    _turnServerController.dispose();
    _turnUsernameController.dispose();
    _turnPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: _panelBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 18,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: _softBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 12, 13),
                child: Row(
                  children: [
                    Icon(
                      _isEditing ? AppIcons.edit : AppIcons.line,
                      size: 20,
                      color: _textPrimary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isEditing
                            ? l10n.accountDialogEditTitle
                            : l10n.accountDialogAddTitle,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.commonClose,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(AppIcons.close, size: 20),
                      style: IconButton.styleFrom(
                        fixedSize: const Size.square(36),
                        minimumSize: const Size.square(36),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionLabel(
                        AppIcons.account,
                        l10n.accountDialogAccountInfo,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _lineNameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.accountDialogLineName,
                          helperText: l10n.accountDialogLineNameHint,
                          prefixIcon: const Icon(AppIcons.line),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.accountDialogUsername,
                          prefixIcon: const Icon(AppIcons.person),
                        ),
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _hidePassword,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.accountDialogPassword,
                          prefixIcon: const Icon(AppIcons.lock),
                          suffixIcon: IconButton(
                            tooltip: _hidePassword
                                ? l10n.accountDialogShowPassword
                                : l10n.accountDialogHidePassword,
                            onPressed: () =>
                                setState(() => _hidePassword = !_hidePassword),
                            icon: Icon(
                              _hidePassword
                                  ? AppIcons.visible
                                  : AppIcons.hidden,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _hostController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: l10n.accountDialogServer,
                                prefixIcon: const Icon(AppIcons.host),
                              ),
                              validator: _requiredValidator,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 112,
                            child: TextFormField(
                              controller: _portController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: l10n.accountDialogPort,
                                hintText: '${_selectedTransport.defaultPort}',
                              ),
                              validator: _portValidator,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.accountDialogDefaultPortHint(
                          _selectedTransport.label,
                          _selectedTransport.defaultPort,
                        ),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                      ),
                      const SizedBox(height: 18),
                      _buildSectionLabel(
                        AppIcons.network,
                        l10n.accountDialogConnection,
                      ),
                      const SizedBox(height: 10),
                      _buildTransportSelector(context),
                      const SizedBox(height: 12),
                      _buildMediaEncryptionSelector(context),
                      const SizedBox(height: 14),
                      _buildAdvancedSettingsSection(context),
                      if (!widget.isNetworkAvailable) ...[
                        const SizedBox(height: 12),
                        Text(
                          l10n.accountDialogNetworkUnavailable,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                decoration: const BoxDecoration(
                  color: _subtlePanel,
                  border: Border(top: BorderSide(color: _softBorder)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.commonCancel),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: widget.isNetworkAvailable ? _submit : null,
                      icon: Icon(_isEditing ? AppIcons.save : AppIcons.add),
                      label: Text(
                        _isEditing
                            ? l10n.accountDialogSave
                            : l10n.accountDialogAddAndRegister,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(IconData icon, String label) {
    final color = _textPrimary.withValues(alpha: 0.68);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportSelector(BuildContext context) {
    final l10n = context.l10n;
    return _buildSelectMenu<SipTransport>(
      label: l10n.accountDialogTransport,
      icon: AppIcons.transport,
      value: _selectedTransport,
      values: SipTransport.values,
      titleBuilder: (transport) =>
          '${transport.label} · ${_accountDialogTransportDescription(l10n, transport)}',
      subtitleBuilder: (transport) =>
          l10n.accountDialogDefaultPort(transport.defaultPort),
      onChanged: (transport) {
        setState(() {
          _selectedTransport = transport;
          // TLS 只保护 SIP 信令；首次切到 TLS 时自动推荐媒体也走 DTLS-SRTP。
          if (transport == SipTransport.tls &&
              _selectedMediaEncryption == MediaEncryptionMode.none) {
            _selectedMediaEncryption = MediaEncryptionMode.dtlsSrtp;
          }
          // 从 TLS/TCP 切到 UDP 时不强制关闭 ICE，避免用户已经明确配置的
          // NAT 策略丢失；下方会给出风险提示，保存时再二次确认。
        });
      },
    );
  }

  Widget _buildMediaEncryptionSelector(BuildContext context) {
    final l10n = context.l10n;
    final showWarning =
        _selectedMediaEncryption.usesSrtp && !_selectedTransport.isSecure;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSelectMenu<MediaEncryptionMode>(
          label: l10n.accountDialogMediaEncryption,
          icon: AppIcons.security,
          value: _selectedMediaEncryption,
          values: MediaEncryptionMode.values,
          titleBuilder: (mode) => _accountDialogMediaLabel(l10n, mode),
          subtitleBuilder: _mediaEncryptionDescription,
          onChanged: (mode) => setState(() => _selectedMediaEncryption = mode),
        ),
        if (showWarning) ...[
          const SizedBox(height: 8),
          Text(
            l10n.accountDialogSrtpWithoutTlsWarning,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.orange.shade800),
          ),
        ],
      ],
    );
  }

  /// 构建弹窗表单里的桌面选择菜单，替代默认 Dropdown 的 Material 弹层样式。
  Widget _buildSelectMenu<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<T> values,
    required String Function(T value) titleBuilder,
    String Function(T value)? subtitleBuilder,
    required ValueChanged<T> onChanged,
  }) {
    final selectedTitle = titleBuilder(value);
    final selectedSubtitle = subtitleBuilder?.call(value);
    return LayoutBuilder(
      builder: (context, constraints) {
        final menuWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : 320.0;
        return MenuAnchor(
          alignmentOffset: const Offset(0, 8),
          style: MenuStyle(
            backgroundColor: const WidgetStatePropertyAll(_panelBackground),
            elevation: const WidgetStatePropertyAll(18),
            shadowColor: WidgetStatePropertyAll(
              Colors.black.withValues(alpha: 0.22),
            ),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: 4),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: _textPrimary.withValues(alpha: 0.12)),
              ),
            ),
          ),
          menuChildren: [
            for (final item in values)
              _buildSelectMenuItem<T>(
                width: menuWidth,
                item: item,
                selected: item == value,
                title: titleBuilder(item),
                subtitle: subtitleBuilder?.call(item),
                onSelected: onChanged,
              ),
          ],
          builder: (context, controller, child) {
            return Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              child: InkWell(
                borderRadius: BorderRadius.circular(7),
                hoverColor: _brandGreen.withValues(alpha: 0.05),
                onTap: controller.isOpen ? controller.close : controller.open,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 54),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _subtlePanel,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: controller.isOpen
                          ? _brandGreen.withValues(alpha: 0.62)
                          : Colors.transparent,
                      width: controller.isOpen ? 1.1 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: _textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: _textSecondary,
                                    fontSize: 11,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              selectedSubtitle == null
                                  ? selectedTitle
                                  : '$selectedTitle · $selectedSubtitle',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: _textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        controller.isOpen
                            ? AppIcons.chevronUp
                            : AppIcons.chevronDown,
                        size: 17,
                        color: _textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSelectMenuItem<T>({
    required double width,
    required T item,
    required bool selected,
    required String title,
    required String? subtitle,
    required ValueChanged<T> onSelected,
  }) {
    return MenuItemButton(
      onPressed: () => onSelected(item),
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(width, 42)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        ),
        overlayColor: WidgetStatePropertyAll(
          _brandGreen.withValues(alpha: 0.08),
        ),
      ),
      child: SizedBox(
        width: math.max(0, width - 20),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              child: selected
                  ? const Icon(AppIcons.check, size: 16, color: _brandGreen)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? _brandGreen : _textPrimary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _textSecondary.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettingsSection(BuildContext context) {
    final l10n = context.l10n;
    final stunServer = _stunServerController.text.trim();
    final accountHints = [
      if (_authUsernameController.text.trim().isNotEmpty)
        l10n.accountDialogAdvancedAuth,
      if (_sipDisplayNameController.text.trim().isNotEmpty)
        l10n.accountDialogAdvancedDisplayName,
      if (_outboundProxyController.text.trim().isNotEmpty)
        l10n.accountDialogAdvancedProxy,
    ];
    final summary = [
      accountHints.isEmpty
          ? l10n.accountDialogAdvancedDefaults
          : accountHints.join(' · '),
      _iceEnabled ? 'ICE' : l10n.accountDialogIceOff,
      if (!_stunEnabled)
        l10n.accountDialogStunOff
      else if (stunServer.isEmpty || stunServer == _defaultStunServer)
        l10n.accountDialogStunDefault
      else
        l10n.accountDialogStunCustom,
      _ipv6Enabled ? 'IPv6' : l10n.accountDialogIpv4Only,
      if (_turnEnabled) 'TURN',
    ].join(' · ');

    return Material(
      color: _subtlePanel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: _softBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          key: ValueKey(_advancedExpanded),
          initiallyExpanded: _advancedExpanded,
          onExpansionChanged: (expanded) =>
              setState(() => _advancedExpanded = expanded),
          tilePadding: const EdgeInsets.fromLTRB(12, 4, 10, 4),
          childrenPadding: EdgeInsets.zero,
          leading: const Icon(AppIcons.tune, size: 19, color: _textSecondary),
          title: Text(
            l10n.accountDialogAdvanced,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              summary,
              style: const TextStyle(fontSize: 12, color: _textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAdvancedGroup(
                    context,
                    icon: AppIcons.account,
                    title: l10n.accountDialogAdvancedAccount,
                    children: [
                      TextFormField(
                        controller: _authUsernameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.accountDialogAuthUsername,
                          helperText: l10n.accountDialogAuthUsernameHint,
                          prefixIcon: const Icon(AppIcons.key),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _sipDisplayNameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.accountDialogSipDisplayName,
                          helperText: l10n.accountDialogSipDisplayNameHint,
                          prefixIcon: const Icon(AppIcons.person),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildAdvancedGroup(
                    context,
                    icon: AppIcons.network,
                    title: l10n.accountDialogAdvancedNetwork,
                    children: [
                      TextFormField(
                        controller: _outboundProxyController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.accountDialogOutboundProxy,
                          helperText: l10n.accountDialogOutboundProxyHint,
                          prefixIcon: const Icon(AppIcons.route),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 4),
                      SwitchListTile.adaptive(
                        value: _ipv6Enabled,
                        onChanged: (enabled) =>
                            setState(() => _ipv6Enabled = enabled),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        secondary: const Icon(AppIcons.public),
                        title: Text(l10n.accountDialogEnableIpv6),
                        subtitle: Text(l10n.accountDialogEnableIpv6Hint),
                      ),
                      const Divider(height: 1),
                      SwitchListTile.adaptive(
                        value: _iceEnabled,
                        onChanged: (enabled) => setState(() {
                          _iceEnabled = enabled;
                          if (!enabled) _turnEnabled = false;
                        }),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        secondary: const Icon(AppIcons.hub),
                        title: Text(l10n.accountDialogEnableIce),
                        subtitle: Text(l10n.accountDialogEnableIceHint),
                      ),
                      if (_usesUdpWithIce)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: _buildUdpIceWarning(context),
                        ),
                      const Divider(height: 1),
                      SwitchListTile.adaptive(
                        value: _stunEnabled,
                        onChanged: (enabled) =>
                            setState(() => _stunEnabled = enabled),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        secondary: const Icon(AppIcons.public),
                        title: Text(l10n.accountDialogEnableStun),
                        subtitle: Text(l10n.accountDialogEnableStunHint),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 160),
                        child: _stunEnabled
                            ? Column(
                                key: const ValueKey('stun-enabled'),
                                children: [
                                  const Divider(height: 1),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      12,
                                      12,
                                      12,
                                    ),
                                    child: TextFormField(
                                      controller: _stunServerController,
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                        labelText: l10n.accountDialogStunServer,
                                        helperText:
                                            l10n.accountDialogStunServerHint,
                                        hintText: _defaultStunServer,
                                        prefixIcon: const Icon(AppIcons.public),
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(
                                key: ValueKey('stun-disabled'),
                              ),
                      ),
                      const Divider(height: 1),
                      SwitchListTile.adaptive(
                        value: _turnEnabled,
                        onChanged: _iceEnabled
                            ? (enabled) => setState(() {
                                _turnEnabled = enabled;
                                // TURN 是 ICE 的中继候选来源；开启 TURN 时顺手打开 ICE，避免用户
                                // 填了 TURN 但媒体协商里没有 relay candidate。
                                if (enabled) _iceEnabled = true;
                              })
                            : null,
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        secondary: const Icon(AppIcons.swap),
                        title: Text(l10n.accountDialogEnableTurn),
                        subtitle: Text(
                          _iceEnabled
                              ? l10n.accountDialogTurnHint
                              : l10n.accountDialogTurnNeedsIce,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 160),
                        child: _turnEnabled
                            ? Padding(
                                key: const ValueKey('turn-enabled'),
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  12,
                                  14,
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller: _turnServerController,
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                        labelText: l10n.accountDialogTurnServer,
                                        hintText: 'turn.example.com:3478',
                                        prefixIcon: const Icon(AppIcons.cloud),
                                      ),
                                      validator: (value) {
                                        if (!_turnEnabled) return null;
                                        return _requiredValidator(value);
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _turnUsernameController,
                                            textInputAction:
                                                TextInputAction.next,
                                            decoration: InputDecoration(
                                              labelText: l10n
                                                  .accountDialogTurnUsername,
                                              prefixIcon: const Icon(
                                                AppIcons.person,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _buildSelectMenu<TurnTransport>(
                                            label:
                                                l10n.accountDialogTurnTransport,
                                            icon: AppIcons.transport,
                                            value: _selectedTurnTransport,
                                            values: TurnTransport.values,
                                            titleBuilder: (transport) =>
                                                transport.label,
                                            subtitleBuilder:
                                                _turnTransportDescription,
                                            onChanged: (transport) => setState(
                                              () => _selectedTurnTransport =
                                                  transport,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _turnPasswordController,
                                      obscureText: _hideTurnPassword,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _submit(),
                                      decoration: InputDecoration(
                                        labelText:
                                            l10n.accountDialogTurnPassword,
                                        prefixIcon: const Icon(AppIcons.key),
                                        suffixIcon: IconButton(
                                          tooltip: _hideTurnPassword
                                              ? l10n.accountDialogShowPassword
                                              : l10n.accountDialogHidePassword,
                                          onPressed: () => setState(
                                            () => _hideTurnPassword =
                                                !_hideTurnPassword,
                                          ),
                                          icon: Icon(
                                            _hideTurnPassword
                                                ? AppIcons.visible
                                                : AppIcons.hidden,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(
                                key: ValueKey('turn-disabled'),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedGroup(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final titleColor = _textPrimary.withValues(alpha: 0.78);
    final baseInputTheme = Theme.of(context).inputDecorationTheme;
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: baseInputTheme.copyWith(
          filled: true,
          fillColor: _subtlePanel,
          border: _advancedFieldBorder(_softBorder),
          enabledBorder: _advancedFieldBorder(_softBorder),
          focusedBorder: _advancedFieldBorder(
            _brandGreen.withValues(alpha: 0.55),
            width: 1.1,
          ),
          errorBorder: _advancedFieldBorder(
            Theme.of(context).colorScheme.error.withValues(alpha: 0.72),
          ),
          focusedErrorBorder: _advancedFieldBorder(
            Theme.of(context).colorScheme.error,
            width: 1.1,
          ),
        ),
      ),
      child: Material(
        color: _panelBackground,
        elevation: 0.6,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: _softBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: titleColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUdpIceWarning(BuildContext context) {
    final warningColor = Colors.orange.shade800;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(AppIcons.info, size: 16, color: warningColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.accountDialogUdpIceWarning,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: warningColor,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _advancedFieldBorder(Color color, {double width = 0.8}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  String _mediaEncryptionDescription(MediaEncryptionMode mode) {
    final l10n = context.l10n;
    return switch (mode) {
      MediaEncryptionMode.none => l10n.accountDialogMediaBestCompatibility,
      MediaEncryptionMode.sdesSrtp => l10n.accountDialogMediaUseTls,
      MediaEncryptionMode.dtlsSrtp => l10n.accountDialogMediaAsteriskDtls,
      MediaEncryptionMode.optionalDtlsFirst =>
        l10n.accountDialogMediaAllowsFallback,
      MediaEncryptionMode.optionalSdesFirst =>
        l10n.accountDialogMediaLegacySrtp,
    };
  }

  String _turnTransportDescription(TurnTransport transport) {
    final l10n = context.l10n;
    return switch (transport) {
      TurnTransport.udp => l10n.accountDialogTurnUdp,
      TurnTransport.tcp => l10n.accountDialogTurnTcp,
      TurnTransport.tls => l10n.accountDialogTurnTls,
    };
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.accountDialogRequired;
    }
    return null;
  }

  String? _portValidator(String? value) {
    final portText = value?.trim() ?? '';
    if (portText.isEmpty) return null;
    final port = int.tryParse(portText);
    if (port == null || port < 1 || port > 65535) {
      return context.l10n.accountDialogInvalidPort;
    }
    return null;
  }

  ({String host, String port}) _splitHostAndPort(String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty) return (host: '', port: '');

    final bracketEnd = value.startsWith('[') ? value.indexOf(']') : -1;
    if (bracketEnd > 0 &&
        bracketEnd + 1 < value.length &&
        value[bracketEnd + 1] == ':') {
      final port = value.substring(bracketEnd + 2);
      if (_isPortText(port)) {
        return (host: value.substring(0, bracketEnd + 1), port: port);
      }
      return (host: value, port: '');
    }

    final colonIndex = value.lastIndexOf(':');
    if (colonIndex <= 0 || colonIndex == value.length - 1) {
      return (host: value, port: '');
    }
    // 只拆常见的 host:port；裸 IPv6 地址包含多个冒号，保持原样，避免误切。
    if (value.indexOf(':') != colonIndex) return (host: value, port: '');

    final port = value.substring(colonIndex + 1);
    if (!_isPortText(port)) return (host: value, port: '');
    return (host: value.substring(0, colonIndex), port: port);
  }

  bool _isPortText(String value) {
    final port = int.tryParse(value);
    return port != null && port >= 1 && port <= 65535;
  }

  String _buildHostValue() {
    final hostText = _hostController.text.trim();
    final portText = _portController.text.trim();
    if (portText.isEmpty) return hostText;

    final host = _splitHostAndPort(hostText).host;
    return '$host:$portText';
  }

  Future<void> _submit() async {
    if (!widget.isNetworkAvailable) return;
    if (!_isEditing && widget.service.hasReachedAccountLimit) {
      ToastUtil.showWarning(
        context.l10n.accountLimitReached(PjsipService.maxAccountCount),
      );
      return;
    }
    if (_turnEnabled && _turnServerController.text.trim().isEmpty) {
      setState(() => _advancedExpanded = true);
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_usesUdpWithIce && !await _confirmUdpIceRisk()) return;

    final mediaSecurity = MediaSecurityConfig(mode: _selectedMediaEncryption);
    final iceConfig = IceConfig(
      enabled: _iceEnabled,
      stunEnabled: _stunEnabled,
      stunServer: _stunServerController.text.trim(),
    );
    final turnConfig = TurnConfig(
      enabled: _turnEnabled,
      server: _turnServerController.text.trim(),
      username: _turnUsernameController.text.trim(),
      password: _turnPasswordController.text,
      transport: _selectedTurnTransport,
    );
    final account = widget.account;
    final host = _buildHostValue();
    if (account == null) {
      widget.service.register(
        lineName: _lineNameController.text.trim(),
        username: _usernameController.text.trim(),
        authUsername: _authUsernameController.text.trim(),
        sipDisplayName: _sipDisplayNameController.text.trim(),
        outboundProxy: _outboundProxyController.text.trim(),
        password: _passwordController.text,
        host: host,
        transport: _selectedTransport,
        mediaSecurity: mediaSecurity,
        iceConfig: iceConfig,
        turnConfig: turnConfig,
        ipv6Enabled: _ipv6Enabled,
      );
    } else {
      widget.service.updateAccount(
        accId: account.accId,
        lineName: _lineNameController.text.trim(),
        username: _usernameController.text.trim(),
        authUsername: _authUsernameController.text.trim(),
        sipDisplayName: _sipDisplayNameController.text.trim(),
        outboundProxy: _outboundProxyController.text.trim(),
        password: _passwordController.text,
        host: host,
        transport: _selectedTransport,
        mediaSecurity: mediaSecurity,
        iceConfig: iceConfig,
        turnConfig: turnConfig,
        ipv6Enabled: _ipv6Enabled,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<bool> _confirmUdpIceRisk() async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.accountDialogConfirmUdpIce),
        content: Text(l10n.accountDialogConfirmUdpIceBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.accountDialogReview),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.accountDialogSaveAnyway),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

String _accountDialogTransportDescription(
  AppLocalizations l10n,
  SipTransport transport,
) => switch (transport) {
  SipTransport.udp => l10n.accountDialogTransportStandard,
  SipTransport.tcp => l10n.accountDialogTransportCompatible,
  SipTransport.tls => l10n.accountDialogTransportSecure,
};

String _accountDialogMediaLabel(
  AppLocalizations l10n,
  MediaEncryptionMode mode,
) => switch (mode) {
  MediaEncryptionMode.none => l10n.accountDialogMediaNone,
  MediaEncryptionMode.sdesSrtp => l10n.accountDialogMediaSdes,
  MediaEncryptionMode.dtlsSrtp => l10n.accountDialogMediaDtls,
  MediaEncryptionMode.optionalDtlsFirst => l10n.accountDialogMediaOptionalDtls,
  MediaEncryptionMode.optionalSdesFirst => l10n.accountDialogMediaOptionalSdes,
};
