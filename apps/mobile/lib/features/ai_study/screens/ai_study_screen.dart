import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/ads/ads.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/ui/ui.dart';
import '../models/ai_study_models.dart';
import '../screens/ai_calibration_screen.dart';
import '../services/ai_study_service.dart';
import '../widgets/ai_module_detail_sheet.dart';
import '../widgets/ai_topic_workspace_view.dart';
import '../widgets/ai_welcome_view.dart';

enum _AiStudyPhase { welcome, workspace }

/// Tab 2: AI Cross-Grade Topic Study Program Screen.
///
/// Orchestrates Phase 0 ([AiWelcomeView]) and Phase 2 ([AiTopicWorkspaceView]),
/// pushing [AiCalibrationScreen] as a full-screen route (no header/footer bar)
/// when generating or recalibrating an AI study program.
class AiStudyScreen extends StatefulWidget {
  final UserProfile? user;
  final AiStudyRepository? repository;
  final AcedexAdsRepository? adsRepository;
  final AiTopicProgramOverview? initialOverview;
  final Map<String, List<TopicModuleItem>>? initialModulesBySubject;

  const AiStudyScreen({
    super.key,
    this.user,
    this.repository,
    this.adsRepository,
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
  String? _modulesError;

  AiTopicProgramOverview? _overview;
  String _selectedSubjectCode = '';
  final Map<String, List<TopicModuleItem>> _modulesBySubject = {};

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AiStudyService.instance;
    AuthStorage.instance.completedUnitsNotifier.addListener(
      _onExternalUnitCompletionsChanged,
    );

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

  @override
  void dispose() {
    AuthStorage.instance.completedUnitsNotifier.removeListener(
      _onExternalUnitCompletionsChanged,
    );
    super.dispose();
  }

  void _onExternalUnitCompletionsChanged() {
    if (!mounted || _modulesBySubject.isEmpty) return;
    final completedSet = AuthStorage.instance.completedUnitsNotifier.value;
    var anyChanged = false;

    final updatedBySubject = <String, List<TopicModuleItem>>{};
    for (final entry in _modulesBySubject.entries) {
      var listChanged = false;
      final updatedList = entry.value.map((mod) {
        var modChanged = false;
        final updatedRefs = mod.references.map((r) {
          final code = r.unitCode.toUpperCase().trim();
          final shouldDone = completedSet.contains(code);
          if (r.isUnitCompleted != shouldDone) {
            modChanged = true;
            listChanged = true;
            anyChanged = true;
            return r.copyWith(isUnitCompleted: shouldDone);
          }
          return r;
        }).toList();
        return modChanged ? mod.copyWith(references: updatedRefs) : mod;
      }).toList();

      updatedBySubject[entry.key] = listChanged ? updatedList : entry.value;
    }

    if (anyChanged) {
      setState(() {
        _modulesBySubject
          ..clear()
          ..addAll(updatedBySubject);
      });
    }
  }

  Future<void> _bootstrap() async {
    final cachedOverview = await _repository.getCachedOverview();
    if (mounted && cachedOverview != null) {
      _applyOverview(cachedOverview);
      setState(() => _initialLoading = false);

      if (_selectedSubjectCode.isNotEmpty) {
        final cachedMods = await _repository.getCachedSubjectModules(
          _selectedSubjectCode,
        );
        if (mounted && cachedMods != null && cachedMods.isNotEmpty) {
          setState(() {
            _modulesBySubject[_selectedSubjectCode] = cachedMods;
          });
        }
      }
    }

    try {
      final liveOverview = await _repository.fetchProgramOverview();
      if (!mounted) return;
      _applyOverview(liveOverview);
      setState(() => _initialLoading = false);
      if (_phase == _AiStudyPhase.workspace &&
          _selectedSubjectCode.isNotEmpty) {
        await _loadSubjectModules(_selectedSubjectCode);
      }
    } catch (_) {
      if (!mounted) return;
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
            (s) =>
                s.subjectCode.toUpperCase() ==
                _selectedSubjectCode.toUpperCase(),
          )) {
        _selectedSubjectCode = overview.subjectSummaries.isNotEmpty
            ? overview.subjectSummaries.first.subjectCode
            : (overview.program!.calibration.weakSubjectCodes.isNotEmpty
                  ? overview.program!.calibration.weakSubjectCodes.first
                  : 'PHY');
      }
    } else {
      _phase = _AiStudyPhase.welcome;
    }
  }

