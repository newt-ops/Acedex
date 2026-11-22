import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../models/dashboard_data.dart';

/// Quick Formula & Concept Flashcards Carousel (Section 5)
///
/// Features:
/// - Horizontal snap-scrolling carousel (264px width per card)
/// - Authentic 3D 180° perspective flip animation on tap
/// - Front Face: Subject badge, title, concept prompt, "Tap to reveal formula →"
/// - Back Face: Royal purple gradient, mono formula box, EUEE Exam Tip
class FormulaFlashcardsCarousel extends StatelessWidget {
  final List<FlashcardItem> flashcards;

  const FormulaFlashcardsCarousel({
    super.key,
    required this.flashcards,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Formula Flashcards',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Row(
              children: [
                Text(
                  'Tap card to flip',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 3),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedRefresh,
                  color: primaryColor,
                  size: 12,
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Horizontal Snap Carousel
        SizedBox(
          height: 154,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: flashcards.length,
            separatorBuilder: (_, i) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _FlippableFlashcard(card: flashcards[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _FlippableFlashcard extends StatefulWidget {
  final FlashcardItem card;

  const _FlippableFlashcard({required this.card});

  @override
  State<_FlippableFlashcard> createState() => _FlippableFlashcardState();
}

class _FlippableFlashcardState extends State<_FlippableFlashcard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6);
    final lineBorder = isDark ? const Color(0xFF2B2B31) : const Color(0xFFE4E4E8);
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return GestureDetector(
      onTap: _toggleFlip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final isUnder = angle > (math.pi / 2);

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 3D perspective depth
              ..rotateY(angle),
            alignment: Alignment.center,
            child: SizedBox(
              width: 264,
              height: 148,
              child: isUnder
                  ? Transform(
                      transform: Matrix4.identity()..rotateY(math.pi),
                      alignment: Alignment.center,
                      child: _buildBackFace(isDark, primaryColor),
                    )
                  : _buildFrontFace(
                      theme: theme,
                      surfaceColor: surfaceColor,
                      lineBorder: lineBorder,
                      subtextColor: subtextColor,
                      primaryColor: primaryColor,
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrontFace({
    required ThemeData theme,
    required Color surfaceColor,
    required Color lineBorder,
    required Color subtextColor,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: lineBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Subject tag + Refresh icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  widget.card.subject.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: primaryColor,
                  ),
                ),
              ),
              HugeIcon(
                icon: HugeIcons.strokeRoundedRefresh,
                color: subtextColor,
                size: 13,
              ),
            ],
          ),

          // Title & Concept Prompt
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.card.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.card.prompt,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.3,
                  color: subtextColor,
                ),
              ),
            ],
          ),

          // CTA
          Text(
            'Tap to reveal formula →',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackFace(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF3A2243),
                  Color(0xFF271A2C),
                ]
              : const [
                  Color(0xFF8A2BA3),
                  Color(0xFF6A1E80),
                ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.card.title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Tap to flip back',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          // Frosted Formula Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.card.formula,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: Colors.white,
              ),
            ),
          ),

          // Exam Tip
          Text(
            widget.card.examTip,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              height: 1.3,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
