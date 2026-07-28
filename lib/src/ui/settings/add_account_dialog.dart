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
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _hostController;
  late final TextEditingController _stunServerController;
  late final TextEditingController _turnServerController;
  late final TextEditingController _turnUsernameController;
  late final TextEditingController _turnPasswordController;
  var _hidePassword = true;
  var _hideTurnPassword = true;
  var _selectedTransport = SipTransport.udp;
  var _selectedMediaEncryption = MediaEncryptionMode.none;
  var _iceEnabled = true;
  var _turnEnabled = false;
  var _selectedTurnTransport = TurnTransport.udp;

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    _usernameController = TextEditingController(
      text: account?.username ?? (kDebugMode ? _debugUsername : ''),
    );
    _passwordController = TextEditingController(
      text: account?.password ?? (kDebugMode ? _debugPassword : ''),
    );
    _hostController = TextEditingController(
      text: account?.host ?? (kDebugMode ? _debugHost : ''),
    );
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
    _iceEnabled = account?.iceConfig.enabled ?? true;
    _turnEnabled = account?.turnConfig.enabled ?? false;
    _selectedTurnTransport = account?.turnConfig.transport ?? TurnTransport.udp;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _hostController.dispose();
    _stunServerController.dispose();
    _turnServerController.dispose();
    _turnUsernameController.dispose();
    _turnPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
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
                        _isEditing ? '编辑线路' : '添加线路',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: '关闭',
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
                      TextFormField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: '线路账号',
                          prefixIcon: Icon(AppIcons.person),
                        ),
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _hidePassword,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: '密码',
                          prefixIcon: const Icon(AppIcons.lock),
                          suffixIcon: IconButton(
                            tooltip: _hidePassword ? '显示密码' : '隐藏密码',
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
                      TextFormField(
                        controller: _hostController,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: const InputDecoration(
                          labelText: '服务器',
                          helperText: '未填写端口时：UDP/TCP 默认 5060，TLS 默认 5061',
                          prefixIcon: Icon(AppIcons.host),
                        ),
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 16),
                      _buildTransportSelector(context),
                      const SizedBox(height: 12),
                      _buildMediaEncryptionSelector(context),
                      const SizedBox(height: 14),
                      _buildAdvancedSettingsSection(context),
                      if (!widget.isNetworkAvailable) ...[
                        const SizedBox(height: 12),
                        Text(
                          '当前网络不可用，暂不能添加线路',
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
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: widget.isNetworkAvailable ? _submit : null,
                      icon: Icon(_isEditing ? AppIcons.save : AppIcons.add),
                      label: Text(_isEditing ? '保存修改' : '添加并注册'),
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

  Widget _buildTransportSelector(BuildContext context) {
    return DropdownButtonFormField<SipTransport>(
      key: ValueKey(_selectedTransport),
      initialValue: _selectedTransport,
      decoration: const InputDecoration(
        labelText: '传输协议',
        prefixIcon: Icon(AppIcons.transport),
      ),
      items: [
        for (final transport in SipTransport.values)
          DropdownMenuItem<SipTransport>(
            value: transport,
            child: Text('${transport.label} · ${transport.description}'),
          ),
      ],
      onChanged: (transport) {
        if (transport == null) return;
        setState(() {
          _selectedTransport = transport;
          // TLS 只保护 SIP 信令；首次切到 TLS 时自动推荐媒体也走 DTLS-SRTP。
          if (transport == SipTransport.tls &&
              _selectedMediaEncryption == MediaEncryptionMode.none) {
            _selectedMediaEncryption = MediaEncryptionMode.dtlsSrtp;
          }
        });
      },
    );
  }

  Widget _buildMediaEncryptionSelector(BuildContext context) {
    final showWarning =
        _selectedMediaEncryption.usesSrtp && !_selectedTransport.isSecure;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<MediaEncryptionMode>(
          key: ValueKey(_selectedMediaEncryption),
          initialValue: _selectedMediaEncryption,
          decoration: const InputDecoration(
            labelText: '媒体加密',
            prefixIcon: Icon(AppIcons.security),
          ),
          items: [
            for (final mode in MediaEncryptionMode.values)
              DropdownMenuItem<MediaEncryptionMode>(
                value: mode,
                child: Text(mode.label),
              ),
          ],
          onChanged: (mode) {
            if (mode == null) return;
            setState(() => _selectedMediaEncryption = mode);
          },
        ),
        if (showWarning) ...[
          const SizedBox(height: 8),
          Text(
            '当前不是 TLS 信令，SRTP 会关闭“安全信令要求”。SDES 会把密钥放进 SDP，建议配合 TLS 使用。',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.orange.shade800),
          ),
        ],
      ],
    );
  }

  Widget _buildAdvancedSettingsSection(BuildContext context) {
    return Material(
      color: _subtlePanel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: _softBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                Icon(AppIcons.tune, size: 20, color: _textPrimary),
                SizedBox(width: 10),
                Text(
                  '高级设置',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile.adaptive(
            value: _iceEnabled,
            onChanged: (enabled) => setState(() {
              _iceEnabled = enabled;
              if (!enabled) _turnEnabled = false;
            }),
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            secondary: const Icon(AppIcons.hub),
            title: const Text('启用 ICE'),
            subtitle: const Text('用于复杂 NAT 网络下协商媒体地址'),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: TextFormField(
              controller: _stunServerController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'STUN 服务器',
                helperText: '清空则使用默认 STUN，多个可用逗号或空格分隔',
                hintText: _defaultStunServer,
                prefixIcon: Icon(AppIcons.public),
              ),
            ),
          ),
          const Divider(height: 1),
          SwitchListTile.adaptive(
            value: _turnEnabled,
            onChanged: (enabled) => setState(() {
              _turnEnabled = enabled;
              // TURN 是 ICE 的中继候选来源；开启 TURN 时顺手打开 ICE，避免用户
              // 填了 TURN 但媒体协商里没有 relay candidate。
              if (enabled) _iceEnabled = true;
            }),
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            secondary: const Icon(AppIcons.swap),
            title: const Text('启用 TURN'),
            subtitle: const Text('无法直连媒体时使用中继服务器'),
          ),
          if (_turnEnabled) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _turnServerController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'TURN 服务器',
                      hintText: 'turn.example.com:3478',
                      prefixIcon: Icon(AppIcons.cloud),
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
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'TURN 用户名',
                            prefixIcon: Icon(AppIcons.person),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<TurnTransport>(
                          key: ValueKey(_selectedTurnTransport),
                          initialValue: _selectedTurnTransport,
                          decoration: const InputDecoration(
                            labelText: 'TURN 协议',
                            prefixIcon: Icon(AppIcons.transport),
                          ),
                          items: [
                            for (final transport in TurnTransport.values)
                              DropdownMenuItem<TurnTransport>(
                                value: transport,
                                child: Text(transport.label),
                              ),
                          ],
                          onChanged: (transport) {
                            if (transport == null) return;
                            setState(() => _selectedTurnTransport = transport);
                          },
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
                      labelText: 'TURN 密码',
                      prefixIcon: const Icon(AppIcons.key),
                      suffixIcon: IconButton(
                        tooltip: _hideTurnPassword ? '显示密码' : '隐藏密码',
                        onPressed: () => setState(
                          () => _hideTurnPassword = !_hideTurnPassword,
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
            ),
          ],
        ],
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return '不能为空';
    return null;
  }

  void _submit() {
    if (!widget.isNetworkAvailable) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final mediaSecurity = MediaSecurityConfig(mode: _selectedMediaEncryption);
    final iceConfig = IceConfig(
      enabled: _iceEnabled,
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
    if (account == null) {
      widget.service.register(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        host: _hostController.text.trim(),
        transport: _selectedTransport,
        mediaSecurity: mediaSecurity,
        iceConfig: iceConfig,
        turnConfig: turnConfig,
      );
    } else {
      widget.service.updateAccount(
        accId: account.accId,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        host: _hostController.text.trim(),
        transport: _selectedTransport,
        mediaSecurity: mediaSecurity,
        iceConfig: iceConfig,
        turnConfig: turnConfig,
      );
    }
    Navigator.of(context).pop();
  }
}
