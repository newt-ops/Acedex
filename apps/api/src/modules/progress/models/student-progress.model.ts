import mongoose, { Schema, Document, Types } from 'mongoose';
import { StudyStatus } from '@acedex/contracts';

export interface IProgressUnitSubdoc {
  unitId: Types.ObjectId;
  unitCode: string;
  subjectCode: string;
  grade: number;
  studyStatus: StudyStatus;
  isStudyCompleted: boolean;
  studyCompletedAt?: Date;
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

export interface IUnlockedUnitSubdoc {
  unitId: Types.ObjectId;
  unitCode: string;
  expiresAt: Date;
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
    previousBrokenStreak: number;
    lastRepairedAt?: Date;
  };
  examAccess: {
    ticketsAvailable: number;
    totalAdsWatched: number;
  };
  offlineAccess: {
    unlockedUnits: IUnlockedUnitSubdoc[];
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
    studyStatus: {
      type: String,
      enum: ['not_started', 'in_progress', 'completed'],
      default: 'not_started',
    },
    isStudyCompleted: { type: Boolean, default: false },
    studyCompletedAt: { type: Date },
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

const UnlockedUnitSchema = new Schema<IUnlockedUnitSubdoc>(
  {
    unitId: { type: Schema.Types.ObjectId, ref: 'Unit', required: true },
    unitCode: { type: String, required: true },
    expiresAt: { type: Date, required: true },
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
      previousBrokenStreak: { type: Number, default: 0 },
      lastRepairedAt: { type: Date },
    },
    examAccess: {
      ticketsAvailable: { type: Number, default: 1 },
      totalAdsWatched: { type: Number, default: 0 },
    },
    offlineAccess: {
      unlockedUnits: { type: [UnlockedUnitSchema], default: [] },
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
