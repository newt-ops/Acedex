import mongoose, { Document, Schema } from 'mongoose';
import { RawQuestionItem, UnitSubmissionStatus } from '@acedex/contracts';

export interface ITempUnitSubmissionDoc extends Document {
  unitCode: string;
  subjectCode: string;
  grade: number;
  unitNumber: number;
  unitTitle: string;
  contributorId: string;
  questions: RawQuestionItem[];
  rawPastedText?: string;
  status: UnitSubmissionStatus;
  reviewNotes?: string;
  submittedAt: Date;
  reviewedAt?: Date;
  reviewedBy?: string;
  createdAt: Date;
  updatedAt: Date;
}

const TempUnitSubmissionSchema = new Schema<ITempUnitSubmissionDoc>(
  {
    unitCode: {
      type: String,
      required: true,
      unique: true,
      uppercase: true,
      trim: true,
      index: true,
    },
    subjectCode: {
      type: String,
      required: true,
      uppercase: true,
      trim: true,
      index: true,
    },
    grade: {
      type: Number,
      required: true,
      min: 9,
      max: 12,
      index: true,
    },
    unitNumber: {
      type: Number,
      required: true,
      min: 1,
    },
    unitTitle: {
      type: String,
      required: true,
      trim: true,
    },
    contributorId: {
      type: String,
      required: true,
      uppercase: true,
      trim: true,
      index: true,
    },
    questions: {
      type: [Schema.Types.Mixed] as any,
      required: true,
      validate: [
        (val: unknown[]) => Array.isArray(val) && val.length === 15,
        'Unit submission must contain exactly 15 questions',
      ],
    },
    rawPastedText: {
      type: String,
    },
    status: {
      type: String,
      enum: ['not_started', 'submitted', 'approved', 'rejected'],
      default: 'submitted',
      index: true,
    },
    reviewNotes: {
      type: String,
      trim: true,
    },
    submittedAt: {
      type: Date,
      default: Date.now,
    },
    reviewedAt: {
      type: Date,
    },
    reviewedBy: {
      type: String,
    },
  },
  {
    collection: 'temp_unit_submissions',
    timestamps: true,
  }
);

// Compound indexes for fast admin querying
TempUnitSubmissionSchema.index({ subjectCode: 1, status: 1 });
TempUnitSubmissionSchema.index({ grade: 1, subjectCode: 1 });

export const TempUnitSubmissionModel = mongoose.model<ITempUnitSubmissionDoc>(
  'TempUnitSubmission',
  TempUnitSubmissionSchema
);