  Future<void> _loadSubjectModules(String subjectCode) async {
    final normalized = subjectCode.toUpperCase().trim();
    if (normalized.isEmpty) return;

    setState(() {
      _selectedSubjectCode = normalized;
      _modulesError = null;
      _loadingModules = true;
    });

    if (!_modulesBySubject.containsKey(normalized)) {
      final cachedFirst = await _repository.getCachedSubjectModules(normalized);
      if (!mounted || _selectedSubjectCode != normalized) return;
      if (cachedFirst != null && cachedFirst.isNotEmpty) {
        setState(() {
          _modulesBySubject[normalized] = cachedFirst;
        });
      }
    }

    try {
      final modules = await _repository.fetchSubjectModules(normalized);
      if (!mounted) return;
      setState(() {
        _modulesBySubject[normalized] = modules;
        if (_selectedSubjectCode == normalized) {
          _modulesError = null;
          _loadingModules = false;
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      final cached = await _repository.getCachedSubjectModules(normalized);
      if (!mounted) return;
      setState(() {
        if (cached != null && cached.isNotEmpty) {
          _modulesBySubject[normalized] = cached;
        }
        if (_selectedSubjectCode == normalized) {
          final hasAny =
              (_modulesBySubject[normalized] ?? const []).isNotEmpty;
          _modulesError = hasAny ? null : e.message;
          _loadingModules = false;
        }
      });
    } catch (_) {
      if (!mounted) return;
      final cached = await _repository.getCachedSubjectModules(normalized);
      if (!mounted) return;
      setState(() {
        if (cached != null && cached.isNotEmpty) {
          _modulesBySubject[normalized] = cached;
        }
        if (_selectedSubjectCode == normalized) {
          final hasAny =
              (_modulesBySubject[normalized] ?? const []).isNotEmpty;
          _modulesError = hasAny
              ? null
              : 'Unable to load topic modules for $normalized right now.';
          _loadingModules = false;
        }
      });
    }
  }

  Future<void> _openDailyTask(AiDailyTaskItem task) async {
    final code = task.subjectCode.toUpperCase().trim();
    if (code.isEmpty) return;

    if (code != _selectedSubjectCode.toUpperCase() ||
        (_modulesBySubject[code] ?? const []).isEmpty) {
      await _loadSubjectModules(code);
    }

    if (!mounted) return;
    final list = _modulesBySubject[code] ?? const [];
    if (list.isEmpty) return;

    final match = list.firstWhere(
      (m) => m.moduleId.toUpperCase() == task.moduleId.toUpperCase(),
      orElse: () => list.first,
    );
    _openModuleDetail(match);
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
        existingModule: target,
        stepNumber: stepNumber,
        stepCompleted: stepCompleted,
        isCompleted: isCompleted,
      );

      if (!mounted) return updated;

      final code = updated.subjectCode.toUpperCase();
      final list = List<TopicModuleItem>.from(_modulesBySubject[code] ?? []);
      setState(() {
        final idx = list.indexWhere((m) => m.moduleId == updated.moduleId);
        if (idx != -1) {
          list[idx] = updated;
        } else {
          list.add(updated);
        }
        _modulesBySubject[code] = list;

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

      unawaited(_repository.saveCachedSubjectModules(code, list));
      if (_overview != null) {
        unawaited(_repository.saveCachedOverview(_overview!));
      }

      if (stepCompleted != null) {
        unawaited(
          AuthStorage.instance.addDailyFocusMinutes(stepCompleted ? 10 : -10),
        );
      } else if (isCompleted != null) {
        unawaited(
          AuthStorage.instance.addDailyFocusMinutes(isCompleted ? 15 : -15),
        );
      }

      if (mounted &&
          updated.coinsAwarded != null &&
          updated.coinsAwarded! > 0) {
        AcedexToast.show(
          context,
          message: '+${updated.coinsAwarded} Ace Coins earned!',
          type: AcedexToastType.success,
        );
      }

      return updated;
    } on ApiException catch (e) {
      if (mounted) {
        AcedexToast.show(
          context,
          message: e.message,
          type: AcedexToastType.error,
        );
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

  Future<TopicModuleItem?> _toggleReferencedUnitMastery(
    TopicModuleItem target,
    TopicReadingReference ref,
    bool completed,
  ) async {
    final unitCode = ref.unitCode.toUpperCase().trim();
    try {
      await AuthStorage.instance.setUnitCompletion(unitCode, completed);

      final result = await _repository.toggleUnitMastery(
        unitCode: unitCode,
        completed: completed,
        moduleId: target.moduleId,
      );

      if (!mounted) return null;

      TopicModuleItem? refreshedTarget;
      final touchedSubjects = <String>{};

      setState(() {
        for (final entry in _modulesBySubject.entries) {
          var listChanged = false;
          final updatedList = entry.value.map((mod) {
            var modChanged = false;
            final updatedRefs = mod.references.map((r) {
              if (r.unitCode.toUpperCase().trim() == unitCode) {
                modChanged = true;
                return r.copyWith(isUnitCompleted: result.isStudyCompleted);
              }
              return r;
            }).toList();

            var nextMod = modChanged ? mod.copyWith(references: updatedRefs) : mod;

            if (mod.moduleId == target.moduleId &&
                result.updatedCompletedSteps != null) {
              modChanged = true;
              nextMod = nextMod.copyWith(
                completedSteps: result.updatedCompletedSteps,
                isCompleted: result.updatedModuleCompleted ?? nextMod.isCompleted,
                progressPercentage:
                    result.updatedProgressPercentage ?? nextMod.progressPercentage,
              );
            }

            if (modChanged) {
              listChanged = true;
            }
            if (nextMod.moduleId == target.moduleId) {
              refreshedTarget = nextMod;
            }
            return nextMod;
          }).toList();

          if (listChanged) {
            _modulesBySubject[entry.key] = updatedList;
            touchedSubjects.add(entry.key);
          }
        }

        if (_overview != null) {
          final targetCode = target.subjectCode.toUpperCase();
          final targetList = _modulesBySubject[targetCode] ?? const [];
          if (targetList.isNotEmpty) {
            final updatedSummaries = _overview!.subjectSummaries.map((s) {
              if (s.subjectCode.toUpperCase() != targetCode) return s;
              final completedCount = targetList.where((m) => m.isCompleted).length;
              final avgPct =
                  (targetList.fold<int>(0, (acc, m) => acc + m.progressPercentage) /
                          targetList.length)
                      .round();
              return AiTopicSubjectSummary(
                subjectCode: s.subjectCode,
                subjectName: s.subjectName,
                totalModules: targetList.length,
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
        }
      });

      for (final subjCode in touchedSubjects) {
        final list = _modulesBySubject[subjCode];
        if (list != null) {
          unawaited(_repository.saveCachedSubjectModules(subjCode, list));
        }
      }
      if (_overview != null) {
        unawaited(_repository.saveCachedOverview(_overview!));
      }

      unawaited(
        AuthStorage.instance.addDailyFocusMinutes(completed ? 15 : -15),
      );

      if (mounted &&
          result.coinsAwarded != null &&
          result.coinsAwarded! > 0) {
        AcedexToast.show(
          context,
          message: '+${result.coinsAwarded} Ace Coins earned!',
          type: AcedexToastType.success,
        );
      }

      return refreshedTarget;
    } on ApiException catch (e) {
      await AuthStorage.instance.setUnitCompletion(unitCode, !completed);
      if (mounted) {
        AcedexToast.show(
          context,
          message: e.message,
          type: AcedexToastType.error,
        );
      }
      return null;
    } catch (_) {
      await AuthStorage.instance.setUnitCompletion(unitCode, !completed);
      if (mounted) {
        AcedexToast.show(
          context,
          message: 'Unable to sync unit mastery right now.',
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
      onToggleMastered: (completed) =>
          _updateModuleProgress(module, isCompleted: completed),
      onToggleUnitMastery: (ref, completed) =>
          _toggleReferencedUnitMastery(module, ref, completed),
    );
  }

  /// Pushes the full-screen calibration route without app header or bottom nav bar.
  Future<void> _openFullScreenCalibration() async {
    final overview = _overview;
    final canGen = overview?.canGenerateToday ?? true;
    if (!canGen) {
      AcedexToast.show(
        context,
        message:
            'You can generate a new AI plan once per day. Resets tomorrow.',
        type: AcedexToastType.info,
      );
      return;
    }

    final generatedOverview = await Navigator.of(context, rootNavigator: true)
        .push<AiTopicProgramOverview>(
          MaterialPageRoute<AiTopicProgramOverview>(
            fullscreenDialog: true,
            builder: (_) => AiCalibrationScreen(
              user: widget.user,
              repository: _repository,
              adsRepository: widget.adsRepository,
              canGenerateToday: canGen,
              requiresAd: overview?.requiresAd ?? true,
              initialCalibration: overview?.program?.calibration,
            ),
          ),
        );

    if (!mounted || generatedOverview == null) return;
    setState(() {
      _applyOverview(generatedOverview);
      _phase = _AiStudyPhase.workspace;
    });
    if (_selectedSubjectCode.isNotEmpty) {
      unawaited(_loadSubjectModules(_selectedSubjectCode));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return const AcedexAiStudySkeleton();
    }

    final overview =
        _overview ??
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
          onStartCalibration: _openFullScreenCalibration,
        );

      case _AiStudyPhase.workspace:
        final currentModules =
            _modulesBySubject[_selectedSubjectCode.toUpperCase()] ?? const [];
        return AiTopicWorkspaceView(
          overview: overview,
          selectedSubjectCode: _selectedSubjectCode,
          modules: currentModules,
          isLoadingModules: _loadingModules,
          modulesError: _modulesError,
          onSelectSubject: _loadSubjectModules,
          onRetryLoadModules: () => _loadSubjectModules(_selectedSubjectCode),
          onOpenDailyTask: _openDailyTask,
          onOpenModule: _openModuleDetail,
          onRecalibrate: _openFullScreenCalibration,
        );
    }
  }
}
