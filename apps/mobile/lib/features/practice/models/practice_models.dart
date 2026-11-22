import 'package:hugeicons/hugeicons.dart';

/// Diagram types supported in EUEE practice questions
enum EueeDiagramType {
  none,
  coilFlux,
  integralArea,
  galvanicCell,
  replicationFork,
}

/// Single Question in an Official EUEE Paper or Practice Session
class EueeQuestion {
  final String id;
  final String unitTag;
  final String stem;
  final EueeDiagramType diagramType;
  final List<String> options;
  final int correctIndex;
  final String hint;
  final String formula;
  final String explanation;

  const EueeQuestion({
    required this.id,
    required this.unitTag,
    required this.stem,
    this.diagramType = EueeDiagramType.none,
    required this.options,
    required this.correctIndex,
    required this.hint,
    required this.formula,
    required this.explanation,
  });

  EueeQuestion copyWith({
    String? id,
    String? unitTag,
    String? stem,
    EueeDiagramType? diagramType,
    List<String>? options,
    int? correctIndex,
    String? hint,
    String? formula,
    String? explanation,
  }) {
    return EueeQuestion(
      id: id ?? this.id,
      unitTag: unitTag ?? this.unitTag,
      stem: stem ?? this.stem,
      diagramType: diagramType ?? this.diagramType,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      hint: hint ?? this.hint,
      formula: formula ?? this.formula,
      explanation: explanation ?? this.explanation,
    );
  }
}

/// Official EUEE Past Paper Definition
class EueePaper {
  final String id;
  final String subject; // 'physics' | 'mathematics' | 'chemistry' | 'biology'
  final String subjectName;
  final String title;
  final String shortTitle;
  final String topics;
  final int durationMins;
  final int? bestScore; // Null means "New"
  final List<EueeQuestion> questions;

  const EueePaper({
    required this.id,
    required this.subject,
    required this.subjectName,
    required this.title,
    required this.shortTitle,
    required this.topics,
    required this.durationMins,
    this.bestScore,
    required this.questions,
  });

  EueePaper copyWith({
    String? id,
    String? subject,
    String? subjectName,
    String? title,
    String? shortTitle,
    String? topics,
    int? durationMins,
    int? bestScore,
    List<EueeQuestion>? questions,
  }) {
    return EueePaper(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      subjectName: subjectName ?? this.subjectName,
      title: title ?? this.title,
      shortTitle: shortTitle ?? this.shortTitle,
      topics: topics ?? this.topics,
      durationMins: durationMins ?? this.durationMins,
      bestScore: bestScore ?? this.bestScore,
      questions: questions ?? this.questions,
    );
  }
}

/// Completed Practice Session Record
class CompletedSession {
  final String id;
  final String paperId;
  final String title;
  final String subtitle;
  final String modeLabel; // 'Study Mode' | 'Exam Mode'
  final String elapsedStr;
  final int scorePct;
  final int correctCount;
  final int totalCount;
  final String dateLabel;
  final List<int?> userAnswers;
  final List<bool> flagged;

  const CompletedSession({
    required this.id,
    required this.paperId,
    required this.title,
    required this.subtitle,
    required this.modeLabel,
    required this.elapsedStr,
    required this.scorePct,
    required this.correctCount,
    required this.totalCount,
    required this.dateLabel,
    required this.userAnswers,
    required this.flagged,
  });

  CompletedSession copyWith({
    String? id,
    String? paperId,
    String? title,
    String? subtitle,
    String? modeLabel,
    String? elapsedStr,
    int? scorePct,
    int? correctCount,
    int? totalCount,
    String? dateLabel,
    List<int?>? userAnswers,
    List<bool>? flagged,
  }) {
    return CompletedSession(
      id: id ?? this.id,
      paperId: paperId ?? this.paperId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      modeLabel: modeLabel ?? this.modeLabel,
      elapsedStr: elapsedStr ?? this.elapsedStr,
      scorePct: scorePct ?? this.scorePct,
      correctCount: correctCount ?? this.correctCount,
      totalCount: totalCount ?? this.totalCount,
      dateLabel: dateLabel ?? this.dateLabel,
      userAnswers: userAnswers ?? this.userAnswers,
      flagged: flagged ?? this.flagged,
    );
  }
}

