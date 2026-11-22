import 'package:flutter/material.dart';
import '../../../core/config/feature_flags.dart';
import '../../../core/models/user_profile.dart';
import '../models/study_models.dart';
import '../widgets/curriculum_hero_card.dart';
import '../widgets/quick_drill_builder_card.dart';
import '../widgets/smart_notes_reader_sheet.dart';
import '../widgets/subject_pill_rail_and_search.dart';
import '../widgets/syllabus_unit_accordion.dart';
import '../widgets/topic_drill_engine_sheet.dart';

/// Clean Apple-Style Study & Curriculum Inside Screen (Tab 1: Study)
///
/// Implements the 6 core components matching the Apple iOS Study Screen specification:
/// 1. Subject Pill Rail & Search / Gliding Filter Bar
/// 2. Active Subject Curriculum Hero Card ("Resume Last Note >")
/// 3. Interactive Syllabus Unit Viewer (Expandable Accordion + Tree)
/// 4. Quick Topic Drill Builder Card
/// 5. Smart Notes Reader (Cupertino Bottom Sheet)
/// 6. Topic Drill Engine (Cupertino Bottom Sheet)
///
/// Bottom padding is set to 130px to scroll clear of the floating concave navigation bar.
class StudyScreen extends StatefulWidget {
  final UserProfile? user;

  const StudyScreen({super.key, this.user});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  // In-memory mutable curriculum store
  late Map<String, SubjectCurriculum> _curriculumMap;
  String _activeSubjectId = 'physics';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // 'all', 'progress', 'bookmarked'

  // Quick Drill Builder State
  String _builderSelectedUnitId = 'all';
  int _builderQuestionCount = 3;
  String _builderDifficulty = 'Standard';

