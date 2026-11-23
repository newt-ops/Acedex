import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/progress/acedex_dots_loader.dart';
import '../models/dashboard_data.dart';

/// Subject definition for Add Study Plan Modal
class _PlanSubject {
  final String id;
  final String name;
  final String meta;
  final String placeholder;
  final List<String> suggestions;
  final List<List<dynamic>> iconData;

  const _PlanSubject({
    required this.id,
    required this.name,
    required this.meta,
    required this.placeholder,
    required this.suggestions,
    required this.iconData,
  });
}

const List<_PlanSubject> _planSubjects = [
  _PlanSubject(
    id: 'physics',
    name: 'Physics',
    meta: 'Natural Science • 100 pts',
    placeholder: 'e.g. Electromagnetism • Unit 4',
    suggestions: [
      'Electromagnetism • Unit 4',
      '2017 EUEE Past Paper',
      'Optics Formulas',
    ],
    iconData: HugeIcons.strokeRoundedAtom01,
  ),
  _PlanSubject(
    id: 'mathematics',
    name: 'Mathematics',
    meta: 'Core Quantitative • 100 pts',
    placeholder: 'e.g. Definite Integrals • Unit 5',
    suggestions: [
      'Definite Integrals • Unit 5',
      '2017 EUEE Calculus Drill',
      'Vectors & Matrices',
    ],
    iconData: HugeIcons.strokeRoundedCalculate,
  ),
  _PlanSubject(
    id: 'chemistry',
    name: 'Chemistry',
    meta: 'Natural Science • 100 pts',
    placeholder: 'e.g. Electrochemistry • Nernst Eq',
    suggestions: [
      'Electrochemistry • Nernst Eq',
      '2016 EUEE Equilibrium',
      'Organic Pathways',
    ],
    iconData: HugeIcons.strokeRoundedChemistry01,
  ),
  _PlanSubject(
    id: 'biology',
    name: 'Biology',
    meta: 'Natural Science • 100 pts',
    placeholder: 'e.g. DNA Replication • Unit 4',
    suggestions: [
      'DNA Replication • Unit 4',
      '2016 EUEE Genetics Quiz',
      'Cellular Respiration',
    ],
    iconData: HugeIcons.strokeRoundedDna,
  ),
  _PlanSubject(
    id: 'english',
    name: 'English',
    meta: 'All Streams • 100 pts',
    placeholder: 'e.g. Inference & Comprehension',
    suggestions: [
      'Inference & Comprehension',
      '2017 EUEE Grammar Drill',
      'Sentence Completion',
    ],
    iconData: HugeIcons.strokeRoundedBook02,
  ),
  _PlanSubject(
    id: 'aptitude',
    name: 'Aptitude',
    meta: 'Scholastic Reasoning • 100 pts',
    placeholder: 'e.g. Analytical Pattern Set',
    suggestions: [
      'Analytical Pattern Set',
      '2017 EUEE Logic Sprint',
      'Quantitative Analogies',
    ],
    iconData: HugeIcons.strokeRoundedIdea01,
  ),
];

/// Cupertino Bottom Sheet: Add Study Plan Modal Card
///
/// Replicates the authentic Apple iOS Add Study Plan specification:
/// - Pull-to-dismiss handle & close button
/// - Gliding Subject Selector with spring animation
/// - Session topic input with clear button & staggered suggestion chips
/// - Flexible Custom Time range bar with +/-15m steppers, duration presets, and slider
/// - Study Mode gliding pill (Deep Focus | Past Paper | Quick Review)
/// - Sticky bottom primary CTA with horizontal 3-dots wave loader
class AddStudyPlanSheet extends StatefulWidget {
  final ValueChanged<StudyTaskItem> onSave;

  const AddStudyPlanSheet({
    super.key,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<StudyTaskItem> onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.54),
      builder: (_) => AddStudyPlanSheet(onSave: onSave),
    );
  }

  @override
  State<AddStudyPlanSheet> createState() => _AddStudyPlanSheetState();
}

class _AddStudyPlanSheetState extends State<AddStudyPlanSheet> {
  // Timeline Range: 06:00 AM (360) to 11:30 PM (1410)
  static const int minDayMinutes = 6 * 60;
  static const int maxDayMinutes = 23 * 60 + 30;

  String _selectedSubjectId = 'physics';
  late final TextEditingController _topicController;
  final FocusNode _topicFocusNode = FocusNode();
  bool _isTopicFocused = false;
  int _startMinutes = 16 * 60 + 30; // 04:30 PM
  int _endMinutes = 18 * 60; // 06:00 PM
  String _selectedFocusMode = 'Deep Focus';
  bool _isSaving = false;

