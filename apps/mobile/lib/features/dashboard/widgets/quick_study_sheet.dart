import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';

/// Cupertino Quick Study Sheet ("Physics • Unit 4: Electromagnetism")
///
/// Features:
/// - Drag grabber pill & circular close button
/// - Key EUEE Formulas display box (Faraday's Law & Lorentz Force)
/// - Interactive 1-Question Warm-Up Check with immediate feedback rationale
class QuickStudySheet extends StatefulWidget {
  const QuickStudySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => const QuickStudySheet(),
    );
  }

  @override
  State<QuickStudySheet> createState() => _QuickStudySheetState();
}

class _QuickStudySheetState extends State<QuickStudySheet> {
  int? _selectedOption; // 0 for Option A, 1 for Option B
  bool? _isCorrect;

  void _handleOptionSelect(int index) {
    setState(() {
      _selectedOption = index;
      _isCorrect = (index == 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6);
    final lineBorder = isDark ? const Color(0xFF2B2B31) : const Color(0xFFE4E4E8);
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141418) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: lineBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 12,
        bottom: MediaQuery.paddingOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Grabber Pill
          Center(
            child: Container(
              width: 36,
              height: 4.5,
              decoration: BoxDecoration(
                color: lineBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'PHYSICS • UNIT 4',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Electromagnetism',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

              AcedexBounceable(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: lineBorder),
                  ),
                  alignment: Alignment.center,
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    color: subtextColor,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Key Formulas Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: lineBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KEY EUEE FORMULAS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: subtextColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFormulaRow(
                  label: "Faraday's Law of Induction",
                  formula: 'ε = −N (ΔΦ / Δt)',
                  primaryColor: primaryColor,
                  lineBorder: lineBorder,
                  subtextColor: subtextColor,
                  showDivider: true,
                ),
                _buildFormulaRow(
                  label: 'Lorentz Magnetic Force',
                  formula: 'F = q · v · B · sinθ',
                  primaryColor: primaryColor,
                  lineBorder: lineBorder,
                  subtextColor: subtextColor,
                  showDivider: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 1-Question Warm-Up Check
          Text(
            '1-QUESTION WARM-UP CHECK',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'A proton enters a uniform magnetic field B parallel to the field lines (θ = 0°). What is the magnetic force on it?',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 10),

          // Option A (Correct)
          _buildOptionButton(
            letter: 'A',
            text: '0 N, because sin(0°) = 0',
            index: 0,
            primaryColor: primaryColor,
            surfaceColor: surfaceColor,
            lineBorder: lineBorder,
            isDark: isDark,
          ),

          const SizedBox(height: 8),

          // Option B (Wrong)
          _buildOptionButton(
            letter: 'B',
            text: 'Maximum force F = qvB along B',
            index: 1,
            primaryColor: primaryColor,
            surfaceColor: surfaceColor,
            lineBorder: lineBorder,
            isDark: isDark,
          ),

          // Feedback Box
          if (_isCorrect != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _isCorrect!
                    ? (isDark ? AppColors.darkSuccess : AppColors.success).withValues(alpha: 0.16)
                    : (isDark ? AppColors.darkError : AppColors.error).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isCorrect!
                      ? (isDark ? AppColors.darkSuccess : AppColors.success)
                      : (isDark ? AppColors.darkError : AppColors.error),
                ),
              ),
              child: Text(
                _isCorrect!
                    ? 'Correct! F = qvB·sin(0°) = 0 N. Ready for Unit 4 drills.'
                    : 'Not quite — when velocity is parallel to B (θ = 0°), sin(0°) = 0 so F = 0 N.',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: _isCorrect!
                      ? (isDark ? AppColors.darkSuccess : AppColors.success)
                      : (isDark ? AppColors.darkError : AppColors.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormulaRow({
    required String label,
    required String formula,
    required Color primaryColor,
    required Color lineBorder,
    required Color subtextColor,
    required bool showDivider,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(bottom: BorderSide(color: lineBorder)),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: subtextColor,
            ),
          ),
          Text(
            formula,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required String letter,
    required String text,
    required int index,
    required Color primaryColor,
    required Color surfaceColor,
    required Color lineBorder,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedOption == index;
    final isThisOptionCorrect = index == 0;

    Color bg = surfaceColor;
    Color border = lineBorder;

    if (isSelected) {
      if (isThisOptionCorrect) {
        bg = (isDark ? AppColors.darkSuccess : AppColors.success).withValues(alpha: 0.16);
        border = isDark ? AppColors.darkSuccess : AppColors.success;
      } else {
        bg = (isDark ? AppColors.darkError : AppColors.error).withValues(alpha: 0.16);
        border = isDark ? AppColors.darkError : AppColors.error;
      }
    }

    return AcedexBounceable(
      onTap: () => _handleOptionSelect(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: isSelected ? 1.5 : 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
