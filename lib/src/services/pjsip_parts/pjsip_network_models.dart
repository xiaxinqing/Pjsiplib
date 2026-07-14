part of '../pjsip_service.dart';

/// PJSIP 网络恢复状态。
///
/// 桌面 VoIP 不只关心“有没有网”，还要关心网络变化后 SIP/RTP 是否稳定。
/// 例如 Wi-Fi 切换、VPN 开关、IP 改变时，PJSIP 可能需要执行 IP change 流程。
enum PjsipNetworkState {
  /// 正常空闲，没有网络恢复任务。
  idle,

  /// 当前系统网络不可用。
  offline,

  /// 系统刚恢复网络，等待短暂稳定窗口，避免立刻恢复又遇到二次抖动。
  waitingForStableNetwork,

  /// 正在执行 PJSIP 的网络恢复/IP change 操作。
  recovering,

  /// 网络恢复流程失败，需要用户重试或等待下一次网络变化。
  failed,
}
