import 'dart:math';

import 'package:flutter/material.dart';
import 'package:venera/components/components.dart';
import 'package:venera/foundation/log.dart';
import 'package:venera/utils/translations.dart';
import 'io.dart';

/// Abstract strategy for renaming comic page files.
///
/// Implement this interface to provide custom rename logic.
/// Register with [RenameStrategyRegistry.register] to make it available in the UI.
abstract class RenameStrategy {
  const RenameStrategy();
  /// User-facing name shown in the strategy selector.
  String get name;

  /// User-facing description shown as hint text.
  String get description;

  /// Generate a new filename (with extension) from the original filename.
  ///
  /// Return `null` to keep the original name unchanged.
  /// [contextFiles] provides the full list of filenames in the same directory
  /// (already filtered to images and sorted), for strategies that need global
  /// context such as sequential numbering.
  String? generateNewName(String originalFileName, {List<String>? contextFiles});

  /// Whether this strategy actually modifies filenames.
  bool get isNoOp => false;

  /// Equality based on runtimeType and name (strategies of same type/name are equal).
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RenameStrategy &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => Object.hash(runtimeType, name);
}

// =============================================================================
// Built-in Strategies
// =============================================================================

/// Keep original filenames — no rename.
class NoRenameStrategy extends RenameStrategy {
  const NoRenameStrategy();

  @override
  String get name => 'Keep Original';

  @override
  String get description => 'Do not rename files';

  @override
  String? generateNewName(String originalFileName, {List<String>? contextFiles}) => null;

  @override
  bool get isNoOp => true;
}

/// Extract the first contiguous number from the filename and zero-pad it.
///
/// Example: `abc123def.jpg` → `0123.jpg`
class ExtractNumberRenameStrategy extends RenameStrategy {
  /// Number of digits to pad to (default 4).
  final int padWidth;

  const ExtractNumberRenameStrategy({this.padWidth = 4});

  @override
  String get name => 'Extract Number';

  @override
  String get description => 'Extract first number, zero-pad to $padWidth digits';

  @override
  String? generateNewName(String originalFileName, {List<String>? contextFiles}) {
    final dotIndex = originalFileName.lastIndexOf('.');
    final stem = dotIndex > 0 ? originalFileName.substring(0, dotIndex) : originalFileName;
    final ext = dotIndex > 0 ? originalFileName.substring(dotIndex) : '';

    final match = RegExp(r'\d+').firstMatch(stem);
    if (match == null) return null;

    final num = int.tryParse(match.group(0)!);
    if (num == null) return null;

    return '${num.toString().padLeft(padWidth, '0')}$ext';
  }
}

/// Rename files sequentially by their current sort order.
///
/// Files are sorted by name, then renamed as `0001.ext`, `0002.ext`, etc.
class SequentialRenameStrategy extends RenameStrategy {
  /// Number of digits to pad to (default 4).
  final int padWidth;

  const SequentialRenameStrategy({this.padWidth = 4});

  @override
  String get name => 'Sequential';

  @override
  String get description => 'Rename as 0001, 0002, ... by current sort order';

  @override
  String? generateNewName(String originalFileName, {List<String>? contextFiles}) => null;
}

// =============================================================================
// Strategy Registry
// =============================================================================

/// Registry for custom rename strategies.
///
/// Register custom strategies via [register] to make them appear in the
/// import preview dialog's strategy selector.
class RenameStrategyRegistry {
  static final List<RenameStrategy> _customStrategies = [];

  /// All registered strategies (built-in + custom).
  static List<RenameStrategy> get all => [
        const NoRenameStrategy(),
        const ExtractNumberRenameStrategy(),
        const SequentialRenameStrategy(),
        ..._customStrategies,
      ];

  /// Register a custom strategy.
  static void register(RenameStrategy strategy) => _customStrategies.add(strategy);

  /// Unregister a previously registered custom strategy.
  static void unregister(RenameStrategy strategy) => _customStrategies.remove(strategy);
}

// =============================================================================
// Data Model
// =============================================================================

/// Preview item showing what will happen to a file during rename.
class RenamePreviewItem {
  final String originalName;
  final String newName;
  final bool willRename;

  const RenamePreviewItem({
    required this.originalName,
    required this.newName,
    required this.willRename,
  });
}

// =============================================================================
// File Renamer Utility
// =============================================================================

/// Utility for scanning directories, generating rename previews, and executing renames.
class FileRenamer {
  static const _imageExtensions = [
    'jpg', 'jpeg', 'png', 'webp', 'gif', 'jpe', 'bmp', 'tiff',
  ];

