/// 把 SIP 结束状态码转换成客服能直接理解的通话结果文案。
///
/// PJSIP 原始状态码偏协议层，比如 403/603 在不同 PBX 上含义会有差异。
/// 这里集中维护 VPhone 当前服务端的业务规则，避免 UI、Toast、通话记录各写一套。
enum SipReasonDirection { inbound, outbound }

/// 与展示语言无关的通话结束原因。
///
/// 数据层只负责把 SIP 状态和历史原因归一成业务语义；具体文案由 UI 的
/// AppLocalizations 提供，避免切换语言后仍显示归档时的语言。
enum SipCallEndReason {
  callEnded,
  incomingEnded,
  authenticationFailed,
  remoteRejected,
  callRejected,
  invalidNumber,
  noAnswer,
  timeout,
  remoteUnavailable,
  ringingUnanswered,
  remoteBusy,
  canceled,
  unsupportedMedia,
  serviceUnavailable,
  redirected,
  callIncomplete,
  serviceError,
  remoteCannotAnswer,
  notConnected,
  mediaFailed,
  blindTransfer,
}

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
    final label = _legacyDetailLabel(
      detailReason(
        statusCode,
        direction: direction,
        wasConnected: wasConnected,
        reachedRinging: reachedRinging,
      ),
    );
    if (!includeSipCode || statusCode <= 0) return label;
    return '$label（SIP $statusCode）';
  }

  /// 返回与展示语言无关的完整业务原因。
  static SipCallEndReason detailReason(
    int statusCode, {
    required SipReasonDirection? direction,
    required bool wasConnected,
    required bool reachedRinging,
  }) {
    if (wasConnected) return SipCallEndReason.callEnded;

    return switch (statusCode) {
      401 || 407 => SipCallEndReason.authenticationFailed,
      403 =>
        reachedRinging
            ? SipCallEndReason.remoteRejected
            : SipCallEndReason.callRejected,
      404 || 484 || 604 => SipCallEndReason.invalidNumber,
      408 =>
        reachedRinging ? SipCallEndReason.noAnswer : SipCallEndReason.timeout,
      410 || 480 => SipCallEndReason.remoteUnavailable,
      603 =>
        reachedRinging
            ? SipCallEndReason.ringingUnanswered
            : SipCallEndReason.remoteUnavailable,
      486 => SipCallEndReason.remoteBusy,
      487 => SipCallEndReason.canceled,
      488 || 606 => SipCallEndReason.unsupportedMedia,
      503 =>
        reachedRinging
            ? SipCallEndReason.remoteRejected
            : SipCallEndReason.serviceUnavailable,
      500 || 502 || 504 => SipCallEndReason.serviceUnavailable,
      >= 300 && < 400 => SipCallEndReason.redirected,
      >= 400 && < 500 => SipCallEndReason.callIncomplete,
      >= 500 && < 600 => SipCallEndReason.serviceError,
      >= 600 => SipCallEndReason.remoteCannotAnswer,
      _ =>
        direction == SipReasonDirection.inbound
            ? SipCallEndReason.incomingEnded
            : SipCallEndReason.callEnded,
    };
  }

  /// 返回不带 SIP 码的旧版中文文案。
  ///
  /// 电话服务内仍有非 Widget 调用依赖字符串；通话记录 UI 使用 [detailReason]
  /// 后自行本地化。保留此方法可避免扩大本次界面国际化的改动范围。
  static String detailLabel(
    int statusCode, {
    required SipReasonDirection? direction,
    required bool wasConnected,
    required bool reachedRinging,
  }) {
    return _legacyDetailLabel(
      detailReason(
        statusCode,
        direction: direction,
        wasConnected: wasConnected,
        reachedRinging: reachedRinging,
      ),
    );
  }

  /// 返回通话记录列表使用的短标签，优先按 SIP 状态码判断。
  static String shortLabel({
    int? statusCode,
    String? fallbackReason,
    bool reachedRinging = false,
  }) {
    return _legacyShortLabel(
      shortReason(
        statusCode: statusCode,
        fallbackReason: fallbackReason,
        reachedRinging: reachedRinging,
      ),
    );
  }

  /// 返回通话记录列表使用的语言无关短原因。
  static SipCallEndReason shortReason({
    int? statusCode,
    String? fallbackReason,
    bool reachedRinging = false,
  }) {
    final code = statusCode ?? _parseSipStatusCode(fallbackReason);
    if (code != null) {
      return switch (code) {
        401 || 407 => SipCallEndReason.authenticationFailed,
        403 =>
          reachedRinging
              ? SipCallEndReason.remoteRejected
              : SipCallEndReason.notConnected,
        404 || 484 || 604 => SipCallEndReason.invalidNumber,
        408 => SipCallEndReason.noAnswer,
        410 || 480 => SipCallEndReason.notConnected,
        603 =>
          reachedRinging
              ? SipCallEndReason.ringingUnanswered
              : SipCallEndReason.notConnected,
        486 => SipCallEndReason.remoteBusy,
        487 => SipCallEndReason.canceled,
        488 || 606 => SipCallEndReason.mediaFailed,
        503 =>
          reachedRinging
              ? SipCallEndReason.remoteRejected
              : SipCallEndReason.serviceError,
        500 || 502 || 504 => SipCallEndReason.serviceError,
        >= 300 && < 400 => SipCallEndReason.redirected,
        >= 400 && < 500 => SipCallEndReason.notConnected,
        >= 500 && < 600 => SipCallEndReason.serviceError,
        >= 600 => SipCallEndReason.notConnected,
        _ => SipCallEndReason.notConnected,
      };
    }

    return reasonFromFallback(fallbackReason);
  }

  /// 将旧版本保存的中英文原因收敛成稳定业务语义。
  static SipCallEndReason reasonFromFallback(String? fallbackReason) {
    final reason = fallbackReason?.trim() ?? '';
    if (reason.isEmpty) return SipCallEndReason.notConnected;
    final normalized = reason.toLowerCase();
    if (_containsAny(normalized, const ['盲转', 'blind transfer'])) {
      return SipCallEndReason.blindTransfer;
    }
    if (_containsAny(normalized, const ['拒接', 'forbidden', 'decline'])) {
      return SipCallEndReason.remoteRejected;
    }
    if (_containsAny(normalized, const ['认证', 'auth'])) {
      return SipCallEndReason.authenticationFailed;
    }
    if (_containsAny(normalized, const ['忙', 'busy'])) {
      return SipCallEndReason.remoteBusy;
    }
    if (_containsAny(normalized, const ['超时', 'timeout'])) {
      return SipCallEndReason.noAnswer;
    }
    if (_containsAny(normalized, const ['号码', 'not found'])) {
      return SipCallEndReason.invalidNumber;
    }
    if (_containsAny(normalized, const ['媒体', 'media'])) {
      return SipCallEndReason.mediaFailed;
    }
    if (_containsAny(normalized, const ['取消', 'canceled', 'cancelled'])) {
      return SipCallEndReason.canceled;
    }
    if (_containsAny(normalized, const ['服务', 'service', 'server error'])) {
      return SipCallEndReason.serviceError;
    }
    if (_containsAny(normalized, const ['不可用', '无法接通', 'unavailable'])) {
      return SipCallEndReason.notConnected;
    }
    return SipCallEndReason.notConnected;
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

  static String _legacyDetailLabel(SipCallEndReason reason) => switch (reason) {
    SipCallEndReason.callEnded => '通话已结束',
    SipCallEndReason.incomingEnded => '来电已结束',
    SipCallEndReason.authenticationFailed => '账号认证失败',
    SipCallEndReason.remoteRejected => '对方已拒接',
    SipCallEndReason.callRejected => '呼叫被拒绝',
    SipCallEndReason.invalidNumber => '号码不存在或无法接通',
    SipCallEndReason.noAnswer => '无人接听',
    SipCallEndReason.timeout => '呼叫超时',
    SipCallEndReason.remoteUnavailable => '对方无法接通',
    SipCallEndReason.ringingUnanswered => '响铃未接',
    SipCallEndReason.remoteBusy => '对方忙线',
    SipCallEndReason.canceled => '呼叫已取消',
    SipCallEndReason.unsupportedMedia => '对方不支持本次通话',
    SipCallEndReason.serviceUnavailable => '电话服务暂时不可用',
    SipCallEndReason.redirected => '呼叫被转移或重定向',
    SipCallEndReason.callIncomplete => '呼叫未完成',
    SipCallEndReason.serviceError => '电话服务异常',
    SipCallEndReason.remoteCannotAnswer => '对方无法接听',
    SipCallEndReason.notConnected => '未接通',
    SipCallEndReason.mediaFailed => '媒体失败',
    SipCallEndReason.blindTransfer => '盲转',
  };

  static String _legacyShortLabel(SipCallEndReason reason) => switch (reason) {
    SipCallEndReason.authenticationFailed => '认证失败',
    SipCallEndReason.remoteRejected => '对方拒接',
    SipCallEndReason.invalidNumber => '号码无效',
    SipCallEndReason.noAnswer => '无人接听',
    SipCallEndReason.ringingUnanswered => '响铃未接',
    SipCallEndReason.remoteBusy => '对方忙线',
    SipCallEndReason.canceled => '已取消',
    SipCallEndReason.mediaFailed || SipCallEndReason.unsupportedMedia => '媒体失败',
    SipCallEndReason.serviceError ||
    SipCallEndReason.serviceUnavailable => '服务异常',
    SipCallEndReason.redirected => '已转移',
    SipCallEndReason.callEnded => '已结束',
    SipCallEndReason.incomingEnded => '来电结束',
    SipCallEndReason.blindTransfer => '已盲转',
    _ => '未接通',
  };
}
