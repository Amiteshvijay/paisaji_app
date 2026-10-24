import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScratchCardWidget extends StatefulWidget {
  final Widget revealedChild;
  final VoidCallback onScratchComplete;
  final double threshold; // 0.50 = 50%
  final double width;
  final double height;

  const ScratchCardWidget({
    super.key,
    required this.revealedChild,
    required this.onScratchComplete,
    this.threshold = 0.50,
    this.width = 310,
    this.height = 390,
  });

  @override
  State<ScratchCardWidget> createState() => _ScratchCardWidgetState();
}

class _ScratchStroke {
  final List<Offset> points = [];
  _ScratchStroke(Offset initialPoint) {
    points.add(initialPoint);
  }
}

class _Sparkle {
  final Offset position;
  final double size;
  final Color color;
  final double velocityX;
  final double velocityY;
  double opacity = 1.0;

  _Sparkle({
    required this.position,
    required this.size,
    required this.color,
    required this.velocityX,
    required this.velocityY,
  });
}

class _ScratchCardWidgetState extends State<ScratchCardWidget> with SingleTickerProviderStateMixin {
  final List<_ScratchStroke> _strokes = [];
  final List<_Sparkle> _sparkles = [];
  bool _isFinished = false;
  double _scratchedPercentage = 0.0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  DateTime _lastHapticTime = DateTime.now();

  // Sampling grid (16 cols x 20 rows = 320 cells)
  static const int _gridCols = 16;
  static const int _gridRows = 20;
  late List<bool> _scratchedGrid;
  static const double _brushRadius = 34.0;

