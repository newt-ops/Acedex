import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../models/dashboard_data.dart';

/// Apple Cupertino-style Add Study Plan modal bottom sheet.
///
/// Features:
/// - Spring-animated horizontal subject pill selector
/// - Unified single-layer topic input field + single-row quick-fill chips
/// - Interactive horizontal drag & swipe timeline (06:00 AM – 11:30 PM)
/// - Tappable Cupertino time wheels + 15-min steppers + duration presets
/// - Gliding Study Mode segmented pill & horizontal 3-dots wave loader
class AddStudyPlanSheet extends StatefulWidget {
  const AddStudyPlanSheet({
    super.key,
    this.initialSubject = 'Physics',
    this.onSave,
  });

  final String initialSubject;
  final ValueChanged<StudyTaskItem>? onSave;

  /// Presents the Add Study Plan sheet and passes the created [StudyTaskItem]
  /// to [onSave] when confirmed.
  static Future<StudyTaskItem?> show(
    BuildContext context, {
    String initialSubject = 'Physics',
    ValueChanged<StudyTaskItem>? onSave,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet<StudyTaskItem>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (sheetContext) {
        return AddStudyPlanSheet(
          initialSubject: initialSubject,
          onSave: onSave,
        );
      },
    );
  }

  @override
  State<AddStudyPlanSheet> createState() => _AddStudyPlanSheetState();
}

class _AddStudyPlanSheetState extends State<AddStudyPlanSheet> {
  static const int _minStudyMinute = 6 * 60; // 06:00 AM (360)
  static const int _maxStudyMinute = 23 * 60 + 30; // 11:30 PM (1410)
  static const int _minDuration = 15; // 15 min minimum block
  static const int _stepMinutes = 15; // 15 min snap increment

  static const List<_SubjectOption> _subjects = [
    _SubjectOption(
      name: 'Physics',
      icon: Icons.blur_circular_rounded,
      topics: [
        'Electromagnetism • Unit 4',
        '2017 EUEE Past Paper',
        'Optics & Wave Formulas',
        'Rotational Dynamics',
      ],
    ),
    _SubjectOption(
      name: 'Mathematics',
      icon: Icons.functions_rounded,
      topics: [
        'Integration Techniques',
        'Limits & Continuity',
        '2017 EUEE Math Drills',
        'Vectors & 3D Geometry',
      ],
    ),
    _SubjectOption(
      name: 'Chemistry',
      icon: Icons.science_outlined,
      topics: [
        'Electrochemistry • Unit 3',
        'Chemical Equilibrium',
        'Organic Functional Groups',
        'Acid-Base Titrations',
      ],
    ),
    _SubjectOption(
      name: 'Biology',
      icon: Icons.biotech_outlined,
      topics: [
        'Molecular Genetics • Unit 4',
        'Cellular Respiration',
        'Human Nervous System',
        'Ecology & Evolution',
      ],
    ),
    _SubjectOption(
      name: 'English',
      icon: Icons.menu_book_rounded,
      topics: [
        'Reading Comprehension',
        'Grammar & Tense Review',
        'Vocabulary in Context',
        '2016 EUEE English Set',
      ],
    ),
    _SubjectOption(
      name: 'Aptitude',
      icon: Icons.psychology_outlined,
      topics: [
        'Quantitative Reasoning',
        'Analytical Logic Puzzles',
        'Verbal Analogies',
        'Timed Speed Drill',
      ],
    ),
  ];

  static const List<String> _studyModes = [
    'Deep Focus',
    'Past Paper',
    'Quick Review',
  ];

  static const List<int> _durationPresets = [30, 45, 60, 90, 120];

  late String _selectedSubject;
  late TextEditingController _topicController;
  final FocusNode _topicFocusNode = FocusNode();

