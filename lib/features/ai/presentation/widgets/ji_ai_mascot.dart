import 'package:flutter/material.dart';

/// Custom Vector Mascot for Ji-AI
/// Matches the reference design:
/// - Rounded white robot head
/// - Dark navy face screen
/// - Two friendly smiling teal eyes
/// - Antenna with circular teal tip
/// - Soft radial blue/teal gradient glow background
/// - 100% Vector, no star or sparkle symbols
class JiAiMascot extends StatelessWidget {
  final double size;

  const JiAiMascot({
    super.key,
    this.size = 190,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _JiAiMascotPainter(),
      ),
    );
  }
}

class _JiAiMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 6;

    // 1. Soft Radial Blue/Teal Glow Background
    final glowRadius = size.width * 0.46;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFBAE6FD).withValues(alpha: 0.55),
          const Color(0xFFCCFBF1).withValues(alpha: 0.35),
          const Color(0xFFE0F2FE).withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.45, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy - 8), radius: glowRadius));

    canvas.drawCircle(Offset(cx, cy - 8), glowRadius, glowPaint);

    // 2. Soft Ground Shadow under head
    final shadowRect = Rect.fromCenter(
      center: Offset(cx, cy + 42),
      width: 100,
      height: 18,
    );
    final shadowPaint = Paint()
      ..color = const Color(0xFF007BFF).withValues(alpha: 0.09)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(shadowRect, shadowPaint);

    // 3. Antenna
    final headTop = cy - 35;
    final antennaStalkPaint = Paint()
      ..color = const Color(0xFF0D9488)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Vertical stalk
    canvas.drawLine(
      Offset(cx, headTop + 2),
      Offset(cx, headTop - 12),
      antennaStalkPaint,
    );

    // Antenna circular teal tip
    final tipCenter = Offset(cx, headTop - 15);
    final tipGlowPaint = Paint()
      ..color = const Color(0xFF14B8A6).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(tipCenter, 7, tipGlowPaint);

    final tipPaint = Paint()
      ..color = const Color(0xFF14B8A6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(tipCenter, 5.5, tipPaint);

    // 4. Robot Head (White with soft drop shadow and crisp border)
    final headRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: 112,
      height: 74,
    );
    final headRRect = RRect.fromRectAndRadius(headRect, const Radius.circular(34));

    // Head elevation shadow
    final headShadowPaint = Paint()
      ..color = const Color(0xFF0A2342).withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawRRect(headRRect.shift(const Offset(0, 6)), headShadowPaint);

    // Head fill
    final headFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(headRRect, headFillPaint);

    // Head border
    final headBorderPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(headRRect, headBorderPaint);

    // 5. Dark Navy Face Screen
    final faceRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: 84,
      height: 50,
    );
    final faceRRect = RRect.fromRectAndRadius(faceRect, const Radius.circular(22));

    final facePaint = Paint()
      ..color = const Color(0xFF0A2342)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(faceRRect, facePaint);

    // 6. Friendly Happy Smiling Teal Eyes (Two smooth curved arcs: ⌒ ⌒)
    final eyePaint = Paint()
      ..color = const Color(0xFF14B8A6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final eyeGlowPaint = Paint()
      ..color = const Color(0xFF14B8A6).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Left Eye: happy curved arc
    final leftPath = Path();
    leftPath.moveTo(cx - 27, cy + 3);
    leftPath.quadraticBezierTo(cx - 19, cy - 7, cx - 11, cy + 3);

    canvas.drawPath(leftPath, eyeGlowPaint);
    canvas.drawPath(leftPath, eyePaint);

    // Right Eye: happy curved arc
    final rightPath = Path();
    rightPath.moveTo(cx + 11, cy + 3);
    rightPath.quadraticBezierTo(cx + 19, cy - 7, cx + 27, cy + 3);

    canvas.drawPath(rightPath, eyeGlowPaint);
    canvas.drawPath(rightPath, eyePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
