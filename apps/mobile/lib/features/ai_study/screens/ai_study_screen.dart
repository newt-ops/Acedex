import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/ui/ui.dart';
import '../models/ai_study_models.dart';
import '../services/ai_study_service.dart';
import '../widgets/ai_calibration_flow.dart';
import '../widgets/ai_module_detail_sheet.dart';
import '../widgets/ai_topic_workspace_view.dart';
import '../widgets/ai_welcome_view.dart';

enum _AiStudyPhase {
  welcome,
  calibration,
  workspace,
}

/// Tab 2: AI Cross-Grade Topic Study Program Screen.
///
/// Orchestrates 3 phases backed live by `/api/v1/topics/*` and local cache:
/// - Phase 0 ([AiWelcomeView]): Introduces cross-grade topic study & "Generate Study Program"
/// - Phase 1 ([AiCalibrationFlow]): 5-stage calibration + 1 rewarded ad + Gemini synthesis
/// - Phase 2 ([AiTopicWorkspaceView]): Priority subjects & sequential cross-grade modules
class AiStudyScreen extends StatefulWidget {
  final UserProfile? user;
  final AiStudyRepository? repository;
  final AiTopicProgramOverview? initialOverview;
  final Map<String, List<TopicModuleItem>>? initialModulesBySubject;

  const AiStudyScreen({
    super.key,
    this.user,
    this.repository,
    this.initialOverview,
    this.initialModulesBySubject,
  });

  @override
  State<AiStudyScreen> createState() => _AiStudyScreenState();
}

class _AiStudyScreenState extends State<AiStudyScreen> {
  late final AiStudyRepository _repository;

  _AiStudyPhase _phase = _AiStudyPhase.welcome;
  bool _initialLoading = true;
  bool _loadingModules = false;

  AiTopicProgramOverview? _overview;
  String _selectedSubjectCode = '';
  final Map<String, List<TopicModuleItem>> _modulesBySubject = {};

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AiStudyService.instance;

    if (widget.initialModulesBySubject != null) {
      _modulesBySubject.addAll(widget.initialModulesBySubject!);
    }

