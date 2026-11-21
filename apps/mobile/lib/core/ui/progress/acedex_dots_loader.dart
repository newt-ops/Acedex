import 'package:flutter/material.dart';

/// Apple-Style Horizontal 3-Dots Wave Loading Component
///
/// Implements the canonical Acedex `three-dots-loader` keyframe wave animation:
/// staggered bounce (-5px vertical lift) and scale (0.84 -> 1.2) with continuous
/// looping at 1.02s per cycle. Replaces standard circular spinners across the app.
class AcedexDotsLoader extends StatefulWidget {
  final double dotSize;
  final double gap;
  final Color? color;
  final Duration duration;

  const AcedexDotsLoader({
    super.key,
    this.dotSize = 6.5,
    this.gap = 5.0,
    this.color,
    this.duration = const Duration(milliseconds: 1020),
  });

  @override
  State<AcedexDotsLoader> createState() => _AcedexDotsLoaderState();
}

class _AcedexDotsLoaderState extends State<AcedexDotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Stagger delays matching HTML specification: 0s, 0.14s, 0.28s of 1.02s
  static const List<double> _delays = [0.0, 0.137, 0.274];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = widget.color ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(3, (index) {
            final t = (_controller.value - _delays[index]) % 1.0;
            final (offsetY, scale, opacity) = _evaluateDotKeyframe(t < 0 ? t + 1.0 : t);

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.gap / 2),
              child: Transform.translate(
                offset: Offset(0, offsetY),
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Container(
                      width: widget.dotSize,
                      height: widget.dotSize,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  /// Evaluates the cubic wave keyframe at normalized progress `t` in [0, 1].
  ///
  /// Keyframe breakdown:
  /// - 0% to 35%: Lift to -5.0px, scale from 0.84 to 1.20, opacity from 0.40 to 1.0
  /// - 35% to 78%: Fall back to 0.0px, scale from 1.20 to 0.84, opacity from 1.0 to 0.40
  /// - 78% to 100%: Rest at 0.0px, scale 0.84, opacity 0.40
  (double, double, double) _evaluateDotKeyframe(double t) {
    if (t < 0.35) {
      // Ascending phase (0 -> 1)
      final norm = t / 0.35;
      final curve = Curves.easeOutBack.transform(norm);
      final offsetY = -5.0 * curve;
      final scale = 0.84 + (1.20 - 0.84) * curve;
      final opacity = 0.40 + (1.0 - 0.40) * norm;
      return (offsetY, scale, opacity);
    } else if (t < 0.78) {
      // Descending phase (1 -> 0)
      final norm = (t - 0.35) / (0.78 - 0.35);
      final curve = Curves.easeInOutCubic.transform(norm);
      final offsetY = -5.0 * (1.0 - curve);
      final scale = 1.20 - (1.20 - 0.84) * curve;
      final opacity = 1.0 - (1.0 - 0.40) * norm;
      return (offsetY, scale, opacity);
    } else {
      // Rest phase
      return (0.0, 0.84, 0.40);
    }
  }
}
