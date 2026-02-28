import 'package:flutter/material.dart';

/// Widget nền chấm bi dùng cho các màn hình không có nội dung cuộn
/// (Login, Splash, Onboarding...).
///
/// Sử dụng:
/// ```dart
/// Stack(
///   children: [
///     const DotPatternBackground(),
///     // ... nội dung chính
///   ],
/// )
/// ```
class DotPatternBackground extends StatelessWidget {
  const DotPatternBackground({
    super.key,
    this.color,
    this.opacity,
    this.spacing = 24.0,
    this.dotRadius = 1.0,
  });

  /// Màu chấm. Mặc định tự chọn theo theme (light/dark).
  final Color? color;

  /// Độ mờ. Mặc định tự chọn theo theme.
  final double? opacity;

  final double spacing;
  final double dotRadius;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color dotColor = color ??
        (isDark ? const Color(0xFF44403C) : const Color(0xFFFDBA74));
    final double dotOpacity = opacity ?? (isDark ? 0.10 : 0.20);

    return Positioned.fill(
      child: CustomPaint(
        painter: _DotPatternPainter(
          color: dotColor,
          opacity: dotOpacity,
          spacing: spacing,
          dotRadius: dotRadius,
        ),
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  const _DotPatternPainter({
    required this.color,
    required this.opacity,
    required this.spacing,
    required this.dotRadius,
  });

  final Color color;
  final double opacity;
  final double spacing;
  final double dotRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPatternPainter old) =>
      old.color != color ||
      old.opacity != opacity ||
      old.spacing != spacing ||
      old.dotRadius != dotRadius;
}
