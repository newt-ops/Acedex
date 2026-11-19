import { Document, Schema, Model } from 'mongoose';
import { getCollectorDb } from '../../../config/collector-database';

export type CollectorAuditAction =
  | 'LOGIN'
  | 'SUBMIT'
  | 'APPROVE'
  | 'REJECT'
  | 'EDIT_QUESTION'
  | 'EXPORT_JSON'
  | 'PROMOTE_TO_PROD';

export interface ICollectorAuditLogDoc extends Document {
  action: CollectorAuditAction;
  actorId: string;
  actorRole: 'student' | 'admin';
  targetUnitCode?: string;
  metadata?: Record<string, any>;
  ipAddress?: string;
  timestamp: Date;
}

export const CollectorAuditSchema = new Schema<ICollectorAuditLogDoc>(
  {
    action: {
      type: String,
      required: true,
      index: true,
    },
    actorId: {
      type: String,
      required: true,
      uppercase: true,
      trim: true,
      index: true,
    },
    actorRole: {
      type: String,
      enum: ['student', 'admin'],
      required: true,
    },
    targetUnitCode: {
      type: String,
      uppercase: true,
      trim: true,
      index: true,
    },
    metadata: {
      type: Schema.Types.Mixed,
    },
    ipAddress: {
      type: String,
    },
    timestamp: {
      type: Date,
      default: Date.now,
      index: true,
    },
  },
  {
    collection: 'audit_logs',
    timestamps: false,
  }
);

CollectorAuditSchema.index({ timestamp: -1 });
CollectorAuditSchema.index({ actorId: 1, action: 1 });

export function getCollectorAuditModel(): Model<ICollectorAuditLogDoc> {
  const db = getCollectorDb();
  if (db.models.CollectorAuditLog) {
    return db.models.CollectorAuditLog as Model<ICollectorAuditLogDoc>;
  }
  return db.model<ICollectorAuditLogDoc>('CollectorAuditLog', CollectorAuditSchema, 'audit_logs');
}

export const CollectorAuditModel = new Proxy({} as Model<ICollectorAuditLogDoc>, {
  get(_target, prop) {
    const model = getCollectorAuditModel();
    const value = (model as any)[prop];
    return typeof value === 'function' ? value.bind(model) : value;
  },
});
