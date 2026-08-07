import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/src/services/sip_call_end_reason_mapper.dart';

void main() {
  group('SIP 通话结束原因语义映射', () {
    test('同一状态码会结合响铃阶段区分拒接和线路失败', () {
      expect(
        SipCallEndReasonMapper.detailReason(
          403,
          direction: SipReasonDirection.outbound,
          wasConnected: false,
          reachedRinging: true,
        ),
        SipCallEndReason.remoteRejected,
      );
      expect(
        SipCallEndReasonMapper.detailReason(
          403,
          direction: SipReasonDirection.outbound,
          wasConnected: false,
          reachedRinging: false,
        ),
        SipCallEndReason.callRejected,
      );
      expect(
        SipCallEndReasonMapper.detailReason(
          503,
          direction: SipReasonDirection.outbound,
          wasConnected: false,
          reachedRinging: false,
        ),
        SipCallEndReason.serviceUnavailable,
      );
    });

    test('已接通的通话优先归类为正常结束', () {
      expect(
        SipCallEndReasonMapper.detailReason(
          486,
          direction: SipReasonDirection.outbound,
          wasConnected: true,
          reachedRinging: true,
        ),
        SipCallEndReason.callEnded,
      );
    });

    test('兼容旧记录中的中英文原因', () {
      expect(
        SipCallEndReasonMapper.reasonFromFallback('对方忙线（SIP 486）'),
        SipCallEndReason.remoteBusy,
      );
      expect(
        SipCallEndReasonMapper.reasonFromFallback('Blind transfer'),
        SipCallEndReason.blindTransfer,
      );
      expect(
        SipCallEndReasonMapper.reasonFromFallback('Service Unavailable'),
        SipCallEndReason.serviceError,
      );
    });

    test('列表原因保持稳定的短语义', () {
      expect(
        SipCallEndReasonMapper.shortReason(
          statusCode: 603,
          reachedRinging: true,
        ),
        SipCallEndReason.ringingUnanswered,
      );
      expect(
        SipCallEndReasonMapper.shortReason(statusCode: 488),
        SipCallEndReason.mediaFailed,
      );
    });
  });
}
