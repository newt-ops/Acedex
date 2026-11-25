import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../models/study_curriculum_data.dart';
import '../models/study_models.dart';

/// Cupertino Unit Quick Notes & Key Formulas Bottom Sheet
class UnitQuickNotesSheet extends StatefulWidget {
  final StudyUnit unit;
  final SubjectCurriculum subject;
  final VoidCallback onCompleteAndUnlockAssessment;
  final String? primaryActionLabel;

  const UnitQuickNotesSheet({
    super.key,
    required this.unit,
    required this.subject,
    required this.onCompleteAndUnlockAssessment,
    this.primaryActionLabel,
  });

  static Future<void> show(
    BuildContext context, {
    required StudyUnit unit,
    required SubjectCurriculum subject,
    required VoidCallback onCompleteAndUnlockAssessment,
    String? primaryActionLabel,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UnitQuickNotesSheet(
        unit: unit,
        subject: subject,
        onCompleteAndUnlockAssessment: onCompleteAndUnlockAssessment,
        primaryActionLabel: primaryActionLabel,
      ),
    );
  }

  @override
  State<UnitQuickNotesSheet> createState() => _UnitQuickNotesSheetState();
}

class _UnitQuickNotesSheetState extends State<UnitQuickNotesSheet> {
  int? _copiedIndex;
  late UnitNotesData _notes;

  @override
  void initState() {
    super.initState();
    _notes = StudyCurriculumData.getNotesForUnit(
      unitCode: widget.unit.code,
      unitTitle: widget.unit.title,
      subjectName: widget.subject.name,
      examWeight: widget.unit.examWeight,
    );
    unawaited(_loadLiveNotes());
  }

  Future<void> _loadLiveNotes() async {
    final remoteCode = widget.unit.unitCode?.trim();
    if (remoteCode == null || remoteCode.isEmpty) return;

    try {
      final res = await ApiClient.instance.get(
        ApiEndpoints.unitNotes(remoteCode),
        requiresAuth: false,
      );
      final data = res['data'];
      if (data is! Map<String, dynamic>) return;

      final rawPoints = (data['summaryPoints'] as List<dynamic>? ?? [])
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final rawFormulas = (data['formulas'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(
            (f) => UnitFormulaData(
              label: f['label'] as String? ?? 'Key Formula',
              expr: f['expr'] as String? ?? '',
            ),
          )
          .where((f) => f.expr.isNotEmpty)
          .toList();
      final tip = (data['examTip'] as String? ?? '').trim();

      if (rawPoints.isEmpty && rawFormulas.isEmpty && tip.isEmpty) return;
      if (!mounted) return;

      setState(() {
        _notes = UnitNotesData(
          unitCode: data['unitCode'] as String? ?? _notes.unitCode,
          unitTitle: data['unitTitle'] as String? ?? _notes.unitTitle,
          subjectName: widget.subject.name,
          examWeight: (data['examWeight'] as String?)?.isNotEmpty == true
              ? data['examWeight'] as String
              : _notes.examWeight,
          summaryPoints: rawPoints.isNotEmpty ? rawPoints : _notes.summaryPoints,
          formulas: rawFormulas.isNotEmpty ? rawFormulas : _notes.formulas,
          examTip: tip.isNotEmpty ? tip : _notes.examTip,
        );
      });
    } catch (_) {
      // Fall back cleanly to StudyCurriculumData notes when offline or in tests.
    }
  }

  void _handleCopyFormula(int index, String formulaText) {
    Clipboard.setData(ClipboardData(text: formulaText));
    HapticFeedback.lightImpact();
    setState(() => _copiedIndex = index);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copiedIndex = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6);
    final raisedBg = isDark ? const Color(0xFF26262D) : Colors.white;
    final lineBorder = isDark ? const Color(0xFF33333E) : const Color(0xFFE4E4E8);
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    final notes = _notes;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: lineBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 32,
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

            // Sheet Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${notes.unitCode} • ${notes.subjectName.toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              notes.examWeight,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notes.unitTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: theme.colorScheme.onSurface,
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

            const Divider(height: 1),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // =========================================================
                    // 1. CONCISE SYLLABUS SUMMARY
                    // =========================================================
                    Text(
                      'CONCISE SYLLABUS SUMMARY',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: subtextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: lineBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: notes.summaryPoints.map((point) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6, right: 10),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    point,
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.45,
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =========================================================
                    // 2. KEY FORMULAS & EQUATIONS
                    // =========================================================
                    Text(
                      'KEY FORMULAS & EQUATIONS',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: subtextColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...notes.formulas.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final f = entry.value;
                      final isCopied = _copiedIndex == idx;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: isDark ? 0.16 : 0.08),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.22),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      f.label,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: subtextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      f.expr,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'monospace',
                                        letterSpacing: -0.2,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AcedexBounceable(
                                onTap: () => _handleCopyFormula(idx, '${f.label}: ${f.expr}'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: raisedBg,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: lineBorder),
                                  ),
                                  child: Text(
                                    isCopied ? 'Copied ✓' : 'Copy',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isCopied ? AppColors.success : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 12),

                    // =========================================================
                    // 3. EUEE EXAM INSIGHT CALLOUT
                    // =========================================================
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2E2215) : const Color(0xFFFEF3E8),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: (isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309))
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedAlertCircle,
                                color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'EUEE EXAM INSIGHT',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notes.examTip,
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Action CTA
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: lineBorder)),
              ),
              child: AcedexBounceable(
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onCompleteAndUnlockAssessment();
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        widget.primaryActionLabel ??
                            (widget.unit.isCompleted
                                ? 'Unit Completed • Launch Assessment'
                                : 'Mark Unit Complete & Unlock Assessment'),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
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
