import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ui.dart';
import '../models/profile_models.dart';

/// EUEE 2026 Exam Registration Details Card with Expandable Accordion
class ExamRegistrationCard extends StatefulWidget {
  final ProfileCandidateRecord record;
  final VoidCallback onEditRegistration;
  final ValueChanged<String> onShowToast;

  const ExamRegistrationCard({
    super.key,
    required this.record,
    required this.onEditRegistration,
    required this.onShowToast,
  });

  @override
  State<ExamRegistrationCard> createState() => _ExamRegistrationCardState();
}

class _ExamRegistrationCardState extends State<ExamRegistrationCard> {
  bool _isAccordionOpen = false;
  bool _isCopiedAdmission = false;
  Timer? _copyTimer;

  @override
  void dispose() {
    _copyTimer?.cancel();
    super.dispose();
  }

  void _handleCopyAdmission() {
    _copyTimer?.cancel();
    Clipboard.setData(ClipboardData(text: widget.record.admissionNo));
    setState(() => _isCopiedAdmission = true);
    widget.onShowToast('Admission Number copied');

    _copyTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _isCopiedAdmission = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoftColor = isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardBg = isDark ? AppColors.darkRaised : AppColors.lightRaised;

    final subjects = ProfileData.subjectsByStream[widget.record.stream] ??
        ProfileData.subjectsByStream['Natural Science']!;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: lineColor),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Title & Confirmed Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EXAM REGISTRATION',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: accentColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF4ADE80).withValues(alpha: 0.16)
                      : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Confirmed',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Structured Key-Value Rows Container
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: lineColor),
            ),
            child: Column(
              children: [
                // Admission Number (Tap to Copy)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Admission Number',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: subtextColor,
                        ),
                      ),
                      AcedexBounceable(
                        onTap: _handleCopyAdmission,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.record.admissionNo,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: _isCopiedAdmission
                                    ? (isDark
                                        ? const Color(0xFF4ADE80).withValues(alpha: 0.16)
                                        : const Color(0xFFDCFCE7))
                                    : accentSoftColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                _isCopiedAdmission ? '✓' : 'Copy',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: _isCopiedAdmission
                                      ? (isDark
                                          ? const Color(0xFF4ADE80)
                                          : const Color(0xFF16A34A))
                                      : accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: lineColor),

                // Exam Center
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Exam Center',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: subtextColor,
                        ),
                      ),
                      Text(
                        '${widget.record.examCenter} (${widget.record.hall})',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: lineColor),

                // Exam Window
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Exam Window',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: subtextColor,
                        ),
                      ),
                      Text(
                        widget.record.examWindow,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: lineColor),

                // Curriculum Track
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Curriculum Track',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: subtextColor,
                        ),
                      ),
                      Text(
                        '${widget.record.grade} • ${widget.record.stream}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Expandable Accordion: View 6 Registered EUEE Subjects
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: lineColor),
            ),
            child: Column(
              children: [
                AcedexBounceable(
                  onTap: () => setState(() => _isAccordionOpen = !_isAccordionOpen),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: accentSoftColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedBookOpen01,
                                color: accentColor,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'View ${subjects.length} Registered EUEE Subjects',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        AnimatedRotation(
                          turns: _isAccordionOpen ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 260),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowDown01,
                            color: subtextColor,
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Accordion Body
                AnimatedSize(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  child: _isAccordionOpen
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: lineColor)),
                          ),
                          child: Column(
                            children: [
                              for (final s in subjects) ...[
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: surfaceColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.name,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w800,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            '${s.code} • ${s.date}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: subtextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: accentSoftColor,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          s.duration,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: accentColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Edit Registration Details CTA Button
          AcedexBounceable(
            onTap: widget.onEditRegistration,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: lineColor),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedEdit02,
                    color: accentColor,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Edit Registration Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
