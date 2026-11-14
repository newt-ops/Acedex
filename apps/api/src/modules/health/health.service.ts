import { HealthCheckResponse } from '@acedex/contracts';
import { getDatabaseStatus } from '../../config/database';
import { env } from '../../config/env';

export class HealthService {
  public static getHealth(): HealthCheckResponse {
    const dbStatus = getDatabaseStatus();
    const mem = process.memoryUsage();

    let status: HealthCheckResponse['status'] = 'healthy';
    if (!dbStatus.connected) {
      status = env.NODE_ENV === 'production' ? 'unhealthy' : 'degraded';
    }

    return {
      status,
      timestamp: new Date().toISOString(),
      uptimeSeconds: Math.floor(process.uptime()),
      environment: env.NODE_ENV,
      version: '1.0.0',
      database: dbStatus,
      memory: {
        heapUsedMB: Math.round((mem.heapUsed / 1024 / 1024) * 100) / 100,
        heapTotalMB: Math.round((mem.heapTotal / 1024 / 1024) * 100) / 100,
        rssMB: Math.round((mem.rss / 1024 / 1024) * 100) / 100,
      },
    };
  }

  public static isReady(): boolean {
    const dbStatus = getDatabaseStatus();
    // In production, server is ready only when database connection is live
    if (env.NODE_ENV === 'production') {
      return dbStatus.connected;
    }
    return true;
  }
}
