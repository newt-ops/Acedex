import mongoose, { Connection } from 'mongoose';
import { env } from './env';
import { logger } from '../common/utils/logger';

let notesConnection: Connection | null = null;

/**
 * Returns the isolated database connection for Quick Notes resources.
 *
 * Defaults to using the dedicated 'acedex_notes' database on the same MongoDB cluster
 * via connection pooling (useDb with caching), or connects to NOTES_MONGODB_URI
 * if explicitly configured.
 */
export function getNotesDb(): Connection {
  if (notesConnection && notesConnection.readyState === 1) {
    return notesConnection;
  }

  // If a dedicated separate cluster URI is specified
  if (env.NOTES_MONGODB_URI) {
    if (!notesConnection) {
      logger.info({ uri: env.NOTES_MONGODB_URI }, 'Creating dedicated MongoDB connection for Quick Notes...');
      notesConnection = mongoose.createConnection(env.NOTES_MONGODB_URI, {
        maxPoolSize: 10,
        serverSelectionTimeoutMS: 30000,
      });

      notesConnection.on('connected', () => {
        logger.info({ db: env.NOTES_DB_NAME }, 'Notes dedicated DB connection established');
      });

      notesConnection.on('error', (err) => {
        logger.error({ err }, 'Notes DB connection error');
      });
    }
    return notesConnection;
  }

  // Same cluster connection pool: switch database context cleanly to 'acedex_notes'
  const targetDbName = env.NOTES_DB_NAME || 'acedex_notes';
  notesConnection = mongoose.connection.useDb(targetDbName, { useCache: true });

  logger.debug({ targetDb: targetDbName }, 'Acquired notes database handle via useDb');
  return notesConnection;
}

/**
 * Ensures the notes database connection is active and ready
 */
export async function initNotesDatabase(): Promise<Connection> {
  if (env.NOTES_MONGODB_URI) {
    const conn = getNotesDb();
    if (conn.readyState !== 1) {
      await conn.asPromise();
    }
    return conn;
  }

  // Ensure primary connection is ready before useDb
  if (mongoose.connection.readyState !== 1 && env.MONGODB_URI) {
    logger.info('Primary MongoDB connection not ready; connecting before initializing notes DB...');
    await mongoose.connect(env.MONGODB_URI, {
      serverSelectionTimeoutMS: 30000,
      maxPoolSize: 10,
    });
  }

  return getNotesDb();
}
