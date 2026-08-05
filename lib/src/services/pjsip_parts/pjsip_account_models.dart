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

/// TURN 中继连接方式。复杂企业网络或 VPN 下，TLS/443/5349 往往最容易穿透。
enum TurnTransport {
  udp('UDP', 'udp'),
  tcp('TCP', 'tcp'),
  tls('TLS', 'tls');

  const TurnTransport(this.label, this.storageKey);

  final String label;
  final String storageKey;
}

/// 媒体加密方式。
///
/// SIP 传输（UDP/TCP/TLS）只决定信令怎么走；语音 RTP 是否加密由这里决定。
/// PJSIP 当前支持两类 SRTP 密钥交换：
///
/// - DTLS-SRTP：媒体层 DTLS 握手协商密钥，Asterisk `media_encryption=dtls`
///   通常需要这个。
/// - SDES-SRTP：密钥放在 SDP 的 `a=crypto` 中，必须配合 TLS 信令才比较安全。
enum MediaEncryptionMode {
  none('不加密 RTP', 'none'),
  sdesSrtp('SDES-SRTP', 'sdes_srtp'),
  dtlsSrtp('DTLS-SRTP', 'dtls_srtp'),
  optionalDtlsFirst('可选 SRTP，优先 DTLS', 'optional_dtls_first'),
  optionalSdesFirst('可选 SRTP，优先 SDES', 'optional_sdes_first');

  const MediaEncryptionMode(this.label, this.storageKey);

  final String label;
  final String storageKey;

  bool get usesSrtp => this != MediaEncryptionMode.none;

  bool get isOptional =>
      this == MediaEncryptionMode.optionalDtlsFirst ||
      this == MediaEncryptionMode.optionalSdesFirst;

  String get modeSummary {
    return switch (this) {
      MediaEncryptionMode.none => '不加密 RTP',
      MediaEncryptionMode.sdesSrtp => 'SDES-SRTP',
      MediaEncryptionMode.dtlsSrtp => 'DTLS-SRTP',
      MediaEncryptionMode.optionalDtlsFirst => '可选 SRTP',
      MediaEncryptionMode.optionalSdesFirst => '可选 SRTP',
    };
  }
}

class MediaSecurityConfig {
  const MediaSecurityConfig({this.mode = MediaEncryptionMode.none});

  final MediaEncryptionMode mode;

  bool get usesSrtp => mode.usesSrtp;

  MediaSecurityConfig copyWith({MediaEncryptionMode? mode}) {
    return MediaSecurityConfig(mode: mode ?? this.mode);
  }
}

class IceConfig {
  const IceConfig({
    this.enabled = false,
    this.stunEnabled = true,
    this.stunServer = '',
  });

  final bool enabled;
  // STUN 与 ICE 独立控制。关闭 STUN 后，ICE 仍可使用 host 和
  // peer-reflexive candidate 完成媒体协商。
  final bool stunEnabled;
  final String stunServer;

  bool get hasStunServer => stunServer.trim().isNotEmpty;

  IceConfig copyWith({bool? enabled, bool? stunEnabled, String? stunServer}) {
    return IceConfig(
      enabled: enabled ?? this.enabled,
      stunEnabled: stunEnabled ?? this.stunEnabled,
      stunServer: stunServer ?? this.stunServer,
    );
  }
}

class TurnConfig {
  const TurnConfig({
    this.enabled = false,
    this.server = '',
    this.username = '',
    this.password = '',
    this.transport = TurnTransport.udp,
  });

  final bool enabled;
  final String server;
  final String username;
  final String password;
  final TurnTransport transport;

  bool get isUsable => enabled && server.trim().isNotEmpty;

  TurnConfig copyWith({
    bool? enabled,
    String? server,
    String? username,
    String? password,
    TurnTransport? transport,
  }) {
    return TurnConfig(
      enabled: enabled ?? this.enabled,
      server: server ?? this.server,
      username: username ?? this.username,
      password: password ?? this.password,
      transport: transport ?? this.transport,
    );
  }
}

