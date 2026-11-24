import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';
import '../../splash/painters/acedex_logo_painter.dart';
import '../models/ai_study_models.dart';
import '../services/ai_study_service.dart';

/// Phase 1: 5-Stage Apple/Cupertino AI Calibration & Gemini Synthesis Flow.
///
/// Adapted directly from the ACEDEX HTML calibration architecture while enforcing:
/// - Stream strictly locked to [UserProfile.stream] (no stream toggle).
/// - Rewarded ad unlock ("Watch 1 Ad & Generate Plan") + 1-per-day guard.
/// - Native horizontal 3-dots wave loader ([AcedexDotsLoader]) — zero circular spinners.
/// - Strict [HugeIcons] icon usage — zero emojis.
class AiCalibrationFlow extends StatefulWidget {
  final UserProfile? user;
  final AiStudyRepository repository;
  final bool canGenerateToday;
  final bool requiresAd;
  final AiCalibrationInput? initialCalibration;
  final ValueChanged<AiTopicProgramOverview> onProgramReady;
  final VoidCallback onCancel;

  const AiCalibrationFlow({
    super.key,
    required this.user,
    required this.repository,
    required this.canGenerateToday,
    required this.requiresAd,
    this.initialCalibration,
    required this.onProgramReady,
    required this.onCancel,
  });

  @override
  State<AiCalibrationFlow> createState() => _AiCalibrationFlowState();
}

