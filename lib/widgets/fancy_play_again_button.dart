import 'package:flutter/material.dart';

class FancyPlayAgainButton extends StatefulWidget {
  final VoidCallback onPressed;

  const FancyPlayAgainButton({
    super.key,
    required this.onPressed,
  });

  @override
  State<FancyPlayAgainButton> createState() => _FancyPlayAgainButtonState();
}

class _FancyPlayAgainButtonState extends State<FancyPlayAgainButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Simple scale animation that pulses between 1.0 and 1.1
          final scale = 1.0 + (_controller.value * 0.1);

          return Transform.scale(
            scale: _isHovering ? 1.15 : scale,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh, size: 24),
              label: const Text(
                'Play Again',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: _isHovering
                    ? Color(0xFF2ECC71) // Lighter green when hovering
                    : Color(0xFF27AE60), // Default green
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: widget.onPressed,
            ),
          );
        },
      ),
    );
  }
}
