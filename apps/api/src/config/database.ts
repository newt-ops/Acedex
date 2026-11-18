import mongoose from 'mongoose';
import { DatabaseConnectionState } from '@acedex/contracts';
import { logger } from '../common/utils/logger';
import { env } from './env';

const stateMap: Record<number, DatabaseConnectionState> = {
  0: 'disconnected',
  1: 'connected',
  2: 'connecting',
  3: 'disconnecting',
  99: 'uninitialized',
};

// Configure mongoose global settings for resilient remote connections
mongoose.set('bufferTimeoutMS', 30000);

// Configure event listeners on the default mongoose connection
mongoose.connection.on('connected', () => {
  logger.info(
    {
      host: mongoose.connection.host,
      database: mongoose.connection.name,
    },
    'MongoDB connection successfully established'
  );
});

mongoose.connection.on('error', (err) => {
  logger.error({ err }, 'MongoDB connection error encountered');
});

mongoose.connection.on('disconnected', () => {
  logger.warn('MongoDB disconnected');
});

mongoose.connection.on('reconnected', () => {
  logger.info('MongoDB reconnected');
});

export async function connectDatabase(customUri?: string): Promise<boolean> {
  const uri = customUri || env.MONGODB_URI;

  if (!uri) {
    if (env.NODE_ENV === 'production') {
      throw new Error('MONGODB_URI must be defined to connect in production');
    }
    logger.warn('No MONGODB_URI provided. Database connection skipped (development/test mode).');
    return false;
  }

  // If already connected, return
  if (mongoose.connection.readyState === 1) {
    logger.debug('MongoDB already connected');
    return true;
  }

  let attempts = 0;
  const maxAttempts = 3;

  while (attempts < maxAttempts) {
    attempts++;
    try {
      logger.info({ attempt: attempts }, 'Connecting to MongoDB Atlas...');
      await mongoose.connect(uri, {
        autoIndex: env.NODE_ENV !== 'production',
        serverSelectionTimeoutMS: 30000,
        maxPoolSize: 10,
      });
      return true;
    } catch (error) {
      logger.warn({ error, attempt: attempts }, `Failed to connect to MongoDB (attempt ${attempts}/${maxAttempts})`);
      if (attempts >= maxAttempts) {
        logger.error({ error }, 'Exhausted MongoDB connection attempts');
        if (env.NODE_ENV === 'production' || process.env.NODE_ENV === 'test') {
          throw error;
        }
        return false;
      }
      // Wait 2 seconds before retry
      await new Promise((resolve) => setTimeout(resolve, 2000));
    }
  }

  return false;
}

export async function disconnectDatabase(): Promise<void> {
  if (mongoose.connection.readyState !== 0) {
    logger.info('Closing MongoDB connection...');
    await mongoose.disconnect();
    logger.info('MongoDB connection closed cleanly');
  }
}

export function getDatabaseStatus(): {
  status: DatabaseConnectionState;
  connected: boolean;
  name?: string;
  host?: string;
} {
  const readyState = mongoose.connection.readyState;
  const status = stateMap[readyState] || 'disconnected';
  const connected = readyState === 1;

  return {
    status,
    connected,
    name: connected ? mongoose.connection.name : undefined,
    host: connected ? mongoose.connection.host : undefined,
  };
}
