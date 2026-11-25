import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';

/// Single Study Task Item for Today's Study Plan
class StudyTaskItem {
  final String id;
  final String title;
  final String subject;
  final String duration;
  final bool completed;
  final String? timeSpan;
  final String? focusMode;

  const StudyTaskItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.duration,
    required this.completed,
    this.timeSpan,
    this.focusMode,
  });

  StudyTaskItem copyWith({
    String? id,
    String? title,
    String? subject,
    String? duration,
    bool? completed,
    String? timeSpan,
    String? focusMode,
  }) {
    return StudyTaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      duration: duration ?? this.duration,
      completed: completed ?? this.completed,
      timeSpan: timeSpan ?? this.timeSpan,
      focusMode: focusMode ?? this.focusMode,
    );
  }
}

/// Syllabus Unit for Subject Mastery expandable drawer
class SyllabusUnit {
  final String unit;
  final String status;
  final String pct;

  const SyllabusUnit({
    required this.unit,
    required this.status,
    required this.pct,
  });
}

/// Subject Mastery Item with syllabus units
class SubjectMasteryItem {
  final String id;
  final String name;
  final int mastery;
  final List<SyllabusUnit> syllabusUnits;

  const SubjectMasteryItem({
    required this.id,
    required this.name,
    required this.mastery,
    required this.syllabusUnits,
  });

  SubjectMasteryItem copyWith({
    String? id,
    String? name,
    int? mastery,
    List<SyllabusUnit>? syllabusUnits,
  }) {
    return SubjectMasteryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      mastery: mastery ?? this.mastery,
      syllabusUnits: syllabusUnits ?? this.syllabusUnits,
    );
  }
}

/// Quick Formula & Concept Flashcard Item (3D Flip)
class FlashcardItem {
  final String id;
  final String subject;
  final String title;
  final String prompt;
  final String formula;
  final String examTip;

  const FlashcardItem({
    required this.id,
    required this.subject,
    required this.title,
    required this.prompt,
    required this.formula,
    required this.examTip,
  });
}

/// Canonical subject color mapping
Color getSubjectColor(String subject) {
  switch (subject.toLowerCase()) {
    case 'physics':
      return AppColors.royalPurple;
    case 'math':
    case 'mathematics':
      return const Color(0xFF2563EB);
    case 'chemistry':
      return AppColors.warning;
    case 'biology':
      return AppColors.success;
    case 'english':
      return const Color(0xFF0D9488);
    case 'aptitude':
      return const Color(0xFF8B5CF6);
    default:
      return AppColors.royalPurple;
  }
}

/// Canonical subject HugeIcon mapping
List<List<dynamic>> getSubjectIconData(String subject) {
  switch (subject.toLowerCase()) {
    case 'physics':
      return HugeIcons.strokeRoundedAtom01;
    case 'math':
    case 'mathematics':
      return HugeIcons.strokeRoundedCalculate;
    case 'chemistry':
      return HugeIcons.strokeRoundedChemistry01;
    case 'biology':
      return HugeIcons.strokeRoundedDna;
    case 'english':
      return HugeIcons.strokeRoundedBook02;
    case 'aptitude':
      return HugeIcons.strokeRoundedIdea01;
    default:
      return HugeIcons.strokeRoundedBookOpen01;
  }
}

/// Initial Study Tasks (starts empty by default as requested; populated when student adds tasks)
final List<StudyTaskItem> defaultStudyTasks = [];

