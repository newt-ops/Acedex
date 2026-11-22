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

  const StudyTaskItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.duration,
    required this.completed,
  });

  StudyTaskItem copyWith({
    String? id,
    String? title,
    String? subject,
    String? duration,
    bool? completed,
  }) {
    return StudyTaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      duration: duration ?? this.duration,
      completed: completed ?? this.completed,
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

/// Single Question in a 3-Question EUEE Mini-Drill
class DrillQuestion {
  final String topic;
  final String q;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const DrillQuestion({
    required this.topic,
    required this.q,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

/// Subject Mastery Item with 3-question drill bank & syllabus units
class SubjectMasteryItem {
  final String id;
  final String name;
  final int mastery;
  final List<SyllabusUnit> syllabusUnits;
  final List<DrillQuestion> questions;

  const SubjectMasteryItem({
    required this.id,
    required this.name,
    required this.mastery,
    required this.syllabusUnits,
    required this.questions,
  });

  SubjectMasteryItem copyWith({
    String? id,
    String? name,
    int? mastery,
    List<SyllabusUnit>? syllabusUnits,
    List<DrillQuestion>? questions,
  }) {
    return SubjectMasteryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      mastery: mastery ?? this.mastery,
      syllabusUnits: syllabusUnits ?? this.syllabusUnits,
      questions: questions ?? this.questions,
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
    default:
      return HugeIcons.strokeRoundedBookOpen01;
  }
}

/// Initial Study Tasks matching the Acedex Curriculum Showcase
final List<StudyTaskItem> defaultStudyTasks = [
  const StudyTaskItem(
    id: 'task-1',
    title: 'Physics: Electromagnetism Formula Review',
    subject: 'Physics',
    duration: '15m',
    completed: true,
  ),
  const StudyTaskItem(
    id: 'task-2',
    title: 'Mathematics: Definite Integrals Past Set',
    subject: 'Math',
    duration: '20m',
    completed: true,
  ),
  const StudyTaskItem(
    id: 'task-3',
    title: 'Chemistry: Galvanic Cells & Nernst Drill',
    subject: 'Chemistry',
    duration: '25m',
    completed: false,
  ),
  const StudyTaskItem(
    id: 'task-4',
    title: 'Biology: Molecular Genetics Enzymes Check',
    subject: 'Biology',
    duration: '15m',
    completed: false,
  ),
];

/// Initial Subject Mastery data with 3-question EUEE drill questions & syllabus
final List<SubjectMasteryItem> defaultSubjectsData = [
  const SubjectMasteryItem(
    id: 'physics',
    name: 'Physics',
    mastery: 82,
    syllabusUnits: [
      SyllabusUnit(unit: 'Unit 3: Fluid Mechanics', status: 'Mastered', pct: '100%'),
      SyllabusUnit(unit: 'Unit 4: Electromagnetism', status: 'In Progress', pct: '80%'),
      SyllabusUnit(unit: 'Unit 5: AC Circuits & Electronics', status: 'Up Next', pct: '65%'),
    ],
    questions: [
      DrillQuestion(
        topic: 'Electromagnetic Induction',
        q: 'A 50-turn coil experiences a magnetic flux drop from 0.08 Wb to 0.02 Wb in 0.15 s. What is the magnitude of the induced EMF?',
        options: ['10 V', '20 V', '30 V', '40 V'],
        correctIndex: 1,
        explanation: "Faraday's Law: |ε| = N·|ΔΦ/Δt| = 50 × (0.06 / 0.15) = 20 V.",
      ),
      DrillQuestion(
        topic: 'Lorentz Force',
        q: 'An electron moves perpendicular to a 0.5 T magnetic field at 2 × 10⁶ m/s. What is the magnetic force? (e = 1.6 × 10⁻¹⁹ C)',
        options: ['1.6 × 10⁻¹³ N', '3.2 × 10⁻¹³ N', '8.0 × 10⁻¹⁴ N', '0 N'],
        correctIndex: 0,
        explanation: 'F = qvB·sin(90°) = (1.6 × 10⁻¹⁹)(2 × 10⁶)(0.5) = 1.6 × 10⁻¹³ N.',
      ),
      DrillQuestion(
        topic: 'Transformers',
        q: 'An ideal step-up transformer has 200 primary turns and 1,000 secondary turns. If input is 120 V AC, what is the output voltage?',
        options: ['24 V', '240 V', '600 V', '1,200 V'],
        correctIndex: 2,
        explanation: 'Vs / Vp = Ns / Np ⇒ Vs = 120 × (1000 / 200) = 600 V.',
      ),
    ],
  ),
  const SubjectMasteryItem(
    id: 'mathematics',
    name: 'Mathematics',
    mastery: 88,
    syllabusUnits: [
      SyllabusUnit(unit: 'Unit 4: Differential Calculus', status: 'Mastered', pct: '96%'),
      SyllabusUnit(unit: 'Unit 5: Integral Calculus', status: 'Mastered', pct: '88%'),
      SyllabusUnit(unit: 'Unit 6: 3D Vectors & Planes', status: 'In Progress', pct: '80%'),
    ],
    questions: [
      DrillQuestion(
        topic: 'Definite Integrals',
        q: 'Evaluate the definite integral ∫₀² (3x² + 2x) dx.',
        options: ['8', '10', '12', '16'],
        correctIndex: 2,
        explanation: 'F(x) = x³ + x². Evaluating from 0 to 2 gives (8 + 4) − 0 = 12.',
      ),
      DrillQuestion(
        topic: 'Chain Rule',
        q: 'Find the derivative dy/dx of y = (2x + 1)⁴ at x = 0.',
        options: ['4', '8', '16', '2'],
        correctIndex: 1,
        explanation: "dy/dx = 4(2x + 1)³ · 2 = 8(2x + 1)³. At x = 0, dy/dx = 8(1)³ = 8.",
      ),
      DrillQuestion(
        topic: 'Limits & Continuity',
        q: 'Evaluate lim (x → 0) [ sin(5x) / x ].',
        options: ['0', '1', '5', '1/5'],
        correctIndex: 2,
        explanation: 'Using the standard limit lim(u→0) sin(u)/u = 1, rewrite as 5 · [sin(5x)/(5x)] = 5.',
      ),
    ],
  ),
  const SubjectMasteryItem(
    id: 'chemistry',
    name: 'Chemistry',
    mastery: 71,
    syllabusUnits: [
      SyllabusUnit(unit: 'Unit 3: Chemical Equilibrium', status: 'Mastered', pct: '84%'),
      SyllabusUnit(unit: 'Unit 4: Electrochemistry', status: 'Needs Focus', pct: '62%'),
      SyllabusUnit(unit: 'Unit 5: Organic Polymers', status: 'In Progress', pct: '67%'),
    ],
    questions: [
      DrillQuestion(
        topic: 'Galvanic Cells',
        q: 'Given Zn²⁺/Zn (E° = −0.76 V) and Cu²⁺/Cu (E° = +0.34 V), what is E°cell for a spontaneous Zn–Cu galvanic cell?',
        options: ['+0.42 V', '−1.10 V', '+1.10 V', '−0.42 V'],
        correctIndex: 2,
        explanation: 'E°cell = E°cathode − E°anode = +0.34 V − (−0.76 V) = +1.10 V.',
      ),
      DrillQuestion(
        topic: 'Electrolysis',
        q: 'During electrolysis of molten NaCl, what product forms at the cathode?',
        options: ['Chlorine gas (Cl₂)', 'Sodium metal (Na)', 'Hydrogen gas (H₂)', 'Oxygen gas (O₂)'],
        correctIndex: 1,
        explanation: 'Reduction occurs at the cathode: Na⁺(l) + e⁻ → Na(l).',
      ),
      DrillQuestion(
        topic: 'Acid-Base Equilibrium',
        q: 'What is the pH of a 0.001 M HCl aqueous solution at 25°C?',
        options: ['1', '2', '3', '11'],
        correctIndex: 2,
        explanation: 'HCl is a strong acid: [H⁺] = 10⁻³ M, so pH = −log(10⁻³) = 3.',
      ),
    ],
  ),
  const SubjectMasteryItem(
    id: 'biology',
    name: 'Biology',
    mastery: 79,
    syllabusUnits: [
      SyllabusUnit(unit: 'Unit 3: Cellular Respiration', status: 'Mastered', pct: '86%'),
      SyllabusUnit(unit: 'Unit 4: Molecular Genetics', status: 'Needs Focus', pct: '73%'),
      SyllabusUnit(unit: 'Unit 5: Ecology & Conservation', status: 'In Progress', pct: '78%'),
    ],
    questions: [
      DrillQuestion(
        topic: 'DNA Replication',
        q: 'Which enzyme relieves supercoiling and torsional strain ahead of the replication fork?',
        options: ['DNA Helicase', 'DNA Topoisomerase (Gyrase)', 'RNA Primase', 'DNA Ligase'],
        correctIndex: 1,
        explanation: 'Topoisomerase (DNA gyrase) prevents supercoiling ahead of the replication fork.',
      ),
      DrillQuestion(
        topic: 'Transcription & Translation',
        q: 'Which mRNA codon serves as the universal start codon and codes for Methionine?',
        options: ['UAA', 'UGA', 'AUG', 'UAG'],
        correctIndex: 2,
        explanation: 'AUG initiates translation and specifies Methionine; UAA, UAG, and UGA are stop codons.',
      ),
      DrillQuestion(
        topic: 'Cellular Energetics',
        q: 'Where does the Krebs (Citric Acid) cycle occur in eukaryotic cells?',
        options: ['Cytoplasm', 'Mitochondrial matrix', 'Inner mitochondrial membrane', 'Ribosome'],
        correctIndex: 1,
        explanation: 'The Krebs cycle takes place inside the mitochondrial matrix.',
      ),
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
