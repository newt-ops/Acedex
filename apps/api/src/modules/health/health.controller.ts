import { Request, Response } from 'express';
import { HealthService } from './health.service';
import { sendSuccess } from '../../common/utils/response';

export class HealthController {
  public static check(_req: Request, res: Response): Response {
    const health = HealthService.getHealth();
    const statusCode = health.status === 'unhealthy' ? 503 : 200;
    return sendSuccess(res, health, statusCode);
  }

  public static readiness(_req: Request, res: Response): Response {
    const isReady = HealthService.isReady();
    if (!isReady) {
      return res.status(503).json({
        success: false,
        status: 'not_ready',
        message: 'Database connection is not ready',
      });
    }

    return res.status(200).json({
      success: true,
      status: 'ready',
    });
  }
}
