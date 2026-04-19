import 'dart:io';

import 'package:flutter/services.dart';
import 'package:venera/foundation/app.dart';
import 'package:venera/foundation/log.dart';

/// 删除结果
class DeleteResult {
  final String path;
  final bool success;
  final String message;

  DeleteResult({
    required this.path,
    required this.success,
    required this.message,
  });

  @override
  String toString() {
    return 'DeleteResult{path: $path, success: $success, message: $message}';
  }
}

/// 删除服务
/// 
/// 在主 isolate 中执行删除操作，避免在 Isolate 中无法使用 MethodChannel 的问题
/// 专门用于处理 Android 端的文件删除，解决权限问题
class DeleteService {
  static DeleteService? _instance;
  static const MethodChannel _methodChannel = MethodChannel("venera/method_channel");

  DeleteService._();

  factory DeleteService() {
    return _instance ??= DeleteService._();
  }

  /// 删除单个目录
  /// 
  /// 在 Android 端优先使用原生方法删除，解决权限问题
  /// 在其他平台或其他方法失败时使用 Flutter 的 Directory.delete
  Future<DeleteResult> deleteDirectory(Directory dir) async {
    if (!dir.existsSync()) {
      return DeleteResult(
        path: dir.path,
        success: false,
        message: 'Directory does not exist',
      );
    }

    // 在 Android 端使用原生方法删除
    if (App.isAndroid) {
      try {
        final result = await _methodChannel.invokeMethod<bool>('deleteDirectory', {
          'path': dir.path,
        });
        if (result == true) {
          Log.info("DeleteService", "Successfully deleted directory via native: ${dir.path}");
          return DeleteResult(
            path: dir.path,
            success: true,
            message: 'Deleted successfully',
          );
        } else {
          Log.warning("DeleteService", "Native delete returned false: ${dir.path}");
        }
      } catch (e) {
        Log.warning("DeleteService", "Native delete failed, falling back to Flutter: ${dir.path}, error: $e");
      }
    }

    // 回退到 Flutter 方法
    try {
      await dir.delete(recursive: true);
      Log.info("DeleteService", "Successfully deleted directory via Flutter: ${dir.path}");
      return DeleteResult(
        path: dir.path,
        success: true,
        message: 'Deleted successfully via Flutter',
      );
    } catch (e, s) {
      Log.error("DeleteService", "Failed to delete directory: ${dir.path}\n$e", s);
      return DeleteResult(
        path: dir.path,
        success: false,
        message: 'Delete failed: $e',
      );
    }
  }

  /// 批量删除目录
  /// 
  /// 在 Android 端使用原生批量删除方法，提高效率
  Future<List<DeleteResult>> deleteDirectories(List<Directory> directories) async {
    if (directories.isEmpty) {
      return [];
    }

    // 在 Android 端使用原生批量删除
    if (App.isAndroid) {
      try {
        final paths = directories.map((d) => d.path).toList();
        final results = await _methodChannel.invokeMethod<List<dynamic>>('deleteDirectories', {
          'paths': paths,
        });

        if (results != null) {
          final deleteResults = results.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            return DeleteResult(
              path: map['path'] as String,
              success: map['success'] as bool,
              message: map['message'] as String,
            );
          }).toList();

          // 记录日志
          for (final result in deleteResults) {
            if (result.success) {
              Log.info("DeleteService", "Successfully deleted: ${result.path}");
            } else {
              Log.error("DeleteService", "Failed to delete: ${result.path}, reason: ${result.message}");
            }
          }

          // 对于失败的目录，尝试使用 Flutter 方法回退
          final failedDirs = deleteResults
              .where((r) => !r.success)
              .map((r) => Directory(r.path))
              .toList();

          if (failedDirs.isNotEmpty) {
            Log.info("DeleteService", "Retrying ${failedDirs.length} failed directories with Flutter method");
            for (final dir in failedDirs) {
              try {
                if (dir.existsSync()) {
                  await dir.delete(recursive: true);
                  Log.info("DeleteService", "Successfully deleted via Flutter fallback: ${dir.path}");
                }
              } catch (e, s) {
                Log.error("DeleteService", "Fallback delete also failed: ${dir.path}\n$e", s);
              }
            }
          }

          return deleteResults;
        }
      } catch (e, s) {
        Log.error("DeleteService", "Native batch delete failed, falling back to Flutter\n$e", s);
      }
    }

    // 回退到 Flutter 方法
    final results = <DeleteResult>[];
    for (final dir in directories) {
      final result = await deleteDirectory(dir);
      results.add(result);
    }
    return results;
  }

  /// 删除单个目录（同步版本，用于简单场景）
  /// 
  /// 注意：同步方法无法使用原生方法，仅作为备用
  DeleteResult deleteDirectorySync(Directory dir) {
    if (!dir.existsSync()) {
      return DeleteResult(
        path: dir.path,
        success: false,
        message: 'Directory does not exist',
      );
    }

    try {
      dir.deleteSync(recursive: true);
      Log.info("DeleteService", "Successfully deleted directory (sync): ${dir.path}");
      return DeleteResult(
        path: dir.path,
        success: true,
        message: 'Deleted successfully',
      );
    } catch (e, s) {
      Log.error("DeleteService", "Failed to delete directory (sync): ${dir.path}\n$e", s);
      return DeleteResult(
        path: dir.path,
        success: false,
        message: 'Delete failed: $e',
      );
    }
  }
}
