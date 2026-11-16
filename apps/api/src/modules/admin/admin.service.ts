import { Types } from 'mongoose';
import {
  QuestionBankFileSchema,
  QuestionBankFile,
  PublicationStatus,
} from '@acedex/contracts';
import { UserModel, IUser } from '../users/user.model';
import { UnitModel, IUnit } from '../curriculum/models/unit.model';
import { SubjectModel } from '../curriculum/models/subject.model';
import { QuestionModel } from '../curriculum/models/question.model';
import { AnswerKeyModel } from '../curriculum/models/answer-key.model';
import { AssessmentAttemptModel } from '../assessments/models/assessment-attempt.model';
import { AuditLogModel } from '../audit/audit-log.model';
import { AuditService } from '../audit/audit.service';
import { NotFoundError, BadRequestError } from '../../common/errors/app-error';

export interface DashboardStats {
  students: {
    total: number;
    active: number;
    suspended: number;
    activeToday: number;
  };
  curriculum: {
    totalUnits: number;
    publishedUnits: number;
    draftUnits: number;
    totalQuestions: number;
  };
  assessments: {
    totalTaken: number;
    totalPassed: number;
    passRate: number;
    averageScore: number;
  };
}

export interface StudentFilterOptions {
  search?: string;
  grade?: number;
  stream?: string;
  status?: string;
  page?: number;
  limit?: number;
}

export interface AuditLogFilterOptions {
  action?: string;
  resource?: string;
  userId?: string;
  page?: number;
  limit?: number;
}

export class AdminService {
  /**
   * Aggregates platform-wide dashboard analytics
   */
  public static async getDashboardStats(): Promise<DashboardStats> {
    const todayStart = new Date();
    todayStart.setUTCHours(0, 0, 0, 0);

    const [
      totalStudents,
      activeStudents,
      suspendedStudents,
      activeStudentsTodayList,
      totalUnits,
      publishedUnits,
      draftUnits,
      totalQuestions,
      totalAssessmentsTaken,
      totalAssessmentsPassed,
      avgScoreResult,
    ] = await Promise.all([
      UserModel.countDocuments({ role: 'student' }),
      UserModel.countDocuments({ role: 'student', status: 'active' }),
      UserModel.countDocuments({ role: 'student', status: 'suspended' }),
      AssessmentAttemptModel.distinct('userId', { completedAt: { $gte: todayStart } }),
      UnitModel.countDocuments({}),
      UnitModel.countDocuments({ isPublished: true }),
      UnitModel.countDocuments({ isPublished: false }),
      QuestionModel.countDocuments({ isPublished: true }),
      AssessmentAttemptModel.countDocuments({}),
      AssessmentAttemptModel.countDocuments({ passed: true }),
      AssessmentAttemptModel.aggregate([
        { $group: { _id: null, avgScore: { $avg: '$percentage' } } },
      ]),
    ]);

    const averageScore =
      avgScoreResult.length > 0
        ? Math.round(avgScoreResult[0].avgScore * 10) / 10
        : 0;

    const passRate =
      totalAssessmentsTaken > 0
        ? Math.round((totalAssessmentsPassed / totalAssessmentsTaken) * 100 * 10) / 10
        : 0;

    return {
      students: {
        total: totalStudents,
        active: activeStudents,
        suspended: suspendedStudents,
        activeToday: activeStudentsTodayList.length,
      },
      curriculum: {
        totalUnits,
        publishedUnits,
        draftUnits,
        totalQuestions,
      },
      assessments: {
        totalTaken: totalAssessmentsTaken,
        totalPassed: totalAssessmentsPassed,
        passRate,
        averageScore,
      },
    };
  }

