import { Schema, Document, Model } from 'mongoose';
import { getNotesDb } from '../../../config/notes-database';
import { UnitSubmissionStatus } from '@acedex/contracts';

export interface INoteFormula {
  label: string;
  expr: string;
}

export interface INoteDefinition {
  term: string;
  definition: string;
}

export interface INoteSubmission extends Document {
  grade: number;
  subject: string;
  subjectCode: string;
  unitNumber: number;
  unitCode: string;
  unitTitle: string;
  examWeight?: string;
  summaryPoints: string[];
  formulas: INoteFormula[];
  examTip: string;
  keyDefinitions: INoteDefinition[];
  eueeFocusTopics: string[];
  status: UnitSubmissionStatus;
  contributorId: string;
  rawPastedText?: string;
  reviewNotes?: string;
  submittedAt: Date;
  reviewedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const NoteFormulaSchema = new Schema<INoteFormula>(
  {
    label: { type: String, required: true, trim: true },
    expr: { type: String, required: true, trim: true },
  },
  { _id: false }
);

const NoteDefinitionSchema = new Schema<INoteDefinition>(
  {
    term: { type: String, required: true, trim: true },
    definition: { type: String, required: true, trim: true },
  },
  { _id: false }
);

const NoteSubmissionSchema = new Schema<INoteSubmission>(
  {
    grade: {
      type: Number,
      required: true,
      enum: [9, 10, 11, 12],
      index: true,
    },
    subject: {
      type: String,
      required: true,
      trim: true,
    },
    subjectCode: {
      type: String,
      required: true,
      uppercase: true,
      trim: true,
      index: true,
    },
    unitNumber: {
      type: Number,
      required: true,
      min: 1,
    },
    unitCode: {
      type: String,
      required: true,
      unique: true,
      uppercase: true,
      trim: true,
      index: true,
    },
    unitTitle: {
      type: String,
      required: true,
      trim: true,
    },
    examWeight: {
      type: String,
      trim: true,
    },
    summaryPoints: {
      type: [String],
      default: [],
    },
    formulas: {
      type: [NoteFormulaSchema],
      default: [],
    },
    examTip: {
      type: String,
      trim: true,
      default: '',
    },
    keyDefinitions: {
      type: [NoteDefinitionSchema],
      default: [],
    },
    eueeFocusTopics: {
      type: [String],
      default: [],
    },
    status: {
      type: String,
      enum: ['not_started', 'submitted', 'approved', 'rejected'],
      default: 'not_started',
      index: true,
    },
    contributorId: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },
    rawPastedText: {
      type: String,
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
  },
  {
    timestamps: true,
    collection: 'note_submissions',
  }
);

NoteSubmissionSchema.index({ grade: 1, subjectCode: 1, unitNumber: 1 });
NoteSubmissionSchema.index({ status: 1, subjectCode: 1 });

export function getNoteSubmissionModel(): Model<INoteSubmission> {
  const db = getNotesDb();
  return db.models.NoteSubmission || db.model<INoteSubmission>('NoteSubmission', NoteSubmissionSchema);
}