  _PlanSubject get _currentSubject =>
      _planSubjects.firstWhere((s) => s.id == _selectedSubjectId);

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController(text: _currentSubject.suggestions.first);
    _topicFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isTopicFocused = _topicFocusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _topicFocusNode.dispose();
    _topicController.dispose();
    super.dispose();
  }

  String _formatTime12h(int totalMins) {
    final clamped = totalMins.clamp(0, 24 * 60 - 1);
    final h24 = clamped ~/ 60;
    final mins = clamped % 60;
    final period = h24 >= 12 ? 'PM' : 'AM';
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    return '${h12.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')} $period';
  }

  String _formatDurationText(int durationMins) {
    final hrs = durationMins ~/ 60;
    final mins = durationMins % 60;
    if (hrs > 0 && mins > 0) return '${hrs}h ${mins}m • $durationMins min';
    if (hrs > 0) return '${hrs}h • $durationMins min';
    return '$mins min';
  }

  String _getTimeOfDayLabel(int startMin) {
    if (startMin < 12 * 60) return 'Morning';
    if (startMin < 17 * 60) return 'Afternoon';
    if (startMin < 21 * 60) return 'Evening';
    return 'Night';
  }

  void _onSelectSubject(String id) {
    if (_selectedSubjectId == id) return;
    final next = _planSubjects.firstWhere((s) => s.id == id);
    setState(() {
      _selectedSubjectId = id;
      _topicController.text = next.suggestions.first;
    });
  }

  void _nudgeStart(int delta) {
    setState(() {
      _startMinutes = (_startMinutes + delta).clamp(minDayMinutes, _endMinutes - 15);
    });
  }

  void _nudgeEnd(int delta) {
    setState(() {
      _endMinutes = (_endMinutes + delta).clamp(_startMinutes + 15, maxDayMinutes);
    });
  }

  void _applyDurationPreset(int presetMins) {
    setState(() {
      if (_startMinutes + presetMins <= maxDayMinutes) {
        _endMinutes = _startMinutes + presetMins;
      } else {
        _endMinutes = maxDayMinutes;
        _startMinutes = (_endMinutes - presetMins).clamp(minDayMinutes, maxDayMinutes - 15);
      }
    });
  }

  void _handleSave() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    final durationMins = (_endMinutes - _startMinutes).clamp(15, 600);
    final durationStr = durationMins >= 60
        ? '${durationMins ~/ 60}h${durationMins % 60 > 0 ? " ${durationMins % 60}m" : ""}'
        : '${durationMins}m';

    final timeSpan = '${_formatTime12h(_startMinutes)} – ${_formatTime12h(_endMinutes)}';

    final newItem = StudyTaskItem(
      id: 'task-${DateTime.now().millisecondsSinceEpoch}',
      title: topic,
      subject: _currentSubject.name,
      duration: durationStr,
      completed: false,
      timeSpan: timeSpan,
      focusMode: _selectedFocusMode,
    );

    widget.onSave(newItem);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6);
    final raisedBg = isDark ? const Color(0xFF2B2B31) : Colors.white;
    final lineBorder = isDark ? const Color(0xFF383842) : const Color(0xFFE4E4E8);
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final durationMins = (_endMinutes - _startMinutes).clamp(15, 600);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: lineBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Pull handle & Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 16, 12),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: subtextColor.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Study Plan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Customize your session & time block',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: subtextColor,
                          ),
                        ),
                      ],
                    ),
                    AcedexBounceable(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: lineBorder),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: subtextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 2. Subject Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SUBJECT',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          color: subtextColor,
                        ),
                      ),
                      Text(
                        _currentSubject.meta,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Horizontal Subject Rail
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: lineBorder),
                      ),
                      child: Row(
                        children: _planSubjects.map((subj) {
                          final isSelected = subj.id == _selectedSubjectId;
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: AcedexBounceable(
                              onTap: () => _onSelectSubject(subj.id),
                              child: Container(
                                height: 34,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    HugeIcon(
                                      icon: subj.iconData,
                                      color: isSelected ? Colors.white : subtextColor,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      subj.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? Colors.white : subtextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 3. Session Topic Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SESSION TOPIC',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          color: subtextColor,
                        ),
                      ),
                      Text(
                        'Tap chip or type custom',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _isTopicFocused ? raisedBg : surfaceColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _isTopicFocused ? primaryColor : lineBorder,
                        width: _isTopicFocused ? 1.5 : 1.0,
                      ),
                      boxShadow: _isTopicFocused
                          ? [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        AnimatedScale(
                          duration: const Duration(milliseconds: 200),
                          scale: _isTopicFocused ? 1.08 : 1.0,
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedEdit02,
                            color: _isTopicFocused ? primaryColor : subtextColor,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            focusNode: _topicFocusNode,
                            controller: _topicController,
                            textInputAction: TextInputAction.done,
                            textCapitalization: TextCapitalization.sentences,
                            cursorColor: primaryColor,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              color: theme.colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: _currentSubject.placeholder,
                              hintStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                                color: subtextColor.withValues(alpha: 0.7),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        if (_topicController.text.isNotEmpty)
                          AcedexBounceable(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _topicController.clear();
                              setState(() {});
                            },
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: lineBorder,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(Icons.close_rounded, size: 13, color: subtextColor),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Staggered Suggestion Chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _currentSubject.suggestions.map((suggestion) {
                      final isMatched = _topicController.text.trim() == suggestion;
                      return AcedexBounceable(
                        onTap: () {
                          setState(() {
                            _topicController.text = suggestion;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isMatched
                                ? primaryColor.withValues(alpha: 0.14)
                                : surfaceColor,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isMatched ? primaryColor : lineBorder,
                            ),
                          ),
                          child: Text(
                            suggestion,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isMatched ? primaryColor : subtextColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // 4. Flexible Custom Time (Time Range Bar)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: lineBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Row 1: Header + Badges
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TIME RANGE',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7,
                                color: subtextColor,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: raisedBg,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: lineBorder),
                                  ),
                                  child: Text(
                                    _getTimeOfDayLabel(_startMinutes),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    _formatDurationText(durationMins),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Start & End Readout Cards
                        Row(
                          children: [
                            // START CARD
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: raisedBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: lineBorder),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'START',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.7,
                                        color: subtextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildNudgeBtn('−', () => _nudgeStart(-15), lineBorder, subtextColor),
                                        Text(
                                          _formatTime12h(_startMinutes),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.2,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        _buildNudgeBtn('+', () => _nudgeStart(15), lineBorder, subtextColor),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // END CARD
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: raisedBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: lineBorder),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'END',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.7,
                                        color: subtextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildNudgeBtn('−', () => _nudgeEnd(-15), lineBorder, subtextColor),
                                        Text(
                                          _formatTime12h(_endMinutes),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.2,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        _buildNudgeBtn('+', () => _nudgeEnd(15), lineBorder, subtextColor),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Interactive Range Slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: primaryColor,
                            inactiveTrackColor: lineBorder,
                            thumbColor: Colors.white,
                            overlayColor: primaryColor.withValues(alpha: 0.16),
                            rangeThumbShape: const RoundRangeSliderThumbShape(
                              enabledThumbRadius: 9,
                              elevation: 3,
                            ),
                            trackHeight: 6,
                          ),
                          child: RangeSlider(
                            values: RangeValues(
                              _startMinutes.toDouble(),
                              _endMinutes.toDouble(),
                            ),
                            min: minDayMinutes.toDouble(),
                            max: maxDayMinutes.toDouble(),
                            divisions: (maxDayMinutes - minDayMinutes) ~/ 15,
                            onChanged: (RangeValues values) {
                              setState(() {
                                _startMinutes = (values.start.round() ~/ 15) * 15;
                                _endMinutes = (values.end.round() ~/ 15) * 15;
                              });
                            },
                          ),
                        ),

                        // Quick Duration Presets
                        Row(
                          children: [30, 45, 60, 90, 120].map((presetMins) {
                            final isSelected = durationMins == presetMins;
                            final label = presetMins >= 60
                                ? (presetMins % 60 == 0 ? '${presetMins ~/ 60}h' : '${presetMins / 60}h')
                                : '${presetMins}m';

                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: AcedexBounceable(
                                  onTap: () => _applyDurationPreset(presetMins),
                                  child: Container(
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? primaryColor.withValues(alpha: 0.14)
                                          : raisedBg,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: isSelected ? primaryColor : lineBorder,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? primaryColor : subtextColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 5. Study Mode Segmented Control
                  Text(
                    'STUDY MODE',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                      color: subtextColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    height: 38,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: lineBorder),
                    ),
                    child: Row(
                      children: ['Deep Focus', 'Past Paper', 'Quick Review'].map((mode) {
                        final isSelected = _selectedFocusMode == mode;
                        return Expanded(
                          child: AcedexBounceable(
                            onTap: () => setState(() => _selectedFocusMode = mode),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? raisedBg : Colors.transparent,
                                borderRadius: BorderRadius.circular(11),
                                border: isSelected ? Border.all(color: lineBorder) : null,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                mode,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? primaryColor : subtextColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Sticky Bottom CTA Button (Elevated above system gesture / navigation bar)
          Builder(
            builder: (context) {
              final bottomInset = MediaQuery.paddingOf(context).bottom;
              return Container(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 18 + bottomInset),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  border: Border(top: BorderSide(color: lineBorder)),
                ),
                child: AcedexBounceable(
                  onTap: _handleSave,
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
                    child: _isSaving
                        ? const AcedexDotsLoader(
                            color: Colors.white,
                            dotSize: 4.5,
                            gap: 3.5,
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Add to Today's Plan",
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNudgeBtn(
    String label,
    VoidCallback onTap,
    Color lineBorder,
    Color subtextColor,
  ) {
    return AcedexBounceable(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: lineBorder),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: subtextColor,
          ),
        ),
      ),
    );
  }
}
