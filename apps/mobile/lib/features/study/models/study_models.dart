import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';

/// Single Concept Check in a Topic Note
class ConceptCheck {
  final String q;
  final List<String> options;
  final int correctIdx;
  final String feedback;

  const ConceptCheck({
    required this.q,
    required this.options,
    required this.correctIdx,
    required this.feedback,
  });
}

/// Single Key Formula with variable definitions
class FormulaItem {
  final String name;
  final String expr;
  final String vars;

  const FormulaItem({
    required this.name,
    required this.expr,
    required this.vars,
  });
}

/// Topic Notes Content
class TopicNotes {
  final List<String> summary;
  final List<FormulaItem> formulas;
  final List<String> tips;
  final ConceptCheck conceptCheck;

  const TopicNotes({
    required this.summary,
    required this.formulas,
    required this.tips,
    required this.conceptCheck,
  });
}

/// Drill Question item for a Topic
class DrillQuestionItem {
  final String topicCode;
  final String difficulty; // 'Standard' | 'EUEE Hard'
  final String q;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String? topicTitle;

  const DrillQuestionItem({
    required this.topicCode,
    required this.difficulty,
    required this.q,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.topicTitle,
  });

  DrillQuestionItem copyWith({
    String? topicCode,
    String? difficulty,
    String? q,
    List<String>? options,
    int? correctIndex,
    String? explanation,
    String? topicTitle,
  }) {
    return DrillQuestionItem(
      topicCode: topicCode ?? this.topicCode,
      difficulty: difficulty ?? this.difficulty,
      q: q ?? this.q,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      explanation: explanation ?? this.explanation,
      topicTitle: topicTitle ?? this.topicTitle,
    );
  }
}

/// Study Sub-Topic
class StudyTopic {
  final String id;
  final String code; // e.g., '1.1', '4.2'
  final String title;
  final String duration;
  final int questionCount;
  final bool completed;
  final bool bookmarked;
  final TopicNotes notes;
  final DrillQuestionItem drillQuestion;

  const StudyTopic({
    required this.id,
    required this.code,
    required this.title,
    required this.duration,
    required this.questionCount,
    required this.completed,
    required this.bookmarked,
    required this.notes,
    required this.drillQuestion,
  });

  StudyTopic copyWith({
    String? id,
    String? code,
    String? title,
    String? duration,
    int? questionCount,
    bool? completed,
    bool? bookmarked,
    TopicNotes? notes,
    DrillQuestionItem? drillQuestion,
  }) {
    return StudyTopic(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      questionCount: questionCount ?? this.questionCount,
      completed: completed ?? this.completed,
      bookmarked: bookmarked ?? this.bookmarked,
      notes: notes ?? this.notes,
      drillQuestion: drillQuestion ?? this.drillQuestion,
    );
  }
}

/// Syllabus Unit
class StudyUnit {
  final String id;
  final String code; // e.g., 'U1', 'U4'
  final String title;
  final String examWeight; // e.g., '28% EUEE'
  final bool expanded;
  final List<StudyTopic> topics;
  final String? unitCode; // e.g., 'PHY-G12-U01', 'ENG-G12-U01'
  final bool isCompleted;
  final int? assessmentScore; // e.g., 14 (out of 15)

  const StudyUnit({
    required this.id,
    required this.code,
    required this.title,
    required this.examWeight,
    required this.expanded,
    required this.topics,
    this.unitCode,
    this.isCompleted = false,
    this.assessmentScore,
  });

  StudyUnit copyWith({
    String? id,
    String? code,
    String? title,
    String? examWeight,
    bool? expanded,
    List<StudyTopic>? topics,
    String? unitCode,
    bool? isCompleted,
    int? assessmentScore,
  }) {
    return StudyUnit(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      examWeight: examWeight ?? this.examWeight,
      expanded: expanded ?? this.expanded,
      topics: topics ?? this.topics,
      unitCode: unitCode ?? this.unitCode,
      isCompleted: isCompleted ?? this.isCompleted,
      assessmentScore: assessmentScore ?? this.assessmentScore,
    );
  }

  String resolvedUnitCode(String subjectCode) {
    if (unitCode != null && unitCode!.isNotEmpty) return unitCode!;
    final numDigits = code.replaceAll(RegExp(r'[^0-9]'), '');
    final numStr = numDigits.isEmpty ? '01' : numDigits.padLeft(2, '0');
    return '${subjectCode.toUpperCase()}-G12-U$numStr';
  }
}

/// Subject Curriculum
class SubjectCurriculum {
  final String id;
  final String name;
  final int mastery;
  final String lastTopicId;
  final List<List<dynamic>> iconData;
  final Color color;
  final List<StudyUnit> units;

  const SubjectCurriculum({
    required this.id,
    required this.name,
    required this.mastery,
    required this.lastTopicId,
    required this.iconData,
    required this.color,
    required this.units,
  });

  String get subjectCode {
    switch (id.toLowerCase()) {
      case 'physics':
        return 'PHY';
      case 'mathematics':
      case 'math':
        return 'MAT';
      case 'chemistry':
      case 'chem':
        return 'CHE';
      case 'biology':
      case 'bio':
        return 'BIO';
      case 'english':
      case 'eng':
        return 'ENG';
      case 'economics':
      case 'eco':
        return 'ECO';
      case 'geography':
      case 'geo':
        return 'GEO';
      case 'history':
      case 'his':
        return 'HIS';
      default:
        return id.length >= 3 ? id.substring(0, 3).toUpperCase() : id.toUpperCase();
    }
  }

  SubjectCurriculum copyWith({
    String? id,
    String? name,
    int? mastery,
    String? lastTopicId,
    List<List<dynamic>>? iconData,
    Color? color,
    List<StudyUnit>? units,
  }) {
    return SubjectCurriculum(
      id: id ?? this.id,
      name: name ?? this.name,
      mastery: mastery ?? this.mastery,
      lastTopicId: lastTopicId ?? this.lastTopicId,
      iconData: iconData ?? this.iconData,
      color: color ?? this.color,
      units: units ?? this.units,
    );
  }
}

