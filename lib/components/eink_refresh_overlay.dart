import 'dart:async';
import 'package:flutter/material.dart';

/// E-Ink 屏幕刷新覆盖层组件
///
/// 用于在墨水屏设备上翻页时提供屏幕刷新效果
/// 通过全屏纯色闪烁来模拟墨水屏刷新（无过渡动画，适合墨水屏特性）
class EinkRefreshOverlay extends StatefulWidget {
  const EinkRefreshOverlay({
    super.key,
    required this.triggerKey,
    required this.color,
    required this.duration,
    this.onAnimationComplete,
  });

  /// 触发标识（用于强制重建 Widget）
  final int triggerKey;

  /// 刷新覆盖层颜色（黑色或白色）
  final Color color;

  /// 停留持续时间（毫秒）
  final int duration;

  /// 完成回调
  final VoidCallback? onAnimationComplete;

  @override
  State<EinkRefreshOverlay> createState() => _EinkRefreshOverlayState();
}

class _EinkRefreshOverlayState extends State<EinkRefreshOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(milliseconds: widget.duration), () {
      if (!mounted) return;
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: widget.color);
  }
}
