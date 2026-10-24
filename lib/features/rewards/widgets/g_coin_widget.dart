import 'package:flutter/material.dart';
import 'package:zeokash/features/rewards/utils/g_coin_assets.dart';

/// Production-ready G Coin widget for Paisaजी loyalty reward system.
/// Displays official metallic gold coins (1-50) with optional reveal & celebration animations.
class GCoinWidget extends StatefulWidget {
  /// Denomination value between 1 and 50 (or aggregate balance)
  final int value;

  /// Display diameter in logical pixels (e.g. 32, 48, 64, 96, 128, 192, 256)
  final double size;

  /// Whether to play scale & rotation reveal animation on mount
  final bool animateOnMount;

  /// Whether to show ambient glowing halo around coin
  final bool showGlow;

  /// Optional badge/balance label displayed below or alongside coin (e.g. "+25 G Coins")
  final String? label;

  /// Text style for the optional balance label
  final TextStyle? labelStyle;

  /// Accessible label for screen readers
  final String? accessibilityLabel;

  /// Optional callback when reveal animation completes
  final VoidCallback? onAnimationComplete;

  const GCoinWidget({
    super.key,
    required this.value,
    this.size = 128.0,
    this.animateOnMount = false,
    this.showGlow = false,
    this.label,
    this.labelStyle,
    this.accessibilityLabel,
    this.onAnimationComplete,
  });

  @override
  State<GCoinWidget> createState() => _GCoinWidgetState();
}

class _GCoinWidgetState extends State<GCoinWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    // Easing curve from 0.7 to 1.0 with subtle overshoot
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.70, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.00)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
    ]).animate(_animController);

    // Subtle rotation (-0.12 rad (~ -7 deg) to 0)
    _rotationAnimation = Tween<double>(begin: -0.12, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.animateOnMount) {
      _animController.forward().then((_) {
        widget.onAnimationComplete?.call();
      });
    } else {
      _animController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant GCoinWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.animateOnMount) {
      _animController.reset();
      _animController.forward().then((_) {
        widget.onAnimationComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semanticText = widget.accessibilityLabel ??
        'Paisaजी ${widget.value} G Coins reward';

    final assetPath = GCoinAssets.safeAssetFor(
      widget.value,
      size: widget.size.toInt(),
    );

    Widget coinImage = Image.asset(
      assetPath,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      cacheWidth: (widget.size * MediaQuery.of(context).devicePixelRatio).toInt(),
      cacheHeight: (widget.size * MediaQuery.of(context).devicePixelRatio).toInt(),
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackCoin();
      },
    );

    Widget animatedCoin = AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animateOnMount ? _scaleAnimation.value : 1.0,
          child: Transform.rotate(
            angle: widget.animateOnMount ? _rotationAnimation.value : 0.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.showGlow)
                  Opacity(
                    opacity: widget.animateOnMount ? _glowAnimation.value : 1.0,
                    child: Container(
                      width: widget.size * 1.15,
                      height: widget.size * 1.15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.40),
                            blurRadius: widget.size * 0.25,
                            spreadRadius: widget.size * 0.05,
                          ),
                        ],
                      ),
                    ),
                  ),
                child!,
              ],
            ),
          ),
        );
      },
      child: coinImage,
    );

    Widget content = animatedCoin;

    if (widget.label != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          animatedCoin,
          const SizedBox(height: 6),
          Text(
            widget.label!,
            style: widget.labelStyle ??
                const TextStyle(
                  color: Color(0xFF0A2342),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Semantics(
      label: semanticText,
      image: true,
      child: content,
    );
  }

  Widget _buildFallbackCoin() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFFFFE082),
            Color(0xFFFFB300),
            Color(0xFFFF8F00),
            Color(0xFFB45309),
          ],
          stops: [0.25, 0.60, 0.85, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFFF9C4),
          width: 2.0,
        ),
      ),
      child: Center(
        child: Text(
          '${widget.value}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: widget.size * 0.28,
          ),
        ),
      ),
    );
  }
}
