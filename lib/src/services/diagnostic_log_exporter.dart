import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../app_identity.dart';

/// 把应用事件日志与 PJSIP 原生日志整理为一个可发送的文本文件。
///
/// 文件保存位置由系统原生窗口选择。这个类不读取 Riverpod 状态，调用方只传入
/// 已经格式化好的摘要和日志，避免把诊断导出与电话业务状态耦合在一起。
class DiagnosticLogExporter {
  const DiagnosticLogExporter._();

  /// 导出诊断日志。用户取消系统保存窗口时返回 `null`。
  static Future<String?> export({
    required List<String> uiLogLines,
    required String nativeLogFilePath,
    required Map<String, String> runtimeSummary,
  }) async {
    final exportedAt = DateTime.now();
    final fileName =
        'VPhone-diagnostics-${DateFormat('yyyyMMdd-HHmmss').format(exportedAt)}.txt';
    final location = await getSaveLocation(
      suggestedName: fileName,
      acceptedTypeGroups: const <XTypeGroup>[
        XTypeGroup(
          label: '文本日志',
          extensions: <String>['txt'],
          mimeTypes: <String>['text/plain'],
          uniformTypeIdentifiers: <String>['public.plain-text'],
        ),
      ],
    );
    if (location == null) return null;

    final packageInfo = await PackageInfo.fromPlatform();
    final nativeLog = await _readNativeLog(nativeLogFilePath);
    final content = _composeContent(
      exportedAt: exportedAt,
      packageInfo: packageInfo,
      runtimeSummary: runtimeSummary,
      uiLogLines: uiLogLines,
      nativeLogFilePath: nativeLogFilePath,
      nativeLog: nativeLog,
    );
    final file = XFile.fromData(
      Uint8List.fromList(utf8.encode(content)),
      mimeType: 'text/plain',
      name: fileName,
    );
    await file.saveTo(location.path);
    return location.path;
  }

  /// PJSIP 可能仍在追加文件，读取失败时把原因写进导出文件，不让整个导出失败。
  static Future<String> _readNativeLog(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        return '[PJSIP 原生日志文件不存在]';
      }
      return await file.readAsString();
    } catch (error) {
      return '[读取 PJSIP 原生日志失败: $error]';
    }
  }

  static String _composeContent({
    required DateTime exportedAt,
    required PackageInfo packageInfo,
    required Map<String, String> runtimeSummary,
    required List<String> uiLogLines,
    required String nativeLogFilePath,
    required String nativeLog,
  }) {
    final buffer = StringBuffer()
      ..writeln('$appDisplayName 诊断日志')
      ..writeln('导出时间: ${exportedAt.toIso8601String()}')
      ..writeln('应用版本: ${packageInfo.version}+${packageInfo.buildNumber}')
      ..writeln('操作系统: ${Platform.operatingSystem}')
      ..writeln('系统版本: ${Platform.operatingSystemVersion}')
      ..writeln('提示: 日志可能包含电话号码、服务器地址和网络信息，请仅发送给可信人员。')
      ..writeln();

    buffer.writeln('===== 运行状态 =====');
    for (final entry in runtimeSummary.entries) {
      buffer.writeln('${entry.key}: ${entry.value}');
    }

    buffer
      ..writeln()
      ..writeln('===== 应用事件日志（最近 ${uiLogLines.length} 条）=====');
    if (uiLogLines.isEmpty) {
      buffer.writeln('[暂无应用事件日志]');
    } else {
      for (final line in uiLogLines) {
        buffer.writeln(line);
      }
    }

    buffer
      ..writeln()
      ..writeln('===== PJSIP 原生日志 =====')
      ..writeln('原文件: $nativeLogFilePath')
      ..writeln(nativeLog.trimRight())
      ..writeln();
    return buffer.toString();
  }
}
