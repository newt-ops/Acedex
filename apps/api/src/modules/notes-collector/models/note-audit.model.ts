import { Schema, Document, Model } from 'mongoose';
import { getNotesDb } from '../../../config/notes-database';

export interface INoteAudit extends Document {
  unitCode: string;
  action: 'submit' | 'approve' | 'reject' | 'sync';
  actorId: string;
  metadata?: Record<string, unknown>;
  createdAt: Date;
}

const NoteAuditSchema = new Schema<INoteAudit>(
  {
    unitCode: {
      type: String,
      required: true,
      uppercase: true,
      trim: true,
      index: true,
    },
    action: {
      type: String,
      required: true,
      enum: ['submit', 'approve', 'reject', 'sync'],
      index: true,
    },
    actorId: {
      type: String,
      required: true,
      trim: true,
    },
    metadata: {
      type: Schema.Types.Mixed,
      default: {},
    },
  },
  {
    timestamps: { createdAt: true, updatedAt: false },
    collection: 'note_audits',
  }
);

export function getNoteAuditModel(): Model<INoteAudit> {
  const db = getNotesDb();
  return db.models.NoteAudit || db.model<INoteAudit>('NoteAudit', NoteAuditSchema);
}