  /// Check if [name] has a supported image extension.
  static bool isImageFile(String name) {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex < 0) return false;
    return _imageExtensions.contains(name.substring(dotIndex + 1).toLowerCase());
  }

  /// Generate a preview of rename results for the given files and strategy.
  ///
  /// Only image files are considered. Non-image files are ignored.
  static List<RenamePreviewItem> preview(List<String> fileNames, RenameStrategy strategy) {
    final imageFiles = fileNames.where(isImageFile).toList()..sort();

    if (imageFiles.isEmpty) return [];

    if (strategy is SequentialRenameStrategy) {
      return List.generate(imageFiles.length, (i) {
        final ext = imageFiles[i].substring(imageFiles[i].lastIndexOf('.'));
        final newName = '${(i + 1).toString().padLeft(strategy.padWidth, '0')}$ext';
        return RenamePreviewItem(
          originalName: imageFiles[i],
          newName: newName,
          willRename: imageFiles[i] != newName,
        );
      });
    }

    return imageFiles.map((name) {
      final newName = strategy.generateNewName(name, contextFiles: imageFiles) ?? name;
      return RenamePreviewItem(
        originalName: name,
        newName: newName,
        willRename: name != newName,
      );
    }).toList();
  }

  /// Check for conflicts: multiple original files mapping to the same new name.
  ///
  /// Returns a map of conflicting new name → list of original names.
  static Map<String, List<String>> findConflicts(List<RenamePreviewItem> items) {
    final seen = <String, String>{};
    final conflicts = <String, List<String>>{};

    for (final item in items) {
      if (!item.willRename) continue;
      if (seen.containsKey(item.newName)) {
        conflicts.putIfAbsent(item.newName, () => [seen[item.newName]!]);
        conflicts[item.newName]!.add(item.originalName);
      } else {
        seen[item.newName] = item.originalName;
      }
    }

    return conflicts;
  }

  /// Execute rename on the filesystem for the given preview items in [dir].
  ///
  /// Returns the number of files that were successfully renamed.
  /// Skips items where [RenamePreviewItem.willRename] is false.
  /// Skips if the target file already exists (prevents accidental overwrite).
  static Future<int> execute(Directory dir, List<RenamePreviewItem> previews) async {
    var renamed = 0;
    for (final item in previews) {
      if (!item.willRename) continue;

      final oldFile = File('${dir.path}/${item.originalName}');
      final newFile = File('${dir.path}/${item.newName}');

      if (!await oldFile.exists()) continue;
      if (await newFile.exists()) continue;

      try {
        await oldFile.rename(newFile.path);
        renamed++;
      } catch (_) {
        // File rename failed (e.g. permission denied) — skip and continue
      }
    }
    return renamed;
  }

  /// Scan a directory for its comic file structure.
  ///
  /// Returns a map where:
  /// - key `''` (empty string) → root-level image files (no-chapter mode)
  /// - key = chapter directory name → image files within that chapter
  ///
  /// All file lists are sorted.
  static Future<Map<String, List<String>>> scanDirectory(Directory dir) async {
    final result = <String, List<String>>{};

    await for (final entry in dir.list()) {
      if (entry is File && isImageFile(entry.name)) {
        result.putIfAbsent('', () => []).add(entry.name);
      } else if (entry is Directory) {
        final files = <String>[];
        await for (final file in entry.list()) {
          if (file is File && isImageFile(file.name)) {
            files.add(file.name);
          }
        }
        if (files.isNotEmpty) {
          files.sort();
          result[entry.name] = files;
        }
      }
    }

    result['']?.sort();
    return result;
  }
}

// =============================================================================
// Preview Dialog
// =============================================================================

