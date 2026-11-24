import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/config/feature_flags.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/progress/acedex_dots_loader.dart';
import '../models/study_models.dart';
import '../widgets/curriculum_hero_card.dart';
import '../widgets/grade_track_sheet.dart';
import '../widgets/smart_notes_reader_sheet.dart';
import '../widgets/subject_pill_rail_and_search.dart';
import '../widgets/syllabus_unit_accordion.dart';
import '../widgets/topic_drill_engine_sheet.dart';
import '../widgets/unit_quick_notes_sheet.dart';

/// Clean Apple-Style Study & Curriculum Inside Screen (Tab 1: Study)
///
/// Supports EUEE Multi-Grade Access (Grades 9 to 12) with Stream Filtering:
/// - Real-time Subject & Unit loading across Grades 9, 10, 11, and 12
/// - Natural Science students access Natural + Common subjects across all grades
/// - Social Science students access Social + Common subjects across all grades
/// - 15-Question Unit Assessment Engine with authentic database questions
/// - Bottom padding set to 130px to scroll clear of concave floating navigation bar.
class StudyScreen extends StatefulWidget {
  final UserProfile? user;
  final Map<String, SubjectCurriculum>? initialCurriculum;

  const StudyScreen({
    super.key,
    this.user,
    this.initialCurriculum,
  });

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  // In-memory mutable curriculum store populated dynamically via API
  Map<String, SubjectCurriculum> _curriculumMap = {};
  String _activeSubjectId = 'physics';
  int _selectedGrade = 12;
  late String _studentStream;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // 'all', 'progress', 'bookmarked'
  bool _isLoading = false;
  String? _loadingUnitsSubjectId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedGrade = widget.user?.grade ?? 12;
    _studentStream = widget.user?.stream ?? 'natural';
    unawaited(AuthStorage.instance.getCompletedUnits());
    if (widget.initialCurriculum != null && widget.initialCurriculum!.isNotEmpty) {
      _curriculumMap = Map.from(widget.initialCurriculum!);
      _activeSubjectId = _curriculumMap.keys.first;
    }
    _fetchLiveCurriculum();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  SubjectCurriculum get _activeSubject =>
      _curriculumMap[_activeSubjectId] ??
      (_curriculumMap.isNotEmpty
          ? _curriculumMap.values.first
          : const SubjectCurriculum(
              id: 'physics',
              name: 'Physics',
              mastery: 0,
              lastTopicId: 'phy-u1',
              iconData: HugeIcons.strokeRoundedAtom01,
              color: AppColors.royalPurple,
              units: [],
            ));

  int _getBookmarkedCount(SubjectCurriculum subj) {
    int count = 0;
    for (final unit in subj.units) {
      count += unit.topics.where((t) => t.bookmarked).length;
    }
    return count;
  }

  String _getLastTopicLabel(SubjectCurriculum subj) {
    for (final unit in subj.units) {
      if (unit.id == subj.lastTopicId || unit.code == subj.lastTopicId) {
        return '${unit.code} • ${unit.title}';
      }
      for (final topic in unit.topics) {
        if (topic.id == subj.lastTopicId) {
          return '${unit.code} • ${topic.title}';
        }
      }
    }
    if (subj.units.isNotEmpty) {
      final firstUnit = subj.units.first;
      return '${firstUnit.code} • ${firstUnit.title}';
    }
    return 'Unit 1 • Introduction';
  }

  void _recalculateSubjectMastery(SubjectCurriculum subj) {
    final total = subj.units.length;
    final done = subj.units.where((u) => u.isCompleted).length;
    final newMastery =
        total > 0 ? ((done / total) * 100).round().clamp(0, 100) : 0;
    _curriculumMap[subj.id] = subj.copyWith(mastery: newMastery);
  }

  void _onSelectGrade(int grade) {
    if (_selectedGrade == grade) return;
    setState(() {
      _selectedGrade = grade;
      _curriculumMap.clear();
      _isLoading = true;
      _errorMessage = null;
    });
    _fetchLiveCurriculum();
  }

