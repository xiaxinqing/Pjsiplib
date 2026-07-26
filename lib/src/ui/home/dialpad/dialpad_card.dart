part of '../../../../main.dart';

/// 拨号卡：负责号码输入、联系人匹配入口、线路选择、键盘和呼叫按钮。
extension _DialpadCard on _MyHomePageState {
  Widget _buildDialpadCard(
    PjsipUIState uiState,
    PjsipService service,
    bool canCall,
    int? selectedAccountId,
    SipAccountInfo? selectedAccount,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final topInset = constraints.maxHeight < 620 ? 18.0 : 64.0;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(18, topInset, 18, 18),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight > topInset + 18
                    ? constraints.maxHeight - topInset - 18
                    : 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _numberController,
                    focusNode: _numberFocusNode,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                    decoration: InputDecoration(
                      hintText: '输入号码',
                      prefixIcon: const Icon(AppIcons.dialpad),
                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _numberController,
                        builder: (context, value, _) {
                          if (value.text.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return IconButton(
                            tooltip: '清空',
                            onPressed: _clearDialpadNumber,
                            icon: const Icon(AppIcons.clear),
                          );
                        },
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: const [_DialpadNumberInputFormatter()],
                    onSubmitted: (_) => _callNumberIfPossible(
                      canCall,
                      service,
                      selectedAccountId,
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _numberController,
                    builder: (context, value, _) {
                      final match = _dialpadContactMatch(value.text);
                      if (match == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _buildDialpadContactMatch(match),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildOutgoingLineSelector(uiState, service),
                  const SizedBox(height: 14),
                  _buildNumberPad(),
                  const SizedBox(height: 14),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _numberController,
                    builder: (context, value, _) {
                      final number = value.text.trim();
                      final unavailableReason = _dialpadCallUnavailableReason(
                        uiState,
                        selectedAccount,
                        number,
                      );
                      final enabled = unavailableReason == null;
                      return Tooltip(
                        message: enabled ? '发起外呼' : unavailableReason,
                        child: SizedBox(
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: enabled
                                ? () => _callNumberIfPossible(
                                    true,
                                    service,
                                    selectedAccountId,
                                  )
                                : null,
                            icon: const Icon(AppIcons.call),
                            label: Text(unavailableReason ?? '呼叫'),
                            style: FilledButton.styleFrom(
                              backgroundColor: _callGreen,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
