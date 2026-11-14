import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/acedex_header_bar.dart';
import '../../assessment/screens/assessment_intro_screen.dart';
import '../providers/curriculum_providers.dart';

class CurriculumScreen extends ConsumerWidget {
  const CurriculumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final selectedGrade = ref.watch(selectedGradeProvider);
    final subjectsAsync = ref.watch(gradeSubjectsWithProgressProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const AcedexFloatingHeaderBar(
        title: 'Curriculum & Units',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Grade Selector Filter Row
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space16,
                vertical: AppTheme.space12,
              ),
              child: Row(
                children: [9, 10, 11, 12].map((grade) {
                  final isSelected = grade == selectedGrade;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: InkWell(
                        onTap: () {
                          ref.read(selectedGradeProvider.notifier).state =
                              grade;
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primary
                                : colors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? colors.primary
                                  : colors.border,
                              width: 1.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Grade $grade',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? colors.onPrimary
                                  : colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Subjects List
            Expanded(
              child: subjectsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                error: (err, stack) => Center(
                  child: Text(
                    'Error loading curriculum: $err',
                    style: TextStyle(color: colors.danger),
                  ),
                ),
                data: (subjects) {
                  if (subjects.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.space24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedBookOpen01,
                              color: colors.textSecondary,
                              size: 40,
                            ),
                            const SizedBox(height: AppTheme.space16),
                            Text(
                              'No Curriculum Found',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppTheme.space8),
                            Text(
                              'Please seed the curriculum database in the Developer Test Lab.',
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space16,
                      vertical: AppTheme.space8,
                    ),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final item = subjects[index];
                      return _SubjectCard(item: item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends ConsumerStatefulWidget {
  const _SubjectCard({required this.item});

  final SubjectWithProgress item;

  @override
  ConsumerState<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends ConsumerState<_SubjectCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final subject = widget.item.subject;
    final total = widget.item.totalUnits;
    final studied = widget.item.studiedUnits;
    final progress = widget.item.progressPercentage;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: colors.border, width: 1.0),
      ),
      child: Column(
        children: [
          // Header Tile
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedBook02,
                          color: colors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppTheme.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$studied of $total units completed',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      HugeIcon(
                        icon: _isExpanded
                            ? HugeIcons.strokeRoundedArrowUp01
                            : HugeIcons.strokeRoundedArrowDown01,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: colors.surfaceAlt,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress == 1.0 ? colors.success : colors.primary,
                      ),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Units Sub-list
          if (_isExpanded) ...[
            Divider(height: 1, color: colors.border),
            _UnitsList(
              subjectId: subject.id,
              subjectName: subject.name,
            ),
          ],
        ],
      ),
    );
  }
}

class _UnitsList extends ConsumerWidget {
  const _UnitsList({
    required this.subjectId,
    required this.subjectName,
  });

  final String subjectId;
  final String subjectName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final unitsAsync = ref.watch(subjectUnitsProvider(subjectId));

    return unitsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppTheme.space16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Text(
          'Error loading units: $err',
          style: TextStyle(color: colors.danger, fontSize: 12),
        ),
      ),
      data: (units) {
        if (units.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppTheme.space16),
            child: Text(
              'No units available for this subject.',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: units.length,
          separatorBuilder: (_, _) =>
              Divider(height: 1, color: colors.border.withValues(alpha: 0.5)),
          itemBuilder: (context, index) {
            final u = units[index];
            final chapter = u.chapter;
            final isStudied = u.isStudied;

            return Padding(
              padding: const EdgeInsets.all(AppTheme.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceAlt,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Unit ${chapter.chapterNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.space12),
                      Expanded(
                        child: Text(
                          chapter.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space12),

                  // Actions Row: Study Toggle & Assessment Unlocker
                  Row(
                    children: [
                      // Toggle Studied Button
                      InkWell(
                        onTap: () async {
                          await ref
                              .read(curriculumServiceProvider)
                              .toggleChapterStudied(chapter.id, isStudied);
                          // Refresh units list and subjects progress
                          ref.invalidate(subjectUnitsProvider(subjectId));
                          ref.invalidate(gradeSubjectsWithProgressProvider);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isStudied
                                ? colors.statusTint(colors.success)
                                : colors.surfaceAlt,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isStudied
                                  ? colors.statusBorder(colors.success)
                                  : colors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: isStudied
                                    ? HugeIcons.strokeRoundedCheckmarkCircle02
                                    : HugeIcons.strokeRoundedCircle,
                                color: isStudied
                                    ? colors.success
                                    : colors.textSecondary,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isStudied ? 'Studied' : 'Mark Studied',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isStudied
                                      ? colors.success
                                      : colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: AppTheme.space8),

                      // Unit Assessment Button (Locked until studied)
                      Expanded(
                        child: isStudied
                            ? InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AssessmentIntroScreen(
                                        chapterId: chapter.id,
                                        unitTitle: chapter.title,
                                        subjectName: subjectName,
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.primarySoft,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: colors.primary,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedTask01,
                                        color: colors.primary,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Take Assessment',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: colors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceAlt
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedLock,
                                      color: colors.textSecondary
                                          .withValues(alpha: 0.6),
                                      size: 13,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Study to unlock assessment',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colors.textSecondary
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
