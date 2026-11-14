import http from 'http';
import { createApp } from './app';
import { env } from './config/env';
import { connectDatabase, disconnectDatabase } from './config/database';
import { logger } from './common/utils/logger';

async function bootstrap() {
  logger.info({ environment: env.NODE_ENV }, 'Starting Acedex Backend Server...');

  // 1. Connect to Database (MongoDB Atlas)
  try {
    await connectDatabase();
  } catch (error) {
    logger.fatal({ error }, 'Failed to initialize database on startup');
    if (env.NODE_ENV === 'production') {
      process.exit(1);
    }
  }

  // 2. Instantiate Express App
  const app = createApp();
  const server = http.createServer(app);

  // 3. Start HTTP Server
  server.listen(env.PORT, () => {
    logger.info(`🚀 Acedex API server running on port ${env.PORT} in ${env.NODE_ENV} mode`);
    logger.info(`Health check available at http://localhost:${env.PORT}/health`);
    logger.info(`API v1 root available at http://localhost:${env.PORT}${env.API_PREFIX}`);
  });

  // 4. Graceful Shutdown Management
  const shutdown = async (signal: string) => {
    logger.info(`Received ${signal}. Initiating graceful shutdown...`);

    // Stop receiving new connections
    server.close(async () => {
      logger.info('HTTP server closed cleanly');

      try {
        await disconnectDatabase();
        logger.info('Acedex backend shutdown complete');
        process.exit(0);
      } catch (err) {
        logger.error({ err }, 'Error during database disconnection');
        process.exit(1);
      }
    });

    // Force exit if shutdown hangs beyond 10s
    setTimeout(() => {
      logger.error('Graceful shutdown timed out after 10s. Forcing exit.');
      process.exit(1);
    }, 10000).unref();
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));

  process.on('unhandledRejection', (reason: unknown) => {
    logger.fatal({ reason }, 'Unhandled Promise Rejection caught');
  });

  process.on('uncaughtException', (error: Error) => {
    logger.fatal({ error }, 'Uncaught Exception caught! Shutting down.');
    process.exit(1);
  });
}

bootstrap().catch((error) => {
  logger.fatal({ error }, 'Fatal error during server bootstrap');
  process.exit(1);
});