  int _startMinutes = 16 * 60 + 30; // 04:30 PM
  int _endMinutes = 18 * 60; // 06:00 PM
  int _selectedModeIndex = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final matched = _subjects.any((s) => s.name == widget.initialSubject);
    _selectedSubject = matched ? widget.initialSubject : _subjects.first.name;
    _topicController = TextEditingController(
      text: _currentSubject.topics.first,
    );
    _topicController.addListener(() {
      if (mounted) setState(() {});
    });
    _topicFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _topicController.dispose();
    _topicFocusNode.dispose();
    super.dispose();
  }

  _SubjectOption get _currentSubject =>
      _subjects.firstWhere((s) => s.name == _selectedSubject);

  int get _durationMinutes => _endMinutes - _startMinutes;

  String get _timeOfDayLabel {
    if (_startMinutes < 12 * 60) return 'Morning';
    if (_startMinutes < 17 * 60) return 'Afternoon';
    if (_startMinutes < 20 * 60 + 30) return 'Evening';
    return 'Night';
  }

  String get _formattedDurationHeader {
    final mins = _durationMinutes;
    final hrs = mins ~/ 60;
    final rem = mins % 60;
    if (hrs == 0) return '${rem}m';
    if (rem == 0) return '${hrs}h • $mins min';
    return '${hrs}h ${rem}m • $mins min';
  }

  String get _compactDurationBadge {
    final mins = _durationMinutes;
    final hrs = mins ~/ 60;
    final rem = mins % 60;
    if (hrs == 0) return '${rem}m';
    if (rem == 0) return '${hrs}h';
    return '${hrs}h ${rem}m';
  }

  static String _formatMinutes(int totalMinutes) {
    final clamped = totalMinutes.clamp(0, 1439);
    final hour24 = clamped ~/ 60;
    final minute = clamped % 60;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  void _selectSubject(String subjectName) {
    if (_selectedSubject == subjectName) return;
    HapticFeedback.selectionClick();
    final previousDefault = _currentSubject.topics.first;
    setState(() {
      _selectedSubject = subjectName;
      if (_topicController.text.trim().isEmpty ||
          _topicController.text.trim() == previousDefault) {
        _topicController.text = _currentSubject.topics.first;
        _topicController.selection = TextSelection.fromPosition(
          TextPosition(offset: _topicController.text.length),
        );
      }
    });
  }

  void _stepStart(int delta) {
    final nextStart = (_startMinutes + delta).clamp(
      _minStudyMinute,
      _endMinutes - _minDuration,
    );
    if (nextStart != _startMinutes) {
      HapticFeedback.selectionClick();
      setState(() => _startMinutes = nextStart);
    }
  }

  void _stepEnd(int delta) {
    final nextEnd = (_endMinutes + delta).clamp(
      _startMinutes + _minDuration,
      _maxStudyMinute,
    );
    if (nextEnd != _endMinutes) {
      HapticFeedback.selectionClick();
      setState(() => _endMinutes = nextEnd);
    }
  }

  void _applyDurationPreset(int targetDuration) {
    HapticFeedback.selectionClick();
    setState(() {
      final candidateEnd = _startMinutes + targetDuration;
      if (candidateEnd <= _maxStudyMinute) {
        _endMinutes = candidateEnd;
      } else {
        _endMinutes = _maxStudyMinute;
        _startMinutes = (_maxStudyMinute - targetDuration).clamp(
          _minStudyMinute,
          _maxStudyMinute - _minDuration,
        );
      }
    });
  }

  Future<void> _openCupertinoTimePicker({required bool isStart}) async {
    HapticFeedback.selectionClick();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    final initialMins = isStart ? _startMinutes : _endMinutes;
    var tempDateTime = DateTime(
      2026,
      1,
      1,
      initialMins ~/ 60,
      initialMins % 60,
    );

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (pickerContext) {
        return Container(
          height: 290,
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(pickerContext).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(
                      isStart ? 'Start Time' : 'End Time',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        final pickedMins =
                            tempDateTime.hour * 60 + tempDateTime.minute;
                        setState(() {
                          if (isStart) {
                            _startMinutes = pickedMins.clamp(
                              _minStudyMinute,
                              _endMinutes - _minDuration,
                            );
                          } else {
                            _endMinutes = pickedMins.clamp(
                              _startMinutes + _minDuration,
                              _maxStudyMinute,
                            );
                          }
                        });
                        HapticFeedback.lightImpact();
                        Navigator.of(pickerContext).pop();
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: accent,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: isDark ? Brightness.dark : Brightness.light,
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    minuteInterval: 5,
                    initialDateTime: tempDateTime,
                    minimumDate: DateTime(2026, 1, 1, 6, 0),
                    maximumDate: DateTime(2026, 1, 1, 23, 30),
                    onDateTimeChanged: (dt) => tempDateTime = dt,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    final cleanTopic = _topicController.text.trim().isEmpty
        ? _currentSubject.topics.first
        : _topicController.text.trim();

    HapticFeedback.lightImpact();
    setState(() => _isSaving = true);

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final task = StudyTaskItem(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: cleanTopic,
      subject: _selectedSubject,
      duration: _compactDurationBadge,
      completed: false,
      timeSpan:
          '${_formatMinutes(_startMinutes)} – ${_formatMinutes(_endMinutes)}',
      focusMode: _studyModes[_selectedModeIndex],
    );

    HapticFeedback.mediumImpact();
    widget.onSave?.call(task);
    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final raised = isDark ? AppColors.darkRaised : AppColors.lightRaised;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoft = isDark
        ? AppColors.accentSoftDark
        : AppColors.accentSoftLight;
    final onAccent = isDark ? AppColors.onAccentDark : AppColors.onAccentLight;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final subtext = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;

    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.88,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: line, width: 0.7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.14),
              blurRadius: 28,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. iOS Grabber Pill
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 12),
                width: 38,
                height: 5,
                decoration: BoxDecoration(
                  color: subtext.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            // 2. Header Row (Fixed at sheet top)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Study Plan',
                          style: TextStyle(
                            color: text,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.45,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Customize your session & time block',
                          style: TextStyle(
                            color: subtext,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: subtext,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Scrollable Content Body
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 3. Spring-Animated Subject Rail
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _subjects.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = _subjects[index];
                    final isSelected = item.name == _selectedSubject;
                    return GestureDetector(
                      onTap: () => _selectSubject(item.name),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutBack,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? accent : surface,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.28),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedScale(
                              scale: isSelected ? 1.08 : 1.0,
                              duration: const Duration(milliseconds: 220),
                              child: Icon(
                                item.icon,
                                size: 16,
                                color: isSelected ? onAccent : subtext,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              item.name,
                              style: TextStyle(
                                color: isSelected ? onAccent : text,
                                fontSize: 13.5,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 4. Unified Single-Layer Session Topic Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SESSION TOPIC',
                    style: TextStyle(
                      color: subtext,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    'Tap chip or type custom',
                    style: TextStyle(
                      color: subtext.withValues(alpha: 0.85),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _topicController,
                focusNode: _topicFocusNode,
                textInputAction: TextInputAction.done,
                style: TextStyle(
                  color: text,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                cursorColor: accent,
                decoration: InputDecoration(
                  hintText: 'e.g. ${_currentSubject.topics.first}',
                  hintStyle: TextStyle(
                    color: subtext.withValues(alpha: 0.65),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: _topicFocusNode.hasFocus ? raised : surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.edit_outlined,
                    size: 19,
                    color: _topicFocusNode.hasFocus ? accent : subtext,
                  ),
                  suffixIcon: _topicController.text.isNotEmpty
                      ? IconButton(
                          key: const ValueKey('clear_topic'),
                          tooltip: 'Clear topic',
                          splashRadius: 18,
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            _topicController.clear();
                          },
                          icon: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: subtext.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: text,
                            ),
                          ),
                        )
                      : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: line, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: accent, width: 1.7),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Single-Row Horizontal Quick-Fill Topic Chips
              SizedBox(
                height: 34,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: ListView.separated(
                    key: ValueKey(_selectedSubject),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _currentSubject.topics.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final chipTopic = _currentSubject.topics[index];
                      final isSelected =
                          _topicController.text.trim() == chipTopic;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _topicController.text = chipTopic;
                          _topicController.selection =
                              TextSelection.fromPosition(
                                TextPosition(offset: chipTopic.length),
                              );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? accentSoft : surface,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isSelected ? accent : line,
                              width: isSelected ? 1.3 : 0.8,
                            ),
                          ),
                          child: Text(
                            chipTopic,
                            style: TextStyle(
                              color: isSelected ? accent : subtext,
                              fontSize: 12.5,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 5. Flexible Time Range Card with Draggable & Swipeable Timeline
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: line, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'TIME RANGE',
                          style: TextStyle(
                            color: subtext,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: raised,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: line, width: 0.7),
                          ),
                          child: Text(
                            _timeOfDayLabel,
                            style: TextStyle(
                              color: text,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accentSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _formattedDurationHeader,
                            style: TextStyle(
                              color: accent,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Start & End Stepper + Tappable Cupertino Time Cards
                    Row(
                      children: [
                        Expanded(
                          child: _TimeEndpointCard(
                            label: 'START',
                            formattedTime: _formatMinutes(_startMinutes),
                            canDecrement: _startMinutes > _minStudyMinute,
                            canIncrement:
                                _startMinutes + _stepMinutes <=
                                _endMinutes - _minDuration,
                            onDecrement: () => _stepStart(-_stepMinutes),
                            onIncrement: () => _stepStart(_stepMinutes),
                            onTapTime: () =>
                                _openCupertinoTimePicker(isStart: true),
                            raisedColor: raised,
                            surfaceColor: surface,
                            textColor: text,
                            subtextColor: subtext,
                            lineColor: line,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TimeEndpointCard(
                            label: 'END',
                            formattedTime: _formatMinutes(_endMinutes),
                            canDecrement:
                                _endMinutes - _stepMinutes >=
                                _startMinutes + _minDuration,
                            canIncrement: _endMinutes < _maxStudyMinute,
                            onDecrement: () => _stepEnd(-_stepMinutes),
                            onIncrement: () => _stepEnd(_stepMinutes),
                            onTapTime: () =>
                                _openCupertinoTimePicker(isStart: false),
                            raisedColor: raised,
                            surfaceColor: surface,
                            textColor: text,
                            subtextColor: subtext,
                            lineColor: line,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Interactive Horizontal Drag & Swipe Range Bar
                    _InteractiveTimeRangeBar(
                      minMinute: _minStudyMinute,
                      maxMinute: _maxStudyMinute,
                      startMinute: _startMinutes,
                      endMinute: _endMinutes,
                      minDuration: _minDuration,
                      stepMinutes: _stepMinutes,
                      accentColor: accent,
                      trackColor: line,
                      thumbColor: raised,
                      subtextColor: subtext,
                      onChanged: (newStart, newEnd) {
                        if (newStart != _startMinutes ||
                            newEnd != _endMinutes) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _startMinutes = newStart;
                            _endMinutes = newEnd;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Quick Duration Presets
                    Row(
                      children: _durationPresets.map((preset) {
                        final isActive = _durationMinutes == preset;
                        final label = preset < 60
                            ? '${preset}m'
                            : preset % 60 == 0
                            ? '${preset ~/ 60}h'
                            : '${(preset / 60).toStringAsFixed(1)}h';
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: preset == _durationPresets.last ? 0 : 6,
                            ),
                            child: GestureDetector(
                              onTap: () => _applyDurationPreset(preset),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isActive ? accentSoft : raised,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: isActive ? accent : line,
                                    width: isActive ? 1.4 : 0.8,
                                  ),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: isActive ? accent : subtext,
                                    fontSize: 12.5,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w600,
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

              // 6. Gliding Cupertino Study Mode Segmented Control
              Text(
                'STUDY MODE',
                style: TextStyle(
                  color: subtext,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: line, width: 0.8),
                ),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment(
                        -1.0 + (_selectedModeIndex * 1.0),
                        0.0,
                      ),
                      child: FractionallySizedBox(
                        widthFactor: 1 / _studyModes.length,
                        heightFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: raised,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.25 : 0.06,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(_studyModes.length, (idx) {
                        final selected = idx == _selectedModeIndex;
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (_selectedModeIndex == idx) return;
                              HapticFeedback.selectionClick();
                              setState(() => _selectedModeIndex = idx);
                            },
                            child: Center(
                              child: Text(
                                _studyModes[idx],
                                style: TextStyle(
                                  color: selected ? accent : subtext,
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
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
                  ],
                ),
              ),
            ),

            // 7. Sticky Bottom CTA (Elevated above system gesture / navigation bar)
            Container(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 14 + bottomPadding),
              decoration: BoxDecoration(
                color: bg,
                border: Border(top: BorderSide(color: line, width: 0.6)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    disabledBackgroundColor: accent,
                    foregroundColor: onAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _isSaving
                        ? _HorizontalThreeDotsLoader(
                            key: const ValueKey('dots_loader'),
                            color: onAccent,
                          )
                        : Row(
                            key: const ValueKey('cta_label'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Add to Today's Plan",
                                style: TextStyle(
                                  color: onAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 19,
                                color: onAccent,
                              ),
                            ],
                          ),
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

class _SubjectOption {
  const _SubjectOption({
    required this.name,
    required this.icon,
    required this.topics,
  });

  final String name;
  final IconData icon;
  final List<String> topics;
}

class _TimeEndpointCard extends StatelessWidget {
  const _TimeEndpointCard({
    required this.label,
    required this.formattedTime,
    required this.canDecrement,
    required this.canIncrement,
    required this.onDecrement,
    required this.onIncrement,
    required this.onTapTime,
    required this.raisedColor,
    required this.surfaceColor,
    required this.textColor,
    required this.subtextColor,
    required this.lineColor,
  });

  final String label;
  final String formattedTime;
  final bool canDecrement;
  final bool canIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onTapTime;
  final Color raisedColor;
  final Color surfaceColor;
  final Color textColor;
  final Color subtextColor;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: raisedColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: lineColor, width: 0.8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: subtextColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniStepButton(
                icon: Icons.remove_rounded,
                enabled: canDecrement,
                onTap: onDecrement,
                surfaceColor: surfaceColor,
                iconColor: textColor,
                lineColor: lineColor,
              ),
              Flexible(
                child: GestureDetector(
                  onTap: onTapTime,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      formattedTime,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
              _MiniStepButton(
                icon: Icons.add_rounded,
                enabled: canIncrement,
                onTap: onIncrement,
                surfaceColor: surfaceColor,
                iconColor: textColor,
                lineColor: lineColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStepButton extends StatelessWidget {
  const _MiniStepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.surfaceColor,
    required this.iconColor,
    required this.lineColor,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final Color surfaceColor;
  final Color iconColor;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1.0 : 0.35,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: surfaceColor,
            shape: BoxShape.circle,
            border: Border.all(color: lineColor, width: 0.8),
          ),
          child: Icon(icon, size: 15, color: iconColor),
        ),
      ),
    );
  }
}

enum _DragTargetMode { none, startThumb, endThumb, rangeBlock }

/// Custom horizontal timeline supporting independent thumb dragging AND
/// swiping the active Royal Purple range bar to shift the entire time slot.
class _InteractiveTimeRangeBar extends StatefulWidget {
  const _InteractiveTimeRangeBar({
    required this.minMinute,
    required this.maxMinute,
    required this.startMinute,
    required this.endMinute,
    required this.minDuration,
    required this.stepMinutes,
    required this.accentColor,
    required this.trackColor,
    required this.thumbColor,
    required this.subtextColor,
    required this.onChanged,
  });

  final int minMinute;
  final int maxMinute;
  final int startMinute;
  final int endMinute;
  final int minDuration;
  final int stepMinutes;
  final Color accentColor;
  final Color trackColor;
  final Color thumbColor;
  final Color subtextColor;
  final void Function(int startMinute, int endMinute) onChanged;

  @override
  State<_InteractiveTimeRangeBar> createState() =>
      _InteractiveTimeRangeBarState();
}

class _InteractiveTimeRangeBarState extends State<_InteractiveTimeRangeBar> {
  _DragTargetMode _dragMode = _DragTargetMode.none;
  double _dragStartX = 0;
  int _initialStart = 0;
  int _initialEnd = 0;

  int get _totalSpan => widget.maxMinute - widget.minMinute;

  int _snap(int rawMinute) {
    final relative = rawMinute - widget.minMinute;
    final snapped =
        (relative / widget.stepMinutes).round() * widget.stepMinutes;
    return (widget.minMinute + snapped).clamp(
      widget.minMinute,
      widget.maxMinute,
    );
  }

  void _handlePanStart(
    DragStartDetails details,
    double usableWidth,
    double thumbRadius,
  ) {
    final localX = details.localPosition.dx - thumbRadius;
    final startPx =
        ((widget.startMinute - widget.minMinute) / _totalSpan) * usableWidth;
    final endPx =
        ((widget.endMinute - widget.minMinute) / _totalSpan) * usableWidth;

    const hitSlop = 22.0;
    final distStart = (localX - startPx).abs();
    final distEnd = (localX - endPx).abs();

    setState(() {
      _dragStartX = localX;
      _initialStart = widget.startMinute;
      _initialEnd = widget.endMinute;

      if (distStart <= hitSlop && distStart <= distEnd) {
        _dragMode = _DragTargetMode.startThumb;
      } else if (distEnd <= hitSlop) {
        _dragMode = _DragTargetMode.endThumb;
      } else if (localX > startPx && localX < endPx) {
        _dragMode = _DragTargetMode.rangeBlock;
      } else if (localX < startPx) {
        _dragMode = _DragTargetMode.startThumb;
      } else {
        _dragMode = _DragTargetMode.endThumb;
      }
    });
    HapticFeedback.selectionClick();
  }

  void _handlePanUpdate(
    DragUpdateDetails details,
    double usableWidth,
    double thumbRadius,
  ) {
    if (_dragMode == _DragTargetMode.none || usableWidth <= 0) return;
    final localX = details.localPosition.dx - thumbRadius;
    final deltaMinutes = ((localX - _dragStartX) / usableWidth) * _totalSpan;

    if (_dragMode == _DragTargetMode.startThumb) {
      final raw = (_initialStart + deltaMinutes).round();
      final nextStart = _snap(
        raw,
      ).clamp(widget.minMinute, widget.endMinute - widget.minDuration);
      widget.onChanged(nextStart, widget.endMinute);
    } else if (_dragMode == _DragTargetMode.endThumb) {
      final raw = (_initialEnd + deltaMinutes).round();
      final nextEnd = _snap(
        raw,
      ).clamp(widget.startMinute + widget.minDuration, widget.maxMinute);
      widget.onChanged(widget.startMinute, nextEnd);
    } else if (_dragMode == _DragTargetMode.rangeBlock) {
      final duration = _initialEnd - _initialStart;
      final rawStart = (_initialStart + deltaMinutes).round();
      final clampedStart = _snap(
        rawStart,
      ).clamp(widget.minMinute, widget.maxMinute - duration);
      widget.onChanged(clampedStart, clampedStart + duration);
    }
  }

  void _handlePanEnd(DragEndDetails _) {
    if (_dragMode != _DragTargetMode.none) {
      setState(() => _dragMode = _DragTargetMode.none);
    }
  }

  @override
  Widget build(BuildContext context) {
    const thumbRadius = 12.0;
    const trackHeight = 8.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final usableWidth = math.max(1.0, totalWidth - thumbRadius * 2);

        final startFraction =
            (widget.startMinute - widget.minMinute) / _totalSpan;
        final endFraction = (widget.endMinute - widget.minMinute) / _totalSpan;

        final startCenter = thumbRadius + startFraction * usableWidth;
        final endCenter = thumbRadius + endFraction * usableWidth;
        final activeWidth = math.max(12.0, endCenter - startCenter);

        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (d) =>
                  _handlePanStart(d, usableWidth, thumbRadius),
              onHorizontalDragUpdate: (d) =>
                  _handlePanUpdate(d, usableWidth, thumbRadius),
              onHorizontalDragEnd: _handlePanEnd,
              child: SizedBox(
                height: 44,
                width: totalWidth,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    // Subtle hour tick marks along the track
                    Positioned(
                      left: thumbRadius,
                      right: thumbRadius,
                      top: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(18, (i) {
                          final isMajor = i % 3 == 0;
                          return Container(
                            width: 1.2,
                            height: isMajor ? 6 : 3.5,
                            decoration: BoxDecoration(
                              color: widget.subtextColor.withValues(
                                alpha: isMajor ? 0.35 : 0.18,
                              ),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Background Track
                    Positioned(
                      left: thumbRadius,
                      right: thumbRadius,
                      top: 12,
                      child: Container(
                        height: trackHeight,
                        decoration: BoxDecoration(
                          color: widget.trackColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),

                    // Swipeable Royal Purple Active Range Bar
                    Positioned(
                      left: startCenter,
                      top: 10,
                      child: Container(
                        width: activeWidth,
                        height: 12,
                        decoration: BoxDecoration(
                          color: widget.accentColor,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: widget.accentColor.withValues(alpha: 0.32),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Start Thumb
                    Positioned(
                      left: startCenter - thumbRadius,
                      top: 4,
                      child: _TimelineThumb(
                        isActive:
                            _dragMode == _DragTargetMode.startThumb ||
                            _dragMode == _DragTargetMode.rangeBlock,
                        accentColor: widget.accentColor,
                        thumbColor: widget.thumbColor,
                      ),
                    ),

                    // End Thumb
                    Positioned(
                      left: endCenter - thumbRadius,
                      top: 4,
                      child: _TimelineThumb(
                        isActive:
                            _dragMode == _DragTargetMode.endThumb ||
                            _dragMode == _DragTargetMode.rangeBlock,
                        accentColor: widget.accentColor,
                        thumbColor: widget.thumbColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Hour Anchor Labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '6 AM',
                    style: TextStyle(
                      color: widget.subtextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '12 PM',
                    style: TextStyle(
                      color: widget.subtextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '6 PM',
                    style: TextStyle(
                      color: widget.subtextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '11:30 PM',
                    style: TextStyle(
                      color: widget.subtextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TimelineThumb extends StatelessWidget {
  const _TimelineThumb({
    required this.isActive,
    required this.accentColor,
    required this.thumbColor,
  });

  final bool isActive;
  final Color accentColor;
  final Color thumbColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isActive ? 1.16 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutBack,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: thumbColor,
          shape: BoxShape.circle,
          border: Border.all(color: accentColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal 3-dots wave loader (Apple-style alternative to circular spinners).
class _HorizontalThreeDotsLoader extends StatefulWidget {
  const _HorizontalThreeDotsLoader({super.key, required this.color});

  final Color color;

  @override
  State<_HorizontalThreeDotsLoader> createState() =>
      _HorizontalThreeDotsLoaderState();
}

class _HorizontalThreeDotsLoaderState extends State<_HorizontalThreeDotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final phase = (_controller.value * 2 * math.pi) - (index * 0.85);
            final wave = (math.sin(phase) + 1) / 2;
            final scale = 0.72 + (wave * 0.38);
            final opacity = 0.45 + (wave * 0.55);

            return Padding(
              padding: EdgeInsets.only(right: index == 2 ? 0 : 6),
              child: Transform.translate(
                offset: Offset(0, -wave * 3.2),
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
