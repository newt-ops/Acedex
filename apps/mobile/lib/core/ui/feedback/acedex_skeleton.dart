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

/// Home / Dashboard Screen Skeleton
class AcedexDashboardSkeleton extends StatelessWidget {
  const AcedexDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF16161A) : Colors.white;
    final border = isDark ? const Color(0xFF26262E) : const Color(0xFFECECEF);
    final boneBg = isDark ? const Color(0xFF24242C) : const Color(0xFFE6E6EC);

    return AcedexSkeleton(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Hero Countdown Card Skeleton
            Container(
              height: 148,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AcedexSkeletonBox(width: 140, height: 16, borderRadius: 6, color: boneBg),
                      AcedexSkeletonBox(width: 72, height: 24, borderRadius: 999, color: boneBg),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      4,
                      (_) => AcedexSkeletonBox(width: 64, height: 48, borderRadius: 12, color: boneBg),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Curriculum Bento Grid Skeleton (2x2)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 98,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AcedexSkeletonBox(width: 80, height: 11, borderRadius: 4, color: boneBg),
                            const Spacer(),
                            AcedexSkeletonBox(width: 60, height: 22, borderRadius: 6, color: boneBg),
                            const SizedBox(height: 6),
                            AcedexSkeletonBox(width: 90, height: 8, borderRadius: 4, color: boneBg),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 98,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AcedexSkeletonBox(width: 75, height: 11, borderRadius: 4, color: boneBg),
                            const Spacer(),
                            AcedexSkeletonBox(width: 50, height: 22, borderRadius: 6, color: boneBg),
                            const SizedBox(height: 6),
                            AcedexSkeletonBox(width: 70, height: 8, borderRadius: 4, color: boneBg),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 98,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AcedexSkeletonBox(width: 85, height: 11, borderRadius: 4, color: boneBg),
                            const Spacer(),
                            AcedexSkeletonBox(width: 65, height: 22, borderRadius: 6, color: boneBg),
                            const SizedBox(height: 6),
                            AcedexSkeletonBox(width: 80, height: 8, borderRadius: 4, color: boneBg),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 98,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AcedexSkeletonBox(width: 70, height: 11, borderRadius: 4, color: boneBg),
                            const Spacer(),
                            AcedexSkeletonBox(width: 55, height: 22, borderRadius: 6, color: boneBg),
                            const SizedBox(height: 6),
                            AcedexSkeletonBox(width: 75, height: 8, borderRadius: 4, color: boneBg),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. Study Plan Skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AcedexSkeletonBox(width: 140, height: 16, borderRadius: 4, color: boneBg),
                AcedexSkeletonBox(width: 50, height: 24, borderRadius: 999, color: boneBg),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(
              2,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      AcedexSkeletonBox(width: 22, height: 22, borderRadius: 7, color: boneBg),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AcedexSkeletonBox(width: 160, height: 12, borderRadius: 4, color: boneBg),
                            const SizedBox(height: 6),
                            AcedexSkeletonBox(width: 80, height: 9, borderRadius: 4, color: boneBg),
                          ],
                        ),
                      ),
                      AcedexSkeletonBox(width: 40, height: 20, borderRadius: 999, color: boneBg),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Study Screen Skeleton
class AcedexStudySkeleton extends StatelessWidget {
  const AcedexStudySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boneBg = isDark ? const Color(0xFF24242C) : const Color(0xFFE6E6EC);

