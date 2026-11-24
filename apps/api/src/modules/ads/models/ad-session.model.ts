import mongoose, { Schema, Document, Types } from 'mongoose';
import { RewardType, AdPlatform } from '@acedex/contracts';

export type AdSessionStatus = 'pending' | 'verified' | 'claimed' | 'expired';

export interface IAdSessionDocument extends Document {
  userId: Types.ObjectId;
  adSessionId: string;
  rewardType: RewardType;
  targetUnitId?: Types.ObjectId;
  targetUnitCode?: string;
  platform: AdPlatform;
  status: AdSessionStatus;
  unityOrderId?: string;
  startedAt: Date;
  expiresAt: Date;
  claimedAt?: Date;
  durationSeconds?: number;
  usedForAiPlan?: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const AdSessionSchema = new Schema<IAdSessionDocument>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    adSessionId: { type: String, required: true, unique: true, index: true },
    rewardType: {
      type: String,
      enum: ['streak_repair', 'exam_access', 'offline_pack', 'ai_study_plan'],
      required: true,
      index: true,
    },
    targetUnitId: { type: Schema.Types.ObjectId, ref: 'Unit' },
    targetUnitCode: { type: String },
    platform: { type: String, enum: ['android', 'ios'], default: 'android' },
    status: {
      type: String,
      enum: ['pending', 'verified', 'claimed', 'expired'],
      default: 'pending',
      index: true,
    },
    unityOrderId: { type: String },
    startedAt: { type: Date, default: Date.now },
    expiresAt: { type: Date, required: true },
    claimedAt: { type: Date },
    durationSeconds: { type: Number, default: 0 },
    usedForAiPlan: { type: Boolean, default: false },
  },
  {
    timestamps: true,
    collection: 'ad_sessions',
  }
);

AdSessionSchema.index({ userId: 1, createdAt: -1 });
AdSessionSchema.index({ unityOrderId: 1 }, { unique: true, sparse: true });

export const AdSessionModel = mongoose.model<IAdSessionDocument>(
  'AdSession',
  AdSessionSchema
);
