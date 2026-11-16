import mongoose, { Document, Model, Schema, Types } from 'mongoose';
import { PublicationStatus } from '@acedex/contracts';

export interface IUnit extends Document {
  grade: number;
  subjectId: Types.ObjectId;
  subjectCode: string;
  unitNumber: number;
  title: string;
  code: string;
  status: PublicationStatus;
  isPublished: boolean;
  questionCount: number;
  createdAt: Date;
  updatedAt: Date;
}

const UnitSchema = new Schema<IUnit>(
  {
    grade: {
      type: Number,
      required: true,
      enum: [9, 10, 11, 12],
      index: true,
    },
    subjectId: {
      type: Schema.Types.ObjectId,
      ref: 'Subject',
      required: true,
      index: true,
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
    title: {
      type: String,
      required: true,
      trim: true,
    },
    code: {
      type: String,
      required: true,
      unique: true,
      uppercase: true,
      trim: true,
      index: true,
    },
    status: {
      type: String,
      enum: ['draft', 'in_review', 'published', 'archived'],
      default: 'draft',
      index: true,
    },
    isPublished: {
      type: Boolean,
      default: false,
      index: true,
    },
    questionCount: {
      type: Number,
      default: 0,
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

UnitSchema.index({ grade: 1, subjectCode: 1, unitNumber: 1 }, { unique: true });
UnitSchema.index({ isPublished: 1, grade: 1 });

export const UnitModel: Model<IUnit> =
  mongoose.models.Unit || mongoose.model<IUnit>('Unit', UnitSchema);
