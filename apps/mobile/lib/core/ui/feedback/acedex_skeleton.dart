import 'package:flutter/material.dart';

/// Apple-Style Shimmer & Skeleton Loading System
///
/// Provides fluid, pulsing skeleton placeholders with Apple Cupertino aesthetics,
/// theme-adaptive neutral palettes, and smooth breathing animations to eliminate
/// sudden flashes or empty jarring states across all Acedex screens.
class AcedexSkeleton extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AcedexSkeleton({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1100),
  });

  @override
  State<AcedexSkeleton> createState() => _AcedexSkeletonState();
}

class _AcedexSkeletonState extends State<AcedexSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.38, end: 0.88).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Base Rectangular / Rounded Box Skeleton
class AcedexSkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final Color? color;

  const AcedexSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? const Color(0xFF23232A) : const Color(0xFFE4E4E9);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? defaultBg,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Text Line Placeholder Skeleton
class AcedexSkeletonText extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const AcedexSkeletonText({
    super.key,
    this.width,
    this.height = 12,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return AcedexSkeletonBox(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

/// Unit Accordion Card Skeleton (Syllabus & Curriculum Loading)
class AcedexSkeletonUnitCard extends StatelessWidget {
  const AcedexSkeletonUnitCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF16161A) : Colors.white;
    final border = isDark ? const Color(0xFF26262E) : const Color(0xFFECECEF);
    final boneBg = isDark ? const Color(0xFF24242C) : const Color(0xFFE6E6EC);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          // Unit Number Badge Squircle
          AcedexSkeletonBox(
            width: 28,
            height: 28,
            borderRadius: 8,
            color: boneBg,
          ),
          const SizedBox(width: 12),

          // Unit Title & Subtitle Stack
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AcedexSkeletonBox(
                  width: 150,
                  height: 12,
                  borderRadius: 4,
                  color: boneBg,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    AcedexSkeletonBox(
                      width: 70,
                      height: 9,
                      borderRadius: 4,
                      color: boneBg,
                    ),
                    const SizedBox(width: 8),
                    AcedexSkeletonBox(
                      width: 45,
                      height: 9,
                      borderRadius: 4,
                      color: boneBg,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Trailing Chevron / Action Placeholder
          AcedexSkeletonBox(
            width: 22,
            height: 22,
            borderRadius: 7,
            color: boneBg,
          ),
        ],
      ),
    );
  }
}

/// Generic Card Skeleton
class AcedexSkeletonCard extends StatelessWidget {
  final double height;

  const AcedexSkeletonCard({
    super.key,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF16161A) : Colors.white;
    final border = isDark ? const Color(0xFF26262E) : const Color(0xFFECECEF);

    return Container(
      height: height,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AcedexSkeletonBox(width: 32, height: 32, borderRadius: 10),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    AcedexSkeletonBox(width: 120, height: 11, borderRadius: 4),
                    SizedBox(height: 5),
                    AcedexSkeletonBox(width: 70, height: 9, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          const AcedexSkeletonBox(width: double.infinity, height: 10, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Skeleton List Container
class AcedexSkeletonList extends StatelessWidget {
  final int itemCount;
  final double spacing;
  final Widget Function(BuildContext context, int index)? itemBuilder;

  const AcedexSkeletonList({
    super.key,
    this.itemCount = 4,
    this.spacing = 10,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return AcedexSkeleton(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(itemCount, (index) {
          final child = itemBuilder != null
              ? itemBuilder!(context, index)
              : const AcedexSkeletonUnitCard();
          return Padding(
            padding: EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : spacing),
            child: child,
          );
        }),
      ),
    );
  }
}