  /**
   * Validates a question bank file without persisting it to the database
   */
  public static previewQuestionBank(rawJson: unknown) {
    const parsed = QuestionBankFileSchema.safeParse(rawJson);

    if (!parsed.success) {
      return {
        valid: false,
        errors: parsed.error.issues.map((i) => ({
          path: i.path.join('.'),
          message: i.message,
        })),
      };
    }

    const data: QuestionBankFile = parsed.data;
    const diffCount = { easy: 0, medium: 0, challenging: 0 };
    for (const q of data.questions) {
      diffCount[q.difficulty]++;
    }

    return {
      valid: true,
      unit: {
        grade: data.grade,
        subject: data.subject,
        unitNumber: data.unitNumber,
        unitTitle: data.unitTitle,
        questionCount: data.questions.length,
        difficultyDistribution: diffCount,
      },
    };
  }

  /**
   * Persists an approved question bank unit and questions into the database
   */
  public static async importQuestionBank(
    rawJson: unknown,
    adminUserId: string
  ) {
    const parsed = QuestionBankFileSchema.safeParse(rawJson);

    if (!parsed.success) {
      throw new BadRequestError(
        `Invalid question bank payload: ${parsed.error.issues[0]?.message}`
      );
    }

    const data = parsed.data;

    // Resolve subject
    const subject = await SubjectModel.findOne({
      $or: [
        { code: data.subject.toUpperCase() },
        { name: new RegExp(`^${data.subject}$`, 'i') },
      ],
    });

    if (!subject) {
      throw new NotFoundError(`Subject '${data.subject}' not found`);
    }

    const subjectCode = subject.code;
    const unitCode = `${subjectCode}-G${String(data.grade).padStart(2, '0')}-U${String(
      data.unitNumber
    ).padStart(2, '0')}`;

    // Upsert unit
    const unitDoc = await UnitModel.findOneAndUpdate(
      { grade: data.grade, subjectCode, unitNumber: data.unitNumber },
      {
        $set: {
          subjectId: subject._id,
          title: data.unitTitle.trim(),
          code: unitCode,
          status: 'published',
          isPublished: true,
          questionCount: 15,
        },
      },
      { upsert: true, new: true }
    );

    // Upsert questions
    const questionOps = data.questions.map((q) => ({
      updateOne: {
        filter: { externalId: q.id },
        update: {
          $set: {
            unitId: unitDoc._id,
            unitCode,
            type: 'multiple_choice',
            difficulty: q.difficulty,
            question: q.question.trim(),
            options: q.options,
            sourceReference: q.sourceReference,
            isPublished: true,
          },
        },
        upsert: true,
      },
    }));

    await QuestionModel.bulkWrite(questionOps as any);

    // Retrieve saved question IDs
    const savedQuestions = await QuestionModel.find({
      externalId: { $in: data.questions.map((q) => q.id) },
    });
    const qMap = new Map(savedQuestions.map((q) => [q.externalId, q._id]));

    // Upsert isolated answer keys
    const answerKeyOps = data.questions.map((q) => ({
      updateOne: {
        filter: { externalId: q.id },
        update: {
          $set: {
            questionId: qMap.get(q.id),
            correctOptionId: q.correctOptionId,
            explanation: q.explanation.trim(),
          },
        },
        upsert: true,
      },
    }));

    await AnswerKeyModel.bulkWrite(answerKeyOps as any);

    AuditService.record({
      action: 'QUESTION_BANK_IMPORTED',
      resource: 'units',
      resourceId: unitDoc._id.toString(),
      userId: adminUserId,
      details: {
        unitCode,
        questionsCount: data.questions.length,
      },
    });

    return {
      unitId: unitDoc._id.toString(),
      unitCode,
      title: unitDoc.title,
      questionsImported: data.questions.length,
      status: unitDoc.status,
    };
  }