/// 一条坐席可用的 SIP 线路/账号。
///
/// 客服平台里，多账号更像“多线路”而不是多个独立窗口。UI 可以根据
/// registrationStatus 展示线路是否在线，外呼默认使用 defaultAccountId。
class SipAccountInfo {
  final int accId;

  /// 本地线路名称，仅用于 VPhone 自己的界面展示，不会写入 SIP From/Contact。
  final String lineName;
  final String username;

  /// SIP Digest 鉴权用户名。为空时使用 username，适配“线路号”和“认证账号”不同的服务器。
  final String authUsername;

  /// SIP From 显示名称。这个字段可能被服务器转发给对端，和本地线路名称不是一回事。
  final String sipDisplayName;

  /// 账号级 SIP 出站代理。为空时请求直接发往注册服务器。
  final String outboundProxy;
  final String password;
  final String host;
  final SipTransport transport;
  final MediaSecurityConfig mediaSecurity;
  final IceConfig iceConfig;
  final TurnConfig turnConfig;

  /// 账号级 IPv6 开关。
  ///
  /// 这里只控制 PJSIP 是否为这条线路生成 IPv6 的 SIP/媒体地址候选；
  /// 不会修改系统网络。默认关闭可以减少 ICE/SDP 体积，避免 UDP INVITE
  /// 过大导致部分服务器或网络链路收不到请求。
  final bool ipv6Enabled;
  final int? registrationStatus;
  final String registrationStatusText;
  final int? registrationExpires;
  final bool registrationEnabled;
  final bool registrationActionInProgress;

  SipAccountInfo({
    required this.accId,
    this.lineName = '',
    required this.username,
    this.authUsername = '',
    this.sipDisplayName = '',
    this.outboundProxy = '',
    this.password = '',
    required this.host,
    this.transport = SipTransport.udp,
    this.mediaSecurity = const MediaSecurityConfig(),
    this.iceConfig = const IceConfig(),
    this.turnConfig = const TurnConfig(),
    this.ipv6Enabled = false,
    this.registrationStatus,
    this.registrationStatusText = '注册中',
    this.registrationExpires,
    this.registrationEnabled = true,
    this.registrationActionInProgress = false,
  });

  SipAccountInfo copyWith({
    int? accId,
    String? lineName,
    String? username,
    String? authUsername,
    String? sipDisplayName,
    String? outboundProxy,
    String? password,
    String? host,
    SipTransport? transport,
    MediaSecurityConfig? mediaSecurity,
    IceConfig? iceConfig,
    TurnConfig? turnConfig,
    bool? ipv6Enabled,
    Object? registrationStatus = _unset,
    String? registrationStatusText,
    Object? registrationExpires = _unset,
    bool? registrationEnabled,
    bool? registrationActionInProgress,
  }) {
    return SipAccountInfo(
      accId: accId ?? this.accId,
      lineName: lineName ?? this.lineName,
      username: username ?? this.username,
      authUsername: authUsername ?? this.authUsername,
      sipDisplayName: sipDisplayName ?? this.sipDisplayName,
      outboundProxy: outboundProxy ?? this.outboundProxy,
      password: password ?? this.password,
      host: host ?? this.host,
      transport: transport ?? this.transport,
      mediaSecurity: mediaSecurity ?? this.mediaSecurity,
      iceConfig: iceConfig ?? this.iceConfig,
      turnConfig: turnConfig ?? this.turnConfig,
      ipv6Enabled: ipv6Enabled ?? this.ipv6Enabled,
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

  bool get isRestoringPlaceholder => accId < 0;

  String get displayName {
    final name = lineName.trim();
    return name.isEmpty ? username : name;
  }

  String get effectiveAuthUsername {
    final authName = authUsername.trim();
    return authName.isEmpty ? username : authName;
  }

  String get lineLabel => '$username@$host';

  String get transportLabel => transport.label;
}