/// Initial Grade 12 National Curriculum Database matching prototype
final Map<String, SubjectCurriculum> defaultCurriculumData = {
  'physics': const SubjectCurriculum(
    id: 'physics',
    name: 'Physics',
    mastery: 82,
    lastTopicId: 'phy-4-2',
    iconData: HugeIcons.strokeRoundedAtom01,
    color: AppColors.royalPurple,
    units: [
      StudyUnit(
        id: 'phy-u1',
        code: 'U1',
        title: 'Application of Physics in Other Fields',
        examWeight: '12% EUEE',
        expanded: false,
        topics: [
          StudyTopic(
            id: 'phy-1-1',
            code: '1.1',
            title: 'Medical Imaging & Biophysics',
            duration: '5 min',
            questionCount: 12,
            completed: true,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'Ultrasound Imaging uses high-frequency longitudinal sound waves (>20 kHz) reflected at tissue boundaries of differing acoustic impedance.',
                'X-Ray & CT Scans rely on differential attenuation of high-energy photons by dense bone versus soft tissue.',
                'MRI (Magnetic Resonance Imaging) aligns hydrogen proton spins in a strong external magnetic field using RF pulses without ionizing radiation.',
              ],
              formulas: [
                FormulaItem(
                  name: 'Acoustic Impedance',
                  expr: 'Z = ρ · v',
                  vars:
                      'ρ = tissue density (kg/m³), v = speed of sound in tissue (m/s)',
                ),
                FormulaItem(
                  name: 'Intensity Reflection Coefficient',
                  expr: 'R = [(Z₂ − Z₁) / (Z₂ + Z₁)]²',
                  vars:
                      'Fraction of ultrasound intensity reflected at boundary',
                ),
              ],
              tips: [
                'EUEE frequently contrasts ionizing (X-ray, CT, Gamma) vs. non-ionizing (Ultrasound, MRI) diagnostic modalities.',
                'Remember that coupling gel eliminates air pockets so Z₂ ≈ Z₁, minimizing reflection at the skin.',
              ],
              conceptCheck: ConceptCheck(
                q: 'Which medical imaging technique uses non-ionizing radio waves and strong magnetic fields?',
                options: [
                  'Computed Tomography (CT)',
                  'Magnetic Resonance Imaging (MRI)',
                ],
                correctIdx: 1,
                feedback:
                    'Correct! MRI uses magnetic fields and radiofrequency pulses—zero ionizing radiation.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '1.1',
              difficulty: 'Standard',
              q: 'Why is acoustic coupling gel applied between an ultrasound transducer and the patient’s skin?',
              options: [
                'To cool the piezoelectric crystal',
                'To reduce acoustic impedance mismatch and prevent reflection by air',
                'To convert transverse waves into longitudinal waves',
                'To increase the frequency of the emitted ultrasound',
              ],
              correctIndex: 1,
              explanation:
                  'Air has a very low acoustic impedance compared to skin, causing nearly 99.9% reflection unless displaced by gel.',
            ),
          ),
          StudyTopic(
            id: 'phy-1-2',
            code: '1.2',
            title: 'Defense & Communication Systems',
            duration: '4 min',
            questionCount: 10,
            completed: false,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'RADAR determines target range by measuring the round-trip time Δt of microwave pulses traveling at c = 3.0 × 10⁸ m/s.',
                'Optical Fibers guide light pulses across long distances via Total Internal Reflection (TIR) when incidence angle exceeds the critical angle θc.',
              ],
              formulas: [
                FormulaItem(
                  name: 'RADAR Target Range',
                  expr: 'd = (c · Δt) / 2',
                  vars:
                      'Divide by 2 because the microwave pulse travels to the target and back',
                ),
                FormulaItem(
                  name: 'Critical Angle for TIR',
                  expr: 'sin(θc) = n₂ / n₁',
                  vars: 'Requires denser core n₁ > cladding n₂',
                ),
              ],
              tips: [
                'Always divide round-trip RADAR or SONAR echo time by 2 when solving for one-way distance!',
              ],
              conceptCheck: ConceptCheck(
                q: 'Total internal reflection inside an optical fiber requires the core refractive index n₁ to be:',
                options: [
                  'Greater than the cladding index n₂',
                  'Less than the cladding index n₂',
                ],
                correctIdx: 0,
                feedback:
                    'Spot on! Light must travel from optically denser core (n₁) toward rarer cladding (n₂).',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '1.2',
              difficulty: 'Standard',
              q: 'A radar pulse returns 4.0 × 10⁻⁴ s after transmission. How far away is the aircraft? (c = 3.0 × 10⁸ m/s)',
              options: ['30 km', '60 km', '120 km', '15 km'],
              correctIndex: 1,
              explanation:
                  'd = (c · Δt) / 2 = (3.0 × 10⁸ × 4.0 × 10⁻⁴) / 2 = 60,000 m = 60 km.',
            ),
          ),
        ],
      ),
      StudyUnit(
        id: 'phy-u2',
        code: 'U2',
        title: 'Two-Dimensional Motion',
        examWeight: '18% EUEE',
        expanded: false,
        topics: [
          StudyTopic(
            id: 'phy-2-1',
            code: '2.1',
            title: 'Projectile Motion & Range Symmetry',
            duration: '6 min',
            questionCount: 16,
            completed: true,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'In ideal projectile motion, horizontal velocity vx = v₀ cosθ remains constant (ax = 0), while vertical motion experiences constant downward acceleration ay = −g.',
                'Complementary launch angles (e.g., 30° and 60°) produce identical horizontal ranges on level ground, with maximum range at 45°.',
              ],
              formulas: [
                FormulaItem(
                  name: 'Horizontal Range',
                  expr: 'R = (v₀² · sin 2θ) / g',
                  vars: 'Valid when launch and landing elevations are equal',
                ),
                FormulaItem(
                  name: 'Maximum Height',
                  expr: 'H = (v₀² · sin²θ) / (2g)',
                  vars: 'Vertical velocity vy = 0 at peak height H',
                ),
              ],
              tips: [
                'At the highest point of a projectile trajectory, speed is NOT zero—it equals v₀ cosθ, and acceleration is still g downward.',
              ],
              conceptCheck: ConceptCheck(
                q: 'At the peak of a projectile’s path launched at angle θ, what is its acceleration?',
                options: ['0 m/s²', '9.8 m/s² downward'],
                correctIdx: 1,
                feedback:
                    'Correct! Gravity acts continuously downward throughout the entire flight.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '2.1',
              difficulty: 'Standard',
              q: 'Two projectiles are launched with the same speed on level ground at 25° and 65°. How do their horizontal ranges compare?',
              options: [
                'The 65° projectile travels farther',
                'The 25° projectile travels farther',
                'Both have the exact same horizontal range',
                'Range depends on projectile mass',
              ],
              correctIndex: 2,
              explanation:
                  '25° + 65° = 90° (complementary angles), and sin(50°) = sin(130°), yielding identical ranges.',
            ),
          ),
          StudyTopic(
            id: 'phy-2-2',
            code: '2.2',
            title: 'Uniform Circular & Rotational Motion',
            duration: '7 min',
            questionCount: 15,
            completed: true,
            bookmarked: true,
            notes: TopicNotes(
              summary: [
                'An object moving in a circle of radius r at constant speed v experiences centripetal acceleration ac = v²/r directed toward the center.',
                'Rotational kinematic equations mirror linear kinematics by replacing (x, v, a) with angular quantities (θ, ω, α).',
              ],
              formulas: [
                FormulaItem(
                  name: 'Centripetal Force',
                  expr: 'Fc = (m · v²) / r = m · ω² · r',
                  vars:
                      'Net inward radial force keeping object on circular path',
                ),
                FormulaItem(
                  name: 'Torque & Moment of Inertia',
                  expr: 'τ = I · α',
                  vars: 'Rotational analog of Newton’s Second Law F = ma',
                ),
              ],
              tips: [
                'Centripetal force is never a separate fundamental force—it is supplied by tension, gravity, friction, or normal force.',
              ],
              conceptCheck: ConceptCheck(
                q: 'If the speed of a car rounding a flat curve doubles, the required centripetal force:',
                options: ['Doubles (2×)', 'Quadruples (4×)'],
                correctIdx: 1,
                feedback:
                    'Correct! Because Fc = mv²/r, doubling v increases Fc by 2² = 4 times.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '2.2',
              difficulty: 'EUEE Hard',
              q: 'A 0.5 kg stone is whirled in a horizontal circle of radius 0.8 m at 4 m/s. What is the tension in the string?',
              options: ['5 N', '10 N', '16 N', '20 N'],
              correctIndex: 1,
              explanation:
                  'T = Fc = m·v² / r = (0.5 × 4²) / 0.8 = 8 / 0.8 = 10 N.',
            ),
          ),
        ],
      ),
      StudyUnit(
        id: 'phy-u3',
        code: 'U3',
        title: 'Fluid Mechanics',
        examWeight: '16% EUEE',
        expanded: false,
        topics: [
          StudyTopic(
            id: 'phy-3-1',
            code: '3.1',
            title: "Pascal's Principle & Archimedes' Buoyancy",
            duration: '5 min',
            questionCount: 14,
            completed: true,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'Pascal’s Principle: Pressure applied to an enclosed incompressible fluid transmits undiminished to every point in the fluid (F₁/A₁ = F₂/A₂).',
                'Archimedes’ Principle: Upward buoyant force equals the weight of fluid displaced by the submerged volume (Fb = ρfluid · Vsub · g).',
              ],
              formulas: [
                FormulaItem(
                  name: 'Hydraulic Lift Ratio',
                  expr: 'F₂ / F₁ = A₂ / A₁ = (d₂ / d₁)²',
                  vars:
                      'Force multiplies by the square of piston diameter ratio',
                ),
                FormulaItem(
                  name: 'Buoyant Force',
                  expr: 'Fb = ρf · Vsub · g',
                  vars: 'ρf = fluid density, Vsub = submerged volume',
                ),
              ],
              tips: [
                'Notice that work is conserved in a hydraulic press: F₁·d₁ = F₂·d₂, so the larger piston moves a smaller distance.',
              ],
              conceptCheck: ConceptCheck(
                q: 'A floating wooden block displaces a weight of water equal to:',
                options: [
                  'The total weight of the wooden block',
                  'Only the weight of the submerged part',
                ],
                correctIdx: 0,
                feedback:
                    'Correct! For any floating object in equilibrium, Fb = Wobject.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '3.1',
              difficulty: 'Standard',
              q: 'A hydraulic lift has piston areas A₁ = 0.02 m² and A₂ = 0.50 m². What input force F₁ lifts a 10,000 N car?',
              options: ['200 N', '400 N', '500 N', '2,500 N'],
              correctIndex: 1,
              explanation:
                  'F₁ = F₂ · (A₁ / A₂) = 10,000 × (0.02 / 0.50) = 400 N.',
            ),
          ),
          StudyTopic(
            id: 'phy-3-2',
            code: '3.2',
            title: 'Continuity & Bernoulli’s Equation',
            duration: '6 min',
            questionCount: 14,
            completed: true,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'Equation of Continuity: Volume flow rate remains constant in steady incompressible flow (A₁v₁ = A₂v₂), so fluid speeds up in narrow constrictions.',
                'Bernoulli’s Principle: Where fluid speed increases, internal static pressure decreases.',
              ],
              formulas: [
                FormulaItem(
                  name: 'Continuity Equation',
                  expr: 'A₁ · v₁ = A₂ · v₂',
                  vars: 'Volume flow rate Q = A·v (m³/s)',
                ),
                FormulaItem(
                  name: 'Bernoulli’s Equation',
                  expr: 'P + ½ρv² + ρgh = constant',
                  vars: 'Conservation of mechanical energy per unit volume',
                ),
              ],
              tips: [
                'Bernoulli’s equation applies to ideal, non-viscous, incompressible, streamline flow.',
              ],
              conceptCheck: ConceptCheck(
                q: 'When water flows from a wide pipe into a narrow nozzle, its speed and pressure:',
                options: [
                  'Speed increases, pressure decreases',
                  'Both speed and pressure increase',
                ],
                correctIdx: 0,
                feedback:
                    'Right! Continuity increases speed v, and Bernoulli’s principle lowers pressure P.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '3.2',
              difficulty: 'Standard',
              q: 'Water flows at 2 m/s through a pipe of cross-sectional area 6 cm². What is its speed when the pipe narrows to 2 cm²?',
              options: ['0.67 m/s', '4 m/s', '6 m/s', '12 m/s'],
              correctIndex: 2,
              explanation: 'A₁v₁ = A₂v₂ ⇒ v₂ = (6 × 2) / 2 = 6 m/s.',
            ),
          ),
        ],
      ),
      StudyUnit(
        id: 'phy-u4',
        code: 'U4',
        title: 'Electromagnetism',
        examWeight: '28% EUEE',
        expanded: true,
        topics: [
          StudyTopic(
            id: 'phy-4-1',
            code: '4.1',
            title: 'Magnetic Fields & Lorentz Force',
            duration: '6 min',
            questionCount: 16,
            completed: true,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'A moving charge q in a magnetic field B experiences the Lorentz magnetic force F = qvB sinθ perpendicular to both velocity v and field B.',
                'Because magnetic force is always perpendicular to velocity, it does zero work and changes only the direction of motion, not kinetic energy.',
              ],
              formulas: [
                FormulaItem(
                  name: 'Lorentz Force on Charge',
                  expr: 'F = q · v · B · sinθ',
                  vars:
                      'θ = angle between velocity vector v and magnetic field B',
                ),
                FormulaItem(
                  name: 'Force on Current Wire',
                  expr: 'F = I · L · B · sinθ',
                  vars: 'I = current (A), L = wire length in field (m)',
                ),
              ],
              tips: [
                'If a charged particle enters perpendicular to B (θ = 90°), it executes uniform circular motion with radius r = mv / (qB).',
              ],
              conceptCheck: ConceptCheck(
                q: 'Does a static uniform magnetic field ever change the kinetic energy of a moving proton?',
                options: [
                  'Yes, when θ = 90°',
                  'No, magnetic force is always perpendicular to velocity',
                ],
                correctIdx: 1,
                feedback:
                    'Correct! W = F·d·cos(90°) = 0 J, so speed and kinetic energy stay constant.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '4.1',
              difficulty: 'Standard',
              q: 'An electron moves perpendicular to a 0.5 T magnetic field at 2 × 10⁶ m/s. What is the magnetic force? (e = 1.6 × 10⁻¹⁹ C)',
              options: [
                '1.6 × 10⁻¹³ N',
                '3.2 × 10⁻¹³ N',
                '8.0 × 10⁻¹⁴ N',
                '0 N',
              ],
              correctIndex: 0,
              explanation:
                  'F = qvB·sin(90°) = (1.6 × 10⁻¹⁹)(2 × 10⁶)(0.5) = 1.6 × 10⁻¹³ N.',
            ),
          ),
          StudyTopic(
            id: 'phy-4-2',
            code: '4.2',
            title: "Faraday's & Lenz's Law",
            duration: '6 min',
            questionCount: 18,
            completed: true,
            bookmarked: true,
            notes: TopicNotes(
              summary: [
                'Magnetic Flux (ΦB) measures field lines passing through area A: ΦB = B·A·cosθ, where θ is between B and the area normal.',
                'Faraday’s Law states induced EMF equals the negative time rate of change of magnetic flux through N loops.',
                'Lenz’s Law dictates that induced current creates a magnetic field that opposes the change in flux producing it (conserving energy).',
              ],
              formulas: [
                FormulaItem(
                  name: "Faraday's Law of Induction",
                  expr: 'ε = −N · (ΔΦB / Δt)',
                  vars: 'N = coil turns, ΔΦB = change in magnetic flux (Wb)',
                ),
                FormulaItem(
                  name: 'Magnetic Flux',
                  expr: 'ΦB = B · A · cosθ',
                  vars: 'θ = angle between B and normal to coil plane',
                ),
              ],
              tips: [
                'Watch EUEE phrasing: if B is parallel to the plane of the coil, θ = 90° with the normal, so ΦB = 0!',
              ],
              conceptCheck: ConceptCheck(
                q: 'When the North pole of a magnet is pushed toward a closed copper loop, the loop face nearest the magnet becomes:',
                options: [
                  'A North pole to oppose the approach',
                  'A South pole to attract the magnet',
                ],
                correctIdx: 0,
                feedback:
                    'Exact! By Lenz’s Law, like poles repel to oppose the increasing magnetic flux.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '4.2',
              difficulty: 'EUEE Hard',
              q: 'A 50-turn coil experiences a magnetic flux drop from 0.08 Wb to 0.02 Wb in 0.15 s. What is the magnitude of the induced EMF?',
              options: ['10 V', '20 V', '30 V', '40 V'],
              correctIndex: 1,
              explanation:
                  '|ε| = N · |ΔΦ / Δt| = 50 × (0.06 / 0.15) = 50 × 0.4 = 20 V.',
            ),
          ),
          StudyTopic(
            id: 'phy-4-3',
            code: '4.3',
            title: 'Transformers & AC Generators',
            duration: '5 min',
            questionCount: 14,
            completed: false,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'An AC Generator rotates a coil in a magnetic field to produce sinusoidal EMF: ε(t) = N·B·A·ω·sin(ωt).',
                'A Transformer steps AC voltage up or down via mutual induction between primary (Np) and secondary (Ns) coils. It does not work on steady DC.',
              ],
              formulas: [
                FormulaItem(
                  name: 'Ideal Transformer Equation',
                  expr: 'Vs / Vp = Ns / Np = Ip / Is',
                  vars: 'Power is conserved: Vp·Ip = Vs·Is',
                ),
                FormulaItem(
                  name: 'Peak Generator EMF',
                  expr: 'εmax = N · B · A · ω',
                  vars: 'ω = 2πf angular frequency (rad/s)',
                ),
              ],
              tips: [
                'Stepping UP voltage steps DOWN current proportionally so P = VI remains constant in an ideal transformer.',
              ],
              conceptCheck: ConceptCheck(
                q: 'Why can a standard transformer NOT step up a steady 12 V DC battery voltage?',
                options: [
                  'DC produces no changing magnetic flux',
                  'Copper coils block direct current',
                ],
                correctIdx: 0,
                feedback:
                    'Correct! Faraday’s Law requires a changing flux (ΔΦ/Δt ≠ 0), which only AC provides.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '4.3',
              difficulty: 'Standard',
              q: 'An ideal step-up transformer has 200 primary turns and 1,000 secondary turns. If input is 120 V AC, what is the output voltage?',
              options: ['24 V', '240 V', '600 V', '1,200 V'],
              correctIndex: 2,
              explanation: 'Vs = Vp × (Ns / Np) = 120 × (1000 / 200) = 600 V.',
            ),
          ),
        ],
      ),
      StudyUnit(
        id: 'phy-u5',
        code: 'U5',
        title: 'Basics of Electronics',
        examWeight: '14% EUEE',
        expanded: false,
        topics: [
          StudyTopic(
            id: 'phy-5-1',
            code: '5.1',
            title: 'P-N Junction Diodes & Rectification',
            duration: '5 min',
            questionCount: 12,
            completed: false,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'Doping silicon with Group V elements (Phosphorus) yields n-type semiconductors; Group III elements (Boron) yield p-type semiconductors.',
                'A p-n junction diode conducts in forward bias (p to +, n to −, ~0.7 V silicon barrier) and blocks current in reverse bias, enabling AC-to-DC rectification.',
              ],
              formulas: [
                FormulaItem(
                  name: 'Silicon Barrier Potential',
                  expr: 'Vbarrier ≈ 0.7 V (Si), 0.3 V (Ge)',
                  vars:
                      'Minimum forward voltage required for significant conduction',
                ),
              ],
              tips: [
                'In a bridge rectifier (full-wave), output ripple frequency is double the input AC frequency (2f).',
              ],
              conceptCheck: ConceptCheck(
                q: 'Which dopant creates an n-type semiconductor when added to pure Silicon?',
                options: ['Phosphorus (Group V)', 'Boron (Group III)'],
                correctIdx: 0,
                feedback:
                    'Correct! Phosphorus donates extra valence electrons as majority carriers.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '5.1',
              difficulty: 'Standard',
              q: 'What is the approximate forward barrier potential of a silicon p-n junction diode at room temperature?',
              options: ['0.1 V', '0.3 V', '0.7 V', '1.5 V'],
              correctIndex: 2,
              explanation:
                  'Silicon diodes have a forward barrier potential of ~0.7 V (Germanium is ~0.3 V).',
            ),
          ),
          StudyTopic(
            id: 'phy-5-2',
            code: '5.2',
            title: 'Transistors & Digital Logic Gates',
            duration: '6 min',
            questionCount: 15,
            completed: false,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'A Bipolar Junction Transistor (BJT) acts as a current amplifier or electronic switch where a small base current IB controls a much larger collector current IC.',
                'Universal logic gates NAND and NOR can implement any Boolean logic function.',
              ],
              formulas: [
                FormulaItem(
                  name: 'Transistor Current Gain',
                  expr: 'β = IC / IB',
                  vars:
                      'IE = IB + IC (emitter current equals base + collector)',
                ),
              ],
              tips: [
                'NAND output is 0 ONLY when all inputs are 1; NOR output is 1 ONLY when all inputs are 0.',
              ],
              conceptCheck: ConceptCheck(
                q: 'A NAND gate produces an output of 0 only when:',
                options: ['All inputs are 1', 'All inputs are 0'],
                correctIdx: 0,
                feedback:
                    'Spot on! NAND is NOT-AND, so 1 AND 1 = 1, inverted to 0.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '5.2',
              difficulty: 'EUEE Hard',
              q: 'In an NPN transistor with current gain β = 100 and base current IB = 0.2 mA, what is the emitter current IE?',
              options: ['20.0 mA', '20.2 mA', '19.8 mA', '2.0 mA'],
              correctIndex: 1,
              explanation:
                  'IC = β·IB = 100 × 0.2 mA = 20.0 mA. Therefore IE = IB + IC = 0.2 + 20.0 = 20.2 mA.',
            ),
          ),
        ],
      ),
    ],
  ),
  'mathematics': const SubjectCurriculum(
    id: 'mathematics',
    name: 'Mathematics',
    mastery: 88,
    lastTopicId: 'math-4-2',
    iconData: HugeIcons.strokeRoundedCalculate,
    color: Color(0xFF2563EB),
    units: [
      StudyUnit(
        id: 'math-u1',
        code: 'U1',
        title: 'Sequences & Series',
        examWeight: '16% EUEE',
        expanded: false,
        topics: [
          StudyTopic(
            id: 'math-1-1',
            code: '1.1',
            title: 'Arithmetic & Geometric Progressions',
            duration: '5 min',
            questionCount: 15,
            completed: true,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'An Arithmetic Sequence has constant difference d: an = a₁ + (n − 1)d.',
                'An infinite Geometric Series converges to S∞ = a₁ / (1 − r) if and only if |r| < 1.',
              ],
              formulas: [
                FormulaItem(
                  name: 'Infinite Geometric Sum',
                  expr: 'S∞ = a₁ / (1 − r),  |r| < 1',
                  vars: 'a₁ = first term, r = common ratio',
                ),
                FormulaItem(
                  name: 'Arithmetic Partial Sum',
                  expr: 'Sn = (n / 2) · [2a₁ + (n − 1)d]',
                  vars: 'Sum of first n terms',
                ),
              ],
              tips: [
                'Always verify |r| < 1 before applying S∞ = a₁ / (1 − r) on EUEE convergence questions.',
              ],
              conceptCheck: ConceptCheck(
                q: 'Find the sum to infinity of the geometric series 12 + 4 + 4/3 + ...',
                options: ['16', '18'],
                correctIdx: 1,
                feedback:
                    'Correct! r = 4/12 = 1/3, so S∞ = 12 / (1 − 1/3) = 12 / (2/3) = 18.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '1.1',
              difficulty: 'Standard',
              q: 'What is the sum of the infinite geometric series 10 − 5 + 2.5 − 1.25 + ...?',
              options: ['20', '20/3', '15/2', '5'],
              correctIndex: 1,
              explanation:
                  'a₁ = 10 and r = −0.5. Since |r| < 1, S∞ = 10 / (1 − (−0.5)) = 10 / 1.5 = 20/3.',
            ),
          ),
        ],
      ),
      StudyUnit(
        id: 'math-u3',
        code: 'U3',
        title: 'Differential Calculus',
        examWeight: '26% EUEE',
        expanded: false,
        topics: [
          StudyTopic(
            id: 'math-3-1',
            code: '3.1',
            title: 'Chain Rule & Implicit Differentiation',
            duration: '6 min',
            questionCount: 20,
            completed: true,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'The Chain Rule differentiates composite functions from outside in: [f(g(x))]′ = f′(g(x)) · g′(x).',
                'For implicit curves like x² + y² = 25, differentiate both sides with respect to x and multiply any y-derivative by dy/dx.',
              ],
              formulas: [
                FormulaItem(
                  name: 'Chain Rule',
                  expr: 'dy/dx = (dy/du) · (du/dx)',
                  vars: 'u = g(x) is the inner function',
                ),
                FormulaItem(
                  name: 'Exponential & Log Derivatives',
                  expr: 'd/dx(eᵏˣ) = k·eᵏˣ,   d/dx(ln x) = 1/x',
                  vars: 'Valid for x > 0 in ln x',
                ),
              ],
              tips: [
                'At critical points where f′(c) = 0, use the Second Derivative Test: f″(c) < 0 implies a local maximum.',
              ],
              conceptCheck: ConceptCheck(
                q: 'What is the derivative of f(x) = ln(3x² + 1)?',
                options: ['6x / (3x² + 1)', '1 / (3x² + 1)'],
                correctIdx: 0,
                feedback:
                    'Correct! By the chain rule, derivative is u′ / u = 6x / (3x² + 1).',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '3.1',
              difficulty: 'Standard',
              q: 'Find the derivative dy/dx of y = (2x + 1)⁴ at x = 0.',
              options: ['4', '8', '16', '2'],
              correctIndex: 1,
              explanation:
                  'dy/dx = 4(2x + 1)³ · 2 = 8(2x + 1)³. At x = 0, dy/dx = 8(1)³ = 8.',
            ),
          ),
        ],
      ),
      StudyUnit(
        id: 'math-u4',
        code: 'U4',
        title: 'Integral Calculus',
        examWeight: '24% EUEE',
        expanded: true,
        topics: [
          StudyTopic(
            id: 'math-4-1',
            code: '4.1',
            title: 'Integration by Substitution',
            duration: '6 min',
            questionCount: 18,
            completed: true,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'u-Substitution reverses the chain rule: choose u = g(x) whose derivative du = g′(x)dx appears inside the integrand.',
                'When evaluating definite integrals with substitution, either update the limits to u(a) and u(b) or back-substitute x before plugging limits.',
              ],
              formulas: [
                FormulaItem(
                  name: 'Substitution Rule',
                  expr: '∫ f(g(x))·g′(x) dx = ∫ f(u) du',
                  vars: 'Let u = g(x), du = g′(x) dx',
                ),
              ],
              tips: [
                'If the numerator is the exact derivative of the denominator, ∫ [g′(x)/g(x)] dx = ln|g(x)| + C immediately!',
              ],
              conceptCheck: ConceptCheck(
                q: 'Evaluate ∫ (2x / (x² + 4)) dx:',
                options: ['ln(x² + 4) + C', '2·ln(x² + 4) + C'],
                correctIdx: 0,
                feedback:
                    'Spot on! Let u = x² + 4, then du = 2x dx, giving ∫ du/u = ln(x² + 4) + C.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '4.1',
              difficulty: 'EUEE Hard',
              q: 'Evaluate the indefinite integral ∫ 6x · (x² + 1)² dx.',
              options: [
                '(x² + 1)³ + C',
                '2(x² + 1)³ + C',
                '3(x² + 1)³ + C',
                '(x² + 1)³/3 + C',
              ],
              correctIndex: 0,
              explanation:
                  'Let u = x² + 1, du = 2x dx ⇒ 3 ∫ u² du = 3 · (u³ / 3) + C = (x² + 1)³ + C.',
            ),
          ),
          StudyTopic(
            id: 'math-4-2',
            code: '4.2',
            title: 'Definite Integrals & Area Under Curves',
            duration: '5 min',
            questionCount: 16,
            completed: true,
            bookmarked: true,
            notes: TopicNotes(
              summary: [
                'By the Fundamental Theorem of Calculus, ∫ₐᵇ f(x) dx = F(b) − F(a), where F′(x) = f(x).',
                'To find total geometric area between two curves f(x) and g(x) on [a, b], integrate ∫ₐᵇ |f(x) − g(x)| dx.',
              ],
              formulas: [
                FormulaItem(
                  name: 'Fundamental Theorem',
                  expr: '∫ₐᵇ f(x) dx = F(b) − F(a)',
                  vars: 'F(x) is any antiderivative of continuous f(x)',
                ),
                FormulaItem(
                  name: 'Area Between Curves',
                  expr: 'Area = ∫ₐᵇ [fupper(x) − flower(x)] dx',
                  vars: 'Split integral where curves intersect',
                ),
              ],
              tips: [
                'Geometric area is always positive; split intervals wherever f(x) crosses below the x-axis.',
              ],
              conceptCheck: ConceptCheck(
                q: 'What is the value of ∫₀² 3x² dx?',
                options: ['6', '8'],
                correctIdx: 1,
                feedback: 'Correct! Antiderivative is x³, and 2³ − 0³ = 8.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '4.2',
              difficulty: 'Standard',
              q: 'Evaluate the definite integral ∫₀² (3x² + 2x) dx.',
              options: ['8', '10', '12', '16'],
              correctIndex: 2,
              explanation:
                  'F(x) = x³ + x². Evaluating from 0 to 2 gives (8 + 4) − 0 = 12.',
            ),
          ),
        ],
      ),
    ],
  ),
  'chemistry': const SubjectCurriculum(
    id: 'chemistry',
    name: 'Chemistry',
    mastery: 71,
    lastTopicId: 'chem-4-1',
    iconData: HugeIcons.strokeRoundedChemistry01,
    color: AppColors.warning,
    units: [
      StudyUnit(
        id: 'chem-u2',
        code: 'U2',
        title: 'Acid-Base Equilibria',
        examWeight: '24% EUEE',
        expanded: false,
        topics: [
          StudyTopic(
            id: 'chem-2-1',
            code: '2.1',
            title: 'pH, Buffers & Henderson-Hasselbalch',
            duration: '6 min',
            questionCount: 16,
            completed: true,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'A Buffer Solution resists pH changes upon addition of small amounts of acid or base and consists of a weak acid and its conjugate base.',
                'Maximum buffer capacity occurs when [A⁻] = [HA], where pH = pKa.',
              ],
              formulas: [
                FormulaItem(
                  name: 'Henderson-Hasselbalch',
                  expr: 'pH = pKa + log([A⁻] / [HA])',
                  vars: 'pKa = −log(Ka) of the weak acid',
                ),
                FormulaItem(
                  name: 'Water Autoionization (25°C)',
                  expr: 'Kw = [H⁺][OH⁻] = 1.0 × 10⁻¹⁴',
                  vars: 'pH + pOH = 14.00 at 25°C',
                ),
              ],
              tips: [
                'Strong acid + strong base equivalence point has pH = 7.0; weak acid + strong base equivalence point has pH > 7.0.',
              ],
              conceptCheck: ConceptCheck(
                q: 'When [CH₃COO⁻] equals [CH₃COOH] in an acetate buffer (pKa = 4.74), the solution pH is:',
                options: ['4.74', '7.00'],
                correctIdx: 0,
                feedback: 'Correct! Since log(1) = 0, pH = pKa = 4.74.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '2.1',
              difficulty: 'Standard',
              q: 'What is the pH of a 0.001 M HCl aqueous solution at 25°C?',
              options: ['1', '2', '3', '11'],
              correctIndex: 2,
              explanation:
                  'HCl is a strong acid: [H⁺] = 10⁻³ M, so pH = −log(10⁻³) = 3.',
            ),
          ),
        ],
      ),
      StudyUnit(
        id: 'chem-u4',
        code: 'U4',
        title: 'Electrochemistry',
        examWeight: '28% EUEE',
        expanded: true,
        topics: [
          StudyTopic(
            id: 'chem-4-1',
            code: '4.1',
            title: 'Galvanic Cells & Standard Cell Potential',
            duration: '7 min',
            questionCount: 18,
            completed: true,
            bookmarked: true,
            notes: TopicNotes(
              summary: [
                'In a spontaneous Galvanic (Voltaic) Cell, oxidation occurs at the Anode (−) and reduction occurs at the Cathode (+).',
                'Electrons flow externally from anode to cathode, while the salt bridge maintains electrical neutrality.',
              ],
              formulas: [
                FormulaItem(
                  name: 'Standard Cell Potential',
                  expr: 'E°cell = E°cathode − E°anode',
                  vars: 'Spontaneous reaction requires E°cell > 0',
                ),
                FormulaItem(
                  name: 'Nernst Equation (298 K)',
                  expr: 'E = E°cell − (0.0592 / n) · log Q',
                  vars: 'n = moles of electrons transferred',
                ),
              ],
              tips: [
                'Never multiply E° values by stoichiometric coefficients! Reduction potential is an intensive property.',
              ],
              conceptCheck: ConceptCheck(
                q: 'In any electrochemical cell (galvanic or electrolytic), reduction always occurs at the:',
                options: ['Cathode', 'Anode'],
                correctIdx: 0,
                feedback:
                    'Spot on! RED CAT (Reduction at Cathode) and AN OX (Anode Oxidation).',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '4.1',
              difficulty: 'EUEE Hard',
              q: 'Given Zn²⁺/Zn (E° = −0.76 V) and Cu²⁺/Cu (E° = +0.34 V), what is E°cell for a spontaneous Zn–Cu galvanic cell?',
              options: ['+0.42 V', '−1.10 V', '+1.10 V', '−0.42 V'],
              correctIndex: 2,
              explanation:
                  'E°cell = E°cathode − E°anode = +0.34 V − (−0.76 V) = +1.10 V.',
            ),
          ),
          StudyTopic(
            id: 'chem-4-2',
            code: '4.2',
            title: "Faraday's Laws of Electrolysis",
            duration: '5 min',
            questionCount: 14,
            completed: false,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'Electrolysis uses external electrical energy to drive a non-spontaneous redox reaction.',
                'Mass deposited at an electrode is directly proportional to total electric charge Q = I · t passed through the electrolyte.',
              ],
              formulas: [
                FormulaItem(
                  name: 'Faraday Electrolysis Mass',
                  expr: 'm = (Q · M) / (n · F) = (I · t · M) / (n · F)',
                  vars: 'F = 96,500 C/mol, M = molar mass, n = e⁻ per ion',
                ),
              ],
              tips: ['Convert time t into SECONDS before computing Q = I · t!'],
              conceptCheck: ConceptCheck(
                q: 'How many Faradays of charge are needed to reduce 1 mole of Al³⁺ ions to solid Aluminum?',
                options: ['1 Faraday', '3 Faradays'],
                correctIdx: 1,
                feedback:
                    'Correct! Al³⁺ + 3e⁻ → Al requires 3 moles of electrons = 3 Faradays.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '4.2',
              difficulty: 'Standard',
              q: 'During electrolysis of molten NaCl, what product forms at the cathode?',
              options: [
                'Chlorine gas (Cl₂)',
                'Sodium metal (Na)',
                'Hydrogen gas (H₂)',
                'Oxygen gas (O₂)',
              ],
              correctIndex: 1,
              explanation:
                  'Reduction occurs at the cathode: Na⁺(l) + e⁻ → Na(l).',
            ),
          ),
        ],
      ),
    ],
  ),
  'biology': const SubjectCurriculum(
    id: 'biology',
    name: 'Biology',
    mastery: 79,
    lastTopicId: 'bio-4-1',
    iconData: HugeIcons.strokeRoundedDna,
    color: AppColors.success,
    units: [
      StudyUnit(
        id: 'bio-u3',
        code: 'U3',
        title: 'Cellular Respiration & Photosynthesis',
        examWeight: '22% EUEE',
        expanded: false,
        topics: [
          StudyTopic(
            id: 'bio-3-1',
            code: '3.1',
            title: 'Glycolysis, Krebs Cycle & Oxidative Phosphorylation',
            duration: '6 min',
            questionCount: 16,
            completed: true,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'Glycolysis occurs in the cytoplasm without oxygen, splitting glucose into 2 pyruvate molecules with a net yield of 2 ATP and 2 NADH.',
                'The Krebs Cycle occurs in the mitochondrial matrix, while Oxidative Phosphorylation across the inner membrane generates ~32–34 ATP using O₂ as final electron acceptor.',
              ],
              formulas: [
                FormulaItem(
                  name: 'Aerobic Respiration Equation',
                  expr: 'C₆H₁₂O₆ + 6O₂ → 6CO₂ + 6H₂O + ~36–38 ATP',
                  vars: 'Complete oxidation of 1 mole of glucose',
                ),
              ],
              tips: [
                'Oxygen is the final electron acceptor in the Electron Transport Chain; without O₂, pyruvate undergoes fermentation.',
              ],
              conceptCheck: ConceptCheck(
                q: 'Where does the Krebs (Citric Acid) cycle occur in eukaryotic cells?',
                options: ['Mitochondrial matrix', 'Cytoplasm'],
                correctIdx: 0,
                feedback:
                    'Correct! Glycolysis is cytoplasmic; the Krebs cycle runs in the mitochondrial matrix.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '3.1',
              difficulty: 'Standard',
              q: 'Which molecule serves as the final electron acceptor at the end of the mitochondrial electron transport chain?',
              options: [
                'NAD⁺',
                'Carbon dioxide (CO₂)',
                'Oxygen (O₂)',
                'Pyruvate',
              ],
              correctIndex: 2,
              explanation:
                  'Oxygen accepts low-energy electrons and combines with H⁺ ions to form water (H₂O).',
            ),
          ),
        ],
      ),
      StudyUnit(
        id: 'bio-u4',
        code: 'U4',
        title: 'Molecular Genetics',
        examWeight: '28% EUEE',
        expanded: true,
        topics: [
          StudyTopic(
            id: 'bio-4-1',
            code: '4.1',
            title: 'DNA Replication Enzymes & Semi-Conservative Model',
            duration: '6 min',
            questionCount: 18,
            completed: true,
            bookmarked: true,
            notes: TopicNotes(
              summary: [
                'DNA replication is semi-conservative: each daughter duplex retains one parental strand and one newly synthesized strand.',
                'Helicase unwinds the double helix; DNA Polymerase III synthesizes new strands exclusively in the 5′ → 3′ direction; DNA Ligase seals Okazaki fragments.',
              ],
              formulas: [
                FormulaItem(
                  name: "Chargaff's Base Pairing",
                  expr: '%A = %T   and   %G = %C',
                  vars:
                      'A pairs with T (2 H-bonds); G pairs with C (3 H-bonds)',
                ),
              ],
              tips: [
                'Memorize enzyme roles: Helicase (unzips), Topoisomerase (relieves supercoiling), Primase (lays RNA primer), Ligase (joins Okazaki fragments).',
              ],
              conceptCheck: ConceptCheck(
                q: 'If a double-stranded DNA sample contains 22% Adenine (A), what percentage is Guanine (G)?',
                options: ['22%', '28%'],
                correctIdx: 1,
                feedback:
                    'Spot on! A = T = 22% (44% total), leaving 56% split equally between G (28%) and C (28%).',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '4.1',
              difficulty: 'EUEE Hard',
              q: 'Which enzyme relieves supercoiling and torsional strain ahead of the DNA replication fork?',
              options: [
                'DNA Helicase',
                'DNA Topoisomerase (Gyrase)',
                'RNA Primase',
                'DNA Ligase',
              ],
              correctIndex: 1,
              explanation:
                  'DNA Topoisomerase (gyrase) cleaves and rejoins DNA strands to prevent supercoiling ahead of helicase.',
            ),
          ),
          StudyTopic(
            id: 'bio-4-2',
            code: '4.2',
            title: 'Transcription, Genetic Code & Translation',
            duration: '5 min',
            questionCount: 15,
            completed: false,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'Transcription synthesizes mRNA from a DNA template using RNA Polymerase inside the nucleus.',
                'Translation decodes mRNA codons at the ribosome: AUG is the universal start codon (Methionine), while UAA, UAG, and UGA are stop codons.',
              ],
              formulas: [
                FormulaItem(
                  name: 'Central Dogma Flow',
                  expr:
                      'DNA ──(Transcription)──▶ mRNA ──(Translation)──▶ Polypeptide',
                  vars: 'In mRNA, Uracil (U) replaces Thymine (T)',
                ),
              ],
              tips: [
                'The genetic code is degenerate (redundant) because multiple codons can specify the same amino acid, but never ambiguous.',
              ],
              conceptCheck: ConceptCheck(
                q: 'Which mRNA codon serves as the universal start codon and codes for Methionine?',
                options: ['UAA', 'UGA', 'AUG', 'UAG'],
                correctIdx: 2,
                feedback:
                    'AUG initiates translation and specifies Methionine; UAA, UAG, and UGA are stop codons.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: '4.2',
              difficulty: 'Standard',
              q: 'Which mRNA codon serves as the universal start codon and codes for Methionine?',
              options: ['UAA', 'UGA', 'AUG', 'UAG'],
              correctIndex: 2,
              explanation:
                  'AUG initiates translation and specifies Methionine; UAA, UAG, and UGA are stop codons.',
            ),
          ),
        ],
      ),
    ],
  ),
  'english': const SubjectCurriculum(
    id: 'english',
    name: 'English',
    mastery: 85,
    lastTopicId: 'eng-1-1',
    iconData: HugeIcons.strokeRoundedBook02,
    color: AppColors.royalPurple,
    units: [
      StudyUnit(
        id: 'eng-u1',
        code: 'U1',
        unitCode: 'ENG-G12-U01',
        title: 'Sustainable Development',
        examWeight: '12% EUEE',
        expanded: false,
        topics: [
          StudyTopic(
            id: 'eng-1-1',
            code: '1.1',
            title: 'Contrast Connectors & Reading Synthesis',
            duration: '6 min',
            questionCount: 15,
            completed: false,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'Sustainable development balances economic growth with environmental protection.',
                'Contrast connectors: whereas, while, in contrast, on the other hand.',
              ],
              formulas: [],
              tips: [
                'Look for contrasting ideas separated by "whereas" or "while" in EUEE reading passages.',
              ],
              conceptCheck: ConceptCheck(
                q: 'Which connector indicates contrast between economic growth and environmental care?',
                options: ['whereas', 'similarly', 'furthermore', 'in addition'],
                correctIdx: 0,
                feedback: '"Whereas" highlights direct contrast between two distinct ideas.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: 'ENG-G12-U01',
              difficulty: 'Standard',
              q: 'Economic growth focuses on quantitative output, ______ sustainable development emphasizes qualitative well-being.',
              options: ['similarly', 'whereas', 'as well as', 'in the same way'],
              correctIndex: 1,
              explanation: "'Whereas' is a contrast connector used to contrast economic growth with sustainable development.",
            ),
          ),
        ],
      ),
      StudyUnit(
        id: 'eng-u2',
        code: 'U2',
        unitCode: 'ENG-G12-U02',
        title: 'Time Management',
        examWeight: '10% EUEE',
        expanded: false,
        topics: [
          StudyTopic(
            id: 'eng-2-1',
            code: '2.1',
            title: 'Conditional Sentences & Scheduling Idioms',
            duration: '5 min',
            questionCount: 15,
            completed: false,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'Zero, First, Second, and Third Conditionals in academic English.',
                'Idioms related to time: against the clock, in the nick of time.',
              ],
              formulas: [],
              tips: [
                'In Third Conditional: If + had + V3, would have + V3.',
              ],
              conceptCheck: ConceptCheck(
                q: 'If we had planned our schedule earlier, we ______ the deadline.',
                options: ['would meet', 'will meet', 'would have met', 'met'],
                correctIdx: 2,
                feedback: 'Third conditional requires "would have + past participle".',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: 'ENG-G12-U02',
              difficulty: 'Standard',
              q: 'If the study schedule ______ adhered to strictly, the syllabus would be mastered ahead of time.',
              options: ['is', 'were', 'had been', 'will be'],
              correctIndex: 1,
              explanation: "Second conditional uses 'were' with subjunctive force.",
            ),
          ),
        ],
      ),
      StudyUnit(
        id: 'eng-u3',
        code: 'U3',
        unitCode: 'ENG-G12-U03',
        title: 'Evidence on Traffic Accident',
        examWeight: '10% EUEE',
        expanded: false,
        topics: [
          StudyTopic(
            id: 'eng-3-1',
            code: '3.1',
            title: 'Passive Voice & Crime Scene Vocabulary',
            duration: '6 min',
            questionCount: 15,
            completed: false,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'Passive voice structures for objective reporting: was observed, is reported to be.',
              ],
              formulas: [],
              tips: ['Passive voice emphasizes the action and receiver over the unknown agent.'],
              conceptCheck: ConceptCheck(
                q: 'The speed of the vehicle ______ by the radar before collision.',
                options: ['was recorded', 'recorded', 'is recording', 'records'],
                correctIdx: 0,
                feedback: 'Past passive: was + past participle.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: 'ENG-G12-U03',
              difficulty: 'Standard',
              q: 'The traffic report stated that the driver ______ to have exceeded the speed limit.',
              options: ['was found', 'found', 'is finding', 'has found'],
              correctIndex: 0,
              explanation: "Objective accident reports use passive 'was found'.",
            ),
          ),
        ],
      ),
      StudyUnit(
        id: 'eng-u4',
        code: 'U4',
        unitCode: 'ENG-G12-U04',
        title: 'Natural Resource Management',
        examWeight: '11% EUEE',
        expanded: false,
        topics: [
          StudyTopic(
            id: 'eng-4-1',
            code: '4.1',
            title: 'Cause and Effect Transitions',
            duration: '5 min',
            questionCount: 15,
            completed: false,
            bookmarked: false,
            notes: TopicNotes(
              summary: [
                'Cause-effect markers: consequently, as a result, owing to, due to.',
              ],
              formulas: [],
              tips: ['"Due to" is followed by a noun phrase; "because" introduces a clause.'],
              conceptCheck: ConceptCheck(
                q: 'The soil erosion worsened ______ heavy deforestation on the ridge.',
                options: ['due to', 'because', 'since', 'consequently'],
                correctIdx: 0,
                feedback: '"Due to" precedes the noun phrase "heavy deforestation".',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: 'ENG-G12-U04',
              difficulty: 'Standard',
              q: 'Deforestation rates increased; ______, downstream reservoirs experienced severe siltation.',
              options: ['consequently', 'similarly', 'although', 'despite'],
              correctIndex: 0,
              explanation: "'Consequently' introduces the direct consequence of the first clause.",
            ),
          ),
        ],
      ),
      StudyUnit(
        id: 'eng-u5',
        code: 'U5',
        unitCode: 'ENG-G12-U05',
        title: 'Mechanized Agriculture',
        examWeight: '10% EUEE',
        expanded: false,
        topics: [
          StudyTopic(
            id: 'eng-5-1',
            code: '5.1',
            title: 'Technical Jargon & Process Description',
            duration: '5 min',
            questionCount: 15,
            completed: false,
            bookmarked: false,
            notes: TopicNotes(
              summary: ['Sequencing words for agricultural mechanization stages: initially, subsequently, finally.'],
              formulas: [],
              tips: ['Look for chronological order indicators in process passages.'],
              conceptCheck: ConceptCheck(
                q: 'The wheat was harvested; ______, it was transported to the regional granary.',
                options: ['subsequently', 'nevertheless', 'otherwise', 'even though'],
                correctIdx: 0,
                feedback: '"Subsequently" indicates the next step in a sequence.',
              ),
            ),
            drillQuestion: DrillQuestionItem(
              topicCode: 'ENG-G12-U05',
              difficulty: 'Standard',
              q: 'Modern combine harvesters reap, thresh, and winnow grain in a single operation, ______ labor costs significantly.',
              options: ['reducing', 'reduced', 'reduce', 'reduces'],
              correctIndex: 0,
              explanation: "Participle clause 'reducing' expresses the result of the main action.",
            ),
          ),
        ],
      ),
    ],
  ),
};
