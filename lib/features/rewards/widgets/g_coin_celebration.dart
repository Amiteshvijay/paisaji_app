import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zeokash/features/rewards/widgets/g_coin_widget.dart';

/// Soft gold celebration particle for G Coin reveal
class _GoldParticle {
  final double angle;
  final double distance;
  final double size;
  final Color color;
  final double speed;

  _GoldParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.speed,
  });
}

/// Full celebration overlay showing G Coin reveal, golden particle burst, and wallet credit feedback
class GCoinCelebrationWidget extends StatefulWidget {
  final int coins;
  final double coinSize;
  final VoidCallback? onCelebrationEnd;

  const GCoinCelebrationWidget({
    super.key,
    required this.coins,
    this.coinSize = 160.0,
    this.onCelebrationEnd,
  });

  @override
  State<GCoinCelebrationWidget> createState() => _GCoinCelebrationWidgetState();
}

class _GCoinCelebrationWidgetState extends State<GCoinCelebrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;
  final List<_GoldParticle> _particles = [];
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    // 24 soft gold particles
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFFFC107),
      const Color(0xFFFFF2A6),
      const Color(0xFFFFB300),
      const Color(0xFFFFE082),
    ];

    for (int i = 0; i < 28; i++) {
      _particles.add(
        _GoldParticle(
          angle: _rng.nextDouble() * 2 * math.pi,
          distance: 40.0 + _rng.nextDouble() * 110.0,
          size: 3.5 + _rng.nextDouble() * 4.5,
          color: colors[_rng.nextInt(colors.length)],
          speed: 0.8 + _rng.nextDouble() * 0.4,
        ),
      );
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.forward().then((_) {
      widget.onCelebrationEnd?.call();
    });
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
        final t = _progress.value;
        final fadeOut = (1.0 - t).clamp(0.0, 1.0);

        return SizedBox(
          width: widget.coinSize,
          height: widget.coinSize,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Ambient Gold Glow
              IgnorePointer(
                child: Container(
                  width: widget.coinSize * 1.5,
                  height: widget.coinSize * 1.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.35 * fadeOut),
                        blurRadius: 40.0 * t,
                        spreadRadius: 10.0 * t,
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Gold Particle Burst (Bursting outward without expanding layout dimensions)
              Positioned(
                width: widget.coinSize * 2.2,
                height: widget.coinSize * 2.2,
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ParticleBurstPainter(
                      particles: _particles,
                      progress: t,
                      opacity: fadeOut,
                    ),
                  ),
                ),
              ),

              // 3. Main G Coin with scale & rotation reveal
              GCoinWidget(
                value: widget.coins,
                size: widget.coinSize,
                animateOnMount: true,
                showGlow: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ParticleBurstPainter extends CustomPainter {
  final List<_GoldParticle> particles;
  final double progress;
  final double opacity;

  _ParticleBurstPainter({
    required this.particles,
    required this.progress,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final currentDist = p.distance * progress * p.speed;
      final dx = center.dx + currentDist * math.cos(p.angle);
      final dy = center.dy + currentDist * math.sin(p.angle);

      paint.color = p.color.withValues(alpha: opacity * (1.0 - progress * 0.4));
      
      // Draw 4-point diamond star sparkle or soft circle
      final pSize = p.size * (1.0 - progress * 0.3);
      canvas.drawCircle(Offset(dx, dy), pSize / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleBurstPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.opacity != opacity;
  }
}
