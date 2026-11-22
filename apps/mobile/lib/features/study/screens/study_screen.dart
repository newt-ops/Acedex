import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';

/// Clean Apple-Style Study & Curriculum Screen (Tab 1: Study)
class StudyScreen extends StatefulWidget {
  final UserProfile? user;

  const StudyScreen({super.key, this.user});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getSubjects() {
    final isSocial = (widget.user?.stream ?? 'natural').toLowerCase() == 'social';

    if (isSocial) {
      return [
        {'name': 'Mathematics', 'units': '8 Units • 42 Topics', 'icon': HugeIcons.strokeRoundedCalculator01, 'color': AppColors.royalPurple, 'progress': '0%'},
        {'name': 'History', 'units': '7 Units • 35 Topics', 'icon': HugeIcons.strokeRoundedBookmark01, 'color': Color(0xFFD97706), 'progress': '0%'},
        {'name': 'Geography', 'units': '6 Units • 28 Topics', 'icon': HugeIcons.strokeRoundedCompass, 'color': Color(0xFF16A34A), 'progress': '0%'},
        {'name': 'Economics', 'units': '8 Units • 38 Topics', 'icon': HugeIcons.strokeRoundedCoins01, 'color': Color(0xFF0284C7), 'progress': '0%'},
        {'name': 'English', 'units': '6 Units • 30 Topics', 'icon': HugeIcons.strokeRoundedGlobe02, 'color': Color(0xFF8B5CF6), 'progress': '0%'},
      ];
    }

    return [
      {'name': 'Physics', 'units': '8 Units • 48 Topics', 'icon': HugeIcons.strokeRoundedAtom01, 'color': Color(0xFF0284C7), 'progress': '0%'},
      {'name': 'Mathematics', 'units': '10 Units • 56 Topics', 'icon': HugeIcons.strokeRoundedCalculator01, 'color': AppColors.royalPurple, 'progress': '0%'},
      {'name': 'Chemistry', 'units': '7 Units • 42 Topics', 'icon': HugeIcons.strokeRoundedTestTube01, 'color': Color(0xFF16A34A), 'progress': '0%'},
      {'name': 'Biology', 'units': '6 Units • 36 Topics', 'icon': HugeIcons.strokeRoundedDna, 'color': Color(0xFFD97706), 'progress': '0%'},
      {'name': 'English', 'units': '6 Units • 30 Topics', 'icon': HugeIcons.strokeRoundedGlobe02, 'color': Color(0xFF8B5CF6), 'progress': '0%'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final gradeLabel = widget.user?.gradeLabel ?? 'Grade 12 • Natural Science';

    final allSubjects = _getSubjects();
    final filtered = allSubjects.where((s) {
      if (_filterQuery.isEmpty) return true;
      return s['name'].toString().toLowerCase().contains(_filterQuery.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Screen Headline
          Text(
            'Curriculum Study',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Browse syllabus units, textbook summaries, and revision notes.',
            style: TextStyle(
              fontSize: 13.5,
              color: subtextColor,
            ),
          ),

          const SizedBox(height: 18),

          // Search Field
          AcedexTextField(
            controller: _searchController,
            hint: 'Search subjects or unit topics...',
            prefixIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: subtextColor,
              size: 20,
            ),
            onChanged: (val) {
              setState(() {
                _filterQuery = val.trim();
              });
            },
          ),

          const SizedBox(height: 20),

          // Enrolled Subjects Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ENROLLED SUBJECTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: subtextColor,
                ),
              ),
              Text(
                gradeLabel,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.royalPurple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Subjects List
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text(
                  'No subjects found matching "$_filterQuery"',
                  style: TextStyle(
                    fontSize: 14,
                    color: subtextColor,
                  ),
                ),
              ),
            )
          else
            for (final sub in filtered) ...[
              AcedexCard(
                variant: AcedexCardVariant.raised,
                onTap: () {
                  AcedexToast.show(
                    context,
                    message: 'Opening ${sub['name']} syllabus & units...',
                    type: AcedexToastType.info,
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (sub['color'] as Color).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: HugeIcon(
                        icon: sub['icon'] as dynamic,
                        color: sub['color'] as Color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub['name'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            sub['units'] as String,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      color: subtextColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}
