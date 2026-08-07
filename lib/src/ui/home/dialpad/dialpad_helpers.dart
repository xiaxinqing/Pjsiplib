part of '../../../../main.dart';

/// 拨号辅助逻辑：负责可拨状态、号码清洗后的输入反馈和发起呼叫。
extension _DialpadHelpers on _MyHomePageState {
  _DialpadAvailabilityStatus _dialpadAvailabilityStatus(
    PjsipUIState uiState,
    SipAccountInfo? account,
    bool canCall,
  ) {
    final l10n = context.l10n;
    if (!uiState.isNetworkAvailable) {
      return _DialpadAvailabilityStatus(
        l10n.statusNetworkUnavailable,
        l10n.dialNetworkUnavailableDescription,
      );
    }
    if (uiState.accounts.isEmpty) {
      return _DialpadAvailabilityStatus(
        l10n.dialNoLinesAdded,
        l10n.dialNoLinesDescription,
      );
    }
    if (account?.isRegistered != true) {
      return _DialpadAvailabilityStatus(
        l10n.dialNoAvailableOutgoing,
        l10n.dialNoOutgoingDescription,
      );
    }
    if (uiState.hasConference) {
      return _DialpadAvailabilityStatus(
        l10n.dialConferenceActive,
        l10n.dialConferenceActiveDescription,
      );
    }
    if (uiState.calls.length >= 4) {
      return _DialpadAvailabilityStatus(
        l10n.dialCapacityReached,
        l10n.dialCapacityDescription(4),
      );
    }
    if (canCall) {
      return _DialpadAvailabilityStatus(
        l10n.dialReady,
        l10n.dialReadyDescription,
      );
    }
    return _DialpadAvailabilityStatus(
      l10n.dialUnavailable,
      l10n.dialUnavailableDescription,
    );
  }

  String? _dialpadCallUnavailableReason(
    PjsipUIState uiState,
    SipAccountInfo? account,
    String number,
  ) {
    final l10n = context.l10n;
    if (number.isEmpty) return l10n.dialEnterNumberToCall;
    if (!uiState.isNetworkAvailable) return l10n.statusNetworkUnavailable;
    if (uiState.accounts.isEmpty) return l10n.dialAddLineFirst;
    if (account?.isRegistered != true) return l10n.dialNoAvailableLine;
    if (uiState.hasConference) return l10n.dialUnavailableDuringConference;
    if (uiState.calls.length >= 4) return l10n.dialCapacityReached;
    return null;
  }

  _DialpadContactMatch? _dialpadContactMatch(String number) {
    final normalizedInput = normalizeContactPhoneNumber(number);
    if (normalizedInput.isEmpty) return null;

    final contacts = ref.watch(contactBookProvider).contacts;
    _DialpadContactMatch? suffixMatch;
    for (final contact in contacts) {
      for (final phone in contact.phoneEntries) {
        final normalizedPhone = normalizeContactPhoneNumber(phone.number);
        if (normalizedPhone.isEmpty) continue;
        if (normalizedPhone == normalizedInput) {
          return _DialpadContactMatch(
            contact: contact,
            phone: phone,
            exact: true,
          );
        }
        if (suffixMatch == null &&
            normalizedInput.length >= 4 &&
            normalizedPhone.endsWith(normalizedInput)) {
          suffixMatch = _DialpadContactMatch(
            contact: contact,
            phone: phone,
            exact: false,
          );
        }
      }
    }
    return suffixMatch;
  }

  void _handleNumberControllerChanged() {
    if (_normalizingDialpadNumber) return;

    final value = _numberController.value;
    final cleaned = _sanitizeDialpadNumber(value.text);
    var current = value.text;
    if (cleaned != value.text) {
      final selectionOffset = _cleanedDialpadSelectionOffset(
        value.text,
        value.selection.extentOffset,
        cleaned.length,
      );
      _normalizingDialpadNumber = true;
      _numberController.value = TextEditingValue(
        text: cleaned,
        selection: TextSelection.collapsed(offset: selectionOffset),
      );
      _normalizingDialpadNumber = false;
      current = cleaned;
    }

    final feedbackKey = _latestInsertedDialpadKey(_lastDialpadValue, current);
    _lastDialpadValue = current;
    if (feedbackKey != null) {
      _flashDialpadKey(feedbackKey);
      if (_section == _WorkspaceSection.dialpad) {
        ref
            .read(pjsipServiceProvider.notifier)
            .playDialpadKeySound(feedbackKey);
      }
    }
  }

  void _insertDialpadKey(String key) {
    final value = _numberController.text;
    final selection = _numberController.selection;
    final start = selection.start < 0 ? value.length : selection.start;
    final end = selection.end < 0 ? value.length : selection.end;
    _numberController.value = TextEditingValue(
      text: value.replaceRange(start, end, key),
      selection: TextSelection.collapsed(offset: start + key.length),
    );
  }

  void _clearDialpadNumber() {
    _numberFocusNode.requestFocus();
    _numberController.clear();
  }

  String? _latestInsertedDialpadKey(String before, String after) {
    if (before == after) return null;

    var prefix = 0;
    while (prefix < before.length &&
        prefix < after.length &&
        before.codeUnitAt(prefix) == after.codeUnitAt(prefix)) {
      prefix++;
    }

    var beforeEnd = before.length;
    var afterEnd = after.length;
    while (beforeEnd > prefix &&
        afterEnd > prefix &&
        before.codeUnitAt(beforeEnd - 1) == after.codeUnitAt(afterEnd - 1)) {
      beforeEnd--;
      afterEnd--;
    }

    final inserted = after.substring(prefix, afterEnd);
    for (var index = inserted.length - 1; index >= 0; index--) {
      final key = inserted[index];
      if (_isDialpadFeedbackKey(key)) return key;
    }
    return null;
  }

  void _flashDialpadKey(String key) {
    if (!_isDialpadFeedbackKey(key)) return;
    _dialpadKeyFeedbackTimer?.cancel();
    _setActiveDialpadKey(key);
    _dialpadKeyFeedbackTimer = Timer(const Duration(milliseconds: 140), () {
      _setActiveDialpadKey(null);
    });
  }

  void _callNumberIfPossible(
    bool canCall,
    PjsipService service,
    int? accountId,
  ) {
    final number = _numberController.text.trim();
    if (!canCall || number.isEmpty) return;
    service.makeCallFromAccount(number, accountId);
    _selectSection(_WorkspaceSection.calls);
  }
}
