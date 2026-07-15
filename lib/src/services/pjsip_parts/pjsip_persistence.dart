part of '../pjsip_service.dart';

const String _seatEnvironmentStorageKey = 'thruv_seat_environment_v1';

class _PersistedSeatEnvironment {
  const _PersistedSeatEnvironment({
    required this.lines,
    required this.defaultLineKey,
  });

  final List<_PersistedSipLine> lines;
  final String? defaultLineKey;

  Map<String, Object?> toJson() {
    return {
      'version': 1,
      'defaultLineKey': defaultLineKey,
      'lines': lines.map((line) => line.toJson()).toList(),
    };
  }

  static _PersistedSeatEnvironment fromJson(Map<String, Object?> json) {
    final rawLines = json['lines'];
    return _PersistedSeatEnvironment(
      defaultLineKey: json['defaultLineKey'] as String?,
      lines: rawLines is List
          ? rawLines
                .whereType<Map>()
                .map(
                  (line) => _PersistedSipLine.fromJson(
                    Map<String, Object?>.from(line),
                  ),
                )
                .where((line) => line.isValid)
                .toList()
          : const [],
    );
  }
}

class _PersistedSipLine {
  const _PersistedSipLine({
    required this.username,
    required this.password,
    required this.host,
    required this.transport,
    required this.registrationEnabled,
  });

  final String username;
  final String password;
  final String host;
  final SipTransport transport;
  final bool registrationEnabled;

  bool get isValid => username.isNotEmpty && host.isNotEmpty;

  Map<String, Object?> toJson() {
    return {
      'username': username,
      'password': password,
      'host': host,
      'transport': transport.name,
      'registrationEnabled': registrationEnabled,
    };
  }

  static _PersistedSipLine fromJson(Map<String, Object?> json) {
    final transportName = json['transport'] as String?;
    return _PersistedSipLine(
      username: (json['username'] as String?)?.trim() ?? '',
      password: json['password'] as String? ?? '',
      host: (json['host'] as String?)?.trim() ?? '',
      transport: SipTransport.values.firstWhere(
        (transport) => transport.name == transportName,
        orElse: () => SipTransport.udp,
      ),
      registrationEnabled: json['registrationEnabled'] as bool? ?? true,
    );
  }
}

extension PjsipPersistenceOperations on PjsipService {
  Future<void> _restoreSeatEnvironment() async {
    if (_isDisposed) return;
    _seatRestoreInProgress = true;
    var shouldPersistAfterRestore = false;
    try {
      final stored = await _readSeatEnvironmentPayload();
      if (_isDisposed || stored == null || stored.isEmpty) return;

      final decoded = jsonDecode(stored);
      if (decoded is! Map) return;

      final environment = _PersistedSeatEnvironment.fromJson(
        Map<String, Object?>.from(decoded),
      );
      if (environment.lines.isEmpty) return;

      _preferredDefaultLineKey = environment.defaultLineKey;
      _addLog('🧩 正在恢复上次坐席环境: ${environment.lines.length} 条线路');

      for (final line in environment.lines) {
        if (_isDisposed) return;
        await register(
          username: line.username,
          password: line.password,
          host: line.host,
          transport: line.transport,
          registrationEnabled: line.registrationEnabled,
          fromRestore: true,
        );
      }

      _applyPreferredDefaultAccount();
      _addLog('✅ 坐席环境恢复完成');
      shouldPersistAfterRestore = true;
    } catch (error) {
      _addLog('❌ 恢复坐席环境失败: $error');
    } finally {
      _seatRestoreInProgress = false;
      if (shouldPersistAfterRestore) {
        unawaited(_persistSeatEnvironment());
      }
    }
  }

  Future<void> _persistSeatEnvironment() async {
    if (_isDisposed || _seatRestoreInProgress) return;
    try {
      final accounts = _uiState.accounts.values.toList()
        ..sort((a, b) => a.lineLabel.compareTo(b.lineLabel));
      final environment = _PersistedSeatEnvironment(
        defaultLineKey: _preferredDefaultLineKey ?? _currentDefaultLineKey(),
        lines: [
          for (final account in accounts)
            _PersistedSipLine(
              username: account.username,
              password: account.password,
              host: account.host,
              transport: account.transport,
              registrationEnabled: account.registrationEnabled,
            ),
        ],
      );
      await _writeSeatEnvironmentPayload(jsonEncode(environment.toJson()));
    } catch (error) {
      _addLog('❌ 保存坐席环境失败: $error');
    }
  }

  Future<String?> _readSeatEnvironmentPayload() async {
    final fallback = _macOsDevelopmentFallbackFile();
    try {
      final secureValue = await _secureStorage.read(
        key: _seatEnvironmentStorageKey,
      );
      if (secureValue != null && secureValue.isNotEmpty) {
        return secureValue;
      }
      return _readMacOsDevelopmentFallback(fallback);
    } catch (error) {
      if (fallback == null) rethrow;
      return _readMacOsDevelopmentFallback(fallback);
    }
  }

  Future<void> _writeSeatEnvironmentPayload(String value) async {
    try {
      await _secureStorage.write(key: _seatEnvironmentStorageKey, value: value);
    } catch (error) {
      final fallback = _macOsDevelopmentFallbackFile();
      if (fallback == null) rethrow;
      await fallback.parent.create(recursive: true);
      await fallback.writeAsString(value);
      if (!_loggedMacOsFallbackWrite) {
        _loggedMacOsFallbackWrite = true;
        _addLog('⚠️ macOS Keychain 不可用，已使用本地开发配置保存坐席环境');
      }
    }
  }

  Future<String?> _readMacOsDevelopmentFallback(File? fallback) async {
    if (fallback == null || !fallback.existsSync()) return null;
    if (!_loggedMacOsFallbackRead) {
      _loggedMacOsFallbackRead = true;
      _addLog('⚠️ macOS Keychain 不可用，使用本地开发配置恢复坐席环境');
    }
    return fallback.readAsString();
  }

  File? _macOsDevelopmentFallbackFile() {
    if (!Platform.isMacOS) return null;
    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) return null;
    return File(
      '$home/Library/Application Support/pjsip_lib/seat_environment_dev.json',
    );
  }

  String? _currentDefaultLineKey() {
    final account = _uiState.defaultAccount;
    return account == null ? null : _lineKey(account.username, account.host);
  }

  String _lineKey(String username, String host) {
    return '${username.trim()}@${_sipHostIdentityKey(host)}';
  }

  void _applyPreferredDefaultAccount() {
    final preferredKey = _preferredDefaultLineKey;
    if (preferredKey == null) return;
    for (final account in _uiState.accounts.values) {
      if (_lineKey(account.username, account.host) != preferredKey) continue;
      if (!account.isRegistered) return;
      if (_uiState.defaultAccountId == account.accId) return;
      setDefaultAccount(account.accId);
      return;
    }
  }
}
