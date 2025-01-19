import 'package:flutter/material.dart';
import 'dart:math' as math;

class FancyPlayAgainButton extends StatefulWidget {
  final VoidCallback onPressed;

  const FancyPlayAgainButton({
    super.key,
    required this.onPressed,
  });

  @override
  State<FancyPlayAgainButton> createState() => _FancyPlayAgainButtonState();
}

class _FancyPlayAgainButtonState extends State<FancyPlayAgainButton> with SingleTickerProviderStateMixin {
  late final AnimationController _buttonAnimationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotateAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeInOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutBack)),
        weight: 50,
      ),
    ]).animate(_buttonAnimationController);

    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: math.pi / 30)
            .chain(CurveTween(curve: Curves.easeInOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: math.pi / 30, end: 0)
            .chain(CurveTween(curve: Curves.easeInOutBack)),
        weight: 50,
      ),
    ]).animate(_buttonAnimationController);

    _buttonAnimationController.repeat();
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedBuilder(
        animation: _buttonAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isHovering ? 1.15 : _scaleAnimation.value,
            child: Transform.rotate(
              angle: _isHovering ? 0 : _rotateAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovering 
                          ? const Color(0xFF27AE60).withOpacity(0.5)
                          : const Color(0xFF27AE60).withOpacity(0.3),
                      blurRadius: _isHovering ? 15 : 10,
                      spreadRadius: _isHovering ? 5 : 2,
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  icon: AnimatedRotation(
                    duration: const Duration(milliseconds: 500),
                    turns: _isHovering ? 1 : 0,
                    child: const Icon(
                      Icons.refresh,
                      size: 28,
                    ),
                  ),
                  label: const Text(
                    'Play Again',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    backgroundColor: _isHovering
                        ? const Color(0xFF2ECC71)
                        : const Color(0xFF27AE60),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: _isHovering ? 8 : 4,
                  ),
                  onPressed: () {
                    _buttonAnimationController.forward(from: 0).then((_) {
                      widget.onPressed();
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}