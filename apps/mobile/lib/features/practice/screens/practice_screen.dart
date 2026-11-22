import 'package:flutter/material.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_colors.dart';
import '../models/practice_models.dart';
import '../widgets/answer_review_view.dart';
import '../widgets/completed_sessions_list.dart';
import '../widgets/custom_mock_builder_card.dart';
import '../widgets/past_papers_list.dart';
import '../widgets/practice_subject_filter_rail.dart';
import '../widgets/quiz_session_view.dart';

/// Clean Apple-Style Practice Inside Screen (Tab 2: Elevated Center Action)
///
/// Implements the 3 interactive views matching the Apple iOS Practice Page prototype:
/// - View 1: EUEE Exam Selector & Practice Hub (Subject filter rail, gliding mode tabs,
///   custom mock builder card, official past papers, and completed sessions)
/// - View 2: Interactive Quiz Session Engine (Study Mode & Exam Mode, Question Navigator Grid,
///   vector diagrams, instant solution checks, and horizontal 3-dots wave submission)
/// - View 3: Score Summary & Answer Review Engine (Animated Circular Score Ring,
///   gliding review filter tabs, question-by-question review & step-by-step explanations)
class PracticeScreen extends StatefulWidget {
  final UserProfile? user;

  const PracticeScreen({super.key, this.user});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  // Navigation View State: 'selector' | 'quiz' | 'review'
  String _currentView = 'selector';

  // View 1 Hub State
  String _selectedSubjectFilter = 'all';
  String _hubMode = 'papers'; // 'papers' | 'custom' | 'completed'
  String _builderSessionMode = 'study'; // 'study' | 'exam'
  int _builderMockCount = 3; // 3 | 5

  // Persistent in-memory session and paper stores
  late List<EueePaper> _papers;
  late List<CompletedSession> _completedSessions;

  // Active Quiz / Review Session State
  EueePaper? _activePaper;
  List<EueeQuestion>? _activeQuizQuestions;
  String? _activeQuizTitle;
  String? _activeQuizShortTitle;
  String? _activeQuizSubtitle;
  String _activeQuizMode = 'study';
  int _activeQuizDurationSecs = 450;

  CompletedSession? _activeReviewSession;

  @override
  void initState() {
    super.initState();
    _papers = List.from(defaultEueePapers);
    _completedSessions = List.from(defaultCompletedSessions);
  }

  void _launchPaperQuiz(EueePaper paper) {
    setState(() {
      _activePaper = paper;
      _activeQuizQuestions = paper.questions;
      _activeQuizTitle = paper.title;
      _activeQuizShortTitle = paper.shortTitle;
      _activeQuizSubtitle = paper.topics;
      _activeQuizMode = _builderSessionMode;
      _activeQuizDurationSecs = 450; // 07:30 EUEE timed block
      _currentView = 'quiz';
    });
  }

  void _launchCustomMockQuiz() {
    final matchingPapers = _selectedSubjectFilter == 'all'
        ? _papers
        : _papers.where((p) => p.subject == _selectedSubjectFilter).toList();

    final pool = <EueeQuestion>[];
    for (final p in matchingPapers) {
      pool.addAll(p.questions);
    }

    final selectedQuestions = pool.take(_builderMockCount).toList();
    final subjTitle = _selectedSubjectFilter == 'all'
        ? 'Mixed Natural Science'
        : practiceSubjects
            .firstWhere((s) => s.id == _selectedSubjectFilter)
            .name;

    setState(() {
      _activePaper = matchingPapers.isNotEmpty ? matchingPapers.first : _papers.first;
      _activeQuizQuestions = selectedQuestions;
      _activeQuizTitle = 'Custom $subjTitle Mock';
      _activeQuizShortTitle = 'Custom Mock • $subjTitle';
      _activeQuizSubtitle =
          '$_builderMockCount Questions • ${_builderSessionMode == 'study' ? 'Study Mode' : 'Exam Mode'}';
      _activeQuizMode = _builderSessionMode;
      _activeQuizDurationSecs = _builderMockCount * 90;
      _currentView = 'quiz';
    });
  }

  void _handleQuizComplete(CompletedSession session) {
    setState(() {
      // Prepend to completed sessions
      _completedSessions.insert(0, session);

      // Update best score on the paper if improved
      final pIdx = _papers.indexWhere((p) => p.id == session.paperId);
      if (pIdx != -1) {
        final currentBest = _papers[pIdx].bestScore;
        if (currentBest == null || session.scorePct > currentBest) {
          _papers[pIdx] = _papers[pIdx].copyWith(bestScore: session.scorePct);
        }
      }

      _activeReviewSession = session;
      _currentView = 'review';
    });
  }

