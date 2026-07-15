part of '../pjsip_service.dart';

/// SIP 信令传输方式。
///
/// UDP 是行业里最常见的默认值；TCP 解决部分网络/报文尺寸兼容问题；
/// TLS 基于 TCP，为注册和呼叫信令提供加密。语音媒体加密属于 SRTP，后续单独配置。
enum SipTransport {
  udp('UDP', '标准模式', 'udp', 5060, false),
  tcp('TCP', '兼容模式', 'tcp', 5060, false),
  tls('TLS', '安全模式', 'tls', 5061, true);

  const SipTransport(
    this.label,
    this.description,
    this.uriParam,
    this.defaultPort,
    this.isSecure,
  );

  final String label;
  final String description;
  final String uriParam;
  final int defaultPort;
  final bool isSecure;

  String get displayName => '$description $label';
}

/// 一条坐席可用的 SIP 线路/账号。
///
/// 客服平台里，多账号更像“多线路”而不是多个独立窗口。UI 可以根据
/// registrationStatus 展示线路是否在线，外呼默认使用 defaultAccountId。
class SipAccountInfo {
  final int accId;
  final String username;
  final String host;
  final SipTransport transport;
  final int? registrationStatus;
  final String registrationStatusText;
  final int? registrationExpires;
  final bool registrationEnabled;
  final bool registrationActionInProgress;

  SipAccountInfo({
    required this.accId,
    required this.username,
    required this.host,
    this.transport = SipTransport.udp,
    this.registrationStatus,
    this.registrationStatusText = '注册中',
    this.registrationExpires,
    this.registrationEnabled = true,
    this.registrationActionInProgress = false,
  });

  SipAccountInfo copyWith({
    int? accId,
    String? username,
    String? host,
    SipTransport? transport,
    Object? registrationStatus = _unset,
    String? registrationStatusText,
    Object? registrationExpires = _unset,
    bool? registrationEnabled,
    bool? registrationActionInProgress,
  }) {
    return SipAccountInfo(
      accId: accId ?? this.accId,
      username: username ?? this.username,
      host: host ?? this.host,
      transport: transport ?? this.transport,
      registrationStatus: identical(registrationStatus, _unset)
          ? this.registrationStatus
          : registrationStatus as int?,
      registrationStatusText:
          registrationStatusText ?? this.registrationStatusText,
      registrationExpires: identical(registrationExpires, _unset)
          ? this.registrationExpires
          : registrationExpires as int?,
      registrationEnabled: registrationEnabled ?? this.registrationEnabled,
      registrationActionInProgress:
          registrationActionInProgress ?? this.registrationActionInProgress,
    );
  }

  bool get isRegistered =>
      registrationEnabled &&
      registrationStatus == 200 &&
      registrationExpires != 0;

  String get displayName => username;

  String get lineLabel => '$username@$host';

  String get transportLabel => transport.label;
}
