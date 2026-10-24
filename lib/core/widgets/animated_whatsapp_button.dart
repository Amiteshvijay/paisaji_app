import 'package:flutter/material.dart';

class AnimatedWhatsAppButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String heroTag;
  final double size;

  const AnimatedWhatsAppButton({
    super.key,
    required this.onPressed,
    this.heroTag = 'whatsapp_support_btn',
    this.size = 52.0,
  });

  @override
  State<AnimatedWhatsAppButton> createState() => _AnimatedWhatsAppButtonState();
}

class _AnimatedWhatsAppButtonState extends State<AnimatedWhatsAppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 240),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Contact PaisaJi Support on WhatsApp',
      button: true,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: const Color(0xFF25D366),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF25D366).withValues(alpha: _isPressed ? 0.6 : 0.35),
                  blurRadius: _isPressed ? 16 : 8,
                  spreadRadius: _isPressed ? 2 : 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.chat,
                color: Colors.white,
                size: widget.size * 0.54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