  @override
  void didUpdateWidget(StudyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user?.stream != oldWidget.user?.stream) {
      _studentStream = widget.user?.stream ?? 'natural';
      _curriculumMap.clear();
      _isLoading = true;
      _errorMessage = null;
      _fetchLiveCurriculum();
    }
  }

  void _handleOpenUnitQuickNotes(StudyUnit unit) {
    UnitQuickNotesSheet.show(
      context,
      unit: unit,
      subject: _activeSubject,
      onCompleteAndUnlockAssessment: () {
        _toggleUnitCompletion(unit.id);
        _handleTakeUnitAssessment(unit);
      },
    );
  }

  /// Synchronize curriculum subjects and units from backend API
  Future<void> _fetchLiveCurriculum() async {
    final grade = _selectedGrade;
    final stream = _studentStream;

    if (_curriculumMap.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // 1. Fetch Subjects for this grade and stream from API
      final subjRes = await ApiClient.instance.get(
        ApiEndpoints.curriculumSubjects(grade: grade, stream: stream),
        requiresAuth: false,
      );
      final subjData = subjRes['data'] ?? subjRes;
      if (subjData is List && subjData.isNotEmpty) {
        final Map<String, SubjectCurriculum> newMap = {};

        for (final s in subjData) {
          final streamCategory = (s['streamCategory'] as String? ?? '').toLowerCase();
          if (streamCategory.isNotEmpty) {
            if (_studentStream == 'natural' && streamCategory == 'social') continue;
            if (_studentStream == 'social' && streamCategory == 'natural') continue;
          }

          final code = (s['code'] as String? ?? '').toUpperCase();
          final name = s['name'] as String? ?? '';
          final slug = (s['slug'] as String? ?? name.toLowerCase()).trim();
          final existing = _curriculumMap[slug] ?? _curriculumMap[code.toLowerCase()];

          newMap[slug] = SubjectCurriculum(
            id: slug,
            name: name,
            mastery: existing?.mastery ?? 0,
            lastTopicId: existing?.lastTopicId ?? '$slug-u1',
            iconData: existing?.iconData ?? _resolveSubjectIcon(code),
            color: existing?.color ?? _resolveSubjectColor(code),
            units: existing?.units ?? [],
          );
        }

        if (newMap.isNotEmpty && mounted) {
          setState(() {
            _curriculumMap = newMap;
            if (!_curriculumMap.containsKey(_activeSubjectId)) {
              _activeSubjectId = _curriculumMap.keys.first;
            }
            _loadingUnitsSubjectId = _activeSubjectId;
          });

          // Fetch Units for the active subject
          await _fetchUnitsForSubject(_activeSubject);
          if (mounted) {
            setState(() => _loadingUnitsSubjectId = null);
          }
        }
      }
    } catch (e) {
      debugPrint('[StudyScreen] Network fetch error: $e');
      if (mounted && _curriculumMap.isEmpty) {
        setState(() {
          _errorMessage =
              'Unable to connect to database. Please check your internet connection.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchUnitsForSubject(SubjectCurriculum subj) async {
    final grade = _selectedGrade;
    try {
      final res = await ApiClient.instance.get(
        ApiEndpoints.curriculumUnits(grade: grade, subject: subj.subjectCode),
        requiresAuth: true,
      );
      final unitsData = res['data'] ?? res;
      if (unitsData is List && unitsData.isNotEmpty) {
        final List<StudyUnit> liveUnits = unitsData.map((raw) {
          final unitNum = raw['unitNumber'] as int? ?? 1;
          final code = 'U$unitNum';
          final unitCode = raw['code'] as String? ??
              '${subj.subjectCode}-G${grade.toString().padLeft(2, '0')}-U${unitNum.toString().padLeft(2, '0')}';
          final title = raw['title'] as String? ?? 'Unit $unitNum';
          final qCount = raw['questionCount'] as int? ?? 15;
          final unitId = raw['_id'] as String? ?? unitCode;
          final isDone = raw['isStudyCompleted'] == true ||
              raw['passed'] == true ||
              AuthStorage.instance.completedUnitsNotifier.value.contains(unitId) ||
              AuthStorage.instance.completedUnitsNotifier.value.contains(unitCode);
          if (raw['isStudyCompleted'] == true || raw['passed'] == true) {
            unawaited(AuthStorage.instance.setUnitCompletion(unitId, true));
            unawaited(AuthStorage.instance.setUnitCompletion(unitCode, true));
          }
          final bestScore = raw['bestScore'] as int?;

          return StudyUnit(
            id: unitId,
            code: code,
            unitCode: unitCode,
            title: title,
            examWeight: '$qCount Questions',
            expanded: false,
            topics: const [],
            isCompleted: isDone,
            assessmentScore: bestScore != null && bestScore > 0 ? bestScore : null,
          );
        }).toList();

        final doneCount = liveUnits.where((u) => u.isCompleted).length;
        final masteryPct = liveUnits.isNotEmpty
            ? ((doneCount / liveUnits.length) * 100).round().clamp(0, 100)
            : 0;

        if (mounted) {
          setState(() {
            _curriculumMap[subj.id] = subj.copyWith(
              units: liveUnits,
              mastery: masteryPct,
            );
          });
        }
      } else if (subj.units.isEmpty && mounted) {
        final fallbackUnits = _resolveFallbackUnits(subj.subjectCode, grade);
        final doneCount = fallbackUnits.where((u) => u.isCompleted).length;
        final masteryPct = fallbackUnits.isNotEmpty
            ? ((doneCount / fallbackUnits.length) * 100).round().clamp(0, 100)
            : 0;
        setState(() {
          _curriculumMap[subj.id] = subj.copyWith(
            units: fallbackUnits,
            mastery: masteryPct,
          );
        });
      }
    } catch (e) {
      debugPrint('[StudyScreen] Error fetching units for ${subj.name}: $e');
      if (subj.units.isEmpty && mounted) {
        final fallbackUnits = _resolveFallbackUnits(subj.subjectCode, grade);
        final doneCount = fallbackUnits.where((u) => u.isCompleted).length;
        final masteryPct = fallbackUnits.isNotEmpty
            ? ((doneCount / fallbackUnits.length) * 100).round().clamp(0, 100)
            : 0;
        setState(() {
          _curriculumMap[subj.id] = subj.copyWith(
            units: fallbackUnits,
            mastery: masteryPct,
          );
        });
      }
    }
  }

  List<List<dynamic>> _resolveSubjectIcon(String code) {
    switch (code) {
      case 'PHY':
        return HugeIcons.strokeRoundedAtom01;
      case 'MAT':
        return HugeIcons.strokeRoundedCalculate;
      case 'CHE':
        return HugeIcons.strokeRoundedTestTube01;
      case 'BIO':
        return HugeIcons.strokeRoundedDna01;
      case 'ENG':
        return HugeIcons.strokeRoundedBookOpen01;
      case 'ECO':
        return HugeIcons.strokeRoundedAnalytics01;
      case 'GEO':
        return HugeIcons.strokeRoundedMapsLocation01;
      case 'HIS':
        return HugeIcons.strokeRoundedHourglass;
      default:
        return HugeIcons.strokeRoundedBook02;
    }
  }

  Color _resolveSubjectColor(String code) {
    switch (code) {
      case 'PHY':
        return AppColors.royalPurple;
      case 'MAT':
        return const Color(0xFF2563EB);
      case 'CHE':
        return const Color(0xFF0D9488);
      case 'BIO':
        return const Color(0xFF16A34A);
      case 'ENG':
        return const Color(0xFFEA580C);
      case 'ECO':
        return const Color(0xFFCA8A04);
      case 'GEO':
        return const Color(0xFF0284C7);
      case 'HIS':
        return const Color(0xFF9333EA);
      default:
        return AppColors.royalPurple;
    }
  }

  void _toggleTopicCompletion(String topicId) {
    final subj = _activeSubject;
    final updatedUnits = subj.units.map((u) {
      final updatedTopics = u.topics.map((t) {
        if (t.id == topicId) {
          return t.copyWith(completed: !t.completed);
        }
        return t;
      }).toList();
      return u.copyWith(topics: updatedTopics);
    }).toList();

    final updatedSubj = subj.copyWith(units: updatedUnits);
    setState(() {
      _curriculumMap[subj.id] = updatedSubj;
      _recalculateSubjectMastery(_curriculumMap[subj.id]!);
    });
  }

  void _toggleUnitCompletion(String unitId) {
    final subj = _activeSubject;
    final unit = subj.units.firstWhere(
      (u) => u.id == unitId,
      orElse: () => subj.units.first,
    );
    final targetState = !unit.isCompleted;

    final updatedUnits = subj.units.map((u) {
      if (u.id == unitId) {
        final updatedTopics = u.topics
            .map((t) => t.copyWith(completed: targetState))
            .toList();
        return u.copyWith(isCompleted: targetState, topics: updatedTopics);
      }
      return u;
    }).toList();

    final updatedSubj = subj.copyWith(units: updatedUnits);
    setState(() {
      _curriculumMap[subj.id] = updatedSubj;
      _recalculateSubjectMastery(_curriculumMap[subj.id]!);
    });

    final unitCode = unit.resolvedUnitCode(subj.subjectCode);
    unawaited(AuthStorage.instance.setUnitCompletion(unitId, targetState));
    unawaited(AuthStorage.instance.setUnitCompletion(unitCode, targetState));

    // Persist real user status directly in database
    unawaited(
      ApiClient.instance
          .post(
            ApiEndpoints.updateUnitStatus(unitCode),
            body: {'status': targetState ? 'completed' : 'not_started'},
            requiresAuth: true,
          )
          .catchError((_) => <String, dynamic>{}),
    );
  }

  List<DrillQuestionItem> _parseQuestionsFromApi(
    List<dynamic> data,
    StudyUnit unit,
    String unitCode,
  ) {
    return data.map((raw) {
      final optionsRaw = raw['options'] as List? ?? [];
      final optionsList = optionsRaw.map((o) {
        if (o is Map) {
          return '${o['id']}. ${o['text']}';
        }
        return o.toString();
      }).toList();

      final correctOpt = raw['correctOptionId'] as String? ?? 'A';
      final correctIdx = correctOpt == 'B'
          ? 1
          : (correctOpt == 'C' ? 2 : (correctOpt == 'D' ? 3 : 0));

      return DrillQuestionItem(
        topicCode: raw['id'] ?? raw['externalId'] ?? unitCode,
        difficulty: (raw['difficulty'] as String? ?? 'Standard'),
        q: raw['question'] as String? ?? '',
        options: optionsList,
        correctIndex: correctIdx,
        explanation: raw['explanation'] as String? ?? '',
        topicTitle: '${unit.code} • ${unit.title}',
        sourceReference: raw['sourceReference'] as String?,
      );
    }).toList();
  }

  Future<void> _handleTakeUnitAssessment(StudyUnit unit) async {
    final subj = _activeSubject;
    final unitCode = unit.resolvedUnitCode(subj.subjectCode);
    final unitId = unit.id;

    List<DrillQuestionItem> assessmentQuestions = [];

    // 1. Try /curriculum/units/$unitId/assessment
    try {
      final res = await ApiClient.instance.get(
        ApiEndpoints.unitAssessment(unitId),
        requiresAuth: false,
      );
      final data = res['data'] ?? res;
      if (data is List && data.isNotEmpty) {
        assessmentQuestions = _parseQuestionsFromApi(data, unit, unitCode);
      }
    } catch (_) {
      if (unitId != unitCode) {
        try {
          final res = await ApiClient.instance.get(
            ApiEndpoints.unitAssessment(unitCode),
            requiresAuth: false,
          );
          final data = res['data'] ?? res;
          if (data is List && data.isNotEmpty) {
            assessmentQuestions = _parseQuestionsFromApi(data, unit, unitCode);
          }
        } catch (_) {}
      }
    }

    // 2. If assessment endpoint returns 404, query /curriculum/units/$unitId/questions
    if (assessmentQuestions.isEmpty) {
      try {
        final res = await ApiClient.instance.get(
          ApiEndpoints.unitQuestions(unitId),
          requiresAuth: false,
        );
        final data = res['data'] ?? res;
        if (data is List && data.isNotEmpty) {
          assessmentQuestions = _parseQuestionsFromApi(data, unit, unitCode);
        }
      } catch (_) {
        if (unitId != unitCode) {
          try {
            final res = await ApiClient.instance.get(
              ApiEndpoints.unitQuestions(unitCode),
              requiresAuth: false,
            );
            final data = res['data'] ?? res;
            if (data is List && data.isNotEmpty) {
              assessmentQuestions = _parseQuestionsFromApi(data, unit, unitCode);
            }
          } catch (_) {}
        }
      }
    }

    if (!mounted) return;

    if (assessmentQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load assessment questions from database. Please check your connection.'),
        ),
      );
      return;
    }

    TopicDrillEngineSheet.show(
      context,
      questions: assessmentQuestions,
      headerBadge: '${subj.name} • 15-Q Assessment',
      headerTitle: '${unit.code}: ${unit.title}',
      subject: subj,
      onDrillCompleted: (score, total, boost) {
        final updatedUnits = subj.units.map((u) {
          if (u.id == unit.id) {
            return u.copyWith(
              isCompleted: true,
              assessmentScore: score,
            );
          }
          return u;
        }).toList();

        final updatedSubj = subj.copyWith(
          units: updatedUnits,
        );

        setState(() {
          _curriculumMap[subj.id] = updatedSubj;
          _recalculateSubjectMastery(_curriculumMap[subj.id]!);
        });
        unawaited(AuthStorage.instance.setUnitCompletion(unit.id, true));
        unawaited(AuthStorage.instance.setUnitCompletion(unitCode, true));

        unawaited(
          ApiClient.instance
              .post(
                ApiEndpoints.updateUnitStatus(unitCode),
                body: {'status': 'completed'},
                requiresAuth: true,
              )
              .catchError((_) => <String, dynamic>{}),
        );
      },
    );
  }

  void _toggleTopicBookmark(String topicId) {
    final subj = _activeSubject;
    final updatedUnits = subj.units.map((u) {
      final updatedTopics = u.topics.map((t) {
        if (t.id == topicId) {
          return t.copyWith(bookmarked: !t.bookmarked);
        }
        return t;
      }).toList();
      return u.copyWith(topics: updatedTopics);
    }).toList();

    setState(() {
      _curriculumMap[subj.id] = subj.copyWith(units: updatedUnits);
    });
  }

  void _toggleUnitExpand(String unitId) {
    final subj = _activeSubject;
    final updatedUnits = subj.units.map((u) {
      if (u.id == unitId) {
        return u.copyWith(expanded: !u.expanded);
      }
      return u;
    }).toList();

    setState(() {
      _curriculumMap[subj.id] = updatedUnits.isNotEmpty
          ? subj.copyWith(units: updatedUnits)
          : subj;
    });
  }

  StudyTopic? _findTopicById(String topicId) {
    for (final subj in _curriculumMap.values) {
      for (final unit in subj.units) {
        for (final topic in unit.topics) {
          if (topic.id == topicId) return topic;
        }
      }
    }
    return null;
  }

  void _launchNotesSheet(StudyTopic topic) {
    final subj = _activeSubject;
    setState(() {
      _curriculumMap[subj.id] = subj.copyWith(lastTopicId: topic.id);
    });

    SmartNotesReaderSheet.show(
      context,
      topic: topic,
      subject: _activeSubject,
      onToggleBookmark: () => _toggleTopicBookmark(topic.id),
      onToggleComplete: () => _toggleTopicCompletion(topic.id),
      onDrillTopic: () {
        final unit = subj.units.firstWhere(
          (u) => u.topics.any((t) => t.id == topic.id),
          orElse: () => subj.units.first,
        );
        _handleTakeUnitAssessment(unit);
      },
    );
  }

  Widget _buildEditorialHeader(ThemeData theme, bool isDark, Color primaryColor) {
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final isNatural = _studentStream == 'natural';
    final streamLabel = isNatural ? 'Natural Science Track' : 'Social Science Track';
    final liveDotColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Editorial Title + Live Track Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Study',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                  height: 1.1,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: liveDotColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: liveDotColor.withValues(alpha: 0.45),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    streamLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Right: Grade Pull-Down Pill
        AcedexBounceable(
          onTap: () {
            GradeTrackSheet.show(
              context,
              selectedGrade: _selectedGrade,
              stream: _studentStream,
              registeredGrade: widget.user?.grade,
              onSelectGrade: _onSelectGrade,
            );
          },
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: isDark ? 0.20 : 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedGraduationCap,
                  color: primaryColor,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  'Grade $_selectedGrade',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 17,
                  color: primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<StudyUnit> _resolveFallbackUnits(String subjectCode, int grade) {
    final Map<String, List<Map<String, String>>> defaults = {
      'PHY': [
        {'code': 'U1', 'title': 'Application of Physics in Other Fields', 'weight': '14% EUEE'},
        {'code': 'U2', 'title': 'Two-dimensional Motion', 'weight': '22% EUEE'},
        {'code': 'U3', 'title': 'Fluid Mechanics', 'weight': '18% EUEE'},
        {'code': 'U4', 'title': 'Electromagnetism', 'weight': '28% EUEE'},
        {'code': 'U5', 'title': 'Basics of Electronics', 'weight': '18% EUEE'},
      ],
      'MAT': [
        {'code': 'U1', 'title': 'Sequences and Series', 'weight': '20% EUEE'},
        {'code': 'U2', 'title': 'Introductions to Calculus', 'weight': '32% EUEE'},
        {'code': 'U3', 'title': 'Statistics', 'weight': '22% EUEE'},
        {'code': 'U4', 'title': 'Introduction to Linear Programming', 'weight': '12% EUEE'},
        {'code': 'U5', 'title': 'Mathematical Applications in Business', 'weight': '14% EUEE'},
      ],
      'CHE': [
        {'code': 'U1', 'title': 'Acid-Base Equilibria', 'weight': '26% EUEE'},
        {'code': 'U2', 'title': 'Electrochemistry', 'weight': '28% EUEE'},
        {'code': 'U3', 'title': 'Industrial Chemistry', 'weight': '18% EUEE'},
        {'code': 'U4', 'title': 'Polymers & Macromolecules', 'weight': '16% EUEE'},
        {'code': 'U5', 'title': 'Environmental Chemistry', 'weight': '12% EUEE'},
      ],
      'BIO': [
        {'code': 'U1', 'title': 'Application of Biology', 'weight': '18% EUEE'},
        {'code': 'U2', 'title': 'Microorganisms & Disease', 'weight': '22% EUEE'},
        {'code': 'U3', 'title': 'Energy Transformation', 'weight': '28% EUEE'},
        {'code': 'U4', 'title': 'Evolution & Genetics', 'weight': '20% EUEE'},
        {'code': 'U5', 'title': 'Human Nervous & Endocrine Systems', 'weight': '12% EUEE'},
      ],
      'ECO': [
        {'code': 'U1', 'title': 'Macroeconomic Indicators & GDP', 'weight': '25% EUEE'},
        {'code': 'U2', 'title': 'Aggregate Demand & Supply', 'weight': '22% EUEE'},
        {'code': 'U3', 'title': 'Fiscal & Monetary Policy', 'weight': '20% EUEE'},
        {'code': 'U4', 'title': 'International Trade & Payments', 'weight': '18% EUEE'},
        {'code': 'U5', 'title': 'Ethiopian Economic Reforms', 'weight': '15% EUEE'},
      ],
      'GEO': [
        {'code': 'U1', 'title': 'Major Geological Processes', 'weight': '24% EUEE'},
        {'code': 'U2', 'title': 'Climate Change & Agro-Ecological Zones', 'weight': '26% EUEE'},
        {'code': 'U3', 'title': 'Sustainable Resource Management', 'weight': '18% EUEE'},
        {'code': 'U4', 'title': 'Population Policies & Urbanization', 'weight': '18% EUEE'},
        {'code': 'U5', 'title': 'GIS & Remote Sensing Applications', 'weight': '14% EUEE'},
      ],
      'HIS': [
        {'code': 'U1', 'title': 'Development of Capitalism & Nationalism', 'weight': '20% EUEE'},
        {'code': 'U2', 'title': 'Africa & the Colonial Experience', 'weight': '24% EUEE'},
        {'code': 'U3', 'title': 'Social & Political Developments in Ethiopia', 'weight': '26% EUEE'},
        {'code': 'U4', 'title': 'World Wars & Cold War Era', 'weight': '16% EUEE'},
        {'code': 'U5', 'title': 'Post-1991 Ethiopia & Regional Integration', 'weight': '14% EUEE'},
      ],
    };

    final list = defaults[subjectCode] ?? defaults['PHY']!;
    return list.map((item) {
      final code = item['code']!;
      final title = item['title']!;
      final weight = item['weight']!;
      final unitCode = '$subjectCode-G${grade.toString().padLeft(2, '0')}-$code';
      final isDone = AuthStorage.instance.completedUnitsNotifier.value.contains(unitCode);
      return StudyUnit(
        id: unitCode,
        code: code,
        unitCode: unitCode,
        title: title,
        examWeight: '$weight • 15 Questions',
        expanded: false,
        topics: const [],
        isCompleted: isDone,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    // Loading State
    if (_isLoading && _curriculumMap.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AcedexDotsLoader(
                color: isDark ? AppColors.accentDark : AppColors.royalPurple,
                dotSize: 6.0,
                gap: 4.5,
              ),
              const SizedBox(height: 14),
              Text(
                'Loading Grade $_selectedGrade Curriculum...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Error State
    if (_errorMessage != null && _curriculumMap.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkErrorSoft : AppColors.lightErrorSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedAlertCircle,
                    color: isDark ? AppColors.darkError : AppColors.error,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Curriculum Unavailable',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                ),
              ),
              const SizedBox(height: 18),
              AcedexBounceable(
                onTap: _fetchLiveCurriculum,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.accentDark : AppColors.royalPurple,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Retry Connection',
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
        ),
      );
    }

    final subj = _activeSubject;
    final subjectsList = _curriculumMap.values.toList();
    final bookmarkedCount = _getBookmarkedCount(subj);
    final lastTopicLabel = _getLastTopicLabel(subj);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 14,
        bottom: 130, // Clears floating concave bottom navigation bar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 0. Editorial Header (Study Title + Live Track Subtitle + Cupertino Grade Pill)
          _buildEditorialHeader(theme, isDark, primaryColor),

          const SizedBox(height: 14),

          // 1. Subject Pill Rail & Search / Filter Bar
          SubjectPillRailAndSearch(
            subjects: subjectsList,
            activeSubjectId: _activeSubjectId,
            onSelectSubject: (id) async {
              setState(() => _activeSubjectId = id);
              if (_curriculumMap[id]?.units.isEmpty ?? true) {
                setState(() => _loadingUnitsSubjectId = id);
                await _fetchUnitsForSubject(_curriculumMap[id]!);
                if (mounted) {
                  setState(() => _loadingUnitsSubjectId = null);
                }
              }
            },
            searchController: _searchController,
            searchQuery: _searchQuery,
            onSearchChanged: (query) {
              setState(() => _searchQuery = query);
            },
            onClearSearch: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            activeFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() => _selectedFilter = filter);
            },
            bookmarkedCount: bookmarkedCount,
          ),

          const SizedBox(height: 16),

          // 2. Active Subject Curriculum Hero Card
          CurriculumHeroCard(
            subject: subj,
            grade: _selectedGrade,
            lastTopicLabel: lastTopicLabel,
            ctaLabel: FeatureFlags.enableSmartNotes ? 'Resume Last Note' : 'Explore Units',
            onResumeNote: () {
              if (subj.units.isNotEmpty) {
                final targetUnit = subj.units.firstWhere(
                  (u) => u.id == subj.lastTopicId || u.code == subj.lastTopicId,
                  orElse: () => subj.units.first,
                );
                _handleTakeUnitAssessment(targetUnit);
              }
            },
          ),

          const SizedBox(height: 18),

          // 3. Interactive Syllabus Unit Viewer (Expandable Accordion with 15-Q Assessments)
          SyllabusUnitAccordion(
            subject: subj,
            isLoading: _loadingUnitsSubjectId == subj.id || (_isLoading && subj.units.isEmpty),
            searchQuery: _searchQuery,
            activeFilter: _selectedFilter,
            showNotesButton: FeatureFlags.enableSmartNotes,
            onToggleUnitExpand: _toggleUnitExpand,
            onToggleUnitComplete: _toggleUnitCompletion,
            onToggleTopicComplete: _toggleTopicCompletion,
            onOpenNotes: (topicId) {
              final topic = _findTopicById(topicId);
              if (topic != null) {
                _launchNotesSheet(topic);
              }
            },
            onOpenUnitQuickNotes: _handleOpenUnitQuickNotes,
            onTakeUnitAssessment: _handleTakeUnitAssessment,
            onResetFilters: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedFilter = 'all';
              });
            },
          ),
        ],
      ),
    );
  }
}
