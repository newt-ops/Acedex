import { Document, Schema, Model } from 'mongoose';
import { getCollectorDb } from '../../../config/collector-database';

export interface IContributorStats {
  totalUnits: number;
  submittedUnits: number;
  approvedUnits: number;
  rejectedUnits: number;
}

export interface ICollectorContributorDoc extends Document {
  contributorId: string;
  name: string;
  subjectCode: string;
  subjectName: string;
  role: 'student' | 'admin';
  isActive: boolean;
  stats?: IContributorStats;
  lastActiveAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export const CollectorContributorSchema = new Schema<ICollectorContributorDoc>(
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
    isActive: {
      type: Boolean,
      default: true,
    },
    stats: {
      totalUnits: { type: Number, default: 0 },
      submittedUnits: { type: Number, default: 0 },
      approvedUnits: { type: Number, default: 0 },
      rejectedUnits: { type: Number, default: 0 },
    },
    lastActiveAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    collection: 'contributors',
    timestamps: true,
  }
);

/**
 * Accessor for the Contributor model bound strictly to the isolated acedex_collector database.
 */
export function getContributorModel(): Model<ICollectorContributorDoc> {
  const db = getCollectorDb();
  if (db.models.Contributor) {
    return db.models.Contributor as Model<ICollectorContributorDoc>;
  }
  return db.model<ICollectorContributorDoc>('Contributor', CollectorContributorSchema, 'contributors');
}

// Export a proxy model so existing `ContributorModel.findOne(...)` calls work seamlessly
export const ContributorModel = new Proxy({} as Model<ICollectorContributorDoc>, {
  get(_target, prop) {
    const model = getContributorModel();
    const value = (model as any)[prop];
    return typeof value === 'function' ? value.bind(model) : value;
  },
});
