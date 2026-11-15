import mongoose, { Document, Model, Schema } from 'mongoose';
import { UserRole, AccountStatus, AuthProvider } from '@acedex/contracts';

export interface IUser extends Document {
  googleId?: string;
  email: string;
  displayName: string;
  avatarUrl?: string;
  role: UserRole;
  status: AccountStatus;
  authProvider: AuthProvider;
  lastLoginAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const UserSchema = new Schema<IUser>(
  {
    googleId: {
      type: String,
      unique: true,
      sparse: true,
      index: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
      index: true,
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
      enum: ['google'],
      default: 'google',
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
        return ret;
      },
    },
  }
);

export const UserModel: Model<IUser> =
  mongoose.models.User || mongoose.model<IUser>('User', UserSchema);
