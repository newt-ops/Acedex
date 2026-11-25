import mongoose, { Schema, Document } from 'mongoose';

export interface IAdConfigDocument extends Document {
  singletonId: string;
  isAdsEnabled: boolean;
  androidGameId: string;
  iosGameId: string;
  androidPlacement: string;
  iosPlacement: string;
  policies: {
    streakRepair: {
      enabled: boolean;
      cooldownHours: number;
    };
    examAccess: {
      enabled: boolean;
      ticketsPerAd: number;
      starterTickets: number;
    };
    offlinePack: {
      enabled: boolean;
      durationHours: number; // 24 hours per user specification
    };
    bonusCoins?: {
      enabled: boolean;
      coinsPerAd: number;
      dailyLimit: number;
    };
  };
  updatedAt: Date;
  createdAt: Date;
}

const AdConfigSchema = new Schema<IAdConfigDocument>(
  {
    singletonId: { type: String, default: 'global_ad_config', unique: true, index: true },
    isAdsEnabled: { type: Boolean, default: true },
    androidGameId: { type: String, default: '6220248' },
    iosGameId: { type: String, default: '6220249' },
    androidPlacement: { type: String, default: 'Reward_Android_Acedex' },
    iosPlacement: { type: String, default: 'Rewarded_iOS' },
    policies: {
      streakRepair: {
        enabled: { type: Boolean, default: true },
        cooldownHours: { type: Number, default: 24 },
      },
      examAccess: {
        enabled: { type: Boolean, default: true },
        ticketsPerAd: { type: Number, default: 1 },
        starterTickets: { type: Number, default: 1 },
      },
      offlinePack: {
        enabled: { type: Boolean, default: true },
        durationHours: { type: Number, default: 24 }, // exactly 24 hours
      },
      bonusCoins: {
        enabled: { type: Boolean, default: true },
        coinsPerAd: { type: Number, default: 10 },
        dailyLimit: { type: Number, default: 5 },
      },
    },
  },
  {
    timestamps: true,
    collection: 'ad_configs',
  }
);

export const AdConfigModel = mongoose.model<IAdConfigDocument>(
  'AdConfig',
  AdConfigSchema
);