  void _handleReviewSession(CompletedSession session) {
    // Locate the paper's questions
    final paper = _papers.firstWhere(
      (p) => p.id == session.paperId,
      orElse: () => _papers.first,
    );
    final questions = paper.questions.take(session.totalCount).toList();

    setState(() {
      _activePaper = paper;
      _activeQuizQuestions = questions;
      _activeReviewSession = session;
      _currentView = 'review';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6);
    final raisedBg = isDark ? const Color(0xFF2B2B31) : Colors.white;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subtextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final accent = isDark ? AppColors.accentDark : AppColors.royalPurple;
    final accentSoft =
        isDark ? accent.withValues(alpha: 0.18) : AppColors.royalPurpleSoft;

    // View 2: Interactive Quiz Session Engine
    if (_currentView == 'quiz' && _activeQuizQuestions != null) {
      return QuizSessionView(
        paperId: _activePaper?.id ?? 'custom-mock',
        title: _activeQuizTitle ?? 'EUEE Practice Session',
        shortTitle: _activeQuizShortTitle ?? 'Practice Session',
        subtitle: _activeQuizSubtitle ?? 'Grade 12 Natural Science',
        mode: _activeQuizMode,
        durationSecs: _activeQuizDurationSecs,
        questions: _activeQuizQuestions!,
        onExit: () => setState(() => _currentView = 'selector'),
        onComplete: _handleQuizComplete,
      );
    }

    // View 3: Score Summary & Answer Review Engine
    if (_currentView == 'review' &&
        _activeReviewSession != null &&
        _activeQuizQuestions != null) {
      return AnswerReviewView(
        session: _activeReviewSession!,
        questions: _activeQuizQuestions!,
        onRetake: () {
          _launchPaperQuiz(_activePaper ?? _papers.first);
        },
        onAllPapers: () => setState(() => _currentView = 'selector'),
      );
    }

    // View 1: EUEE Exam Selector & Practice Hub
    final filteredPapers = _selectedSubjectFilter == 'all'
        ? _papers
        : _papers.where((p) => p.subject == _selectedSubjectFilter).toList();

    final filteredCompleted = _selectedSubjectFilter == 'all'
        ? _completedSessions
        : _completedSessions.where((s) {
            final p = _papers.where((paper) => paper.id == s.paperId);
            return p.isNotEmpty ? p.first.subject == _selectedSubjectFilter : true;
          }).toList();

    final double hubGliderAlignX = _hubMode == 'papers'
        ? -1.0
        : (_hubMode == 'custom' ? 0.0 : 1.0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 14,
        bottom: 130, // Clears floating bottom navigation bar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Eyebrow & Headline
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'EUEE EXAM BANK',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'Practice',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Official Ethiopian Grade 12 past papers & timed mocks',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: subtextColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Subject Filter Rail
          PracticeSubjectFilterRail(
            subjects: practiceSubjects,
            selectedSubjectId: _selectedSubjectFilter,
            onSelectSubject: (id) {
              setState(() => _selectedSubjectFilter = id);
            },
          ),

          const SizedBox(height: 14),

          // Mode Gliding Segmented Control ("Past Papers" | "Custom Mock" | "Completed")
          Container(
            height: 34,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: lineColor),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeInOut,
                  alignment: Alignment(hubGliderAlignX, 0.0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / 3,
                    child: Container(
                      height: 27,
                      decoration: BoxDecoration(
                        color: raisedBg,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: lineColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildHubModeBtn(
                      label: 'Past Papers',
                      isActive: _hubMode == 'papers',
                      onTap: () => setState(() => _hubMode = 'papers'),
                      accent: accent,
                      subtextColor: subtextColor,
                    ),
                    _buildHubModeBtn(
                      label: 'Custom Mock',
                      isActive: _hubMode == 'custom',
                      onTap: () => setState(() => _hubMode = 'custom'),
                      accent: accent,
                      subtextColor: subtextColor,
                    ),
                    _buildHubModeBtn(
                      label: 'Completed',
                      badgeCount: _completedSessions.length,
                      isActive: _hubMode == 'completed',
                      onTap: () => setState(() => _hubMode = 'completed'),
                      accent: accent,
                      accentSoft: accentSoft,
                      subtextColor: subtextColor,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Quick Custom Mock Builder Card
          if (_hubMode == 'papers' || _hubMode == 'custom') ...[
            CustomMockBuilderCard(
              selectedSubjectId: _selectedSubjectFilter,
              sessionMode: _builderSessionMode,
              questionCount: _builderMockCount,
              onModeChanged: (mode) => setState(() => _builderSessionMode = mode),
              onCountChanged: (count) => setState(() => _builderMockCount = count),
              onStartSession: _launchCustomMockQuiz,
            ),
            const SizedBox(height: 16),
          ],

          // Official EUEE Past Papers Section
          if (_hubMode == 'papers') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Official EUEE Past Papers',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: textColor,
                  ),
                ),
                Text(
                  '${filteredPapers.length} ${filteredPapers.length == 1 ? "Paper" : "Papers"}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            PastPapersList(
              papers: filteredPapers,
              onStartPaper: _launchPaperQuiz,
            ),
            const SizedBox(height: 16),
          ],

          // Recent Completed Sessions Section
          if (_hubMode == 'papers' || _hubMode == 'completed') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Completed Sessions',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: textColor,
                  ),
                ),
                Text(
                  'Tap to inspect',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CompletedSessionsList(
              sessions: filteredCompleted,
              onReviewSession: _handleReviewSession,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHubModeBtn({
    required String label,
    int? badgeCount,
    required bool isActive,
    required VoidCallback onTap,
    required Color accent,
    Color? accentSoft,
    required Color subtextColor,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive ? accent : subtextColor,
                ),
              ),
              if (badgeCount != null && badgeCount > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: accentSoft ?? accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
