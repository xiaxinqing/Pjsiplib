part of '../pjsip_service.dart';

/// UI 日志模型。
///
/// 服务层每发生一个关键动作都会写入一条日志，例如注册、来电、音频设备切换。
/// `debugPrint` 面向开发控制台，`PjsipLog` 面向页面上的日志列表。
class PjsipLog {
  /// 展示给用户/开发者看的日志内容。
  final String message;

  /// 日志创建时间。这里在构造时生成，避免 UI 层重复补时间。
  final DateTime time;

  PjsipLog(this.message) : time = DateTime.now();
}