    if (widget.initialOverview != null) {
      _applyOverview(widget.initialOverview!);
      _initialLoading = false;
    } else {
      unawaited(_bootstrap());
    }
  }

  Future<void> _bootstrap() async {
    // 1. Hydrate instantaneously from local cache if available
    final cachedOverview = await _repository.getCachedOverview();
    if (mounted && cachedOverview != null) {
      _applyOverview(cachedOverview);
      setState(() => _initialLoading = false);

      if (_selectedSubjectCode.isNotEmpty) {
        final cachedMods =
            await _repository.getCachedSubjectModules(_selectedSubjectCode);
        if (mounted && cachedMods != null && cachedMods.isNotEmpty) {
          setState(() {
            _modulesBySubject[_selectedSubjectCode] = cachedMods;
          });
        }
      }
    }

    // 2. Sync live with MongoDB
    try {
      final liveOverview = await _repository.fetchProgramOverview();
      if (!mounted) return;
      _applyOverview(liveOverview);
      setState(() => _initialLoading = false);
      if (_phase == _AiStudyPhase.workspace && _selectedSubjectCode.isNotEmpty) {
        await _loadSubjectModules(_selectedSubjectCode);
      }
    } catch (_) {
      if (!mounted) return;
      // Offline fresh fallback so Welcome remains crisp
      _overview ??= AiTopicProgramOverview(
        hasProgram: false,
        canGenerateToday: true,
        requiresAd: true,
        subjectSummaries: AiStudyPresets.subjectsForStream(widget.user?.stream)
            .map(
              (s) => AiTopicSubjectSummary(
                subjectCode: s.code,
                subjectName: s.name,
                totalModules: 10,
                completedModules: 0,
                masteryPercentage: 0,
                hasTopicBank: true,
              ),
            )
            .toList(),
      );
      setState(() => _initialLoading = false);
    }
  }

  void _applyOverview(AiTopicProgramOverview overview) {
    _overview = overview;
    if (overview.hasProgram && overview.program != null) {
      _phase = _AiStudyPhase.workspace;
      if (_selectedSubjectCode.isEmpty ||
          !overview.subjectSummaries.any(
            (s) => s.subjectCode.toUpperCase() == _selectedSubjectCode.toUpperCase(),
          )) {
        _selectedSubjectCode = overview.subjectSummaries.isNotEmpty
            ? overview.subjectSummaries.first.subjectCode
            : (overview.program!.calibration.weakSubjectCodes.isNotEmpty
                ? overview.program!.calibration.weakSubjectCodes.first
                : 'PHY');
      }
    } else if (_phase != _AiStudyPhase.calibration) {
      _phase = _AiStudyPhase.welcome;
    }
  }

  Future<void> _loadSubjectModules(String subjectCode) async {
    final normalized = subjectCode.toUpperCase();
    setState(() {
      _selectedSubjectCode = normalized;
      _loadingModules = true;
    });

    try {
      final modules = await _repository.fetchSubjectModules(normalized);
      if (!mounted) return;
      setState(() {
        _modulesBySubject[normalized] = modules;
        _loadingModules = false;
      });
    } catch (_) {
      if (!mounted) return;
      final cached = await _repository.getCachedSubjectModules(normalized);
      if (!mounted) return;
      setState(() {
        if (cached != null) _modulesBySubject[normalized] = cached;
        _loadingModules = false;
      });
    }
  }

  Future<TopicModuleItem?> _updateModuleProgress(
    TopicModuleItem target, {
    int? stepNumber,
    bool? stepCompleted,
    bool? isCompleted,
  }) async {
    try {
      final updated = await _repository.updateModuleProgress(
        moduleId: target.moduleId,
        stepNumber: stepNumber,
        stepCompleted: stepCompleted,
        isCompleted: isCompleted,
      );

      if (!mounted) return updated;

      setState(() {
        final code = updated.subjectCode.toUpperCase();
        final list = List<TopicModuleItem>.from(_modulesBySubject[code] ?? []);
        final idx = list.indexWhere((m) => m.moduleId == updated.moduleId);
        if (idx != -1) {
          list[idx] = updated;
          _modulesBySubject[code] = list;
        }

        // Update summary percentages cleanly without a second blocking reload
        if (_overview != null) {
          final updatedSummaries = _overview!.subjectSummaries.map((s) {
            if (s.subjectCode.toUpperCase() != code) return s;
            final completedCount = list.where((m) => m.isCompleted).length;
            final avgPct = list.isEmpty
                ? s.masteryPercentage
                : (list.fold<int>(0, (acc, m) => acc + m.progressPercentage) /
                        list.length)
                    .round();
            return AiTopicSubjectSummary(
              subjectCode: s.subjectCode,
              subjectName: s.subjectName,
              totalModules: list.isNotEmpty ? list.length : s.totalModules,
              completedModules: completedCount,
              masteryPercentage: avgPct,
              priorityRank: s.priorityRank,
              hasTopicBank: s.hasTopicBank,
            );
          }).toList();

          _overview = AiTopicProgramOverview(
            hasProgram: _overview!.hasProgram,
            canGenerateToday: _overview!.canGenerateToday,
            nextAllowedAt: _overview!.nextAllowedAt,
            requiresAd: _overview!.requiresAd,
            program: _overview!.program,
            subjectSummaries: updatedSummaries,
          );
        }
      });

      return updated;
    } on ApiException catch (e) {
      if (mounted) {
        AcedexToast.show(context, message: e.message, type: AcedexToastType.error);
      }
      return null;
    } catch (_) {
      if (mounted) {
        AcedexToast.show(
          context,
          message: 'Unable to save progress right now.',
          type: AcedexToastType.error,
        );
      }
      return null;
    }
  }

  void _openModuleDetail(TopicModuleItem module) {
    AiModuleDetailSheet.show(
      context,
      module: module,
      onToggleStep: (stepNum, completed) => _updateModuleProgress(
        module,
        stepNumber: stepNum,
        stepCompleted: completed,
      ),
      onToggleMastered: (completed) => _updateModuleProgress(
        module,
        isCompleted: completed,
      ),
    );
  }

  void _handleRecalibrate() {
    final canGen = _overview?.canGenerateToday ?? true;
    if (!canGen) {
      AcedexToast.show(
        context,
        message: 'You can generate a new AI plan once per day. Resets tomorrow.',
        type: AcedexToastType.info,
      );
      return;
    }
    setState(() => _phase = _AiStudyPhase.calibration);
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return const AcedexAiStudySkeleton();
    }

    final overview = _overview ??
        const AiTopicProgramOverview(
          hasProgram: false,
          canGenerateToday: true,
          requiresAd: true,
          subjectSummaries: [],
        );

    switch (_phase) {
      case _AiStudyPhase.welcome:
        return AiWelcomeView(
          user: widget.user,
          canGenerateToday: overview.canGenerateToday,
          requiresAd: overview.requiresAd,
          onStartCalibration: () {
            if (!overview.canGenerateToday) {
              AcedexToast.show(
                context,
                message: 'You already generated an AI plan today. Resets tomorrow.',
                type: AcedexToastType.info,
              );
              return;
            }
            setState(() => _phase = _AiStudyPhase.calibration);
          },
        );

      case _AiStudyPhase.calibration:
        return AiCalibrationFlow(
          user: widget.user,
          repository: _repository,
          canGenerateToday: overview.canGenerateToday,
          requiresAd: overview.requiresAd,
          initialCalibration: overview.program?.calibration,
          onCancel: () {
            setState(() {
              _phase = overview.hasProgram
                  ? _AiStudyPhase.workspace
                  : _AiStudyPhase.welcome;
            });
          },
          onProgramReady: (generatedOverview) {
            setState(() {
              _applyOverview(generatedOverview);
              _phase = _AiStudyPhase.workspace;
            });
            if (_selectedSubjectCode.isNotEmpty) {
              unawaited(_loadSubjectModules(_selectedSubjectCode));
            }
          },
        );

      case _AiStudyPhase.workspace:
        final currentModules =
            _modulesBySubject[_selectedSubjectCode.toUpperCase()] ?? const [];
        return AiTopicWorkspaceView(
          overview: overview,
          selectedSubjectCode: _selectedSubjectCode,
          modules: currentModules,
          isLoadingModules: _loadingModules,
          onSelectSubject: _loadSubjectModules,
          onOpenModule: _openModuleDetail,
          onRecalibrate: _handleRecalibrate,
        );
    }
  }
}