  @override
  void initState() {
    super.initState();
    _curriculumMap = Map.from(defaultCurriculumData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  SubjectCurriculum get _activeSubject =>
      _curriculumMap[_activeSubjectId] ?? _curriculumMap.values.first;

  int _getBookmarkedCount(SubjectCurriculum subj) {
    int count = 0;
    for (final unit in subj.units) {
      count += unit.topics.where((t) => t.bookmarked).length;
    }
    return count;
  }

  String _getLastTopicLabel(SubjectCurriculum subj) {
    for (final unit in subj.units) {
      for (final topic in unit.topics) {
        if (topic.id == subj.lastTopicId) {
          return '${unit.code} • ${topic.title}';
        }
      }
    }
    if (subj.units.isNotEmpty && subj.units.first.topics.isNotEmpty) {
      final firstUnit = subj.units.first;
      final firstTopic = firstUnit.topics.first;
      return '${firstUnit.code} • ${firstTopic.title}';
    }
    return 'Unit 1 • Introduction';
  }

  void _recalculateSubjectMastery(SubjectCurriculum subj) {
    int total = 0;
    int done = 0;
    for (final u in subj.units) {
      total += u.topics.length;
      done += u.topics.where((t) => t.completed).length;
    }
    final ratioPct = total > 0 ? ((done / total) * 100).round() : 75;
    final newMastery =
        (subj.mastery * 0.65 + ratioPct * 0.35).round().clamp(55, 99);
    _curriculumMap[subj.id] = subj.copyWith(mastery: newMastery);
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
      _curriculumMap[subj.id] = subj.copyWith(units: updatedUnits);
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
      onDrillTopic: () => _launchTopicDrill(topic, 3, 'Standard'),
    );
  }

  void _launchTopicDrill(StudyTopic topic, int count, String difficulty) {
    final subj = _activeSubject;
    final pool = _buildSubjectQuestionPool(subj, subj.units, difficulty);
    final primaryQ = topic.drillQuestion.copyWith(
      topicTitle: '${topic.code} ${topic.title}',
    );

    final rest = pool.where((item) => item.q != primaryQ.q).toList();
    final drillQuestions = [primaryQ, ...rest].take(count).toList();

    TopicDrillEngineSheet.show(
      context,
      questions: drillQuestions,
      headerBadge: '${subj.name} • Topic ${topic.code}',
      headerTitle: topic.title,
      subject: subj,
      onDrillCompleted: (score, total, boost) {
        setState(() {
          final newMastery = (subj.mastery + boost).clamp(55, 99);
          _curriculumMap[subj.id] = subj.copyWith(mastery: newMastery);
        });
      },
    );
  }

  void _launchCustomDrill(String unitId, int count, String difficulty) {
    final subj = _activeSubject;
    final targetUnits = unitId == 'all'
        ? subj.units
        : subj.units.where((u) => u.id == unitId).toList();

    final pool = _buildSubjectQuestionPool(subj, targetUnits, difficulty);
    final drillQuestions = pool.take(count).toList();

    final unitLabel = unitId == 'all'
        ? 'All ${subj.name} Units'
        : (targetUnits.isNotEmpty
            ? '${targetUnits.first.code}: ${targetUnits.first.title}'
            : 'Custom Drill');

    TopicDrillEngineSheet.show(
      context,
      questions: drillQuestions,
      headerBadge: '${subj.name} • $difficulty',
      headerTitle: unitLabel,
      subject: subj,
      onDrillCompleted: (score, total, boost) {
        setState(() {
          final newMastery = (subj.mastery + boost).clamp(55, 99);
          _curriculumMap[subj.id] = subj.copyWith(mastery: newMastery);
        });
      },
    );
  }

  List<DrillQuestionItem> _buildSubjectQuestionPool(
    SubjectCurriculum subj,
    List<StudyUnit> targetUnits,
    String preferredDifficulty,
  ) {
    final pool = <DrillQuestionItem>[];
    for (final u in targetUnits) {
      for (final t in u.topics) {
        pool.add(t.drillQuestion.copyWith(
          topicTitle: '${t.code} ${t.title}',
        ));
      }
    }

    pool.sort((a, b) {
      final aMatch = a.difficulty == preferredDifficulty ? 0 : 1;
      final bMatch = b.difficulty == preferredDifficulty ? 0 : 1;
      return aMatch.compareTo(bMatch);
    });

    if (pool.length < 8) {
      for (final u in subj.units) {
        for (final t in u.topics) {
          if (!pool.any((item) => item.q == t.drillQuestion.q)) {
            pool.add(t.drillQuestion.copyWith(
              topicTitle: '${t.code} ${t.title}',
            ));
          }
        }
      }
    }

    int idx = 0;
    while (pool.length < 8 && pool.isNotEmpty) {
      final base = pool[idx % pool.length];
      pool.add(base.copyWith(
        topicTitle: '${base.topicTitle ?? ""} (Set B)',
      ));
      idx++;
    }

    return pool;
  }

  @override
  Widget build(BuildContext context) {
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
          // 1. Subject Pill Rail & Search / Filter Bar
          SubjectPillRailAndSearch(
            subjects: subjectsList,
            activeSubjectId: _activeSubjectId,
            onSelectSubject: (id) {
              setState(() {
                _activeSubjectId = id;
                _builderSelectedUnitId = 'all'; // reset builder unit to all
              });
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
            lastTopicLabel: lastTopicLabel,
            ctaLabel: FeatureFlags.enableSmartNotes ? 'Resume Last Note' : 'Start Unit Drill',
            onResumeNote: () {
              final topic = _findTopicById(subj.lastTopicId) ??
                  (subj.units.isNotEmpty && subj.units.first.topics.isNotEmpty
                      ? subj.units.first.topics.first
                      : null);
              if (topic != null) {
                if (FeatureFlags.enableSmartNotes) {
                  _launchNotesSheet(topic);
                } else {
                  _launchTopicDrill(topic, 3, 'Standard');
                }
              }
            },
          ),

          const SizedBox(height: 18),

          // 3. Interactive Syllabus Unit Viewer (Expandable Accordion + Tree)
          SyllabusUnitAccordion(
            subject: subj,
            searchQuery: _searchQuery,
            activeFilter: _selectedFilter,
            showNotesButton: FeatureFlags.enableSmartNotes,
            onToggleUnitExpand: _toggleUnitExpand,
            onToggleTopicComplete: _toggleTopicCompletion,
            onOpenNotes: (topicId) {
              final topic = _findTopicById(topicId);
              if (topic != null) {
                if (FeatureFlags.enableSmartNotes) {
                  _launchNotesSheet(topic);
                } else {
                  _launchTopicDrill(topic, 3, 'Standard');
                }
              }
            },
            onOpenDrill: (topicId) {
              final topic = _findTopicById(topicId);
              if (topic != null) {
                _launchTopicDrill(topic, 3, 'Standard');
              }
            },
            onResetFilters: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedFilter = 'all';
              });
            },
          ),

          const SizedBox(height: 18),

          // 4. Quick Topic Drill Builder Card
          QuickTopicDrillBuilderCard(
            subject: subj,
            selectedUnitId: _builderSelectedUnitId,
            questionCount: _builderQuestionCount,
            difficulty: _builderDifficulty,
            onUnitChanged: (unitId) {
              setState(() => _builderSelectedUnitId = unitId);
            },
            onCountChanged: (count) {
              setState(() => _builderQuestionCount = count);
            },
            onDifficultyChanged: (diff) {
              setState(() => _builderDifficulty = diff);
            },
            onStartDrill: (unitId, count, diff) {
              _launchCustomDrill(unitId, count, diff);
            },
          ),
        ],
      ),
    );
  }
}