/// Subject metadata for the Practice filter rail
class PracticeSubjectMeta {
  final String id;
  final String name;
  final List<List<dynamic>>? iconData;

  const PracticeSubjectMeta({
    required this.id,
    required this.name,
    this.iconData,
  });
}

final List<PracticeSubjectMeta> practiceSubjects = [
  const PracticeSubjectMeta(id: 'all', name: 'All'),
  const PracticeSubjectMeta(
    id: 'physics',
    name: 'Physics',
    iconData: HugeIcons.strokeRoundedAtom01,
  ),
  const PracticeSubjectMeta(
    id: 'mathematics',
    name: 'Mathematics',
    iconData: HugeIcons.strokeRoundedCalculator01,
  ),
  const PracticeSubjectMeta(
    id: 'chemistry',
    name: 'Chemistry',
    iconData: HugeIcons.strokeRoundedChemistry01,
  ),
  const PracticeSubjectMeta(
    id: 'biology',
    name: 'Biology',
    iconData: HugeIcons.strokeRoundedDna,
  ),
];

/// Authentic Grade 12 EUEE Papers matching the prototype
final List<EueePaper> defaultEueePapers = [
  const EueePaper(
    id: 'phy-2017',
    subject: 'physics',
    subjectName: 'Physics',
    title: 'Physics — EUEE 2017 E.C. (2025)',
    shortTitle: 'EUEE 2017 E.C. • Physics',
    topics: 'Electromagnetism & Mechanics',
    durationMins: 8,
    bestScore: 80,
    questions: [
      EueeQuestion(
        id: 'p17-q1',
        unitTag: 'EUEE 2017 E.C. • Unit 4: Electromagnetism',
        stem:
            'A 50-turn circular coil experiences a uniform magnetic flux decrease from 0.08 Wb to 0.02 Wb in 0.15 s. What is the magnitude of the induced EMF?',
        diagramType: EueeDiagramType.coilFlux,
        options: ['10 V', '20 V', '30 V', '40 V'],
        correctIndex: 1,
        hint:
            'Use Faraday’s Law: |ε| = N · |ΔΦB / Δt|, where ΔΦB = 0.02 − 0.08 = −0.06 Wb.',
        formula: '|ε| = N · |ΔΦB / Δt|',
        explanation:
            'By Faraday’s Law of Electromagnetic Induction, |ε| = 50 × (|0.02 − 0.08| / 0.15) = 50 × (0.06 / 0.15) = 50 × 0.4 = 20 V.',
      ),
      EueeQuestion(
        id: 'p17-q2',
        unitTag: 'EUEE 2017 E.C. • Unit 2: Two-Dimensional Motion',
        stem:
            'A projectile is launched from level ground at 30° above the horizontal with speed 40 m/s. What is its horizontal speed at the highest point of its trajectory? (g = 10 m/s²)',
        options: ['0 m/s', '20 m/s', '20√3 m/s', '40 m/s'],
        correctIndex: 2,
        hint:
            'Horizontal acceleration ax = 0 in ideal projectile motion, so vx = v₀ cos(30°) throughout flight.',
        formula: 'vx = v₀ · cosθ',
        explanation:
            'At peak height, vertical velocity vy = 0, while horizontal velocity remains constant: vx = 40 · cos(30°) = 40 × (√3 / 2) = 20√3 m/s.',
      ),
      EueeQuestion(
        id: 'p17-q3',
        unitTag: 'EUEE 2017 E.C. • Unit 3: Fluid Mechanics',
        stem:
            'Water flows steadily at 2.0 m/s through a horizontal pipe of cross-sectional area 6.0 cm². If the pipe narrows to 2.0 cm², what is the speed in the narrow section?',
        options: ['0.67 m/s', '4.0 m/s', '6.0 m/s', '12.0 m/s'],
        correctIndex: 2,
        hint:
            'Volume flow rate is conserved for incompressible fluids: A₁v₁ = A₂v₂.',
        formula: 'A₁ · v₁ = A₂ · v₂',
        explanation:
            'From the Equation of Continuity, v₂ = (A₁ / A₂) · v₁ = (6.0 cm² / 2.0 cm²) × 2.0 m/s = 3 × 2.0 = 6.0 m/s.',
      ),
      EueeQuestion(
        id: 'p17-q4',
        unitTag: 'EUEE 2017 E.C. • Unit 4: Electromagnetism',
        stem:
            'An ideal step-up transformer has 200 turns on its primary coil and 1,000 turns on its secondary coil. When connected to 120 V AC, what is the secondary voltage?',
        options: ['24 V', '240 V', '600 V', '1,200 V'],
        correctIndex: 2,
        hint:
            'Voltage ratio equals turns ratio in an ideal transformer: Vs / Vp = Ns / Np.',
        formula: 'Vs / Vp = Ns / Np',
        explanation:
            'Vs = Vp × (Ns / Np) = 120 V × (1000 / 200) = 120 × 5 = 600 V.',
      ),
      EueeQuestion(
        id: 'p17-q5',
        unitTag: 'EUEE 2017 E.C. • Unit 5: Basics of Electronics',
        stem:
            'In an NPN bipolar junction transistor with current gain β = 100 and base current IB = 0.2 mA, what is the emitter current IE?',
        options: ['2.0 mA', '19.8 mA', '20.0 mA', '20.2 mA'],
        correctIndex: 3,
        hint:
            'First compute collector current IC = β · IB, then add base current: IE = IB + IC.',
        formula: 'IC = β · IB,   IE = IB + IC',
        explanation:
            'IC = 100 × 0.2 mA = 20.0 mA. By Kirchhoff’s Current Law, emitter current IE = IB + IC = 0.2 mA + 20.0 mA = 20.2 mA.',
      ),
    ],
  ),
  const EueePaper(
    id: 'math-2017',
    subject: 'mathematics',
    subjectName: 'Mathematics',
    title: 'Mathematics — EUEE 2017 E.C. (2025)',
    shortTitle: 'EUEE 2017 E.C. • Mathematics',
    topics: 'Calculus & Vectors',
    durationMins: 8,
    bestScore: 100,
    questions: [
      EueeQuestion(
        id: 'm17-q1',
        unitTag: 'EUEE 2017 E.C. • Unit 4: Integral Calculus',
        stem:
            'Evaluate the definite integral ∫₀² (3x² + 2x) dx representing the area under the curve from x = 0 to x = 2.',
        diagramType: EueeDiagramType.integralArea,
        options: ['8', '10', '12', '16'],
        correctIndex: 2,
        hint:
            'Find the antiderivative F(x) = x³ + x², then compute F(2) − F(0).',
        formula: '∫ₐᵇ f(x) dx = F(b) − F(a)',
        explanation:
            'An antiderivative of 3x² + 2x is F(x) = x³ + x². Evaluating at limits: F(2) − F(0) = (2³ + 2²) − 0 = 8 + 4 = 12.',
      ),
      EueeQuestion(
        id: 'm17-q2',
        unitTag: 'EUEE 2017 E.C. • Unit 3: Differential Calculus',
        stem: 'If f(x) = ln(3x² + 1), what is the derivative f′(1)?',
        options: ['3/2', '3/4', '1/4', '6'],
        correctIndex: 0,
        hint:
            'Apply the chain rule: d/dx[ln(u)] = u′ / u with u = 3x² + 1.',
        formula: 'd/dx [ln(g(x))] = g′(x) / g(x)',
        explanation:
            'f′(x) = 6x / (3x² + 1). Substituting x = 1 yields f′(1) = 6(1) / (3(1)² + 1) = 6 / 4 = 3/2.',
      ),
      EueeQuestion(
        id: 'm17-q3',
        unitTag: 'EUEE 2017 E.C. • Unit 1: Sequences & Series',
        stem:
            'What is the sum of the infinite geometric series 12 + 4 + 4/3 + 4/9 + ...?',
        options: ['16', '18', '20', '24'],
        correctIndex: 1,
        hint:
            'Find the common ratio r = a₂ / a₁ and apply S∞ = a₁ / (1 − r).',
        formula: 'S∞ = a₁ / (1 − r),   |r| < 1',
        explanation:
            'Here a₁ = 12 and r = 4 / 12 = 1/3. Since |r| < 1, S∞ = 12 / (1 − 1/3) = 12 / (2/3) = 18.',
      ),
      EueeQuestion(
        id: 'm17-q4',
        unitTag: 'EUEE 2017 E.C. • Unit 2: Vectors in Space',
        stem:
            'For what value of k are the vectors u = (2, k, −3) and v = (4, −2, 2) orthogonal (perpendicular)?',
        options: ['k = 1', 'k = 2', 'k = −1', 'k = 4'],
        correctIndex: 0,
        hint:
            'Two non-zero vectors are orthogonal if and only if their dot product u · v = 0.',
        formula: 'u · v = u₁v₁ + u₂v₂ + u₃v₃ = 0',
        explanation:
            'Setting u · v = 0 gives (2)(4) + (k)(−2) + (−3)(2) = 0 ⇒ 8 − 2k − 6 = 0 ⇒ 2 − 2k = 0 ⇒ k = 1.',
      ),
      EueeQuestion(
        id: 'm17-q5',
        unitTag: 'EUEE 2017 E.C. • Unit 4: Integral Calculus',
        stem: 'Evaluate the indefinite integral ∫ 6x · (x² + 1)² dx.',
        options: [
          '(x² + 1)³ + C',
          '2(x² + 1)³ + C',
          '3(x² + 1)³ + C',
          '(x² + 1)³/3 + C'
        ],
        correctIndex: 0,
        hint:
            'Let u = x² + 1 so that du = 2x dx, rewriting 6x dx as 3 du.',
        formula: '∫ uⁿ du = uⁿ⁺¹ / (n + 1) + C',
        explanation:
            'Let u = x² + 1, du = 2x dx. Then ∫ 3u² du = 3 · (u³ / 3) + C = u³ + C = (x² + 1)³ + C.',
      ),
    ],
  ),
  const EueePaper(
    id: 'chem-2016',
    subject: 'chemistry',
    subjectName: 'Chemistry',
    title: 'Chemistry — EUEE 2016 E.C. (2024)',
    shortTitle: 'EUEE 2016 E.C. • Chemistry',
    topics: 'Electrochemistry & Equilibria',
    durationMins: 8,
    bestScore: 60,
    questions: [
      EueeQuestion(
        id: 'c16-q1',
        unitTag: 'EUEE 2016 E.C. • Unit 4: Electrochemistry',
        stem:
            'Given standard reduction potentials Zn²⁺/Zn (E° = −0.76 V) and Cu²⁺/Cu (E° = +0.34 V), what is E°cell for a spontaneous Zn–Cu galvanic cell?',
        diagramType: EueeDiagramType.galvanicCell,
        options: ['+0.42 V', '−1.10 V', '+1.10 V', '−0.42 V'],
        correctIndex: 2,
        hint:
            'In a spontaneous galvanic cell, the more positive reduction potential is the cathode.',
        formula: 'E°cell = E°cathode − E°anode',
        explanation:
            'Cu²⁺/Cu (+0.34 V) acts as cathode and Zn²⁺/Zn (−0.76 V) acts as anode: E°cell = +0.34 V − (−0.76 V) = +1.10 V.',
      ),
      EueeQuestion(
        id: 'c16-q2',
        unitTag: 'EUEE 2016 E.C. • Unit 2: Acid-Base Equilibria',
        stem:
            'An acetate buffer contains equal molar concentrations of CH₃COOH (pKa = 4.74) and CH₃COONa. What is the pH of this buffer?',
        options: ['2.37', '4.74', '7.00', '9.26'],
        correctIndex: 1,
        hint:
            'Use the Henderson-Hasselbalch equation when [A⁻] = [HA].',
        formula: 'pH = pKa + log([A⁻] / [HA])',
        explanation:
            'When [CH₃COO⁻] = [CH₃COOH], [A⁻]/[HA] = 1 and log(1) = 0, so pH = pKa = 4.74.',
      ),
      EueeQuestion(
        id: 'c16-q3',
        unitTag: 'EUEE 2016 E.C. • Unit 4: Electrolysis',
        stem:
            'How many Faradays of electricity are required to reduce 1.0 mole of Al³⁺ ions to solid aluminum metal at the cathode?',
        options: ['1.0 F', '2.0 F', '3.0 F', '96,500 F'],
        correctIndex: 2,
        hint: 'Write the half-reaction: Al³⁺ + 3e⁻ → Al(s).',
        formula: 'Q = n · F   (1 mol e⁻ = 1 Faraday)',
        explanation:
            'Reducing 1 mole of Al³⁺ requires 3 moles of electrons (Al³⁺ + 3e⁻ → Al), which equals 3.0 Faradays.',
      ),
      EueeQuestion(
        id: 'c16-q4',
        unitTag: 'EUEE 2016 E.C. • Unit 1: Chemical Kinetics',
        stem:
            'For a first-order reaction with rate constant k = 0.0693 min⁻¹, what is the half-life (t₁/₂) of the reactant?',
        options: ['5.0 min', '10.0 min', '14.4 min', '20.0 min'],
        correctIndex: 1,
        hint:
            'For a first-order reaction, half-life is independent of initial concentration: t₁/₂ = 0.693 / k.',
        formula: 't₁/₂ = ln(2) / k ≈ 0.693 / k',
        explanation: 't₁/₂ = 0.693 / 0.0693 min⁻¹ = 10.0 minutes.',
      ),
      EueeQuestion(
        id: 'c16-q5',
        unitTag: 'EUEE 2016 E.C. • Unit 3: Industrial Chemistry',
        stem:
            'In the Haber process (N₂(g) + 3H₂(g) ⇌ 2NH₃(g), ΔH = −92 kJ), which catalyst is used to accelerate ammonia synthesis?',
        options: [
          'Vanadium(V) oxide (V₂O₅)',
          'Finely divided Iron (Fe)',
          'Platinum-Rhodium gauze',
          'Nickel (Ni)'
        ],
        correctIndex: 1,
        hint:
            'V₂O₅ is used in the Contact process for H₂SO₄; Haber process uses an iron-based catalyst.',
        formula: 'N₂ + 3H₂ ⇌ 2NH₃   (Fe catalyst)',
        explanation:
            'Finely divided Iron (Fe) promoted with K₂O and Al₂O₃ lowers activation energy in the Haber-Bosch ammonia process.',
      ),
    ],
  ),
  const EueePaper(
    id: 'bio-2016',
    subject: 'biology',
    subjectName: 'Biology',
    title: 'Biology — EUEE 2016 E.C. (2024)',
    shortTitle: 'EUEE 2016 E.C. • Biology',
    topics: 'Molecular Genetics & Enzymes',
    durationMins: 8,
    bestScore: null, // "New" badge
    questions: [
      EueeQuestion(
        id: 'b16-q1',
        unitTag: 'EUEE 2016 E.C. • Unit 4: Molecular Genetics',
        stem:
            'Which enzyme relieves supercoiling and torsional strain ahead of the replication fork during semi-conservative DNA replication?',
        diagramType: EueeDiagramType.replicationFork,
        options: [
          'DNA Helicase',
          'DNA Topoisomerase (Gyrase)',
          'RNA Primase',
          'DNA Ligase'
        ],
        correctIndex: 1,
        hint:
            'Helicase unwinds the double helix; another enzyme prevents overwinding ahead of it.',
        formula: 'Topoisomerase → relieves supercoiling ahead of fork',
        explanation:
            'DNA Topoisomerase (DNA gyrase) transiently cleaves and rejoins DNA strands ahead of helicase to relieve torsional supercoiling.',
      ),
      EueeQuestion(
        id: 'b16-q2',
        unitTag: 'EUEE 2016 E.C. • Unit 4: Molecular Genetics',
        stem:
            'According to Chargaff’s base-pairing rules, if a double-stranded DNA molecule contains 22% Adenine (A), what percentage is Guanine (G)?',
        options: ['22%', '28%', '44%', '56%'],
        correctIndex: 1,
        hint:
            'In double-stranded DNA, %A = %T and %A + %T + %G + %C = 100%.',
        formula: '%A = %T   and   %G = %C',
        explanation:
            'Since %A = 22%, %T = 22% (44% combined). The remaining 56% is split equally between G and C: %G = 56% / 2 = 28%.',
      ),
      EueeQuestion(
        id: 'b16-q3',
        unitTag: 'EUEE 2016 E.C. • Unit 3: Cellular Respiration',
        stem:
            'Which molecule serves as the final electron acceptor at the end of the mitochondrial electron transport chain?',
        options: [
          'NAD⁺',
          'Pyruvate',
          'Oxygen (O₂)',
          'Carbon dioxide (CO₂)'
        ],
        correctIndex: 2,
        hint:
            'Without this molecule, oxidative phosphorylation halts and cells switch to fermentation.',
        formula: '½O₂ + 2H⁺ + 2e⁻ → H₂O',
        explanation:
            'Molecular oxygen (O₂) accepts low-energy electrons at Complex IV and combines with H⁺ ions to form water.',
      ),
      EueeQuestion(
        id: 'b16-q4',
        unitTag: 'EUEE 2016 E.C. • Unit 2: Enzymes',
        stem:
            'How does a competitive inhibitor affect enzyme kinetics when substrate concentration is gradually increased?',
        options: [
          'It lowers Vmax permanently',
          'It binds to the active site and can be overcome by high substrate concentration',
          'It binds only to an allosteric site',
          'It denatures the enzyme tertiary structure'
        ],
        correctIndex: 1,
        hint:
            'Competitive inhibitors resemble the substrate and compete directly for the active site.',
        formula: 'Km increases (apparent),   Vmax unchanged',
        explanation:
            'A competitive inhibitor reversibly binds the active site; flooding the system with excess substrate outcompetes the inhibitor, restoring Vmax.',
      ),
      EueeQuestion(
        id: 'b16-q5',
        unitTag: 'EUEE 2016 E.C. • Unit 4: Protein Synthesis',
        stem:
            'Which mRNA codon functions as the universal start codon and specifies Methionine during translation?',
        options: ['UAA', 'UAG', 'AUG', 'UGA'],
        correctIndex: 2,
        hint: 'UAA, UAG, and UGA are stop codons.',
        formula: 'AUG → Start Codon (Methionine)',
        explanation:
            'AUG initiates ribosomal translation and codes for Methionine, whereas UAA, UAG, and UGA signal termination.',
      ),
    ],
  ),
  const EueePaper(
    id: 'phy-2015',
    subject: 'physics',
    subjectName: 'Physics',
    title: 'Physics — EUEE 2015 E.C. (2023)',
    shortTitle: 'EUEE 2015 E.C. • Physics',
    topics: 'Wave Optics & Thermodynamics',
    durationMins: 8,
    bestScore: 80,
    questions: [
      EueeQuestion(
        id: 'p15-q1',
        unitTag: 'EUEE 2015 E.C. • Unit 6: Wave Optics',
        stem:
            'In Young’s double-slit experiment, if the distance between the two slits is halved while wavelength and screen distance remain constant, the fringe spacing:',
        options: [
          'Is halved',
          'Doubles',
          'Quadruples',
          'Remains unchanged'
        ],
        correctIndex: 1,
        hint:
            'Fringe width Δy = (λ · L) / d is inversely proportional to slit separation d.',
        formula: 'Δy = (λ · L) / d',
        explanation:
            'Because Δy is inversely proportional to slit separation d, halving d (d → d/2) doubles the fringe spacing Δy.',
      ),
      EueeQuestion(
        id: 'p15-q2',
        unitTag: 'EUEE 2015 E.C. • Unit 7: Thermodynamics',
        stem:
            'An ideal Carnot heat engine operates between a hot reservoir at 600 K and a cold sink at 300 K. What is its maximum theoretical efficiency?',
        options: ['25%', '50%', '67%', '75%'],
        correctIndex: 1,
        hint:
            'Carnot efficiency η = 1 − (Tc / Th) with temperatures in Kelvin.',
        formula: 'η = 1 − (Tc / Th)',
        explanation:
            'η = 1 − (300 K / 600 K) = 1 − 0.50 = 0.50, or 50%.',
      ),
      EueeQuestion(
        id: 'p15-q3',
        unitTag: 'EUEE 2015 E.C. • Unit 7: Thermodynamics',
        stem:
            'During an adiabatic expansion of an ideal gas (Q = 0), what happens to the internal energy and temperature of the gas?',
        options: [
          'Both internal energy and temperature decrease',
          'Internal energy increases while temperature stays constant',
          'Both remain constant',
          'Temperature increases as the gas does work'
        ],
        correctIndex: 0,
        hint:
            'Apply the First Law of Thermodynamics: ΔU = Q − W with Q = 0 and W > 0.',
        formula: 'ΔU = Q − W   (Q = 0 ⇒ ΔU = −W)',
        explanation:
            'When an ideal gas expands adiabatically (Q = 0), it does positive work on its surroundings (W > 0), so ΔU = −W < 0 and temperature drops.',
      ),
      EueeQuestion(
        id: 'p15-q4',
        unitTag: 'EUEE 2015 E.C. • Unit 6: Wave Optics',
        stem:
            'Light travels from crown glass (n₁ = 1.50) into air (n₂ = 1.00). What is the sine of the critical angle θc for total internal reflection?',
        options: ['0.50', '0.67', '0.75', '1.50'],
        correctIndex: 1,
        hint: 'At the critical angle, sin(θc) = n₂ / n₁.',
        formula: 'sin(θc) = n₂ / n₁',
        explanation: 'sin(θc) = 1.00 / 1.50 = 2/3 ≈ 0.67.',
      ),
      EueeQuestion(
        id: 'p15-q5',
        unitTag: 'EUEE 2015 E.C. • Unit 1: Biophysics & Waves',
        stem:
            'Which phenomenon demonstrates that light waves are transverse rather than longitudinal?',
        options: [
          'Interference',
          'Diffraction',
          'Polarization',
          'Refraction'
        ],
        correctIndex: 2,
        hint:
            'Longitudinal waves like sound in air cannot undergo this phenomenon.',
        formula: 'Malus’s Law: I = I₀ · cos²θ',
        explanation:
            'Only transverse waves oscillate perpendicular to propagation direction and can therefore be polarized.',
      ),
    ],
  ),
];

/// Initial completed sessions matching prototype
final List<CompletedSession> defaultCompletedSessions = [
  const CompletedSession(
    id: 'comp-1',
    paperId: 'phy-2017',
    title: 'Physics — EUEE 2017 E.C.',
    subtitle: 'Electromagnetism & Mechanics',
    modeLabel: 'Exam Mode',
    elapsedStr: '04:12',
    scorePct: 80,
    correctCount: 4,
    totalCount: 5,
    dateLabel: 'Today, 08:15 AM',
    userAnswers: [1, 2, 0, 2, 3], // Q3 answered wrong (0 instead of 2)
    flagged: [false, false, true, false, false],
  ),
  const CompletedSession(
    id: 'comp-2',
    paperId: 'math-2017',
    title: 'Mathematics — EUEE 2017 E.C.',
    subtitle: 'Calculus & Vectors',
    modeLabel: 'Study Mode',
    elapsedStr: '05:40',
    scorePct: 100,
    correctCount: 5,
    totalCount: 5,
    dateLabel: 'Yesterday',
    userAnswers: [2, 0, 1, 0, 0],
    flagged: [false, true, false, false, false],
  ),
];
