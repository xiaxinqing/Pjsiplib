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
      if (_isDisposed || stored == null || stored.isEmpty) {
        _uiState = _uiState.copyWith(
          seatEnvironmentState: SeatEnvironmentState.ready,
        );
        return;
      }

      final decoded = _decodeSeatEnvironmentPayload(stored);
      if (decoded == null) {
        _uiState = _uiState.copyWith(
          seatEnvironmentState: SeatEnvironmentState.ready,
        );
        return;
      }

      final environment = _PersistedSeatEnvironment.fromJson(decoded);
      if (environment.lines.isEmpty) {
        _uiState = _uiState.copyWith(
          seatEnvironmentState: SeatEnvironmentState.ready,
        );
        return;
      }

      _preferredDefaultLineKey = environment.defaultLineKey;
      _showRestoringSeatEnvironment(environment);
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
      _uiState = _uiState.copyWith(
        seatEnvironmentState: SeatEnvironmentState.ready,
      );
      _addLog('❌ 恢复坐席环境失败: $error');
    } finally {
      _seatRestoreInProgress = false;
      if (!_isDisposed &&
          _uiState.seatEnvironmentState != SeatEnvironmentState.ready) {
        _uiState = _uiState.copyWith(
          seatEnvironmentState: SeatEnvironmentState.ready,
        );
      }
      if (shouldPersistAfterRestore) {
        unawaited(_persistSeatEnvironment());
      }
    }
  }

  Future<void> _persistSeatEnvironment() async {
    if (_isDisposed || _seatRestoreInProgress) return;
    _seatPersistQueue = _seatPersistQueue.then((_) {
      if (_isDisposed || _seatRestoreInProgress) return Future<void>.value();
      return _persistSeatEnvironmentNow();
    });
    return _seatPersistQueue;
  }

  Future<void> _persistSeatEnvironmentNow() async {
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

  void _showRestoringSeatEnvironment(_PersistedSeatEnvironment environment) {
    var nextPlaceholderId = -1;
    final accounts = <int, SipAccountInfo>{};
    int? defaultAccountId;

    for (final line in environment.lines) {
      final normalizedHost = _normalizeSipHost(line.host, line.transport);
      final account = SipAccountInfo(
        accId: nextPlaceholderId,
        username: line.username,
        password: line.password,
        host: normalizedHost,
        transport: line.transport,
        registrationStatus: line.registrationEnabled ? null : 0,
        registrationStatusText: line.registrationEnabled ? '恢复中' : '已暂停',
        registrationExpires: line.registrationEnabled ? null : 0,
        registrationEnabled: line.registrationEnabled,
        registrationActionInProgress: line.registrationEnabled,
      );
      accounts[account.accId] = account;
      if (environment.defaultLineKey ==
          _lineKey(account.username, account.host)) {
        defaultAccountId = account.accId;
      }
      nextPlaceholderId--;
    }

    final defaultAccount = defaultAccountId == null
        ? null
        : accounts[defaultAccountId];
    _uiState = _uiState.copyWith(
      accounts: accounts,
      defaultAccountId: defaultAccountId,
      accId: defaultAccount?.accId ?? -1,
      host: defaultAccount?.host ?? '',
      seatEnvironmentState: SeatEnvironmentState.restoring,
    );
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
      final tempFile = File('${fallback.path}.tmp');
      await tempFile.writeAsString(value, flush: true);
      if (fallback.existsSync()) {
        await fallback.delete();
      }
      await tempFile.rename(fallback.path);
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

  Map<String, Object?>? _decodeSeatEnvironmentPayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      return decoded is Map ? Map<String, Object?>.from(decoded) : null;
    } on FormatException {
      final repaired = _balancedJsonPrefix(payload);
      if (repaired == null || repaired == payload) rethrow;
      final decoded = jsonDecode(repaired);
      if (decoded is! Map) return null;
      _addLog('⚠️ 坐席环境配置存在尾部脏数据，已自动修复');
      return Map<String, Object?>.from(decoded);
    }
  }

  String? _balancedJsonPrefix(String payload) {
    var depth = 0;
    var inString = false;
    var escaping = false;
    for (var i = 0; i < payload.length; i++) {
      final char = payload.codeUnitAt(i);
      if (inString) {
        if (escaping) {
          escaping = false;
        } else if (char == 0x5C) {
          escaping = true;
        } else if (char == 0x22) {
          inString = false;
        }
        continue;
      }
      if (char == 0x22) {
        inString = true;
      } else if (char == 0x7B || char == 0x5B) {
        depth++;
      } else if (char == 0x7D || char == 0x5D) {
        depth--;
        if (depth == 0) {
          return payload.substring(0, i + 1);
        }
      }
    }
    return null;
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
