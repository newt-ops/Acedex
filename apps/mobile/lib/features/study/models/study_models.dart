import 'package:flutter/material.dart';

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

/// Subject Curriculum Model
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
