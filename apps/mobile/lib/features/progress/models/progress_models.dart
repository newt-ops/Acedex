import 'package:hugeicons/hugeicons.dart';

/// Analytics timeframe options
enum ProgressTimeframe {
  sevenDays('7d', '7 Days'),
  thirtyDays('30d', '30 Days'),
  allTerm('term', 'All Term');

  final String key;
  final String label;
  const ProgressTimeframe(this.key, this.label);
}

/// Readiness Pillar types
enum ReadinessPillarType {
  coverage('Syllabus Coverage'),
  accuracy('Mock Accuracy'),
  consistency('Consistency');

  final String title;
  const ReadinessPillarType(this.title);
}

/// Chart metric toggle
enum ChartMetricType {
  hours('Study Hours'),
  accuracy('Quiz Accuracy');

  final String label;
  const ChartMetricType(this.label);
}

/// Subject filter tabs
enum SubjectFilterTab {
  all('All'),
  focus('Needs Focus'),
  ready('Exam Ready');

  final String label;
  const SubjectFilterTab(this.label);
}

/// Single data point for the 7-period chart
class TimeframePoint {
  final String short;
  final String label;
  final double hours;
  final int qs;
  final int acc;

  const TimeframePoint({
    required this.short,
    required this.label,
    required this.hours,
    required this.qs,
    required this.acc,
  });
}

/// Complete dataset for a selected timeframe
class TimeframeData {
  final int readinessPct;
  final int projectedScore;
  final String percentile;
  final String delta;
  final String subcopy;
  final int coveragePct;
  final int accuracyPct;
  final int consistencyPct;
  final String footerHours;
  final String footerAcc;
  final String footerQs;
  final List<TimeframePoint> points;
  final Map<String, String> subjectDeltas;

  const TimeframeData({
    required this.readinessPct,
    required this.projectedScore,
    required this.percentile,
    required this.delta,
    required this.subcopy,
    required this.coveragePct,
    required this.accuracyPct,
    required this.consistencyPct,
    required this.footerHours,
    required this.footerAcc,
    required this.footerQs,
    required this.points,
    required this.subjectDeltas,
  });
}

/// Single day cell for the 28-day consistency heatmap
class HeatmapDay {
  final String date;
  final double hours;
  final int acc;
  final int level; // 0 to 4

  const HeatmapDay({
    required this.date,
    required this.hours,
    required this.acc,
    required this.level,
  });
}

/// Unit progress within a subject
class SubjectUnitProgress {
  final String name;
  int pct;
  final bool isWeakest;

  SubjectUnitProgress({
    required this.name,
    required this.pct,
    this.isWeakest = false,
  });
}

