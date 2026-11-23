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

/// Question item for Unit Assessments and Quizzes
class DrillQuestionItem {
  final String topicCode;
  final String difficulty; // 'Easy' | 'Medium' | 'Challenging' | 'Standard'
  final String q;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String? topicTitle;
  final String? sourceReference;

  const DrillQuestionItem({
    required this.topicCode,
    required this.difficulty,
    required this.q,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.topicTitle,
    this.sourceReference,
  });

  DrillQuestionItem copyWith({
    String? topicCode,
    String? difficulty,
    String? q,
    List<String>? options,
    int? correctIndex,
    String? explanation,
    String? topicTitle,
    String? sourceReference,
  }) {
    return DrillQuestionItem(
      topicCode: topicCode ?? this.topicCode,
      difficulty: difficulty ?? this.difficulty,
      q: q ?? this.q,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      explanation: explanation ?? this.explanation,
      topicTitle: topicTitle ?? this.topicTitle,
      sourceReference: sourceReference ?? this.sourceReference,
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
  final TopicNotes? notes;

  const StudyTopic({
    required this.id,
    required this.code,
    required this.title,
    this.duration = '5 min',
    this.questionCount = 15,
    this.completed = false,
    this.bookmarked = false,
    this.notes,
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
    );
  }
}

/// Syllabus Unit
class StudyUnit {
  final String id;
  final String code; // e.g., 'U1', 'U2'
  final String title;
  final String examWeight; // e.g., '15 Questions • Ethiopian Curriculum Bank'
  final bool expanded;
  final List<StudyTopic> topics;
  final String? unitCode; // e.g., 'MAT-G12-U01', 'PHY-G12-U01'
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
      case 'phy':
        return 'PHY';
      case 'mathematics':
      case 'math':
      case 'mat':
        return 'MAT';
      case 'chemistry':
      case 'chem':
      case 'che':
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

/// Authentic Grade 12 National Curriculum Database matching MongoDB Atlas (56 Units, 8 Subjects)
final Map<String, SubjectCurriculum> defaultCurriculumData = {
  // 1. Mathematics (5 Units)
  'mathematics': const SubjectCurriculum(
    id: 'mathematics',
    name: 'Mathematics',
    mastery: 88,
    lastTopicId: 'MAT-G12-U01',
    iconData: HugeIcons.strokeRoundedCalculate,
    color: Color(0xFF2563EB),
    units: [
      StudyUnit(
        id: 'MAT-G12-U01',
        code: 'U1',
        unitCode: 'MAT-G12-U01',
        title: 'Sequences and Series',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'MAT-G12-U02',
        code: 'U2',
        unitCode: 'MAT-G12-U02',
        title: 'Introductions to Calculus',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'MAT-G12-U03',
        code: 'U3',
        unitCode: 'MAT-G12-U03',
        title: 'Statistics',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'MAT-G12-U04',
        code: 'U4',
        unitCode: 'MAT-G12-U04',
        title: 'Introduction to Linear Programming',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'MAT-G12-U05',
        code: 'U5',
        unitCode: 'MAT-G12-U05',
        title: 'Mathematical Applications in Business',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
    ],
  ),

  // 2. Physics (5 Units)
  'physics': const SubjectCurriculum(
    id: 'physics',
    name: 'Physics',
    mastery: 82,
    lastTopicId: 'PHY-G12-U01',
    iconData: HugeIcons.strokeRoundedAtom01,
    color: AppColors.royalPurple,
    units: [
      StudyUnit(
        id: 'PHY-G12-U01',
        code: 'U1',
        unitCode: 'PHY-G12-U01',
        title: 'Application of Physics in Other Fields',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'PHY-G12-U02',
        code: 'U2',
        unitCode: 'PHY-G12-U02',
        title: 'Two-dimensional Motion',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'PHY-G12-U03',
        code: 'U3',
        unitCode: 'PHY-G12-U03',
        title: 'Fluid Mechanics',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'PHY-G12-U04',
        code: 'U4',
        unitCode: 'PHY-G12-U04',
        title: 'Electromagnetism',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'PHY-G12-U05',
        code: 'U5',
        unitCode: 'PHY-G12-U05',
        title: 'Basics of Electronics',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
    ],
  ),

  // 3. Chemistry (5 Units)
  'chemistry': const SubjectCurriculum(
    id: 'chemistry',
    name: 'Chemistry',
    mastery: 71,
    lastTopicId: 'CHE-G12-U01',
    iconData: HugeIcons.strokeRoundedTestTube01,
    color: Color(0xFF0D9488),
    units: [
      StudyUnit(
        id: 'CHE-G12-U01',
        code: 'U1',
        unitCode: 'CHE-G12-U01',
        title: 'Acid-Base Equilibria',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'CHE-G12-U02',
        code: 'U2',
        unitCode: 'CHE-G12-U02',
        title: 'Electrochemistry',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'CHE-G12-U03',
        code: 'U3',
        unitCode: 'CHE-G12-U03',
        title: 'Industrial Chemistry',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'CHE-G12-U04',
        code: 'U4',
        unitCode: 'CHE-G12-U04',
        title: 'Polymers',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'CHE-G12-U05',
        code: 'U5',
        unitCode: 'CHE-G12-U05',
        title: 'Introduction to Environmental Chemistry',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
    ],
  ),

  // 4. Biology (6 Units)
  'biology': const SubjectCurriculum(
    id: 'biology',
    name: 'Biology',
    mastery: 79,
    lastTopicId: 'BIO-G12-U01',
    iconData: HugeIcons.strokeRoundedDna01,
    color: Color(0xFF16A34A),
    units: [
      StudyUnit(
        id: 'BIO-G12-U01',
        code: 'U1',
        unitCode: 'BIO-G12-U01',
        title: 'Application of Biology',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'BIO-G12-U02',
        code: 'U2',
        unitCode: 'BIO-G12-U02',
        title: 'Microorganisms',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'BIO-G12-U03',
        code: 'U3',
        unitCode: 'BIO-G12-U03',
        title: 'Energy Transformation',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'BIO-G12-U04',
        code: 'U4',
        unitCode: 'BIO-G12-U04',
        title: 'Evolution',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'BIO-G12-U05',
        code: 'U5',
        unitCode: 'BIO-G12-U05',
        title: 'Human Body System',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'BIO-G12-U06',
        code: 'U6',
        unitCode: 'BIO-G12-U06',
        title: 'Climate Change',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
    ],
  ),

  // 5. English (10 Units)
  'english': const SubjectCurriculum(
    id: 'english',
    name: 'English',
    mastery: 85,
    lastTopicId: 'ENG-G12-U01',
    iconData: HugeIcons.strokeRoundedBookOpen01,
    color: Color(0xFFEA580C),
    units: [
      StudyUnit(
        id: 'ENG-G12-U01',
        code: 'U1',
        unitCode: 'ENG-G12-U01',
        title: 'Sustainable Development',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'ENG-G12-U02',
        code: 'U2',
        unitCode: 'ENG-G12-U02',
        title: 'Time Management',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'ENG-G12-U03',
        code: 'U3',
        unitCode: 'ENG-G12-U03',
        title: 'Evidence on Traffic Accident',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'ENG-G12-U04',
        code: 'U4',
        unitCode: 'ENG-G12-U04',
        title: 'Natural Resource Management',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'ENG-G12-U05',
        code: 'U5',
        unitCode: 'ENG-G12-U05',
        title: 'Mechanized Agriculture',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'ENG-G12-U06',
        code: 'U6',
        unitCode: 'ENG-G12-U06',
        title: 'Green Economies',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'ENG-G12-U07',
        code: 'U7',
        unitCode: 'ENG-G12-U07',
        title: 'National Pride',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'ENG-G12-U08',
        code: 'U8',
        unitCode: 'ENG-G12-U08',
        title: 'Telemedicine',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'ENG-G12-U09',
        code: 'U9',
        unitCode: 'ENG-G12-U09',
        title: 'Conflict Management',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'ENG-G12-U10',
        code: 'U10',
        unitCode: 'ENG-G12-U10',
        title: 'Robotics',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
    ],
  ),

  // 6. Economics (8 Units)
  'economics': const SubjectCurriculum(
    id: 'economics',
    name: 'Economics',
    mastery: 74,
    lastTopicId: 'ECO-G12-U01',
    iconData: HugeIcons.strokeRoundedAnalytics01,
    color: Color(0xFFCA8A04),
    units: [
      StudyUnit(
        id: 'ECO-G12-U01',
        code: 'U1',
        unitCode: 'ECO-G12-U01',
        title: 'The Fundamental Concepts of Macroeconomics',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'ECO-G12-U02',
        code: 'U2',
        unitCode: 'ECO-G12-U02',
        title: 'Aggregate Demand and Aggregate Supply Analysis',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'ECO-G12-U03',
        code: 'U3',
        unitCode: 'ECO-G12-U03',
        title: 'Macroeconomic Policy',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'ECO-G12-U04',
        code: 'U4',
        unitCode: 'ECO-G12-U04',
        title: 'Poverty and Inequality',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'ECO-G12-U05',
        code: 'U5',
        unitCode: 'ECO-G12-U05',
        title: 'Tax Theory and Practice',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'ECO-G12-U06',
        code: 'U6',
        unitCode: 'ECO-G12-U06',
        title: 'International Trade and Finance',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'ECO-G12-U07',
        code: 'U7',
        unitCode: 'ECO-G12-U07',
        title: 'Macroeconomic Reforms in Ethiopia',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'ECO-G12-U08',
        code: 'U8',
        unitCode: 'ECO-G12-U08',
        title: 'Economy, Environment and Climate Change',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
    ],
  ),

  // 7. Geography (8 Units)
  'geography': const SubjectCurriculum(
    id: 'geography',
    name: 'Geography',
    mastery: 78,
    lastTopicId: 'GEO-G12-U01',
    iconData: HugeIcons.strokeRoundedMapsLocation01,
    color: Color(0xFF0284C7),
    units: [
      StudyUnit(
        id: 'GEO-G12-U01',
        code: 'U1',
        unitCode: 'GEO-G12-U01',
        title: 'Major Geological Processes Associated with Plate Tectonics',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'GEO-G12-U02',
        code: 'U2',
        unitCode: 'GEO-G12-U02',
        title: 'Climate Change',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'GEO-G12-U03',
        code: 'U3',
        unitCode: 'GEO-G12-U03',
        title: 'Management of Conflict Over Resources',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'GEO-G12-U04',
        code: 'U4',
        unitCode: 'GEO-G12-U04',
        title: 'Population and Socio-Economic Development',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'GEO-G12-U05',
        code: 'U5',
        unitCode: 'GEO-G12-U05',
        title: 'Challenges of Economic Development',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'GEO-G12-U06',
        code: 'U6',
        unitCode: 'GEO-G12-U06',
        title: 'Solutions to Environmental and Sustainability Problems',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'GEO-G12-U07',
        code: 'U7',
        unitCode: 'GEO-G12-U07',
        title: 'Contemporary Global Geographic Issues and Public Concerns',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'GEO-G12-U08',
        code: 'U8',
        unitCode: 'GEO-G12-U08',
        title: 'Geographical Enquiry and Map Making',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
    ],
  ),

  // 8. History (9 Units)
  'history': const SubjectCurriculum(
    id: 'history',
    name: 'History',
    mastery: 80,
    lastTopicId: 'HIS-G12-U01',
    iconData: HugeIcons.strokeRoundedHourglass,
    color: Color(0xFF9333EA),
    units: [
      StudyUnit(
        id: 'HIS-G12-U01',
        code: 'U1',
        unitCode: 'HIS-G12-U01',
        title: 'Development of Capitalism and Nationalism from 1815 to 1914',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'HIS-G12-U02',
        code: 'U2',
        unitCode: 'HIS-G12-U02',
        title: 'Africa and the Colonial Experience (1880s – 1960s)',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'HIS-G12-U03',
        code: 'U3',
        unitCode: 'HIS-G12-U03',
        title: 'Social, Economic and Political Developments in Ethiopia, Mid 19th C. to 1941',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'HIS-G12-U04',
        code: 'U4',
        unitCode: 'HIS-G12-U04',
        title: 'Society and Politics in the Age of World Wars, 1914 - 1945',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'HIS-G12-U05',
        code: 'U5',
        unitCode: 'HIS-G12-U05',
        title: 'Global and Regional Developments Since 1945',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'HIS-G12-U06',
        code: 'U6',
        unitCode: 'HIS-G12-U06',
        title: 'Ethiopia: Internal Developments and External Influences from 1941 to 1991',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'HIS-G12-U07',
        code: 'U7',
        unitCode: 'HIS-G12-U07',
        title: 'Africa since the 1960s',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'HIS-G12-U08',
        code: 'U8',
        unitCode: 'HIS-G12-U08',
        title: 'Post 1991 Developments in Ethiopia',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
      StudyUnit(
        id: 'HIS-G12-U09',
        code: 'U9',
        unitCode: 'HIS-G12-U09',
        title: 'Indigenous Knowledge Systems and Heritages of Ethiopia',
        examWeight: '15 Questions • Ethiopian Curriculum Bank',
        expanded: false,
        topics: [],
      ),
    ],
  ),
};
