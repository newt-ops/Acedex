import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/feedback/acedex_dialog.dart';
import '../models/dashboard_data.dart';
import 'add_study_plan_sheet.dart';

/// Today's Study Plan (Section 3)
///
/// Features:
/// - Header with dynamic progress badge & "+ Add" button
/// - Opens Apple-style Cupertino `AddStudyPlanSheet` modal
/// - Clean empty state when no tasks are planned yet
/// - Celebratory Banner when 100% of tasks are completed (+50 XP)
/// - Interactive Task Rows with iOS spring squircle checkboxes, "Up Next" highlight,
///   strikethrough text, subject pills with color dots, time spans, and duration badges
/// - Deletable tasks with one-tap delete button
class StudyPlanSection extends StatefulWidget {
  final List<StudyTaskItem> tasks;
  final ValueChanged<String> onToggleTask;
  final void Function(String title, String subject, String duration) onAddTask;
  final ValueChanged<String>? onDeleteTask;
  final ValueChanged<StudyTaskItem>? onAddStudyPlan;

  const StudyPlanSection({
    super.key,
    required this.tasks,
    required this.onToggleTask,
    required this.onAddTask,
    this.onDeleteTask,
    this.onAddStudyPlan,
  });

  @override
  State<StudyPlanSection> createState() => _StudyPlanSectionState();
}

class _StudyPlanSectionState extends State<StudyPlanSection> {
  void _openAddModal() {
    AddStudyPlanSheet.show(
      context,
      onSave: (task) {
        if (widget.onAddStudyPlan != null) {
          widget.onAddStudyPlan!(task);
        } else {
          widget.onAddTask(task.title, task.subject, task.duration);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6);
    final raisedBg = isDark ? const Color(0xFF2B2B31) : Colors.white;
    final lineBorder = isDark ? const Color(0xFF2B2B31) : const Color(0xFFE4E4E8);
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    final completedCount = widget.tasks.where((t) => t.completed).length;
    final totalCount = widget.tasks.length;
    final isAllDone = totalCount > 0 && completedCount == totalCount;
    final firstUncheckedIdx = widget.tasks.indexWhere((t) => !t.completed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // =====================================================================
        // HEADER: Title + Progress Badge + "+ Add" Button
        // =====================================================================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "Today's Study Plan",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    totalCount == 0 ? '0 planned' : '$completedCount of $totalCount done',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),

            AcedexBounceable(
              onTap: _openAddModal,
              child: Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: lineBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // =====================================================================
        // EMPTY STATE (NO TASKS)
        // =====================================================================
        if (widget.tasks.isEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: lineBorder),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar03,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'No Tasks Planned Yet',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Schedule your daily study sessions to master EUEE units.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: subtextColor,
                  ),
                ),
                const SizedBox(height: 14),
                AcedexBounceable(
                  onTap: _openAddModal,
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Add Study Plan',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // =====================================================================
          // CELEBRATORY BANNER (100% COMPLETE)
          // =====================================================================
          if (isAllDone) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkSuccess : AppColors.success)
                    .withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkSuccess : AppColors.success,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                        color: isDark ? AppColors.darkSuccess : AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'All daily goals complete! +50 XP',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkSuccess : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '100%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.darkSuccess : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // =====================================================================
          // TASK ROWS (DELETABLE)
          // =====================================================================
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.tasks.length,
            separatorBuilder: (_, i) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final task = widget.tasks[index];
              final isUpNext = !task.completed && index == firstUncheckedIdx;
              final dotColor = getSubjectColor(task.subject);

              final rowBg = isUpNext
                  ? (isDark
                      ? primaryColor.withValues(alpha: 0.18)
                      : primaryColor.withValues(alpha: 0.08))
                  : surfaceColor;
              final rowBorder = isUpNext ? primaryColor : lineBorder;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: rowBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: rowBorder),
                ),
                child: Row(
                  children: [
                    // Spring Animated Squircle Checkbox
                    AcedexBounceable(
                      onTap: () => widget.onToggleTask(task.id),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: task.completed ? primaryColor : raisedBg,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: task.completed ? primaryColor : subtextColor,
                            width: 1.8,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: task.completed
                            ? const Icon(
                                Icons.check_rounded,
                                size: 15,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Task Title & Subject Badge
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.onToggleTask(task.id),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.1,
                                color: task.completed
                                    ? subtextColor
                                    : theme.colorScheme.onSurface,
                                decoration: task.completed
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 5,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: raisedBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: lineBorder),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: dotColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 85),
                                        child: Text(
                                          task.subject,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (task.timeSpan != null && task.timeSpan!.isNotEmpty)
                                  Text(
                                    task.timeSpan!,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w500,
                                      color: subtextColor,
                                    ),
                                  ),
                                if (task.focusMode != null && task.focusMode!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      task.focusMode!,
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w700,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                if (isUpNext)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'UP NEXT',
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Duration Badge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: raisedBg,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: lineBorder),
                      ),
                      child: Text(
                        task.duration,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: subtextColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),

                    // Deletable action button with custom Acedex confirmation modal
                    if (widget.onDeleteTask != null) ...[
                      const SizedBox(width: 6),
                      AcedexBounceable(
                        onTap: () async {
                          final confirmed = await showAcedexConfirmDialog(
                            context,
                            title: 'Delete Task',
                            message: 'Are you sure you want to remove "${task.title}" from today\'s plan?',
                            confirmLabel: 'Delete',
                            cancelLabel: 'Keep',
                            isDestructive: true,
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedDelete02,
                              color: Color(0xFFEF4444),
                              size: 22,
                            ),
                          );
                          if (confirmed == true && context.mounted) {
                            widget.onDeleteTask!(task.id);
                          }
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedDelete02,
                            size: 14,
                            color: subtextColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
