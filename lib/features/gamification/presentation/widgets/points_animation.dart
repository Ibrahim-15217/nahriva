import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nahriva/core/theme/app_colors.dart';

class PointsAnimation extends StatefulWidget {
  final int points;
  final bool show;

  const PointsAnimation({super.key, required this.points, this.show = true});

  @override
  State<PointsAnimation> createState() => _PointsAnimationState();
}

class _PointsAnimationState extends State<PointsAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _scaleAnim = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack)),
    );

    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeIn)),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.5), end: const Offset(0, -1.0)).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );

    if (widget.show) _controller.forward();
  }

  @override
  void didUpdateWidget(PointsAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rng = Random();
    final dx = rng.nextDouble() * 100 - 50;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(
            offset: Offset(dx, _slideAnim.value.dy * 60),
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppColors.primaryDark : AppColors.primaryLight).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 18),
                    Text(
                      '+${widget.points}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.eco, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
