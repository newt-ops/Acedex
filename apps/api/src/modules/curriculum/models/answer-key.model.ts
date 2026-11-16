import mongoose, { Document, Model, Schema, Types } from 'mongoose';

export interface IAnswerKey extends Document {
  questionId: Types.ObjectId;
  externalId: string;
  correctOptionId: 'A' | 'B' | 'C' | 'D';
  explanation: string;
  createdAt: Date;
  updatedAt: Date;
}

const AnswerKeySchema = new Schema<IAnswerKey>(
  {
    questionId: {
      type: Schema.Types.ObjectId,
      ref: 'Question',
      required: true,
      unique: true,
      index: true,
    },
    externalId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true,
    },
    correctOptionId: {
      type: String,
      enum: ['A', 'B', 'C', 'D'],
      required: true,
    },
    explanation: {
      type: String,
      required: true,
      trim: true,
    },
  },
  {
    collection: 'answer_keys',
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

export const AnswerKeyModel: Model<IAnswerKey> =
  mongoose.models.AnswerKey ||
  mongoose.model<IAnswerKey>('AnswerKey', AnswerKeySchema, 'answer_keys');
