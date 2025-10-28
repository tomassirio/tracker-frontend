import 'package:flutter/material.dart';

/// Wanderer app logo - backpacker silhouette on earth
class WandererLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const WandererLogo({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _WandererLogoPainter(logoColor)),
    );
  }
}

class _WandererLogoPainter extends CustomPainter {
  final Color color;

  _WandererLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04;

    // Draw earth circle (bottom portion)
    final earthRadius = size.width * 0.35;
    final earthCenter = Offset(size.width / 2, size.height * 0.75);

    // Draw earth arc (visible portion)
    final earthRect = Rect.fromCircle(center: earthCenter, radius: earthRadius);
    canvas.drawArc(
      earthRect,
      3.14 * 0.8, // Start angle (slightly left of bottom)
      3.14 * 1.4, // Sweep angle (arc across bottom)
      false,
      strokePaint,
    );

    // Draw latitude/longitude lines on earth
    final thinPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02;

    // Horizontal line
    canvas.drawLine(
      Offset(size.width / 2 - earthRadius * 0.7, size.height * 0.75),
      Offset(size.width / 2 + earthRadius * 0.7, size.height * 0.75),
      thinPaint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.75 - earthRadius * 0.3),
      Offset(size.width / 2, size.height * 0.75 + earthRadius * 0.3),
      thinPaint,
    );

    // Draw backpacker silhouette on top of earth
    final backpackerPath = Path();

    // Scale factors
    final centerX = size.width / 2;
    final baseY = size.height * 0.75 - earthRadius * 0.3;
    final scale = size.width * 0.08;

    // Head
    canvas.drawCircle(Offset(centerX, baseY - scale * 1.5), scale * 0.4, paint);

    // Body
    backpackerPath.moveTo(centerX, baseY - scale);
    backpackerPath.lineTo(centerX, baseY + scale);

    // Backpack (rectangle on back)
    final backpackRect = Rect.fromLTWH(
      centerX + scale * 0.1,
      baseY - scale * 0.8,
      scale * 0.5,
      scale * 1.2,
    );
    canvas.drawRect(backpackRect, paint);

    // Left leg (forward)
    backpackerPath.moveTo(centerX, baseY + scale);
    backpackerPath.lineTo(centerX - scale * 0.3, baseY + scale * 2);

    // Right leg (back)
    backpackerPath.moveTo(centerX, baseY + scale);
    backpackerPath.lineTo(centerX + scale * 0.5, baseY + scale * 1.8);

    // Left arm
    backpackerPath.moveTo(centerX, baseY - scale * 0.3);
    backpackerPath.lineTo(centerX - scale * 0.5, baseY + scale * 0.2);

    // Right arm
    backpackerPath.moveTo(centerX, baseY - scale * 0.3);
    backpackerPath.lineTo(centerX + scale * 0.3, baseY);

    // Walking stick
    backpackerPath.moveTo(centerX - scale * 0.5, baseY + scale * 0.2);
    backpackerPath.lineTo(centerX - scale * 0.7, baseY + scale * 1.5);

    final backpackerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(backpackerPath, backpackerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
