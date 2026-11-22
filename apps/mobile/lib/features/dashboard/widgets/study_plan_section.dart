import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../models/dashboard_data.dart';

/// Today's Study Plan (Section 3)
///
/// Features:
/// - Header with dynamic progress badge ("2 of 4 done") & "+ Add" button
/// - Inline Cupertino Task Input Drawer (title text field, subject & duration dropdowns, cancel/save)
/// - Celebratory Banner when 100% of tasks are completed (+50 XP)
/// - Interactive Task Rows with iOS spring squircle checkboxes, "Up Next" highlight,
///   strikethrough text, subject pills with color dots, and duration badges
class StudyPlanSection extends StatefulWidget {
  final List<StudyTaskItem> tasks;
  final ValueChanged<String> onToggleTask;
  final void Function(String title, String subject, String duration) onAddTask;

  const StudyPlanSection({
    super.key,
    required this.tasks,
    required this.onToggleTask,
    required this.onAddTask,
  });

  @override
  State<StudyPlanSection> createState() => _StudyPlanSectionState();
}

class _StudyPlanSectionState extends State<StudyPlanSection> {
  bool _isAddDrawerOpen = false;
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  String _selectedSubject = 'Physics';
  String _selectedDuration = '20m';

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _toggleDrawer([bool? force]) {
    setState(() {
      _isAddDrawerOpen = force ?? !_isAddDrawerOpen;
      if (_isAddDrawerOpen) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) _titleFocusNode.requestFocus();
        });
      } else {
        _titleController.clear();
        _titleFocusNode.unfocus();
      }
    });
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _titleFocusNode.requestFocus();
      return;
    }

    widget.onAddTask(title, _selectedSubject, _selectedDuration);
    _toggleDrawer(false);
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
                    '$completedCount of $totalCount done',
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
              onTap: () => _toggleDrawer(),
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
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedAdd01,
                      color: primaryColor,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
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
        // INLINE CUPERTINO TASK INPUT DRAWER
        // =====================================================================
        AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          child: _isAddDrawerOpen
              ? Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: primaryColor),
                  ),
                  child: Column(
                    children: [
                      // Title Input Field
                      TextField(
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        maxLength: 56,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'e.g., Physics: Capacitor Circuits Review',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: subtextColor,
                          ),
                          filled: true,
                          fillColor: raisedBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: lineBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: lineBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 1.5),
                          ),
                        ),
                        onSubmitted: (_) => _saveTask(),
                      ),

                      const SizedBox(height: 10),

                      // Dropdowns + Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Selects (Subject & Duration)
                          Row(
                            children: [
                              _buildDropdown<String>(
                                value: _selectedSubject,
                                items: const ['Physics', 'Math', 'Chemistry', 'Biology'],
                                onChanged: (v) {
                                  if (v != null) setState(() => _selectedSubject = v);
                                },
                                raisedBg: raisedBg,
                                lineBorder: lineBorder,
                              ),
                              const SizedBox(width: 8),
                              _buildDropdown<String>(
                                value: _selectedDuration,
                                items: const ['15m', '20m', '25m', '30m'],
                                onChanged: (v) {
                                  if (v != null) setState(() => _selectedDuration = v);
                                },
                                raisedBg: raisedBg,
                                lineBorder: lineBorder,
                              ),
                            ],
                          ),

                          // Cancel & Save Buttons
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _toggleDrawer(false),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: subtextColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              AcedexBounceable(
                                onTap: _saveTask,
                                child: Container(
                                  height: 28,
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),

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
        // TASK ROWS
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

            return AcedexBounceable(
              onTap: () => widget.onToggleTask(task.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: rowBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: rowBorder),
                ),
                child: Row(
                  children: [
                    // Spring Animated Squircle Checkbox
                    Container(
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

                    const SizedBox(width: 10),

                    // Task Title & Subject Badge
                    Expanded(
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
                          Row(
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
                                    Text(
                                      task.subject,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isUpNext) ...[
                                const SizedBox(width: 6),
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
                            ],
                          ),
                        ],
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
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required Color raisedBg,
    required Color lineBorder,
  }) {
    final theme = Theme.of(context);

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: raisedBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: lineBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          onChanged: onChanged,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: theme.colorScheme.onSurface,
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                item.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
