import { Document, Schema, Model } from 'mongoose';
import { RawQuestionItem, UnitSubmissionStatus } from '@acedex/contracts';
import { getCollectorDb } from '../../../config/collector-database';

export interface ISubmissionHistoryItem {
  version: number;
  submittedAt: Date;
  contributorId: string;
  questionsCount: number;
  status: string;
  notes?: string;
}

export interface ICollectorSubmissionDoc extends Document {
  unitCode: string;
  subjectCode: string;
  grade: number;
  unitNumber: number;
  unitTitle: string;
  contributorId: string;
  questions: RawQuestionItem[];
  rawPastedText?: string;
  status: UnitSubmissionStatus;
  version: number;
  reviewNotes?: string;
  reviewedBy?: string;
  reviewedAt?: Date;
  submittedAt: Date;
  history?: ISubmissionHistoryItem[];
  createdAt: Date;
  updatedAt: Date;
}

export const CollectorSubmissionSchema = new Schema<ICollectorSubmissionDoc>(
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
    version: {
      type: Number,
      default: 1,
    },
    reviewNotes: {
      type: String,
      trim: true,
    },
    reviewedBy: {
      type: String,
    },
    reviewedAt: {
      type: Date,
    },
    submittedAt: {
      type: Date,
      default: Date.now,
    },
    history: {
      type: [
        {
          version: Number,
          submittedAt: Date,
          contributorId: String,
          questionsCount: Number,
          status: String,
          notes: String,
        },
      ],
      default: [],
    },
  },
  {
    collection: 'unit_submissions',
    timestamps: true,
  }
);

// High performance compound indexes for fast query resolution
CollectorSubmissionSchema.index({ subjectCode: 1, status: 1 });
CollectorSubmissionSchema.index({ grade: 1, subjectCode: 1 });
CollectorSubmissionSchema.index({ status: 1, submittedAt: -1 });

/**
 * Accessor for the UnitSubmission model bound strictly to the isolated acedex_collector database.
 */
export function getUnitSubmissionModel(): Model<ICollectorSubmissionDoc> {
  const db = getCollectorDb();
  if (db.models.UnitSubmission) {
    return db.models.UnitSubmission as Model<ICollectorSubmissionDoc>;
  }
  return db.model<ICollectorSubmissionDoc>('UnitSubmission', CollectorSubmissionSchema, 'unit_submissions');
}

// Proxy model for seamless backward compatibility
export const UnitSubmissionModel = new Proxy({} as Model<ICollectorSubmissionDoc>, {
  get(_target, prop) {
    const model = getUnitSubmissionModel();
    const value = (model as any)[prop];
    return typeof value === 'function' ? value.bind(model) : value;
  },
});
