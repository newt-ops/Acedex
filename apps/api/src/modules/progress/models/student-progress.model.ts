import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IProgressUnitSubdoc {
  unitId: Types.ObjectId;
  unitCode: string;
  subjectCode: string;
  grade: number;
  bestScore: number;
  bestPercentage: number;
  totalQuestions: number;
  passed: boolean;
  attemptsCount: number;
  lastAttemptAt: Date;
}

export interface ISubjectMasterySubdoc {
  subjectCode: string;
  unitsCompleted: number;
  totalUnits: number;
  masteryPercentage: number;
}

export interface IStudentProgressDocument extends Document {
  userId: Types.ObjectId;
  overallStats: {
    totalAssessmentsTaken: number;
    totalAssessmentsPassed: number;
    averageScore: number;
    totalTimeSpentSeconds: number;
  };
  streak: {
    currentStreak: number;
    longestStreak: number;
    lastActivityDate?: string; // YYYY-MM-DD
  };
  units: IProgressUnitSubdoc[];
  subjectMastery: ISubjectMasterySubdoc[];
  createdAt: Date;
  updatedAt: Date;
}

const ProgressUnitSchema = new Schema<IProgressUnitSubdoc>(
  {
    unitId: { type: Schema.Types.ObjectId, ref: 'Unit', required: true },
    unitCode: { type: String, required: true },
    subjectCode: { type: String, required: true },
    grade: { type: Number, required: true },
    bestScore: { type: Number, default: 0 },
    bestPercentage: { type: Number, default: 0 },
    totalQuestions: { type: Number, default: 15 },
    passed: { type: Boolean, default: false },
    attemptsCount: { type: Number, default: 0 },
    lastAttemptAt: { type: Date, default: Date.now },
  },
  { _id: false }
);

const SubjectMasterySchema = new Schema<ISubjectMasterySubdoc>(
  {
    subjectCode: { type: String, required: true },
    unitsCompleted: { type: Number, default: 0 },
    totalUnits: { type: Number, default: 0 },
    masteryPercentage: { type: Number, default: 0 },
  },
  { _id: false }
);

const StudentProgressSchema = new Schema<IStudentProgressDocument>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, unique: true, index: true },
    overallStats: {
      totalAssessmentsTaken: { type: Number, default: 0 },
      totalAssessmentsPassed: { type: Number, default: 0 },
      averageScore: { type: Number, default: 0 },
      totalTimeSpentSeconds: { type: Number, default: 0 },
    },
    streak: {
      currentStreak: { type: Number, default: 0 },
      longestStreak: { type: Number, default: 0 },
      lastActivityDate: { type: String, default: '' },
    },
    units: { type: [ProgressUnitSchema], default: [] },
    subjectMastery: { type: [SubjectMasterySchema], default: [] },
  },
  {
    timestamps: true,
    collection: 'student_progress',
  }
);

export const StudentProgressModel = mongoose.model<IStudentProgressDocument>(
  'StudentProgress',
  StudentProgressSchema
);
