import mongoose, { Document, Model, Schema } from 'mongoose';
import { SubjectStreamCategory } from '@acedex/contracts';

export interface ISubject extends Document {
  code: string;
  name: string;
  slug: string;
  order: number;
  grades: number[];
  streamCategory: SubjectStreamCategory;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const SubjectSchema = new Schema<ISubject>(
  {
    code: {
      type: String,
      required: true,
      unique: true,
      uppercase: true,
      trim: true,
      index: true,
    },
    name: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    slug: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
      index: true,
    },
    order: {
      type: Number,
      default: 0,
      index: true,
    },
    grades: {
      type: [Number],
      default: [9, 10, 11, 12],
    },
    streamCategory: {
      type: String,
      enum: ['natural', 'social', 'common'],
      required: true,
      default: 'common',
      index: true,
    },
    isActive: {
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

export const SubjectModel: Model<ISubject> =
  mongoose.models.Subject || mongoose.model<ISubject>('Subject', SubjectSchema);
