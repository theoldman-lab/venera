import 'package:flutter/material.dart';

/// E-Ink 屏幕刷新覆盖层组件
///
/// 用于在墨水屏设备上翻页时提供屏幕刷新效果
/// 通过全屏颜色闪烁来模拟墨水屏刷新
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

  /// 动画持续时间（毫秒）
  final int duration;

  /// 动画完成回调
  final VoidCallback? onAnimationComplete;

  @override
  State<EinkRefreshOverlay> createState() => _EinkRefreshOverlayState();
}

class _EinkRefreshOverlayState extends State<EinkRefreshOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    // 动画分为两个阶段：淡入和淡出
    // 每个阶段占用总时间的一半
    final halfDuration = Duration(milliseconds: widget.duration ~/ 2);

    _controller = AnimationController(
      duration: halfDuration,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // 启动动画序列：淡入 -> 淡出
    _controller.forward().then((_) {
      if (!mounted) return;
      _controller.reverse().then((_) {
        if (!mounted) return;
        widget.onAnimationComplete?.call();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 AnimatedBuilder 确保动画值变化时正确重建
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            color: widget.color,
          ),
        );
      },
    );
  }
}
