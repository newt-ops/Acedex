import mongoose, { Schema, Document } from 'mongoose';
import {
  SubjectStreamCategory,
  TopicReadingReference,
  TopicLearningStep,
} from '@acedex/contracts';

export interface ITopicModuleDocument extends Document {
  moduleId: string;
  subjectCode: string;
  subjectName: string;
  streamCategory: SubjectStreamCategory;
  moduleNumber: number;
  phase: string;
  title: string;
  rationale: string;
  references: TopicReadingReference[];
  sequence: TopicLearningStep[];
  prerequisites: string[];
  masteryCheckpoint: string;
  sourceFile: string;
  createdAt: Date;
  updatedAt: Date;
}

const TopicReferenceSchema = new Schema<TopicReadingReference>(
  {
    grade: { type: Number, required: true },
    unitNumber: { type: Number, required: true },
    unitCode: { type: String, required: true },
    unitTitle: { type: String, required: true },
    pages: { type: String, default: '' },
  },
  { _id: false }
);

const TopicLearningStepSchema = new Schema<TopicLearningStep>(
  {
    stepNumber: { type: Number, required: true },
    text: { type: String, required: true },
    grade: { type: Number },
    unitNumber: { type: Number },
    unitCode: { type: String },
    pages: { type: String },
  },
  { _id: false }
);

const TopicModuleSchema = new Schema<ITopicModuleDocument>(
  {
    moduleId: { type: String, required: true, unique: true, index: true },
    subjectCode: { type: String, required: true, uppercase: true, trim: true, index: true },
    subjectName: { type: String, required: true },
    streamCategory: {
      type: String,
      enum: ['natural', 'social', 'common'],
      default: 'common',
      index: true,
    },
    moduleNumber: { type: Number, required: true },
    phase: { type: String, default: 'Core Mastery' },
    title: { type: String, required: true },
    rationale: { type: String, default: '' },
    references: { type: [TopicReferenceSchema], default: [] },
    sequence: { type: [TopicLearningStepSchema], default: [] },
    prerequisites: { type: [String], default: [] },
    masteryCheckpoint: { type: String, default: '' },
    sourceFile: { type: String, default: '' },
  },
  {
    timestamps: true,
    collection: 'topic_modules',
  }
);

TopicModuleSchema.index({ subjectCode: 1, moduleNumber: 1 }, { unique: true });

export const TopicModuleModel = mongoose.model<ITopicModuleDocument>(
  'TopicModule',
  TopicModuleSchema
);