/// Booster drill multiple-choice question
class BoosterQuestion {
  final String stem;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const BoosterQuestion({
    required this.stem,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

/// Subject Mastery state model
class SubjectMastery {
  final String id;
  final String name;
  int mastery;
  final String weightLabel;
  final int pacingSec;
  final String weakestTopic;
  final dynamic icon;
  final List<SubjectUnitProgress> units;
  final List<BoosterQuestion> boosterQuestions;

  SubjectMastery({
    required this.id,
    required this.name,
    required this.mastery,
    required this.weightLabel,
    required this.pacingSec,
    required this.weakestTopic,
    required this.icon,
    required this.units,
    required this.boosterQuestions,
  });
}

/// Static datasets and helpers
abstract class ProgressData {
  static const Map<ProgressTimeframe, TimeframeData> timeframeMap = {
    ProgressTimeframe.sevenDays: TimeframeData(
      readinessPct: 78,
      projectedScore: 468,
      percentile: 'Top 5%',
      delta: '+4.2%',
      subcopy: 'On track for AAU Engineering & Medicine cutoff.',
      coveragePct: 79,
      accuracyPct: 83,
      consistencyPct: 88,
      footerHours: '18.4 hrs',
      footerAcc: '83.4%',
      footerQs: '268 Qs',
      points: [
        TimeframePoint(short: 'Mon', label: 'Mon • Nov 16', hours: 2.2, qs: 32, acc: 79),
        TimeframePoint(short: 'Tue', label: 'Tue • Nov 17', hours: 2.7, qs: 40, acc: 82),
        TimeframePoint(short: 'Wed', label: 'Wed • Nov 18', hours: 1.9, qs: 28, acc: 80),
        TimeframePoint(short: 'Thu', label: 'Thu • Nov 19', hours: 3.1, qs: 46, acc: 86),
        TimeframePoint(short: 'Fri', label: 'Fri • Nov 20', hours: 2.6, qs: 38, acc: 84),
        TimeframePoint(short: 'Sat', label: 'Sat • Nov 21', hours: 3.0, qs: 44, acc: 85),
        TimeframePoint(short: 'Sun', label: 'Sun • Nov 22', hours: 2.9, qs: 40, acc: 88),
      ],
      subjectDeltas: {'math': '+3.4%', 'physics': '+4.8%', 'biology': '+2.6%', 'chemistry': '+1.9%'},
    ),
    ProgressTimeframe.thirtyDays: TimeframeData(
      readinessPct: 81,
      projectedScore: 486,
      percentile: 'Top 3%',
      delta: '+6.8%',
      subcopy: 'Strong upward trajectory across all 4 core sciences.',
      coveragePct: 82,
      accuracyPct: 85,
      consistencyPct: 91,
      footerHours: '76.5 hrs',
      footerAcc: '84.8%',
      footerQs: '1,120 Qs',
      points: [
        TimeframePoint(short: 'W1', label: 'Oct 25 – Oct 31', hours: 2.3, qs: 145, acc: 81),
        TimeframePoint(short: 'W2', label: 'Nov 01 – Nov 07', hours: 2.5, qs: 158, acc: 83),
        TimeframePoint(short: 'W3', label: 'Nov 08 – Nov 14', hours: 2.8, qs: 172, acc: 85),
        TimeframePoint(short: 'Mon', label: 'Nov 16 • Mon', hours: 2.2, qs: 148, acc: 82),
        TimeframePoint(short: 'Wed', label: 'Nov 18 • Wed', hours: 2.9, qs: 166, acc: 86),
        TimeframePoint(short: 'Fri', label: 'Nov 20 • Fri', hours: 3.1, qs: 170, acc: 87),
        TimeframePoint(short: 'Sun', label: 'Nov 22 • Sun', hours: 3.0, qs: 161, acc: 88),
      ],
      subjectDeltas: {'math': '+5.1%', 'physics': '+6.4%', 'biology': '+4.2%', 'chemistry': '+3.8%'},
    ),
    ProgressTimeframe.allTerm: TimeframeData(
      readinessPct: 76,
      projectedScore: 456,
      percentile: 'Top 7%',
      delta: '+9.4%',
      subcopy: 'Steady cumulative growth since Term 1 diagnostic.',
      coveragePct: 78,
      accuracyPct: 80,
      consistencyPct: 84,
      footerHours: '214.0 hrs',
      footerAcc: '80.6%',
      footerQs: '3,240 Qs',
      points: [
        TimeframePoint(short: 'Sep', label: 'September • Term 1', hours: 1.8, qs: 380, acc: 74),
        TimeframePoint(short: 'Oct', label: 'October • Term 1', hours: 2.1, qs: 430, acc: 77),
        TimeframePoint(short: 'Nov', label: 'November • Term 1', hours: 2.4, qs: 490, acc: 80),
        TimeframePoint(short: 'Dec', label: 'December • Midterms', hours: 2.7, qs: 540, acc: 82),
        TimeframePoint(short: 'Jan', label: 'January • Term 2', hours: 2.5, qs: 470, acc: 81),
        TimeframePoint(short: 'Feb', label: 'February • Mocks', hours: 2.8, qs: 460, acc: 84),
        TimeframePoint(short: 'Mar', label: 'March • EUEE Prep', hours: 3.0, qs: 470, acc: 86),
      ],
      subjectDeltas: {'math': '+8.2%', 'physics': '+9.6%', 'biology': '+7.5%', 'chemistry': '+6.4%'},
    ),
  };

  static String getPillarExplanation(ReadinessPillarType pillar, int pct) {
    switch (pillar) {
      case ReadinessPillarType.coverage:
        return 'Syllabus Coverage ($pct%): 19 of 24 Grade 12 Natural Science units completed with notes & formula checks.';
      case ReadinessPillarType.accuracy:
        return 'Mock Accuracy ($pct%): Weighted average score across timed EUEE past papers and unit drills over the selected window.';
      case ReadinessPillarType.consistency:
        return 'Consistency ($pct%): Tracks daily study target adherence (2.5h/day) and uninterrupted active study streaks.';
    }
  }

  static const List<HeatmapDay> heatmapDays = [
    HeatmapDay(date: 'Oct 26 • Mon', hours: 1.8, acc: 78, level: 2),
    HeatmapDay(date: 'Oct 27 • Tue', hours: 2.5, acc: 81, level: 3),
    HeatmapDay(date: 'Oct 28 • Wed', hours: 0.0, acc: 0, level: 0),
    HeatmapDay(date: 'Oct 29 • Thu', hours: 2.2, acc: 80, level: 2),
    HeatmapDay(date: 'Oct 30 • Fri', hours: 2.8, acc: 83, level: 3),
    HeatmapDay(date: 'Oct 31 • Sat', hours: 3.4, acc: 85, level: 4),
    HeatmapDay(date: 'Nov 01 • Sun', hours: 2.6, acc: 82, level: 3),

    HeatmapDay(date: 'Nov 02 • Mon', hours: 2.1, acc: 81, level: 2),
    HeatmapDay(date: 'Nov 03 • Tue', hours: 2.9, acc: 84, level: 3),
    HeatmapDay(date: 'Nov 04 • Wed', hours: 1.2, acc: 76, level: 1),
    HeatmapDay(date: 'Nov 05 • Thu', hours: 2.7, acc: 83, level: 3),
    HeatmapDay(date: 'Nov 06 • Fri', hours: 3.2, acc: 86, level: 4),
    HeatmapDay(date: 'Nov 07 • Sat', hours: 3.5, acc: 87, level: 4),
    HeatmapDay(date: 'Nov 08 • Sun', hours: 2.4, acc: 82, level: 2),

    HeatmapDay(date: 'Nov 09 • Mon', hours: 2.6, acc: 83, level: 3),
    HeatmapDay(date: 'Nov 10 • Tue', hours: 0.0, acc: 0, level: 0),
    HeatmapDay(date: 'Nov 11 • Wed', hours: 2.3, acc: 81, level: 2),
    HeatmapDay(date: 'Nov 12 • Thu', hours: 2.8, acc: 84, level: 3),
    HeatmapDay(date: 'Nov 13 • Fri', hours: 3.1, acc: 85, level: 4),
    HeatmapDay(date: 'Nov 14 • Sat', hours: 3.3, acc: 86, level: 4),
    HeatmapDay(date: 'Nov 15 • Sun', hours: 2.5, acc: 83, level: 3),

    HeatmapDay(date: 'Nov 16 • Mon', hours: 2.2, acc: 79, level: 2),
    HeatmapDay(date: 'Nov 17 • Tue', hours: 2.7, acc: 82, level: 3),
    HeatmapDay(date: 'Nov 18 • Wed', hours: 1.9, acc: 80, level: 2),
    HeatmapDay(date: 'Nov 19 • Thu', hours: 3.1, acc: 86, level: 4),
    HeatmapDay(date: 'Nov 20 • Fri', hours: 2.6, acc: 84, level: 3),
    HeatmapDay(date: 'Nov 21 • Sat', hours: 3.0, acc: 85, level: 4),
    HeatmapDay(date: 'Nov 22 • Today', hours: 2.9, acc: 88, level: 4),
  ];

  static List<SubjectMastery> getInitialSubjects() {
    return [
      SubjectMastery(
        id: 'math',
        name: 'Mathematics',
        mastery: 88,
        weightLabel: '100 pts',
        pacingSec: 54,
        weakestTopic: 'Integration by Parts',
        icon: HugeIcons.strokeRoundedCalculate,
        units: [
          SubjectUnitProgress(name: 'Unit 1: Sequences & Series', pct: 94),
          SubjectUnitProgress(name: 'Unit 2: Vectors in Space', pct: 90),
          SubjectUnitProgress(name: 'Unit 3: Differential Calculus', pct: 89),
          SubjectUnitProgress(name: 'Unit 4: Integral Calculus', pct: 79, isWeakest: true),
        ],
        boosterQuestions: const [
          BoosterQuestion(
            stem: 'Evaluate ∫ x · eˣ dx using integration by parts (∫ u dv = uv − ∫ v du).',
            options: ['x·eˣ + eˣ + C', 'x·eˣ − eˣ + C', 'eˣ − x·eˣ + C', '½x²·eˣ + C'],
            correctIndex: 1,
            explanation: 'Choose u = x (du = dx) and dv = eˣ dx (v = eˣ). Then ∫ x·eˣ dx = x·eˣ − ∫ eˣ dx = x·eˣ − eˣ + C.',
          ),
          BoosterQuestion(
            stem: 'What is the definite integral ∫₀^π sin(x) dx?',
            options: ['0', '1', '2', 'π'],
            correctIndex: 2,
            explanation: '∫₀^π sin(x) dx = [−cos(x)]₀^π = −cos(π) − (−cos(0)) = −(−1) + 1 = 2.',
          ),
        ],
      ),
      SubjectMastery(
        id: 'physics',
        name: 'Physics',
        mastery: 82,
        weightLabel: '100 pts',
        pacingSec: 58,
        weakestTopic: "Faraday's Induction",
        icon: HugeIcons.strokeRoundedAtom01,
        units: [
          SubjectUnitProgress(name: 'Unit 1: Biophysics & Waves', pct: 88),
          SubjectUnitProgress(name: 'Unit 2: 2D Projectile Motion', pct: 86),
          SubjectUnitProgress(name: 'Unit 3: Fluid Mechanics', pct: 81),
          SubjectUnitProgress(name: 'Unit 4: Electromagnetism', pct: 73, isWeakest: true),
        ],
        boosterQuestions: const [
          BoosterQuestion(
            stem: 'According to Lenz’s Law, the direction of an induced current always opposes:',
            options: [
              'The resistance of the conducting loop',
              'The change in magnetic flux that produced it',
              'The gravitational force on the coil',
              'The steady DC supply voltage',
            ],
            correctIndex: 1,
            explanation: 'Lenz’s Law (the minus sign in ε = −N ΔΦB/Δt) ensures induced current opposes the flux change, conserving energy.',
          ),
          BoosterQuestion(
            stem: 'A 40-turn coil experiences a flux change of 0.05 Wb in 0.10 s. Find the induced EMF magnitude.',
            options: ['2 V', '10 V', '20 V', '40 V'],
            correctIndex: 2,
            explanation: '|ε| = N · |ΔΦB / Δt| = 40 × (0.05 / 0.10) = 40 × 0.5 = 20 V.',
          ),
        ],
      ),
      SubjectMastery(
        id: 'biology',
        name: 'Biology',
        mastery: 79,
        weightLabel: '100 pts',
        pacingSec: 49,
        weakestTopic: 'Enzyme Kinetics',
        icon: HugeIcons.strokeRoundedDna,
        units: [
          SubjectUnitProgress(name: 'Unit 1: Microorganisms & Ecology', pct: 85),
          SubjectUnitProgress(name: 'Unit 2: Enzymes & Metabolism', pct: 71, isWeakest: true),
          SubjectUnitProgress(name: 'Unit 3: Cellular Respiration', pct: 81),
          SubjectUnitProgress(name: 'Unit 4: Molecular Genetics', pct: 79),
        ],
        boosterQuestions: const [
          BoosterQuestion(
            stem: 'How does a non-competitive (allosteric) inhibitor alter enzyme kinetics?',
            options: [
              'Increases Km without changing Vmax',
              'Decreases Vmax without changing Km',
              'Binds directly to the substrate molecule',
              'Increases both Km and Vmax',
            ],
            correctIndex: 1,
            explanation: 'Non-competitive inhibitors bind an allosteric site, reducing active enzyme concentration so Vmax decreases while Km stays constant.',
          ),
          BoosterQuestion(
            stem: 'Which cofactor class consists of organic non-protein molecules such as NAD⁺ and FAD?',
            options: ['Prosthetic metal ions', 'Coenzymes', 'Zymogens', 'Isozymes'],
            correctIndex: 1,
            explanation: 'Coenzymes (like NAD⁺, FAD, and CoA) are organic vitamin-derived carriers required for enzyme catalysis.',
          ),
        ],
      ),
      SubjectMastery(
        id: 'chemistry',
        name: 'Chemistry',
        mastery: 71,
        weightLabel: '100 pts',
        pacingSec: 64,
        weakestTopic: 'Galvanic Cell Potential',
        icon: HugeIcons.strokeRoundedChemistry01,
        units: [
          SubjectUnitProgress(name: 'Unit 1: Chemical Kinetics', pct: 76),
          SubjectUnitProgress(name: 'Unit 2: Acid-Base Equilibria', pct: 74),
          SubjectUnitProgress(name: 'Unit 3: Industrial Chemistry', pct: 72),
          SubjectUnitProgress(name: 'Unit 4: Electrochemistry', pct: 62, isWeakest: true),
        ],
        boosterQuestions: const [
          BoosterQuestion(
            stem: 'Given Ag⁺/Ag (E° = +0.80 V) and Fe²⁺/Fe (E° = −0.44 V), compute E°cell for a spontaneous galvanic cell.',
            options: ['+0.36 V', '−1.24 V', '+1.24 V', '−0.36 V'],
            correctIndex: 2,
            explanation: 'E°cell = E°cathode − E°anode = +0.80 V − (−0.44 V) = +1.24 V (spontaneous since E°cell > 0).',
          ),
          BoosterQuestion(
            stem: 'At which electrode does oxidation always occur in both galvanic and electrolytic cells?',
            options: ['Cathode', 'Anode', 'Salt bridge', 'Reference electrode'],
            correctIndex: 1,
            explanation: 'Oxidation (loss of electrons) always takes place at the Anode, while reduction occurs at the Cathode.',
          ),
        ],
      ),
    ];
  }
}
