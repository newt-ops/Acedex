import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IBookmarkDocument extends Document {
  userId: Types.ObjectId;
  questionId: Types.ObjectId;
  externalId: string;
  unitId: Types.ObjectId;
  unitCode: string;
  subjectCode: string;
  grade: number;
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

const BookmarkSchema = new Schema<IBookmarkDocument>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    questionId: { type: Schema.Types.ObjectId, ref: 'Question', required: true, index: true },
    externalId: { type: String, required: true },
    unitId: { type: Schema.Types.ObjectId, ref: 'Unit', required: true },
    unitCode: { type: String, required: true },
    subjectCode: { type: String, required: true, uppercase: true, trim: true, index: true },
    grade: { type: Number, required: true, enum: [9, 10, 11, 12], index: true },
    notes: { type: String, maxlength: 500 },
  },
  {
    timestamps: true,
    collection: 'question_bookmarks',
  }
);

BookmarkSchema.index({ userId: 1, questionId: 1 }, { unique: true });
BookmarkSchema.index({ userId: 1, subjectCode: 1, grade: 1 });
BookmarkSchema.index({ userId: 1, createdAt: -1 });

export const BookmarkModel = mongoose.model<IBookmarkDocument>('Bookmark', BookmarkSchema);
