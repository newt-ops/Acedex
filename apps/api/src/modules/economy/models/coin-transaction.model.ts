import mongoose, { Schema, Document, Types } from 'mongoose';
import { CoinTransactionType, EconomyStoreItemKey } from '@acedex/contracts';

export interface ICoinTransactionDocument extends Document {
  userId: Types.ObjectId;
  type: CoinTransactionType;
  amount: number;
  balanceAfter: number;
  reason: string;
  milestoneKey?: string;
  itemKey?: EconomyStoreItemKey;
  metadata?: Record<string, unknown>;
  createdAt: Date;
}

const CoinTransactionSchema = new Schema<ICoinTransactionDocument>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    type: {
      type: String,
      enum: ['earn_welcome', 'earn_milestone', 'earn_ad', 'spend'],
      required: true,
    },
    amount: { type: Number, required: true },
    balanceAfter: { type: Number, required: true, min: 0 },
    reason: { type: String, required: true, trim: true },
    milestoneKey: { type: String },
    itemKey: { type: String },
    metadata: { type: Schema.Types.Mixed },
  },
  {
    timestamps: { createdAt: true, updatedAt: false },
    collection: 'coin_transactions',
  }
);

CoinTransactionSchema.index({ userId: 1, createdAt: -1 });
// Guarantee idempotent one-time milestone awards per student at the database level
CoinTransactionSchema.index(
  { userId: 1, milestoneKey: 1 },
  { unique: true, sparse: true }
);

export const CoinTransactionModel = mongoose.model<ICoinTransactionDocument>(
  'CoinTransaction',
  CoinTransactionSchema
);
