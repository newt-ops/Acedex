import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import cookieParser from 'cookie-parser';
import { env } from './config/env';
import { requestLogger } from './middleware/request-logger';
import { notFoundHandler } from './middleware/not-found';
import { errorHandler } from './middleware/error.middleware';
import { v1Routes } from './routes/v1.routes';
import { HealthController } from './modules/health/health.controller';

export function createApp(): Application {
  const app = express();

  // 1. Security Headers
  app.use(helmet());

  // 2. Cross-Origin Resource Sharing
  const allowedOrigins = env.CORS_ORIGIN.split(',').map((origin) => origin.trim());
  app.use(
    cors({
      origin: (origin, callback) => {
        // Allow requests with no origin (e.g. mobile apps, curl, server-to-server)
        if (!origin) return callback(null, true);
        if (allowedOrigins.indexOf(origin) !== -1 || allowedOrigins.includes('*')) {
          return callback(null, true);
        }
        return callback(new Error(`Origin ${origin} not allowed by CORS`));
      },
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
    })
  );

  // 3. Request Parsers
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));
  app.use(cookieParser());

  // 4. Request Logging
  app.use(requestLogger);

  // 5. Cloud Platform Direct Health Check (Render/ALB)
  app.get('/health', HealthController.check);
  app.get('/ready', HealthController.readiness);

  // 6. Root Informational Endpoint
  app.get('/', (_req: Request, res: Response) => {
    res.json({
      name: 'Acedex API',
      description: 'EUEE Study Management and Assessment Platform API',
      version: '1.0.0',
      environment: env.NODE_ENV,
      endpoints: {
        health: '/health',
        apiV1: env.API_PREFIX,
      },
    });
  });

  // 7. Versioned API Routes (/api/v1)
  app.use(env.API_PREFIX, v1Routes);

  // 8. 404 Not Found Middleware
  app.use(notFoundHandler);

  // 9. Centralized Error Handler
  app.use(errorHandler);

  return app;
}