    return AcedexSkeleton(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grade Selector Bar
            Row(
              children: List.generate(
                4,
                (_) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: AcedexSkeletonBox(height: 32, borderRadius: 999, color: boneBg),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Subject Chips Horizontal
            Row(
              children: List.generate(
                3,
                (_) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AcedexSkeletonBox(width: 90, height: 32, borderRadius: 999, color: boneBg),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 4 Unit Accordion Cards
            ...List.generate(
              4,
              (index) => const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: AcedexSkeletonUnitCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// AI Topic Study Screen Skeleton
class AcedexAiStudySkeleton extends StatelessWidget {
  const AcedexAiStudySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF16161A) : Colors.white;
    final border = isDark ? const Color(0xFF26262E) : const Color(0xFFECECEF);
    final boneBg = isDark ? const Color(0xFF24242C) : const Color(0xFFE6E6EC);

    return AcedexSkeleton(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AI Topic Program Summary Hero Banner
            Container(
              height: 118,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AcedexSkeletonBox(width: 140, height: 16, borderRadius: 6, color: boneBg),
                  const SizedBox(height: 8),
                  AcedexSkeletonBox(width: 210, height: 11, borderRadius: 4, color: boneBg),
                  const Spacer(),
                  AcedexSkeletonBox(width: 110, height: 26, borderRadius: 999, color: boneBg),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Priority Subject Pill Rail
            Row(
              children: List.generate(
                3,
                (_) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AcedexSkeletonBox(width: 96, height: 34, borderRadius: 999, color: boneBg),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Topic Module Cards
            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 84,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      AcedexSkeletonBox(width: 44, height: 44, borderRadius: 14, color: boneBg),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AcedexSkeletonBox(width: 150, height: 13, borderRadius: 4, color: boneBg),
                            const SizedBox(height: 6),
                            AcedexSkeletonBox(width: 105, height: 10, borderRadius: 4, color: boneBg),
                          ],
                        ),
                      ),
                      AcedexSkeletonBox(width: 34, height: 24, borderRadius: 999, color: boneBg),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress Screen Skeleton
class AcedexProgressSkeleton extends StatelessWidget {
  const AcedexProgressSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF16161A) : Colors.white;
    final border = isDark ? const Color(0xFF26262E) : const Color(0xFFECECEF);
    final boneBg = isDark ? const Color(0xFF24242C) : const Color(0xFFE6E6EC);

    return AcedexSkeleton(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Overall Mastery Gauge Card
            Container(
              height: 130,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  AcedexSkeletonBox(width: 80, height: 80, borderRadius: 999, color: boneBg),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AcedexSkeletonBox(width: 120, height: 16, borderRadius: 6, color: boneBg),
                        const SizedBox(height: 8),
                        AcedexSkeletonBox(width: 90, height: 11, borderRadius: 4, color: boneBg),
                        const SizedBox(height: 8),
                        AcedexSkeletonBox(width: double.infinity, height: 8, borderRadius: 4, color: boneBg),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Subject Breakdown Cards
            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      AcedexSkeletonBox(width: 32, height: 32, borderRadius: 10, color: boneBg),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AcedexSkeletonBox(width: 100, height: 12, borderRadius: 4, color: boneBg),
                            const SizedBox(height: 6),
                            AcedexSkeletonBox(width: 60, height: 8, borderRadius: 4, color: boneBg),
                          ],
                        ),
                      ),
                      AcedexSkeletonBox(width: 44, height: 14, borderRadius: 4, color: boneBg),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile Screen Skeleton
class AcedexProfileSkeleton extends StatelessWidget {
  const AcedexProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF16161A) : Colors.white;
    final border = isDark ? const Color(0xFF26262E) : const Color(0xFFECECEF);
    final boneBg = isDark ? const Color(0xFF24242C) : const Color(0xFFE6E6EC);

    return AcedexSkeleton(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Student ID Card Placeholder
            Container(
              height: 190,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AcedexSkeletonBox(width: 80, height: 12, borderRadius: 4, color: boneBg),
                      AcedexSkeletonBox(width: 60, height: 20, borderRadius: 999, color: boneBg),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      AcedexSkeletonBox(width: 50, height: 50, borderRadius: 999, color: boneBg),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AcedexSkeletonBox(width: 130, height: 16, borderRadius: 4, color: boneBg),
                          const SizedBox(height: 6),
                          AcedexSkeletonBox(width: 90, height: 10, borderRadius: 4, color: boneBg),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Preference Group
            ...List.generate(
              2,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      AcedexSkeletonBox(width: 24, height: 24, borderRadius: 8, color: boneBg),
                      const SizedBox(width: 14),
                      AcedexSkeletonBox(width: 120, height: 12, borderRadius: 4, color: boneBg),
                      const Spacer(),
                      AcedexSkeletonBox(width: 16, height: 16, borderRadius: 4, color: boneBg),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