/// Initial Subject Mastery data & syllabus (starts from 0% real baseline)
final List<SubjectMasteryItem> defaultSubjectsData = [
  const SubjectMasteryItem(
    id: 'physics',
    name: 'Physics',
    mastery: 0,
    syllabusUnits: [
      SyllabusUnit(unit: 'Unit 3: Fluid Mechanics', status: 'Not Started', pct: '0%'),
      SyllabusUnit(unit: 'Unit 4: Electromagnetism', status: 'Not Started', pct: '0%'),
      SyllabusUnit(unit: 'Unit 5: AC Circuits & Electronics', status: 'Not Started', pct: '0%'),
    ],
  ),
  const SubjectMasteryItem(
    id: 'mathematics',
    name: 'Mathematics',
    mastery: 0,
    syllabusUnits: [
      SyllabusUnit(unit: 'Unit 4: Differential Calculus', status: 'Not Started', pct: '0%'),
      SyllabusUnit(unit: 'Unit 5: Integral Calculus', status: 'Not Started', pct: '0%'),
      SyllabusUnit(unit: 'Unit 6: 3D Vectors & Planes', status: 'Not Started', pct: '0%'),
    ],
  ),
  const SubjectMasteryItem(
    id: 'chemistry',
    name: 'Chemistry',
    mastery: 0,
    syllabusUnits: [
      SyllabusUnit(unit: 'Unit 3: Chemical Equilibrium', status: 'Not Started', pct: '0%'),
      SyllabusUnit(unit: 'Unit 4: Electrochemistry', status: 'Not Started', pct: '0%'),
      SyllabusUnit(unit: 'Unit 5: Organic Polymers', status: 'Not Started', pct: '0%'),
    ],
  ),
  const SubjectMasteryItem(
    id: 'biology',
    name: 'Biology',
    mastery: 0,
    syllabusUnits: [
      SyllabusUnit(unit: 'Unit 3: Cellular Respiration', status: 'Not Started', pct: '0%'),
      SyllabusUnit(unit: 'Unit 4: Molecular Genetics', status: 'Not Started', pct: '0%'),
      SyllabusUnit(unit: 'Unit 5: Ecology & Conservation', status: 'Not Started', pct: '0%'),
    ],
  ),
  const SubjectMasteryItem(
    id: 'english',
    name: 'English',
    mastery: 0,
    syllabusUnits: [
      SyllabusUnit(unit: 'Unit 1: Sustainable Development', status: 'Not Started', pct: '0%'),
      SyllabusUnit(unit: 'Unit 2: Time Management', status: 'Not Started', pct: '0%'),
      SyllabusUnit(unit: 'Unit 3: Traffic Accidents Evidence', status: 'Not Started', pct: '0%'),
    ],
  ),
];

/// Initial Flashcards matching the 3D Snap Carousel
final List<FlashcardItem> defaultFlashcardsData = [
  const FlashcardItem(
    id: 'fc-1',
    subject: 'Physics • Unit 4',
    title: "Faraday's Law",
    prompt: 'Induced EMF in a coil of N turns from changing magnetic flux',
    formula: 'ε = −N · (ΔΦ / Δt)',
    examTip: "EUEE Tip: Negative sign reflects Lenz's Law opposing flux change.",
  ),
  const FlashcardItem(
    id: 'fc-2',
    subject: 'Mathematics • Unit 4',
    title: 'Chain Rule',
    prompt: 'Derivative of a composite function f(g(x))',
    formula: "d/dx [f(g(x))] = f′(g(x)) · g′(x)",
    examTip: "EUEE Tip: Always multiply by the inner derivative g′(x)!",
  ),
  const FlashcardItem(
    id: 'fc-3',
    subject: 'Chemistry • Unit 4',
    title: 'Nernst Equation',
    prompt: 'Cell potential E at 298 K under non-standard concentrations',
    formula: 'E = E° − (0.0592 / n) · log Q',
    examTip: 'EUEE Tip: At equilibrium, E = 0 and Q = Keq.',
  ),
  const FlashcardItem(
    id: 'fc-4',
    subject: 'Biology • Unit 4',
    title: 'DNA Replication',
    prompt: 'Direction of new strand synthesis & leading vs. lagging strand',
    formula: "5′ → 3′ Synthesis Only",
    examTip: 'EUEE Tip: Okazaki fragments on lagging strand are joined by DNA Ligase.',
  ),
];
