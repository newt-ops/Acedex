import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/progress/acedex_dots_loader.dart';
import '../models/dashboard_data.dart';

/// Subject Mastery & EUEE Drill Launcher (Section 4)
///
/// Features:
/// - Cupertino Segmented Filter Bar ("All", "Needs Focus", "Strong") with sliding glider
/// - Expandable Subject Cards with progress bars, mastery percentage, and chevron rotation
/// - Grade 12 Syllabus Drawer displaying units and completion percentages
/// - Interactive "Drill" button with compact 3-dots wave loader launching the 3-Q Mini-Drill
class SubjectMasterySection extends StatefulWidget {
  final List<SubjectMasteryItem> subjects;
  final ValueChanged<SubjectMasteryItem> onStartDrill;

  const SubjectMasterySection({
    super.key,
    required this.subjects,
    required this.onStartDrill,
  });

  @override
  State<SubjectMasterySection> createState() => _SubjectMasterySectionState();
}

class _SubjectMasterySectionState extends State<SubjectMasterySection> {
  String _activeFilter = 'all'; // 'all' | 'focus' | 'strong'
  String? _expandedSubjectId;
  String? _loadingDrillSubjectId;

  void _handleDrillTap(SubjectMasteryItem subject) {
    if (_loadingDrillSubjectId != null) return;
    setState(() => _loadingDrillSubjectId = subject.id);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _loadingDrillSubjectId = null);
        widget.onStartDrill(subject);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = isDark
        ? const Color(0xFF1B1B1F)
        : const Color(0xFFF4F4F6);
    final raisedBg = isDark ? const Color(0xFF2B2B31) : Colors.white;
    final lineBorder = isDark
        ? const Color(0xFF2B2B31)
        : const Color(0xFFE4E4E8);
    final subtextColor = isDark
        ? AppColors.darkSubtext
        : AppColors.lightSubtext;

    // Filter logic
    final filteredSubjects = widget.subjects.where((s) {
      if (_activeFilter == 'focus') return s.mastery < 80;
      if (_activeFilter == 'strong') return s.mastery >= 80;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // =====================================================================
        // HEADER: Section Title + Subtitle
        // =====================================================================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subject Mastery',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Tap card for syllabus',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: subtextColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // =====================================================================
        // SEGMENTED FILTER BAR WITH SLIDING GLIDER
        // =====================================================================
        Container(
          height: 32,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: lineBorder),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                alignment: _activeFilter == 'all'
                    ? Alignment.centerLeft
                    : (_activeFilter == 'focus'
                          ? Alignment.center
                          : Alignment.centerRight),
                child: FractionallySizedBox(
                  widthFactor: 1 / 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: raisedBg,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: lineBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterButton(
                      'All',
                      'all',
                      primaryColor,
                      subtextColor,
                    ),
                  ),
                  Expanded(
                    child: _buildFilterButton(
                      'Needs Focus',
                      'focus',
                      primaryColor,
                      subtextColor,
                    ),
                  ),
                  Expanded(
                    child: _buildFilterButton(
                      'Strong',
                      'strong',
                      primaryColor,
                      subtextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // =====================================================================
        // SUBJECT MASTERY CARDS
        // =====================================================================
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredSubjects.length,
          separatorBuilder: (_, i) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final subject = filteredSubjects[index];
            final isExpanded = _expandedSubjectId == subject.id;
            final isStrong = subject.mastery >= 80;
            final accentColor = isStrong
                ? (isDark ? AppColors.darkSuccess : AppColors.success)
                : primaryColor;
            final iconData = getSubjectIconData(subject.name);
            final isLoadingDrill = _loadingDrillSubjectId == subject.id;

            return AcedexBounceable(
              onTap: () {
                setState(() {
                  _expandedSubjectId = isExpanded ? null : subject.id;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isExpanded ? primaryColor : lineBorder,
                  ),
                ),
                child: Column(
                  children: [
                    // Main Card Row
                    Row(
                      children: [
                        // Subject Icon Container
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: HugeIcon(
                            icon: iconData,
                            color: primaryColor,
                            size: 18,
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Title, Chevron, Mastery & Progress
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        subject.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      AnimatedRotation(
                                        turns: isExpanded ? 0.5 : 0.0,
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        child: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 16,
                                          color: subtextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${subject.mastery}%',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: accentColor,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  height: 6,
                                  color: lineBorder,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: (subject.mastery / 100)
                                          .clamp(0.0, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: accentColor,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        // "Drill" Button with 3-Dots Wave Loader
                        AcedexBounceable(
                          onTap: () => _handleDrillTap(subject),
                          child: Container(
                            height: 30,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: isLoadingDrill
                                ? AcedexDotsLoader(
                                    color: primaryColor,
                                    dotSize: 4.0,
                                    gap: 3.0,
                                  )
                                : Text(
                                    'Drill',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: primaryColor,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),

                    // Expandable Grade 12 Syllabus Drawer
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      child: isExpanded
                          ? Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: lineBorder),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'GRADE 12 SYLLABUS UNITS',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                      color: subtextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ...subject.syllabusUnits.map((u) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 3,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              u.unit,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color:
                                                    theme.colorScheme.onSurface,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            u.pct,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: primaryColor,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterButton(
    String label,
    String key,
    Color primaryColor,
    Color subtextColor,
  ) {
    final isActive = _activeFilter == key;

    return GestureDetector(
      onTap: () => setState(() => _activeFilter = key),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 28,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isActive ? primaryColor : subtextColor,
            ),
          ),
        ),
      ),
    );
  }
}
