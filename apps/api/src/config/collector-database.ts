import mongoose, { Connection } from 'mongoose';
import { env } from './env';
import { logger } from '../common/utils/logger';

let collectorConnection: Connection | null = null;

/**
 * Returns the isolated database connection for all Question Collector resources.
 *
 * Defaults to using the dedicated 'acedex_collector' database on the same MongoDB Atlas cluster
 * via connection pooling (useDb with caching), or connects directly to COLLECTOR_MONGODB_URI
 * if a separate cluster URI is specified.
 */
export function getCollectorDb(): Connection {
  if (collectorConnection && collectorConnection.readyState === 1) {
    return collectorConnection;
  }

  // If a dedicated separate cluster URI is supplied in environment
  if (env.COLLECTOR_MONGODB_URI) {
    if (!collectorConnection) {
      logger.info({ uri: env.COLLECTOR_MONGODB_URI }, 'Creating dedicated MongoDB connection for Collector...');
      collectorConnection = mongoose.createConnection(env.COLLECTOR_MONGODB_URI, {
        maxPoolSize: 10,
        serverSelectionTimeoutMS: 30000,
      });

      collectorConnection.on('connected', () => {
        logger.info({ db: env.COLLECTOR_DB_NAME }, 'Collector dedicated DB connection established');
      });

      collectorConnection.on('error', (err) => {
        logger.error({ err }, 'Collector DB connection error');
      });
    }
    return collectorConnection;
  }

  // Primary shared connection pool: switch database context cleanly to 'acedex_collector'
  const targetDbName = env.COLLECTOR_DB_NAME || 'acedex_collector';
  collectorConnection = mongoose.connection.useDb(targetDbName, { useCache: true });

  logger.debug({ targetDb: targetDbName }, 'Acquired collector database handle via useDb');
  return collectorConnection;
}

/**
 * Ensures the collector database connection is active and ready
 */
export async function initCollectorDatabase(): Promise<Connection> {
  if (env.COLLECTOR_MONGODB_URI) {
    const conn = getCollectorDb();
    if (conn.readyState !== 1) {
      await conn.asPromise();
    }
    return conn;
  }

  // When using primary connection, ensure mongoose.connection is connected
  if (mongoose.connection.readyState !== 1 && env.MONGODB_URI) {
    logger.info('Primary MongoDB connection not ready; connecting before initializing collector DB...');
    await mongoose.connect(env.MONGODB_URI, {
      serverSelectionTimeoutMS: 30000,
      maxPoolSize: 10,
    });
  }

  return getCollectorDb();
}
