import { AuditLogModel } from './audit-log.model';
import { logger } from '../../common/utils/logger';

export interface RecordAuditParams {
  userId?: string;
  userEmail?: string;
  action: string;
  resource: string;
  resourceId?: string;
  details?: Record<string, unknown>;
  ipAddress?: string;
  userAgent?: string;
}

export class AuditService {
  public static async record(params: RecordAuditParams): Promise<void> {
    try {
      await AuditLogModel.create({
        userId: params.userId,
        userEmail: params.userEmail,
        action: params.action,
        resource: params.resource,
        resourceId: params.resourceId,
        details: params.details,
        ipAddress: params.ipAddress,
        userAgent: params.userAgent,
      });
      logger.info(
        {
          action: params.action,
          resource: params.resource,
          userId: params.userId,
          userEmail: params.userEmail,
        },
        `[AUDIT] ${params.action} on ${params.resource}`
      );
    } catch (err) {
      // Audit logging errors should be logged but never crash the core application transaction
      logger.error({ err, params }, 'Failed to record audit log entry');
    }
  }
}
