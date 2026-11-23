import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/config/feature_flags.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/progress/acedex_dots_loader.dart';
import '../models/study_models.dart';
import '../widgets/curriculum_hero_card.dart';
import '../widgets/smart_notes_reader_sheet.dart';
import '../widgets/subject_pill_rail_and_search.dart';
import '../widgets/syllabus_unit_accordion.dart';
import '../widgets/topic_drill_engine_sheet.dart';

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
              mastery: 75,
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
    final ratioPct = total > 0 ? ((done / total) * 100).round() : 75;
    final newMastery =
        (subj.mastery * 0.65 + ratioPct * 0.35).round().clamp(55, 99);
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
            mastery: existing?.mastery ?? 75,
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
        requiresAuth: false,
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
          final isDone = raw['isStudyCompleted'] == true || raw['passed'] == true;
          final bestScore = raw['bestScore'] as int?;

          return StudyUnit(
            id: raw['_id'] as String? ?? unitCode,
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

        if (mounted) {
          setState(() {
            _curriculumMap[subj.id] = subj.copyWith(units: liveUnits);
          });
        }
      }
    } catch (e) {
      debugPrint('[StudyScreen] Error fetching units for ${subj.name}: $e');
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

    if (targetState) {
      final unitCode = unit.resolvedUnitCode(subj.subjectCode);
      unawaited(
        ApiClient.instance
            .post(ApiEndpoints.completeUnit(unitCode), requiresAuth: true)
            .catchError((_) => <String, dynamic>{}),
      );
    }
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
          mastery: (subj.mastery + boost).clamp(55, 99),
          units: updatedUnits,
        );

        setState(() {
          _curriculumMap[subj.id] = updatedSubj;
        });

        unawaited(
          ApiClient.instance
              .post(ApiEndpoints.completeUnit(unitCode), requiresAuth: true)
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

  Widget _buildGradeSelector(ThemeData theme, bool isDark, Color primaryColor) {
    final surfaceColor = isDark ? const Color(0xFF1E1E26) : const Color(0xFFF4F4F7);
    final activeBg = isDark ? const Color(0xFF2C2C38) : Colors.white;
    final subtextColor = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final lineBorder = isDark ? const Color(0xFF33333F) : const Color(0xFFE5E5EA);

    final isNatural = _studentStream == 'natural';
    final streamLabel = isNatural ? 'Natural Science Track' : 'Social Science Track';
    final streamBadgeBg = isNatural
        ? (isDark ? const Color(0xFF1A2E22) : const Color(0xFFEAF8EF))
        : (isDark ? const Color(0xFF2E2215) : const Color(0xFFFEF3E8));
    final streamColor = isNatural
        ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D))
        : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Track Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedGraduationCap,
                  color: subtextColor,
                  size: 13,
                ),
                const SizedBox(width: 5),
                Text(
                  'EUEE CURRICULUM LEVEL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: streamBadgeBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: streamColor.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: streamColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    streamLabel,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: streamColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 4-Segment Gliding Grade Switcher
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: lineBorder),
          ),
          child: Row(
            children: [9, 10, 11, 12].map((g) {
              final isSelected = _selectedGrade == g;
              return Expanded(
                child: AcedexBounceable(
                  onTap: () => _onSelectGrade(g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? activeBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Grade $g',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            letterSpacing: -0.2,
                            color: isSelected
                                ? (isDark ? Colors.white : AppColors.royalPurple)
                                : subtextColor,
                          ),
                        ),
                        if (widget.user?.grade == g) ...[
                          const SizedBox(width: 3.5),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? AppColors.accentDark : AppColors.royalPurple)
                                  : subtextColor.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
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
          // 0. Grade Selector (Grades 9-12) & Stream Track Badge
          _buildGradeSelector(theme, isDark, primaryColor),

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
