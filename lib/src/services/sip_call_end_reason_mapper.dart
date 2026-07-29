/// 把 SIP 结束状态码转换成客服能直接理解的通话结果文案。
///
/// PJSIP 原始状态码偏协议层，比如 403/603 在不同 PBX 上含义会有差异。
/// 这里集中维护 VPhone 当前服务端的业务规则，避免 UI、Toast、通话记录各写一套。
enum SipReasonDirection { inbound, outbound }

class SipCallEndReasonMapper {
  const SipCallEndReasonMapper._();

  /// 返回右侧详情、Toast 使用的完整文案。
  static String detailText(
    int statusCode, {
    required SipReasonDirection? direction,
    required bool wasConnected,
    required bool reachedRinging,
    bool includeSipCode = false,
  }) {
    final label = detailLabel(
      statusCode,
      direction: direction,
      wasConnected: wasConnected,
      reachedRinging: reachedRinging,
    );
    if (!includeSipCode || statusCode <= 0) return label;
    return '$label（SIP $statusCode）';
  }

  /// 返回不带 SIP 码的完整业务文案。
  static String detailLabel(
    int statusCode, {
    required SipReasonDirection? direction,
    required bool wasConnected,
    required bool reachedRinging,
  }) {
    if (wasConnected) return '通话已结束';

    return switch (statusCode) {
      // Digest 鉴权挑战正常会继续重发 INVITE；如果最终停在这里才提示账号问题。
      401 || 407 => '账号认证失败',

      // 当前 PBX 在响铃后用 403 + Q.850 cause=21 表示明确拒接。
      // 未响铃的 403 更可能是权限、路由或服务端策略拒绝，不能直接说成对方拒接。
      403 => reachedRinging ? '对方已拒接' : '呼叫被拒绝',

      404 || 484 || 604 => '号码不存在或无法接通',
      408 => reachedRinging ? '无人接听' : '呼叫超时',
      410 || 480 => '对方无法接通',
      // Asterisk 这边响铃一段时间后可能返回 603 + Q.850 cause=16。
      // 这种不能精确判断为人为拒接，用“响铃未接”更贴近客服视角。
      603 => reachedRinging ? '响铃未接' : '对方无法接通',
      486 => '对方忙线',
      487 => '呼叫已取消',
      488 || 606 => '对方不支持本次通话',
      500 || 502 || 503 || 504 => '电话服务暂时不可用',
      >= 300 && < 400 => '呼叫被转移或重定向',
      >= 400 && < 500 => '呼叫未完成',
      >= 500 && < 600 => '电话服务异常',
      >= 600 => '对方无法接听',
      _ => direction == SipReasonDirection.inbound ? '来电已结束' : '通话已结束',
    };
  }

  /// 返回通话记录列表使用的短标签，优先按 SIP 状态码判断。
  static String shortLabel({
    int? statusCode,
    String? fallbackReason,
    bool reachedRinging = false,
  }) {
    final code = statusCode ?? _parseSipStatusCode(fallbackReason);
    if (code != null) {
      return switch (code) {
        401 || 407 => '认证失败',
        403 => reachedRinging ? '对方拒接' : '无法接通',
        404 || 484 || 604 => '号码无效',
        408 => '无人接听',
        410 || 480 => '无法接通',
        603 => reachedRinging ? '响铃未接' : '无法接通',
        486 => '对方忙线',
        487 => '已取消',
        488 || 606 => '媒体失败',
        500 || 502 || 503 || 504 => '服务异常',
        >= 300 && < 400 => '已转移',
        >= 400 && < 500 => '未接通',
        >= 500 && < 600 => '服务异常',
        >= 600 => '无法接通',
        _ => '未接通',
      };
    }

    final reason = fallbackReason?.trim() ?? '';
    if (reason.isEmpty) return '未接通';
    if (_containsAny(reason, const ['拒接', 'Forbidden', 'Decline'])) {
      return '对方拒接';
    }
    if (_containsAny(reason, const ['忙', 'Busy'])) return '对方忙线';
    if (_containsAny(reason, const ['超时', 'Timeout'])) return '无人接听';
    if (_containsAny(reason, const ['号码', 'Not Found'])) return '号码无效';
    if (_containsAny(reason, const ['媒体', 'Media'])) return '媒体失败';
    if (_containsAny(reason, const ['不可用', '无法接通', 'Unavailable'])) {
      return '无法接通';
    }
    return '未接通';
  }

  static int? _parseSipStatusCode(String? reason) {
    if (reason == null || reason.isEmpty) return null;
    final match = RegExp(r'\bSIP\s*(\d{3})\b').firstMatch(reason);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  static bool _containsAny(String value, List<String> patterns) {
    return patterns.any(value.contains);
  }
}
