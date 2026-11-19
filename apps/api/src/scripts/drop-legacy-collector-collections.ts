import mongoose from 'mongoose';
import { env } from '../config/env';
import { logger } from '../common/utils/logger';

/**
 * Migration Script: Purge Legacy Collector Collections from Primary Database
 *
 * This script safely targets the primary production/development database (e.g., 'acedex')
 * and drops temporary collections ('temp_contributors', 'temp_unit_submissions')
 * while strictly safeguarding core production student collections.
 */
async function dropLegacyCollectorCollections() {
  const uri = env.MONGODB_URI;
  if (!uri) {
    throw new Error('MONGODB_URI environment variable is not defined.');
  }

  logger.info('Connecting to primary MongoDB for legacy collection cleanup...');
  await mongoose.connect(uri, { serverSelectionTimeoutMS: 30000 });

  const db = mongoose.connection.db;
  if (!db) {
    throw new Error('Failed to acquire MongoDB database reference.');
  }

  const dbName = mongoose.connection.name;
  logger.info({ dbName }, `Connected to primary database: ${dbName}`);

  const collections = await db.listCollections().toArray();
  const collectionNames = collections.map((c) => c.name);

  logger.info({ existingCollections: collectionNames }, 'Current collections in primary database');

  const targetsToDrop = ['temp_contributors', 'temp_unit_submissions'];
  const droppedCollections: string[] = [];

  for (const target of targetsToDrop) {
    if (collectionNames.includes(target)) {
      logger.info(`Dropping legacy collection '${target}' from database '${dbName}'...`);
      await db.dropCollection(target);
      droppedCollections.push(target);
      logger.info(`Successfully dropped collection '${target}'.`);
    } else {
      logger.info(`Collection '${target}' does not exist in '${dbName}' (already clean).`);
    }
  }

  // Verification step: list collections again to confirm
  const afterCollections = await db.listCollections().toArray();
  const afterNames = afterCollections.map((c) => c.name);

  console.log('\n=========================================');
  console.log('🧹 LEGACY COLLECTION PURGE COMPLETED');
  console.log('=========================================');
  console.log(`🎯 Database: ${dbName}`);
  console.log(`🗑️ Dropped Collections: ${droppedCollections.length > 0 ? droppedCollections.join(', ') : 'None (Already Clean)'}`);
  console.log(`🛡️ Remaining Collections (Safe): ${afterNames.join(', ')}`);
  console.log('=========================================\n');

  await mongoose.disconnect();
}

dropLegacyCollectorCollections().catch((err) => {
  logger.error({ err }, 'Failed to drop legacy collector collections');
  process.exit(1);
});