/// Show a dialog that previews file ordering and lets the user choose a rename
/// strategy before importing a comic.
///
/// [directory] is the comic directory to scan.
/// [initialStrategy] pre-selects a strategy (defaults to the first in registry).
/// [comicName] is shown as a subtitle (typically the directory name).
///
/// Returns the chosen [RenameStrategy], or `null` if the user cancelled.
/// Returns [NoRenameStrategy] if no image files are found (still allows import).
Future<RenameStrategy?> showRenamePreviewDialog(
  BuildContext context,
  Directory directory, {
  RenameStrategy? initialStrategy,
  String? comicName,
}) async {
  final scanResult = await FileRenamer.scanDirectory(directory);
  final hasImages = scanResult.values.any((f) => f.isNotEmpty);

  Log.info("Import Comic",
      "Rename preview: dir='$comicName', chapters=${scanResult.length}, hasImages=$hasImages");

  if (!hasImages) {
    Log.info("Import Comic", "Rename preview skipped: no image files found in directory");
    return const NoRenameStrategy();
  }

  Log.info("Import Comic", "Showing rename preview dialog with ${scanResult.values.fold<int>(0, (s, l) => s + l.length)} image files");

  return showDialog<RenameStrategy>(
    context: context,
    builder: (ctx) {
      var selected = initialStrategy ?? RenameStrategyRegistry.all.first;

      return StatefulBuilder(
        builder: (ctx, setState) {
          final allPreviews = <String, List<RenamePreviewItem>>{};
          for (final e in scanResult.entries) {
            allPreviews[e.key] = FileRenamer.preview(e.value, selected);
          }

          final totalFiles = allPreviews.values.fold<int>(0, (s, l) => s + l.length);
          final willRenameCount =
              allPreviews.values.fold<int>(0, (s, l) => s + l.where((i) => i.willRename).length);

          final conflicts = <String, List<String>>{};
          for (final l in allPreviews.values) {
            conflicts.addAll(FileRenamer.findConflicts(l));
          }

          return ContentDialog(
            title: 'Import Preview'.tl,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (comicName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      comicName,
                      style: Theme.of(ctx).textTheme.titleMedium,
                    ),
                  ),
                Text(
                  '@total image files, @willRename will be renamed'
                      .tlParams({'total': totalFiles.toString(), 'willRename': willRenameCount.toString()}),
                ),
                if (conflicts.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Warning: @count naming conflicts detected'
                        .tlParams({'count': conflicts.length.toString()}),
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  height: min(totalFiles * 26.0 + 48, 320),
                  child: _buildFileListView(allPreviews),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('${'Strategy'.tl}: '),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<RenameStrategy>(
                        isExpanded: true,
                        value: selected,
                        items: RenameStrategyRegistry.all
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.name, overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (s) {
                          if (s != null) setState(() => selected = s);
                        },
                        underline: const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
                if (!selected.isNoOp)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      selected.description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: Text('Cancel'.tl),
              ),
              FilledButton(
                onPressed: conflicts.isNotEmpty
                    ? null
                    : () => Navigator.pop(ctx, selected),
                child: Text('Import'.tl),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Build the scrollable file list for the preview dialog.
Widget _buildFileListView(Map<String, List<RenamePreviewItem>> allPreviews) {
  final flatItems = <_DisplayEntry>[];

  for (final entry in allPreviews.entries) {
    if (entry.value.isEmpty) continue;

    if (entry.key.isNotEmpty) {
      flatItems.add(_ChapterHeader(entry.key));
    }

    final truncated = _truncateForDisplay(entry.value);
    for (final item in truncated) {
      flatItems.add(item);
    }
  }

  return ListView.builder(
    itemCount: flatItems.length,
    itemBuilder: (ctx, index) {
      final item = flatItems[index];
      if (item is _ChapterHeader) {
        return Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 2, left: 4),
          child: Text(
            '\u{1F4C1} ${item.name}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        );
      }
      if (item is _EllipsisEntry) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Text('  ...', style: TextStyle(color: Colors.grey)),
        );
      }
      if (item is _FileEntry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.originalName,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.willRename) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('\u2192', style: TextStyle(color: Colors.orange, fontSize: 12)),
                ),
                Flexible(
                  child: Text(
                    item.newName,
                    style: const TextStyle(color: Colors.orange, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    },
  );
}

/// Truncate a preview list for display: show first 8 + last 3 if length > 14.
List<_DisplayEntry> _truncateForDisplay(List<RenamePreviewItem> items) {
  if (items.length <= 14) {
    return items.map((i) => _FileEntry(i.originalName, i.newName, i.willRename)).toList();
  }
  return [
    ...items.take(8).map((i) => _FileEntry(i.originalName, i.newName, i.willRename)),
    _EllipsisEntry(),
    ...items.skip(items.length - 3).map((i) => _FileEntry(i.originalName, i.newName, i.willRename)),
  ];
}

// ---- Internal display entry types ----

sealed class _DisplayEntry {}

class _ChapterHeader extends _DisplayEntry {
  final String name;
  _ChapterHeader(this.name);
}

class _FileEntry extends _DisplayEntry {
  final String originalName;
  final String newName;
  final bool willRename;
  _FileEntry(this.originalName, this.newName, this.willRename);
}

class _EllipsisEntry extends _DisplayEntry {}
