import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../app_identity.dart';

class PreparedCallRecordingFile {
  const PreparedCallRecordingFile({
    required this.temporaryFile,
    required this.finalFile,
    required this.temporaryRelativePath,
    required this.finalRelativePath,
  });

  final File temporaryFile;
  final File finalFile;
  final String temporaryRelativePath;
  final String finalRelativePath;
}

class RecoveredCallRecordingFile {
  const RecoveredCallRecordingFile({
    required this.relativePath,
    required this.fileSizeBytes,
    required this.estimatedDuration,
  });

  final String relativePath;
  final int fileSizeBytes;
  final Duration estimatedDuration;
}

/// 管理本地通话录音文件的唯一入口。
///
/// PJSIP 只接触临时 WAV；正常销毁 recorder 后再原子重命名为最终文件，避免历史页
/// 把尚未写完 WAV 头的文件当成可播放录音。数据库只保存相对此根目录的路径。
abstract final class CallRecordingStorage {
  static const String _directoryName = 'recordings';

  static Future<Directory> rootDirectory() async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory(
      p.join(support.path, appStorageDirectoryName, _directoryName),
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  static Future<PreparedCallRecordingFile> prepare({
    required String sessionKey,
    required DateTime startedAt,
    required String directionCode,
    required String localNumber,
    required String remoteNumber,
  }) async {
    final root = await rootDirectory();
    final relativeDirectory = p.join(
      startedAt.year.toString().padLeft(4, '0'),
      startedAt.month.toString().padLeft(2, '0'),
    );
    final directory = Directory(p.join(root.path, relativeDirectory));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final fileStem = buildFileStem(
      sessionKey: sessionKey,
      startedAt: startedAt,
      directionCode: directionCode,
      localNumber: localNumber,
      remoteNumber: remoteNumber,
    );
    final temporaryRelativePath = p.join(
      relativeDirectory,
      '$fileStem.partial.wav',
    );
    final finalRelativePath = p.join(relativeDirectory, '$fileStem.wav');
    final temporaryFile = File(p.join(root.path, temporaryRelativePath));
    final finalFile = File(p.join(root.path, finalRelativePath));
    if (await temporaryFile.exists()) await temporaryFile.delete();
    if (await finalFile.exists()) await finalFile.delete();
    return PreparedCallRecordingFile(
      temporaryFile: temporaryFile,
      finalFile: finalFile,
      temporaryRelativePath: temporaryRelativePath,
      finalRelativePath: finalRelativePath,
    );
  }

  /// 录音文件名仅使用 ASCII，避免 Windows/PJSIP 在非 UTF-8 系统代码页下
  /// 无法创建中文路径。C 后缀是 PJSIP callId，只用于避免并发通话重名。
  static String buildFileStem({
    required String sessionKey,
    required DateTime startedAt,
    required String directionCode,
    required String localNumber,
    required String remoteNumber,
  }) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final timestamp =
        '${startedAt.year.toString().padLeft(4, '0')}'
        '${twoDigits(startedAt.month)}'
        '${twoDigits(startedAt.day)}-'
        '${twoDigits(startedAt.hour)}'
        '${twoDigits(startedAt.minute)}'
        '${twoDigits(startedAt.second)}-'
        '${startedAt.millisecond.toString().padLeft(3, '0')}';
    final safeDirection = directionCode.toUpperCase() == 'IN' ? 'IN' : 'OUT';
    String safeNumber(String value) {
      final sanitized = value
          .trim()
          .replaceAll(RegExp(r'[^A-Za-z0-9+_-]+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');
      return sanitized.isEmpty ? 'unknown' : sanitized;
    }

    final safeLocalNumber = safeNumber(localNumber);
    final safeRemoteNumber = safeNumber(remoteNumber);
    final callPath = safeDirection == 'IN'
        ? '${safeRemoteNumber}_TO_$safeLocalNumber'
        : '${safeLocalNumber}_TO_$safeRemoteNumber';
    final sessionParts = sessionKey.split('-');
    final safeCallId = sessionParts.last.replaceAll(
      RegExp(r'[^A-Za-z0-9_-]'),
      '_',
    );
    return '${timestamp}_${safeDirection}_${callPath}_C$safeCallId';
  }

  static Future<File> finalize(PreparedCallRecordingFile prepared) async {
    if (!await prepared.temporaryFile.exists()) return prepared.finalFile;
    if (await prepared.finalFile.exists()) await prepared.finalFile.delete();
    return prepared.temporaryFile.rename(prepared.finalFile.path);
  }

  static Future<RecoveredCallRecordingFile?> recoverInterrupted(
    String relativePath,
  ) async {
    var finalRelativePath = relativePath;
    var source = await resolve(relativePath);
    if (relativePath.endsWith('.partial.wav')) {
      finalRelativePath = relativePath.replaceFirst(
        RegExp(r'\.partial\.wav$'),
        '.wav',
      );
      final completedFile = await resolve(finalRelativePath);
      if (await source.exists()) {
        if (await completedFile.exists()) await completedFile.delete();
        source = await source.rename(completedFile.path);
      } else if (await completedFile.exists()) {
        // 可能已完成重命名，但在数据库更新前进程退出。
        source = completedFile;
      } else {
        return null;
      }
    }
    if (!await source.exists()) return null;
    final size = await source.length();
    // 当前录音固定为 8kHz / 单声道 / 16-bit PCM，WAV 数据约 16000 bytes/s。
    final audioBytes = size > 44 ? size - 44 : 0;
    return RecoveredCallRecordingFile(
      relativePath: finalRelativePath,
      fileSizeBytes: size,
      estimatedDuration: Duration(milliseconds: audioBytes * 1000 ~/ 16000),
    );
  }

  static Future<File> resolve(String relativePath) async {
    final root = await rootDirectory();
    final normalizedRelativePath = p.normalize(relativePath);
    if (p.isAbsolute(normalizedRelativePath) ||
        normalizedRelativePath == '..' ||
        normalizedRelativePath.startsWith('..${p.separator}')) {
      throw const FileSystemException('Invalid recording path');
    }
    final resolvedPath = p.normalize(p.join(root.path, normalizedRelativePath));
    if (!p.isWithin(root.path, resolvedPath)) {
      throw const FileSystemException('Recording path is outside storage root');
    }
    return File(resolvedPath);
  }

  static Future<bool> exists(String relativePath) async {
    return (await resolve(relativePath)).exists();
  }

  static Future<void> delete(String relativePath) async {
    final file = await resolve(relativePath);
    if (await file.exists()) await file.delete();
  }

  static Future<String?> export(
    String relativePath, {
    required String suggestedName,
  }) async {
    final source = await resolve(relativePath);
    if (!await source.exists()) return null;
    final location = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'WAV 音频',
          extensions: ['wav'],
          mimeTypes: ['audio/wav'],
          uniformTypeIdentifiers: ['com.microsoft.waveform-audio'],
        ),
      ],
    );
    if (location == null) return null;
    await XFile(source.path, mimeType: 'audio/wav').saveTo(location.path);
    return location.path;
  }

  static Future<void> reveal(String relativePath) async {
    final file = await resolve(relativePath);
    if (!await file.exists()) {
      throw const FileSystemException('Recording file does not exist');
    }
    if (Platform.isMacOS) {
      final result = await Process.run('open', ['-R', file.path]);
      if (result.exitCode != 0) {
        throw FileSystemException('Unable to reveal recording', file.path);
      }
      return;
    }
    if (Platform.isWindows) {
      // explorer.exe 通常把命令转交给已有的资源管理器进程，随后可能以 1 退出，
      // 但文件夹仍会正常打开。等待并检查 exitCode 会产生“先报失败、后打开”的
      // 假失败；只要进程成功启动，就认为系统已经接收了打开请求。
      await Process.start('explorer.exe', [
        '/select,',
        file.path,
      ], mode: ProcessStartMode.detached);
      return;
    }
    final result = await Process.run('xdg-open', [file.parent.path]);
    if (result.exitCode != 0) {
      throw FileSystemException('Unable to reveal recording', file.path);
    }
  }
}
