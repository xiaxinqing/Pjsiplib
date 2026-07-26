part of '../../../../main.dart';

/// 拨号输入格式化器：只允许电话键盘相关字符进入输入框。
class _DialpadNumberInputFormatter extends TextInputFormatter {
  const _DialpadNumberInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = _sanitizeDialpadNumber(newValue.text);
    if (cleaned == newValue.text) return newValue;

    final selectionOffset = _cleanedDialpadSelectionOffset(
      newValue.text,
      newValue.selection.extentOffset,
      cleaned.length,
    );
    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }
}

/// 拨号联系人匹配结果：记录命中的联系人、号码字段和匹配类型。
class _DialpadContactMatch {
  const _DialpadContactMatch({
    required this.contact,
    required this.phone,
    required this.exact,
  });

  final ContactEntry contact;
  final ContactPhoneEntry phone;
  final bool exact;
}

/// 拨号可用状态文案：封装右侧空状态的标题和说明。
class _DialpadAvailabilityStatus {
  const _DialpadAvailabilityStatus(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

bool _isDialpadFeedbackKey(String value) {
  return value.length == 1 && '0123456789*#'.contains(value);
}

String _sanitizeDialpadNumber(String input) {
  var value = input.trim();
  final uriMatch = RegExp(
    r'(?:sip|sips|tel):([^@;>\s]+)',
    caseSensitive: false,
  ).firstMatch(value);
  if (uriMatch != null) value = uriMatch.group(1) ?? value;

  final buffer = StringBuffer();
  for (var index = 0; index < value.length; index++) {
    final char = value[index];
    if ('0123456789*#'.contains(char)) {
      buffer.write(char);
      continue;
    }
    if (_isPlusChar(char)) {
      buffer.write('+');
      continue;
    }
  }
  return buffer.toString();
}

bool _isPlusChar(String value) {
  return value == '+' || value == '＋' || value == '﹢' || value == '➕';
}

int _cleanedDialpadSelectionOffset(
  String value,
  int rawOffset,
  int cleanedLength,
) {
  final safeOffset = math.max(0, math.min(rawOffset, value.length));
  final prefix = value.substring(0, safeOffset);
  final offset = _sanitizeDialpadNumber(prefix).length;
  return math.min(offset, cleanedLength);
}