  @override
  void initState() {
    super.initState();
    _scratchedGrid = List.filled(_gridCols * _gridRows, false);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _triggerScratchHaptic() {
    final now = DateTime.now();
    if (now.difference(_lastHapticTime).inMilliseconds > 75) {
      _lastHapticTime = now;
      HapticFeedback.selectionClick();
    }
  }

  void _spawnSparkles(Offset point) {
    final random = math.Random();
    for (int i = 0; i < 3; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final speed = random.nextDouble() * 2.5 + 1.0;
      _sparkles.add(_Sparkle(
        position: point + Offset((random.nextDouble() - 0.5) * 16, (random.nextDouble() - 0.5) * 16),
        size: random.nextDouble() * 3.5 + 2.0,
        color: random.nextBool() ? const Color(0xFFFFD54F) : Colors.white,
        velocityX: math.cos(angle) * speed,
        velocityY: math.sin(angle) * speed,
      ));
    }
    if (_sparkles.length > 30) {
      _sparkles.removeRange(0, _sparkles.length - 30);
    }
  }

  void _startStroke(Offset point) {
    if (_isFinished) return;
    setState(() {
      _strokes.add(_ScratchStroke(point));
      _updateScratchedArea(point);
      _spawnSparkles(point);
    });
    _triggerScratchHaptic();
  }

  void _continueStroke(Offset point) {
    if (_isFinished) return;
    if (_strokes.isEmpty) {
      _startStroke(point);
      return;
    }
    setState(() {
      _strokes.last.points.add(point);
      _updateScratchedArea(point);
      _spawnSparkles(point);
    });
    _triggerScratchHaptic();
  }

  void _updateScratchedArea(Offset point) {
    final cellWidth = widget.width / _gridCols;
    final cellHeight = widget.height / _gridRows;

    int newlyScratched = 0;
    for (int r = 0; r < _gridRows; r++) {
      for (int c = 0; c < _gridCols; c++) {
        final index = r * _gridCols + c;
        if (!_scratchedGrid[index]) {
          final cellCenterX = (c + 0.5) * cellWidth;
          final cellCenterY = (r + 0.5) * cellHeight;
          final distance = (Offset(cellCenterX, cellCenterY) - point).distance;
          if (distance <= _brushRadius) {
            _scratchedGrid[index] = true;
            newlyScratched++;
          }
        }
      }
    }

    if (newlyScratched > 0) {
      final scratchedCount = _scratchedGrid.where((cleared) => cleared).length;
      _scratchedPercentage = scratchedCount / (_gridCols * _gridRows);

      // Trigger reveal when 50% is scratched
      if (_scratchedPercentage >= widget.threshold && !_isFinished) {
        _autoFinishReveal();
      }
    }
  }

  void _autoFinishReveal() {
    if (_isFinished) return;
    _isFinished = true;
    HapticFeedback.mediumImpact();
    _fadeController.forward().then((_) {
      if (mounted) {
        widget.onScratchComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withValues(alpha: 0.28),
            blurRadius: 30,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Revealed prize content underneath
          Positioned.fill(
            child: widget.revealedChild,
          ),

          // Scratchable Metallic Foil Overlay
          if (!_isFinished || _fadeController.isAnimating)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: child,
                  );
                },
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (event) => _startStroke(event.localPosition),
                  onPointerMove: (event) => _continueStroke(event.localPosition),
                  child: CustomPaint(
                    size: Size(widget.width, widget.height),
                    painter: _RealisticScratchPainter(
                      strokes: _strokes,
                      sparkles: _sparkles,
                      brushRadius: _brushRadius,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RealisticScratchPainter extends CustomPainter {
  final List<_ScratchStroke> strokes;
  final List<_Sparkle> sparkles;
  final double brushRadius;

  _RealisticScratchPainter({
    required this.strokes,
    required this.sparkles,
    required this.brushRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Isolated layer for metallic foil
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // Metallic Brushed Silver-Gold Gradient
    final foilPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFF9C4), // Soft Gold
          Color(0xFFE0E0E0), // Platinum
          Color(0xFFFFECB3), // Amber Foil
          Color(0xFFB0BEC5), // Silver Gray
          Color(0xFFFFF176), // Bright Gold
        ],
        stops: [0.0, 0.25, 0.55, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(24)),
      foilPaint,
    );

    // Fine Metallic Shimmer Diagonals
    final shimmerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 1.5;
    for (double i = -size.height; i < size.width * 2; i += 18) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height * 0.8, size.height), shimmerPaint);
    }

    // Outer Decorative Border
    final borderPaint = Paint()
      ..color = const Color(0xFFB45309).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(14, 14, size.width - 28, size.height - 28), const Radius.circular(18)),
      borderPaint,
    );

    // Center Gift Box Emoji Icon
    final giftPainter = TextPainter(
      text: const TextSpan(
        text: '🎁',
        style: TextStyle(fontSize: 56),
      ),
      textDirection: TextDirection.ltr,
    );
    giftPainter.layout();
    giftPainter.paint(canvas, Offset((size.width - giftPainter.width) / 2, size.height * 0.26));

    // Brand and Scratch Instruction
    final textPainter = TextPainter(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Paisaजी Rewards\n',
            style: TextStyle(
              color: Color(0xFF92400E),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          TextSpan(
            text: 'SCRATCH & WIN\n',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.2,
            ),
          ),
          TextSpan(
            text: 'Rub your finger to reveal coins!',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: size.width - 40);
    textPainter.paint(canvas, Offset((size.width - textPainter.width) / 2, size.height * 0.58));

    // 2. Clear scratched areas using BlendMode.clear
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = brushRadius * 2
      ..style = PaintingStyle.stroke;

    final circleClearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points.first, brushRadius, circleClearPaint);
      } else {
        for (final p in stroke.points) {
          canvas.drawCircle(p, brushRadius, circleClearPaint);
        }
        final path = Path();
        path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, clearPaint);
      }
    }

    // 3. Draw Sparkle Flakes at scratching points
    final sparklePaint = Paint();
    for (final sp in sparkles) {
      sparklePaint.color = sp.color.withValues(alpha: sp.opacity * 0.9);
      canvas.drawCircle(sp.position, sp.size, sparklePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RealisticScratchPainter oldDelegate) => true;
}
