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
  googleId?: string;
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
    googleId: {
      type: String,
      unique: true,
      sparse: true,
      index: true,
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
      enum: ['google', 'phone'],
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
 * Generates a unique branded ACEDEX Student ID (e.g. ACEDEX-839201)
 */
export async function generateUniqueAcedexId(): Promise<string> {
  let attempts = 0;
  while (attempts < 10) {
    const randomSuffix = Math.floor(100000 + Math.random() * 900000);
    const candidateId = `ACEDEX-${randomSuffix}`;
    const exists = await UserModel.exists({ acedexId: candidateId });
    if (!exists) {
      return candidateId;
    }
    attempts++;
  }
  // Fallback to timestamp suffix if multiple collisions occur
  return `ACEDEX-${Date.now().toString().slice(-6)}`;
}

export const UserModel: Model<IUser> =
  mongoose.models.User || mongoose.model<IUser>('User', UserSchema);
