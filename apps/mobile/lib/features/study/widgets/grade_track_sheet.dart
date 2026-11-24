import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';

/// Cupertino Grade Level Selector Sheet
class GradeTrackSheet extends StatefulWidget {
  final int selectedGrade;
  final String stream; // 'natural' | 'social' (registered stream for display)
  final int? registeredGrade;
  final ValueChanged<int> onSelectGrade;

  const GradeTrackSheet({
    super.key,
    required this.selectedGrade,
    required this.stream,
    this.registeredGrade,
    required this.onSelectGrade,
  });

  static Future<void> show(
    BuildContext context, {
    required int selectedGrade,
    required String stream,
    int? registeredGrade,
    required ValueChanged<int> onSelectGrade,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GradeTrackSheet(
        selectedGrade: selectedGrade,
        stream: stream,
        registeredGrade: registeredGrade,
        onSelectGrade: onSelectGrade,
      ),
    );
  }

  @override
  State<GradeTrackSheet> createState() => _GradeTrackSheetState();
}

class _GradeTrackSheetState extends State<GradeTrackSheet> {
  late int _currentGrade;

  @override
  void initState() {
    super.initState();
    _currentGrade = widget.selectedGrade;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6);
    final lineBorder = isDark ? const Color(0xFF33333E) : const Color(0xFFE4E4E8);
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    final streamLabel = widget.stream.toLowerCase() == 'social'
        ? 'Social Science'
        : 'Natural Science';

    final grades = [
      {'grade': 9, 'desc': 'Foundation Ethiopian Curriculum', 'badge': ''},
      {'grade': 10, 'desc': 'Secondary Core Concepts', 'badge': ''},
      {'grade': 11, 'desc': 'Pre-Entrance Advanced Units', 'badge': ''},
      {'grade': 12, 'desc': 'National University Entrance Exam', 'badge': 'EUEE FOCUS'},
    ];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: lineBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Handle Bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 36,
                height: 4.5,
                decoration: BoxDecoration(
                  color: lineBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Curriculum Grade',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ethiopian Ministry of Education • $streamLabel',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: subtextColor,
                          ),
                        ),
                      ],
                    ),
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
                      child: Icon(Icons.close_rounded, size: 16, color: subtextColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Scrollable Options Body
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Grade Level Selector Cards
                    Text(
                      'GRADE LEVEL (EUEE MULTI-GRADE ACCESS)',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: subtextColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...grades.map((item) {
                      final grade = item['grade'] as int;
                      final desc = item['desc'] as String;
                      final badge = item['badge'] as String;
                      final isSelected = _currentGrade == grade;
                      final isUserGrade = widget.registeredGrade == grade;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: AcedexBounceable(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _currentGrade = grade);
                            widget.onSelectGrade(grade);
                            Future.delayed(const Duration(milliseconds: 140), () {
                              if (context.mounted) Navigator.of(context).pop();
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withValues(alpha: isDark ? 0.20 : 0.10)
                                  : surfaceColor,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? primaryColor : lineBorder,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Grade $grade',
                                            style: TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.2,
                                              color: isSelected ? primaryColor : theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          if (badge.isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: primaryColor,
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                badge,
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.4,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                          if (isUserGrade && badge.isEmpty) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: primaryColor.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                'REGISTERED',
                                                style: TextStyle(
                                                  fontSize: 8.5,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.4,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        desc,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: subtextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
