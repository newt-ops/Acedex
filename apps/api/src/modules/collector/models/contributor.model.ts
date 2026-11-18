import mongoose, { Document, Schema } from 'mongoose';

export interface IContributorDoc extends Document {
  contributorId: string;
  name: string;
  subjectCode: string;
  subjectName: string;
  role: 'student' | 'admin';
  lastActiveAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const ContributorSchema = new Schema<IContributorDoc>(
  {
    contributorId: {
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
      trim: true,
    },
    subjectCode: {
      type: String,
      required: true,
      uppercase: true,
      trim: true,
      index: true,
    },
    subjectName: {
      type: String,
      required: true,
      trim: true,
    },
    role: {
      type: String,
      enum: ['student', 'admin'],
      default: 'student',
    },
    lastActiveAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    collection: 'temp_contributors',
    timestamps: true,
  }
);

export const ContributorModel = mongoose.model<IContributorDoc>(
  'TempContributor',
  ContributorSchema
);
