import 'dart:math' as math;
import 'package:flutter/material.dart';

class ScratchConfettiWidget extends StatefulWidget {
  final int count;
  const ScratchConfettiWidget({super.key, this.count = 45});

  @override
  State<ScratchConfettiWidget> createState() => _ScratchConfettiWidgetState();
}

class _ScratchConfettiWidgetState extends State<ScratchConfettiWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  final List<Color> _colors = const [
    Color(0xFFFFD700), // Gold
    Color(0xFF1565D8), // Zeo Blue
    Color(0xFFFF4081), // Pink
    Color(0xFF00E676), // Green
    Color(0xFF7C4DFF), // Purple
    Color(0xFFFF9100), // Orange
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    for (int i = 0; i < widget.count; i++) {
      _particles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        y: -0.1 - _random.nextDouble() * 0.4,
        size: 7 + _random.nextDouble() * 9,
        color: _colors[_random.nextInt(_colors.length)],
        speed: 0.7 + _random.nextDouble() * 0.8,
        swaySpeed: 2 + _random.nextDouble() * 3,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 8,
      ));
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double speed;
  final double swaySpeed;
  final double rotation;
  final double rotationSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
    required this.swaySpeed,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final currentY = (p.y + p.speed * progress) * size.height;
      final currentX = (p.x * size.width) + math.sin(progress * p.swaySpeed * math.pi * 2) * 28;
      final currentAngle = p.rotation + p.rotationSpeed * progress;

      if (currentY > size.height + 20) continue;

      final paint = Paint()
        ..color = p.color.withValues(alpha: (1.0 - (progress * 0.75)).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentAngle);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
