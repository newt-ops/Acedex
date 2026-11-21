import mongoose, { Document, Model, Schema } from 'mongoose';
import {
  UserRole,
  AccountStatus,
  AuthProvider,
  StudentGender,
  StudentStream,
} from '@acedex/contracts';

export interface IUser extends Document {
  acedexId: string;
  email?: string;
  phone?: string;
  pinHash?: string;
  displayName: string;
  avatarUrl?: string;
  gender?: StudentGender;
  grade?: number;
  stream?: StudentStream | null;
  role: UserRole;
  status: AccountStatus;
  authProvider: AuthProvider;
  lastLoginAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const UserSchema = new Schema<IUser>(
  {
    acedexId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true,
    },
    email: {
      type: String,
      unique: true,
      sparse: true,
      lowercase: true,
      trim: true,
      index: true,
    },
    phone: {
      type: String,
      unique: true,
      sparse: true,
      trim: true,
      index: true,
    },
    pinHash: {
      type: String,
      select: false,
    },
    displayName: {
      type: String,
      required: true,
      trim: true,
    },
    avatarUrl: {
      type: String,
      trim: true,
    },
    gender: {
      type: String,
      enum: ['male', 'female'],
    },
    grade: {
      type: Number,
      enum: [9, 10, 11, 12],
    },
    stream: {
      type: String,
      enum: ['natural', 'social'],
      default: null,
    },
    role: {
      type: String,
      enum: ['student', 'content_manager', 'admin', 'super_admin'],
      default: 'student',
      index: true,
    },
    status: {
      type: String,
      enum: ['active', 'suspended', 'pending_deletion'],
      default: 'active',
      index: true,
    },
    authProvider: {
      type: String,
      enum: ['phone'],
      required: true,
      default: 'phone',
    },
    lastLoginAt: {
      type: Date,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform(_doc, ret: Record<string, any>) {
        ret.id = ret._id ? ret._id.toString() : undefined;
        delete ret._id;
        delete ret.__v;
        delete ret.pinHash;
        return ret;
      },
    },
  }
);

UserSchema.pre('validate', async function () {
  if (!this.acedexId) {
    this.acedexId = await generateUniqueAcedexId();
  }
});

/**
 * Generates a unique branded ACEDEX Student Candidate ID in format ACX-YY-XXXX (e.g. ACX-26-5480)
 */
export async function generateUniqueAcedexId(preferredId?: string): Promise<string> {
  const currentYear = new Date().getFullYear().toString().slice(-2); // e.g. '26'

  // If a valid preferred candidate ID was provided from onboarding draft (e.g. ACX-26-5480)
  if (preferredId && /^ACX-\d{2}-\d{4}$/.test(preferredId)) {
    const exists = await UserModel.exists({ acedexId: preferredId });
    if (!exists) {
      return preferredId;
    }
  }

  let attempts = 0;
  while (attempts < 10) {
    const randomSuffix = Math.floor(1000 + Math.random() * 9000); // 4 digits (1000-9999)
    const candidateId = `ACX-${currentYear}-${randomSuffix}`;
    const exists = await UserModel.exists({ acedexId: candidateId });
    if (!exists) {
      return candidateId;
    }
    attempts++;
  }
  // Fallback to padded timestamp slice if multiple collisions occur
  const timestampSuffix = (Date.now() % 10000).toString().padStart(4, '0');
  return `ACX-${currentYear}-${timestampSuffix}`;
}

export const UserModel: Model<IUser> =
  mongoose.models.User || mongoose.model<IUser>('User', UserSchema);
