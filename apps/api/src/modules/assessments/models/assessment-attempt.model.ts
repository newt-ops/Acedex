import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IGradedAnswerSubdoc {
  questionId: Types.ObjectId;
  externalId: string;
  selectedOptionId: 'A' | 'B' | 'C' | 'D' | null;
  correctOptionId: 'A' | 'B' | 'C' | 'D';
  isCorrect: boolean;
  explanation: string;
}

export interface IAssessmentAttemptDocument extends Document {
  userId: Types.ObjectId;
  unitId: Types.ObjectId;
  unitCode: string;
  attemptId: string;
  score: number;
  totalQuestions: number;
  percentage: number;
  passed: boolean;
  durationSeconds: number;
  answers: IGradedAnswerSubdoc[];
  status: 'completed' | 'abandoned';
  completedAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

const GradedAnswerSchema = new Schema<IGradedAnswerSubdoc>(
  {
    questionId: { type: Schema.Types.ObjectId, ref: 'Question', required: true },
    externalId: { type: String, required: true },
    selectedOptionId: { type: String, enum: ['A', 'B', 'C', 'D', null], default: null },
    correctOptionId: { type: String, enum: ['A', 'B', 'C', 'D'], required: true },
    isCorrect: { type: Boolean, required: true },
    explanation: { type: String, required: true },
  },
  { _id: false }
);

const AssessmentAttemptSchema = new Schema<IAssessmentAttemptDocument>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    unitId: { type: Schema.Types.ObjectId, ref: 'Unit', required: true, index: true },
    unitCode: { type: String, required: true, index: true },
    attemptId: { type: String, required: true, unique: true, index: true },
    score: { type: Number, required: true, min: 0 },
    totalQuestions: { type: Number, required: true, min: 1 },
    percentage: { type: Number, required: true, min: 0, max: 100 },
    passed: { type: Boolean, required: true, index: true },
    durationSeconds: { type: Number, default: 0, min: 0 },
    answers: { type: [GradedAnswerSchema], required: true },
    status: {
      type: String,
      enum: ['completed', 'abandoned'],
      default: 'completed',
    },
    completedAt: { type: Date, default: Date.now },
  },
  {
    timestamps: true,
    collection: 'assessment_attempts',
  }
);

AssessmentAttemptSchema.index({ userId: 1, attemptId: 1 }, { unique: true });
AssessmentAttemptSchema.index({ userId: 1, unitId: 1, completedAt: -1 });
AssessmentAttemptSchema.index({ userId: 1, createdAt: -1 });

export const AssessmentAttemptModel = mongoose.model<IAssessmentAttemptDocument>(
  'AssessmentAttempt',
  AssessmentAttemptSchema
);
