import mongoose, { Document, Model, Schema, Types } from 'mongoose';
import { QuestionDifficulty, QuestionOption } from '@acedex/contracts';

export interface IQuestion extends Document {
  unitId: Types.ObjectId;
  unitCode: string;
  externalId: string;
  type: 'multiple_choice';
  difficulty: QuestionDifficulty;
  question: string;
  options: QuestionOption[];
  sourceReference?: string;
  isPublished: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const QuestionOptionSchema = new Schema(
  {
    id: {
      type: String,
      enum: ['A', 'B', 'C', 'D'],
      required: true,
    },
    text: {
      type: String,
      required: true,
      trim: true,
    },
  },
  { _id: false }
);

const QuestionSchema = new Schema<IQuestion>(
  {
    unitId: {
      type: Schema.Types.ObjectId,
      ref: 'Unit',
      required: true,
      index: true,
    },
    unitCode: {
      type: String,
      required: true,
      uppercase: true,
      trim: true,
      index: true,
    },
    externalId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true,
    },
    type: {
      type: String,
      enum: ['multiple_choice'],
      default: 'multiple_choice',
      required: true,
    },
    difficulty: {
      type: String,
      enum: ['easy', 'medium', 'challenging'],
      required: true,
      index: true,
    },
    question: {
      type: String,
      required: true,
      trim: true,
    },
    options: {
      type: [QuestionOptionSchema],
      required: true,
      validate: [
        (val: QuestionOption[]) => val.length === 4,
        'Question must have exactly 4 options (A, B, C, D)',
      ],
    },
    sourceReference: {
      type: String,
      trim: true,
    },
    isPublished: {
      type: Boolean,
      default: true,
      index: true,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform(_doc, ret: Record<string, any>) {
        ret.id = ret._id ? ret._id.toString() : undefined;
        delete ret._id;
        delete ret.__v;
        return ret;
      },
    },
  }
);

QuestionSchema.index({ unitId: 1, isPublished: 1 });

export const QuestionModel: Model<IQuestion> =
  mongoose.models.Question || mongoose.model<IQuestion>('Question', QuestionSchema);