  /**
   * Toggles unit publication status (draft <-> published)
   */
  public static async updateUnitStatus(
    unitId: string,
    status: PublicationStatus,
    adminUserId: string
  ): Promise<IUnit> {
    let unit = null;
    if (Types.ObjectId.isValid(unitId)) {
      unit = await UnitModel.findById(unitId);
    }
    if (!unit) {
      unit = await UnitModel.findOne({ code: unitId.toUpperCase() });
    }

    if (!unit) {
      throw new NotFoundError(`Unit '${unitId}' not found`);
    }

    if (status === 'published') {
      const qCount = await QuestionModel.countDocuments({
        unitId: unit._id,
        isPublished: true,
      });

      if (qCount < 15) {
        throw new BadRequestError(
          `Cannot publish unit '${unit.code}': Only ${qCount} questions found (15 required)`
        );
      }
      unit.isPublished = true;
      unit.questionCount = qCount;
    } else {
      unit.isPublished = false;
    }

    unit.status = status;
    await unit.save();

    AuditService.record({
      action: 'UNIT_STATUS_UPDATED',
      resource: 'units',
      resourceId: unit._id.toString(),
      userId: adminUserId,
      details: { unitCode: unit.code, newStatus: status },
    });

    return unit;
  }

  /**
   * Lists students with search, filters, and pagination
   */
  public static async listStudents(options: StudentFilterOptions) {
    const page = options.page && options.page > 0 ? options.page : 1;
    const limit = options.limit && options.limit > 0 ? options.limit : 20;
    const skip = (page - 1) * limit;

    const filter: Record<string, any> = { role: 'student' };

    if (options.grade) {
      filter.grade = options.grade;
    }
    if (options.stream) {
      filter.stream = options.stream;
    }
    if (options.status) {
      filter.status = options.status;
    }
    if (options.search) {
      const regex = new RegExp(options.search, 'i');
      filter.$or = [
        { acedexId: regex },
        { phone: regex },
        { displayName: regex },
        { email: regex },
      ];
    }

    const [students, total] = await Promise.all([
      UserModel.find(filter)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .select('-pinHash')
        .lean(),
      UserModel.countDocuments(filter),
    ]);

    return {
      items: students.map((s) => ({
        id: s._id.toString(),
        acedexId: s.acedexId,
        displayName: s.displayName,
        phone: s.phone,
        email: s.email,
        gender: s.gender,
        grade: s.grade,
        stream: s.stream,
        status: s.status,
        createdAt: s.createdAt.toISOString(),
      })),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Suspends or activates a student account
   */
  public static async updateStudentStatus(
    studentId: string,
    status: 'active' | 'suspended',
    adminUserId: string
  ): Promise<IUser> {
    let student = null;
    if (Types.ObjectId.isValid(studentId)) {
      student = await UserModel.findById(studentId);
    }
    if (!student) {
      student = await UserModel.findOne({ acedexId: studentId.toUpperCase() });
    }

    if (!student) {
      throw new NotFoundError(`Student '${studentId}' not found`);
    }

    student.status = status;
    await student.save();

    AuditService.record({
      action: 'STUDENT_STATUS_UPDATED',
      resource: 'users',
      resourceId: student._id.toString(),
      userId: adminUserId,
      details: { studentAcedexId: student.acedexId, newStatus: status },
    });

    return student;
  }

  /**
   * Lists system audit logs
   */
  public static async listAuditLogs(options: AuditLogFilterOptions) {
    const page = options.page && options.page > 0 ? options.page : 1;
    const limit = options.limit && options.limit > 0 ? options.limit : 20;
    const skip = (page - 1) * limit;

    const filter: Record<string, any> = {};

    if (options.action) {
      filter.action = options.action;
    }
    if (options.resource) {
      filter.resource = options.resource;
    }
    if (options.userId) {
      filter.userId = options.userId;
    }

    const [logs, total] = await Promise.all([
      AuditLogModel.find(filter)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      AuditLogModel.countDocuments(filter),
    ]);

    return {
      items: logs.map((l) => ({
        id: l._id.toString(),
        userId: l.userId ? l.userId.toString() : undefined,
        userEmail: l.userEmail,
        action: l.action,
        resource: l.resource,
        resourceId: l.resourceId,
        details: l.details,
        ipAddress: l.ipAddress,
        userAgent: l.userAgent,
        timestamp: (l.createdAt || new Date()).toISOString(),
      })),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}
