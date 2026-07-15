part of '../pjsip_service.dart';

/// 一条坐席可用的 SIP 线路/账号。
///
/// 客服平台里，多账号更像“多线路”而不是多个独立窗口。UI 可以根据
/// registrationStatus 展示线路是否在线，外呼默认使用 defaultAccountId。
class SipAccountInfo {
  final int accId;
  final String username;
  final String host;
  final int? registrationStatus;
  final String registrationStatusText;

  SipAccountInfo({
    required this.accId,
    required this.username,
    required this.host,
    this.registrationStatus,
    this.registrationStatusText = '注册中',
  });

  SipAccountInfo copyWith({
    int? accId,
    String? username,
    String? host,
    Object? registrationStatus = _unset,
    String? registrationStatusText,
  }) {
    return SipAccountInfo(
      accId: accId ?? this.accId,
      username: username ?? this.username,
      host: host ?? this.host,
      registrationStatus: identical(registrationStatus, _unset)
          ? this.registrationStatus
          : registrationStatus as int?,
      registrationStatusText:
          registrationStatusText ?? this.registrationStatusText,
    );
  }

  bool get isRegistered => registrationStatus == 200;

  String get displayName => username;

  String get lineLabel => '$username@$host';
}