class _AiCalibrationFlowState extends State<AiCalibrationFlow>
    with SingleTickerProviderStateMixin {
  int _step = 1; // 1..4 input steps, 5 = synthesis/blueprint
  bool _isForward = true;
  bool _isSynthesizing = true;
  String? _synthesisError;
  int _completedDiagSteps = 0;

  late String _tierId;
  late int _targetScore;
  late List<String> _weakSubjectCodes;
  late String _budgetId;
  late String _peakWindow;
  late String _prepStageId;

  bool _limitWarnActive = false;
  AiTopicProgramOverview? _generatedOverview;

  late AnimationController _pulseController;
  Timer? _diagTimer;

  String get _lockedStream => AiStudyPresets.normalizeStream(widget.user?.stream);
  List<AiStreamSubjectOption> get _streamSubjects =>
      AiStudyPresets.subjectsForStream(_lockedStream);

  @override
  void initState() {
    super.initState();
    final seed = widget.initialCalibration;
    final defaultSubjects = _lockedStream == 'social' ? ['HIS', 'ECO'] : ['PHY', 'MAT'];

    _tierId = seed?.tierId ?? 'competitive';
    _targetScore = (seed?.targetScore ?? 485).clamp(400, 600);
    _weakSubjectCodes = seed != null && seed.weakSubjectCodes.isNotEmpty
        ? List<String>.from(seed.weakSubjectCodes.take(3))
        : defaultSubjects;

    // Filter out any subjects that do not belong to the locked stream
    final validCodes = _streamSubjects.map((s) => s.code).toSet();
    _weakSubjectCodes = _weakSubjectCodes.where(validCodes.contains).toList();
    if (_weakSubjectCodes.isEmpty) {
      _weakSubjectCodes = defaultSubjects;
    }

    _budgetId = AiStudyPresets.dailyBudgets
        .firstWhere(
          (b) => b.dailyMinutes == (seed?.dailyMinutes ?? 90),
          orElse: () => AiStudyPresets.dailyBudgets[1],
        )
        .id;
    _peakWindow = seed?.peakWindow ?? 'Morning';
    _prepStageId = seed?.prepStageId ?? 'reviewing';

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void dispose() {
    _diagTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _goToStep(int next, {bool forward = true}) {
    _diagTimer?.cancel();
    _pulseController.stop();
    setState(() {
      _step = next.clamp(1, 5);
      _isForward = forward;
    });
  }

  AiDailyBudgetOption get _selectedBudget =>
      AiStudyPresets.dailyBudgets.firstWhere(
        (b) => b.id == _budgetId,
        orElse: () => AiStudyPresets.dailyBudgets[1],
      );

  Future<void> _handleGeneratePressed() async {
    if (!widget.canGenerateToday) {
      AcedexToast.show(
        context,
        message: 'Daily limit reached — you can generate a new AI plan once per day.',
        type: AcedexToastType.warning,
      );
      return;
    }

    String? adSessionId;
    if (widget.requiresAd) {
      final claimedId = await _RewardedAdUnlockSheet.show(
        context,
        onClaimReward: widget.repository.startAndClaimRewardedAd,
      );
      if (claimedId == null || !mounted) return;
      adSessionId = claimedId;
    }

    _startSynthesis(adSessionId: adSessionId);
  }

  Future<void> _startSynthesis({String? adSessionId}) async {
    _pulseController.repeat(reverse: true);
    setState(() {
      _step = 5;
      _isForward = true;
      _isSynthesizing = true;
      _synthesisError = null;
      _completedDiagSteps = 0;
    });

    _diagTimer?.cancel();
    _diagTimer = Timer.periodic(const Duration(milliseconds: 620), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_completedDiagSteps < 3) {
        setState(() => _completedDiagSteps++);
      } else {
        timer.cancel();
      }
    });

    final input = AiCalibrationInput(
      tierId: _tierId,
      targetScore: _targetScore,
      weakSubjectCodes: List<String>.from(_weakSubjectCodes),
      dailyMinutes: _selectedBudget.dailyMinutes,
      peakWindow: _peakWindow,
      prepStageId: _prepStageId,
    );

    try {
      final overview = await widget.repository.generateProgram(
        input,
        adSessionId: adSessionId,
      );
      if (!mounted) return;
      _diagTimer?.cancel();
      _pulseController.stop();
      setState(() {
        _completedDiagSteps = 3;
        _generatedOverview = overview;
        _isSynthesizing = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      _diagTimer?.cancel();
      _pulseController.stop();
      setState(() {
        _isSynthesizing = false;
        _synthesisError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      _diagTimer?.cancel();
      _pulseController.stop();
      setState(() {
        _isSynthesizing = false;
        _synthesisError = 'Unable to reach Gemini planner. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoft = isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final onAccent = isDark ? AppColors.onAccentDark : AppColors.onAccentLight;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final raised = isDark ? AppColors.darkRaised : AppColors.lightRaised;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return Column(
      children: [
        // 1. Top Onboarding Chrome (Back / AI Calibration + Gemini AI Pill + 5-Segment Bar)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_step == 1)
                    Row(
                      children: [
                        AcedexBounceable(
                          onTap: widget.onCancel,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6, top: 2, bottom: 2),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowLeft01,
                              color: accent,
                              size: 18,
                            ),
                          ),
                        ),
                        Text(
                          'AI Calibration',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    )
                  else
                    AcedexBounceable(
                      onTap: _isSynthesizing && _step == 5
                          ? null
                          : () => _goToStep(_step - 1, forward: false),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowLeft01,
                              color: accent,
                              size: 17,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accentSoft,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: accent.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedAiSparkles,
                          color: accent,
                          size: 12,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Gemini AI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 5-Segment Horizontal Animated Progress Bar
              Row(
                children: List.generate(5, (idx) {
                  final filled = idx < _step;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: idx == 4 ? 0 : 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          height: 4,
                          color: line,
                          child: AnimatedFractionallySizedBox(
                            duration: const Duration(milliseconds: 360),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.centerLeft,
                            widthFactor: filled ? 1.0 : 0.0,
                            child: Container(color: accent),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        // 2. Scrollable Stage Content + Sticky Bottom CTA
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 132),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, animation) {
                final beginOffset = Offset(_isForward ? 0.08 : -0.08, 0.0);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: beginOffset,
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey('step_${_step}_${_isSynthesizing}_$_synthesisError'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_step == 1)
                      _buildStep1(context, accent, accentSoft, onAccent, surface, raised, line, subtext)
                    else if (_step == 2)
                      _buildStep2(context, accent, accentSoft, onAccent, surface, raised, line, subtext)
                    else if (_step == 3)
                      _buildStep3(context, accent, accentSoft, onAccent, surface, raised, line, subtext)
                    else if (_step == 4)
                      _buildStep4(context, accent, accentSoft, onAccent, surface, raised, line, subtext)
                    else
                      _buildStep5(context, accent, accentSoft, onAccent, surface, raised, line, subtext),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1(
    BuildContext context,
    Color accent,
    Color accentSoft,
    Color onAccent,
    Color surface,
    Color raised,
    Color line,
    Color subtext,
  ) {
    final streamLabel = AiStudyPresets.streamDisplayLabel(_lockedStream);
    final gradeNum = widget.user?.grade ?? 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'STEP 1 OF 4 • GOAL CALIBRATION',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
            color: accent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "What's your EUEE target?",
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Calibrated strictly for your registered Grade $gradeNum • $streamLabel track.',
          style: TextStyle(fontSize: 12.5, color: subtext),
        ),
        const SizedBox(height: 14),

        // Locked Stream Pill (NO stream toggle per ACEDEX rule)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: line),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accentSoft,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedSquareLock02,
                  color: accent,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registered Academic Track',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: subtext,
                      ),
                    ),
                    Text(
                      'Grade $gradeNum • $streamLabel',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              AcedexBadge(
                label: 'Locked',
                variant: AcedexBadgeVariant.neutral,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 3 Interactive Score Tier Cards
        ...AiStudyPresets.scoreTiers.map((tier) {
          final selected = _tierId == tier.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AcedexBounceable(
              onTap: () {
                setState(() {
                  _tierId = tier.id;
                  _targetScore = tier.defaultScore;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? accentSoft : surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? accent : line,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            children: [
                              Text(
                                tier.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              if (tier.recommended)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accent,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'Recommended',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: onAccent,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tier.subtitle,
                            style: TextStyle(fontSize: 11.5, color: subtext),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _CheckCircle(
                      selected: selected,
                      accent: accent,
                      onAccent: onAccent,
                      raised: raised,
                      line: line,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        // Fine-Tune Slider Card (400-600)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: line),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Fine-Tune Target Score',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$_targetScore / 600 pts',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: accent,
                  inactiveTrackColor: line,
                  thumbColor: Colors.white,
                  overlayColor: accent.withValues(alpha: 0.14),
                ),
                child: Slider(
                  value: _targetScore.toDouble(),
                  min: 400,
                  max: 600,
                  divisions: 40,
                  onChanged: (val) {
                    final rounded = val.round();
                    setState(() {
                      _targetScore = rounded;
                      if (rounded < 460) {
                        _tierId = 'solid';
                      } else if (rounded < 530) {
                        _tierId = 'competitive';
                      } else {
                        _tierId = 'merit';
                      }
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('400 Pass', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: subtext)),
                  Text('500 Honors', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: subtext)),
                  Text('600 Max', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: subtext)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),
        AcedexButton(
          label: 'Continue',
          size: AcedexButtonSize.lg,
          trailingIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowRight01,
            color: onAccent,
            size: 18,
          ),
          onPressed: () => _goToStep(2, forward: true),
        ),
      ],
    );
  }

  Widget _buildStep2(
    BuildContext context,
    Color accent,
    Color accentSoft,
    Color onAccent,
    Color surface,
    Color raised,
    Color line,
    Color subtext,
  ) {
    final subjects = _streamSubjects;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'STEP 2 OF 4 • DIAGNOSTIC FOCUS',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: _limitWarnActive
                    ? AppColors.warning.withValues(alpha: 0.16)
                    : accentSoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _limitWarnActive
                    ? 'Max 3 Selected'
                    : '${_weakSubjectCodes.length} / 3 Selected',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: _limitWarnActive ? AppColors.warning : accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Which subjects need a boost?',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pick 1 to 3 subjects. Gemini assigns Priority #1–#3 topic modules here.',
          style: TextStyle(fontSize: 12.5, color: subtext),
        ),
        const SizedBox(height: 14),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subjects.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.32,
          ),
          itemBuilder: (context, idx) {
            final subj = subjects[idx];
            final rankIdx = _weakSubjectCodes.indexOf(subj.code);
            final selected = rankIdx != -1;

            return AcedexBounceable(
              onTap: () {
                if (selected) {
                  setState(() {
                    _weakSubjectCodes.removeAt(rankIdx);
                    _limitWarnActive = false;
                  });
                } else if (_weakSubjectCodes.length < 3) {
                  setState(() {
                    _weakSubjectCodes.add(subj.code);
                    _limitWarnActive = false;
                  });
                } else {
                  setState(() => _limitWarnActive = true);
                  Future.delayed(const Duration(milliseconds: 950), () {
                    if (mounted) setState(() => _limitWarnActive = false);
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected ? accentSoft : surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? accent : line,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: raised,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: line),
                          ),
                          alignment: Alignment.center,
                          child: HugeIcon(
                            icon: subj.icon,
                            color: selected ? accent : subtext,
                            size: 18,
                          ),
                        ),
                        Container(
                          height: 24,
                          constraints: const BoxConstraints(minWidth: 26),
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          decoration: BoxDecoration(
                            color: selected ? accent : raised,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: selected ? accent : line),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            selected ? '#${rankIdx + 1}' : '+',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: selected ? onAccent : subtext,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subj.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          selected ? 'Priority #${rankIdx + 1} • 10 Modules' : subj.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: selected ? accent : subtext,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 18),
        AcedexButton(
          label: _weakSubjectCodes.isEmpty ? 'Select at least 1 subject' : 'Continue',
          size: AcedexButtonSize.lg,
          trailingIcon: _weakSubjectCodes.isNotEmpty
              ? HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  color: onAccent,
                  size: 18,
                )
              : null,
          onPressed: _weakSubjectCodes.isEmpty
              ? null
              : () => _goToStep(3, forward: true),
        ),
      ],
    );
  }

  Widget _buildStep3(
    BuildContext context,
    Color accent,
    Color accentSoft,
    Color onAccent,
    Color surface,
    Color raised,
    Color line,
    Color subtext,
  ) {
    final activePeak = AiStudyPresets.peakWindows.firstWhere(
      (p) => p.id == _peakWindow,
      orElse: () => AiStudyPresets.peakWindows[0],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'STEP 3 OF 4 • TIME ARCHITECTURE',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
            color: accent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Daily study commitment?',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Gemini paces your daily topic blocks to prevent burnout.',
          style: TextStyle(fontSize: 12.5, color: subtext),
        ),
        const SizedBox(height: 14),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: AiStudyPresets.dailyBudgets.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.38,
          ),
          itemBuilder: (context, idx) {
            final b = AiStudyPresets.dailyBudgets[idx];
            final selected = _budgetId == b.id;

            return AcedexBounceable(
              onTap: () => setState(() => _budgetId = b.id),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected ? accentSoft : surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? accent : line,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: selected ? accent : raised,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              b.tag,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: selected ? onAccent : subtext,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _CheckCircle(
                          selected: selected,
                          accent: accent,
                          onAccent: onAccent,
                          raised: raised,
                          line: line,
                          size: 20,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.label,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          b.weeklyLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: selected ? accent : subtext,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 14),

        // Peak Focus Window Cupertino Segmented Control
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: line),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Peak Focus Window',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Best Energy',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: raised,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: line),
                ),
                child: Row(
                  children: AiStudyPresets.peakWindows.map((pw) {
                    final active = pw.id == _peakWindow;
                    return Expanded(
                      child: AcedexBounceable(
                        onTap: () => setState(() => _peakWindow = pw.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(
                            vertical: 9,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: active ? accentSoft : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                HugeIcon(
                                  icon: pw.icon,
                                  color: active ? accent : subtext,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  pw.label,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: active ? accent : subtext,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                activePeak.hint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: subtext,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),
        AcedexButton(
          label: 'Continue',
          size: AcedexButtonSize.lg,
          trailingIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowRight01,
            color: onAccent,
            size: 18,
          ),
          onPressed: () => _goToStep(4, forward: true),
        ),
      ],
    );
  }

  Widget _buildStep4(
    BuildContext context,
    Color accent,
    Color accentSoft,
    Color onAccent,
    Color surface,
    Color raised,
    Color line,
    Color subtext,
  ) {
    final ctaLabel = !widget.canGenerateToday
        ? 'Daily Plan Already Generated Today'
        : widget.requiresAd
            ? 'Watch 1 Ad & Generate Plan'
            : 'Generate AI Study Plan';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'STEP 4 OF 4 • BASELINE CHECK',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
            color: accent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Where are you in your prep?',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Balances textbook concept modules against mastery checkpoints.',
          style: TextStyle(fontSize: 12.5, color: subtext),
        ),
        const SizedBox(height: 14),

        ...AiStudyPresets.prepStages.map((stage) {
          final selected = _prepStageId == stage.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AcedexBounceable(
              onTap: () => setState(() => _prepStageId = stage.id),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? accentSoft : surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? accent : line,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stage.title,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                stage.ratioText,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: subtext,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _CheckCircle(
                          selected: selected,
                          accent: accent,
                          onAccent: onAccent,
                          raised: raised,
                          line: line,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 8,
                        padding: const EdgeInsets.all(1.5),
                        color: raised,
                        child: Row(
                          children: [
                            Expanded(
                              flex: stage.notesPct,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              flex: stage.drillsPct,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.34),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 8),

        // Rewarded Ad & 1-Per-Day Policy Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: line),
          ),
          child: Row(
            children: [
              HugeIcon(
                icon: widget.canGenerateToday
                    ? HugeIcons.strokeRoundedPlay
                    : HugeIcons.strokeRoundedClock01,
                color: widget.canGenerateToday ? accent : AppColors.warning,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.canGenerateToday
                      ? (widget.requiresAd
                          ? 'Watch 1 short rewarded ad to generate your personalized Gemini study program (1 generation per day).'
                          : 'Ready to generate your personalized Gemini study program (1 generation per day).')
                      : 'You already generated an AI plan today. You can regenerate again tomorrow.',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: subtext,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        AcedexButton(
          label: ctaLabel,
          size: AcedexButtonSize.lg,
          leadingIcon: HugeIcon(
            icon: widget.canGenerateToday
                ? HugeIcons.strokeRoundedAiSparkles
                : HugeIcons.strokeRoundedClock01,
            color: onAccent,
            size: 18,
          ),
          onPressed: widget.canGenerateToday ? _handleGeneratePressed : null,
        ),
      ],
    );
  }

  Widget _buildStep5(
    BuildContext context,
    Color accent,
    Color accentSoft,
    Color onAccent,
    Color surface,
    Color raised,
    Color line,
    Color subtext,
  ) {
    if (_isSynthesizing) {
      final weakNames = _weakSubjectCodes.join(', ');
      final diagSteps = [
        'Weighting Grade ${widget.user?.grade ?? 12} ${AiStudyPresets.streamDisplayLabel(_lockedStream)} topic bank...',
        'Allocating priority hours to $weakNames...',
        'Scheduling $_peakWindow focus modules with exact page citations...',
      ];

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    const Color(0xFF1B1820),
                    const Color(0xFF24192A),
                    const Color(0xFF2F1D39),
                  ]
                : [
                    Colors.white,
                    const Color(0xFFFAF2FC),
                    const Color(0xFFF0DDF6),
                  ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: line),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 0.96 + 0.08 * _pulseController.value;
                return Transform.scale(scale: scale, child: child);
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: raised,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: line),
                    ),
                    child: CustomPaint(
                      painter: AcedexLogoPainter(
                        archSpring: 1.0,
                        waveSpring: 1.0,
                        orbSpring: 1.0,
                        showOrb: true,
                        color: accent,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: raised, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedAiSparkles,
                        color: onAccent,
                        size: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'GEMINI AI SYNTHESIS',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
                color: accent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Calibrating your topic blueprint',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            AcedexDotsLoader(color: accent, dotSize: 7, gap: 6),
            const SizedBox(height: 20),

            ...List.generate(diagSteps.length, (i) {
              final done = i < _completedDiagSteps;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 280),
                  opacity: done ? 1.0 : 0.48,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      color: raised,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: done ? accent : line),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: done
                                ? AppColors.success.withValues(alpha: 0.16)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: done ? AppColors.success : line,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: done
                              ? HugeIcon(
                                  icon: HugeIcons.strokeRoundedTick02,
                                  color: AppColors.success,
                                  size: 12,
                                )
                              : Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            diagSteps[i],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
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
      );
    }

    if (_synthesisError != null || _generatedOverview?.program == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: line),
        ),
        child: Column(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedRefresh,
              color: AppColors.warning,
              size: 32,
            ),
            const SizedBox(height: 10),
            Text(
              'Could Not Generate Blueprint',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _synthesisError ?? 'Unexpected planner error. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: subtext),
            ),
            const SizedBox(height: 16),
            AcedexButton(
              label: 'Back to Step 4',
              onPressed: () => _goToStep(4, forward: false),
            ),
          ],
        ),
      );
    }

    final overview = _generatedOverview!;
    final program = overview.program!;
    final opacities = [1.0, 0.80, 0.62, 0.42, 0.25];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Blueprint Hero Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accentSoft,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accent.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedAiSparkles,
                            color: onAccent,
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              program.generatedBy == 'gemini'
                                  ? 'GEMINI AI BLUEPRINT'
                                  : 'SMART TOPIC BLUEPRINT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: onAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+10 pts buffer',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Projected EUEE Readiness',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: subtext),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${program.projectedScore}',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/ 600',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'DAILY PACE',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: subtext,
                          ),
                        ),
                        Text(
                          '${_selectedBudget.label} • ${program.calibration.peakWindow}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                program.diagnosticSummary,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                  color: subtext,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. Stacked Royal Purple Weekly Allocation Bar
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'WEEKLY SUBJECT ALLOCATION',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedBudget.weeklyLabel,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 10,
                  color: raised,
                  child: Row(
                    children: List.generate(program.subjectAllocations.length, (i) {
                      final alloc = program.subjectAllocations[i];
                      return Expanded(
                        flex: alloc.sharePercentage.clamp(5, 100),
                        child: Container(
                          color: accent.withValues(alpha: opacities[i % opacities.length]),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: List.generate(program.subjectAllocations.length, (i) {
                  final alloc = program.subjectAllocations[i];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: raised,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: alloc.priorityRank != null
                            ? accent.withValues(alpha: 0.35)
                            : line,
                      ),
                    ),
                    child: Text(
                      alloc.priorityRank != null
                          ? '#${alloc.priorityRank} ${alloc.subjectName} • ${alloc.formattedWeeklyHours}'
                          : '${alloc.subjectName} • ${alloc.formattedWeeklyHours}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: alloc.priorityRank != null
                            ? accent
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 3. Today's Recommended Focus Modules (with Textbook Citations)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TODAY'S PRIORITY TOPIC BLOCKS",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              ...program.dailyFocusTasks.map((task) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: raised,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AcedexBadge(
                            label: '${task.durationMinutes}m',
                            variant: AcedexBadgeVariant.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${task.subjectName} • ${task.priorityTag}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                      if (task.whereToRead.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Read: ${task.whereToRead}',
                          style: TextStyle(fontSize: 11, color: subtext),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        AcedexButton(
          label: 'Start Topic Study Program',
          size: AcedexButtonSize.lg,
          trailingIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowRight01,
            color: onAccent,
            size: 18,
          ),
          onPressed: () => widget.onProgramReady(overview),
        ),
      ],
    );
  }
}

class _CheckCircle extends StatelessWidget {
  final bool selected;
  final Color accent;
  final Color onAccent;
  final Color raised;
  final Color line;
  final double size;

  const _CheckCircle({
    required this.selected,
    required this.accent,
    required this.onAccent,
    required this.raised,
    required this.line,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: selected ? accent : raised,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? accent : line,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? HugeIcon(
              icon: HugeIcons.strokeRoundedTick02,
              color: onAccent,
              size: size * 0.56,
            )
          : null,
    );
  }
}

/// Rewarded Ad Playback & Unlock Dialog gating AI Study Program Generation.
class _RewardedAdUnlockSheet extends StatefulWidget {
  final Future<String> Function() onClaimReward;

  const _RewardedAdUnlockSheet({required this.onClaimReward});

  static Future<String?> show(
    BuildContext context, {
    required Future<String> Function() onClaimReward,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _RewardedAdUnlockSheet(onClaimReward: onClaimReward),
    );
  }

  @override
  State<_RewardedAdUnlockSheet> createState() => _RewardedAdUnlockSheetState();
}

class _RewardedAdUnlockSheetState extends State<_RewardedAdUnlockSheet> {
  int _secondsRemaining = 3;
  bool _claiming = false;
  String? _errorText;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = 3;
      _errorText = null;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _claimNow();
      }
    });
  }

  Future<void> _claimNow() async {
    setState(() {
      _secondsRemaining = 0;
      _claiming = true;
    });
    try {
      final adSessionId = await widget.onClaimReward();
      if (!mounted) return;
      Navigator.of(context).pop(adSessionId);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _claiming = false;
        _errorText = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _claiming = false;
        _errorText = 'Could not verify rewarded ad. Please retry.';
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoft = isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: line)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: line,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accentSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedPlay,
                color: accent,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _claiming ? 'Unlocking Gemini AI...' : 'Rewarded Ad Unlock',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorText ??
                  (_claiming
                      ? 'Confirming ad reward before building your cross-grade topic roadmap.'
                      : 'Supporting ACEDEX free AI planning • Unlocking in ${_secondsRemaining}s...'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: subtext, height: 1.4),
            ),
            const SizedBox(height: 18),
            AcedexDotsLoader(color: accent, dotSize: 7, gap: 6),
            const SizedBox(height: 16),
            if (_errorText != null)
              Row(
                children: [
                  Expanded(
                    child: AcedexButton(
                      label: 'Cancel',
                      variant: AcedexButtonVariant.outline,
                      onPressed: () => Navigator.of(context).pop(null),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AcedexButton(
                      label: 'Retry Ad',
                      onPressed: _startCountdown,
                    ),
                  ),
                ],
              )
            else
              AcedexButton(
                label: 'Cancel',
                variant: AcedexButtonVariant.ghost,
                onPressed: _claiming ? null : () => Navigator.of(context).pop(null),
              ),
          ],
        ),
      ),
    );
  }
}
