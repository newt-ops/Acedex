import mongoose from 'mongoose';
import { env } from '../config/env';
import { logger } from '../common/utils/logger';

/**
 * Migration Script: Clear Sample Questions, Answer Keys, Assessment Attempts, and Student Progress
 *
 * Requirements:
 * - Target: Strictly the primary database 'acedex' (NOT 'acedex_collector').
 * - Actions: Clear all documents from:
 *     1. 'questions'
 *     2. 'answer_keys'
 *     3. 'assessment_attempts'
 *     4. 'student_progress'
 * - Safeguard: Assert database name strictly equals 'acedex', preserve users, subjects, units, ad_configs, ad_sessions, auditlogs.
 */
async function clearAcedexSampleData() {
  const uri = env.MONGODB_URI;
  if (!uri) {
    throw new Error('MONGODB_URI environment variable is not defined.');
  }

  logger.info('Connecting to primary MongoDB cluster...');
  await mongoose.connect(uri, { serverSelectionTimeoutMS: 30000 });

  const db = mongoose.connection.db;
  if (!db) {
    throw new Error('Failed to acquire MongoDB database reference.');
  }

  const dbName = mongoose.connection.name;
  logger.info({ dbName }, `Connected to database: ${dbName}`);

  // Strict safety check: Ensure we are targeting the main acedex database
  if (dbName !== 'acedex') {
    throw new Error(
      `ABORTING: Expected primary database 'acedex' but connected to '${dbName}'. Safeguarding data.`
    );
  }

  const collections = await db.listCollections().toArray();
  const collectionNames = collections.map((c) => c.name);

  logger.info({ existingCollections: collectionNames }, "Existing collections in 'acedex'");

  const targetsToClear = [
    'questions',
    'answer_keys',
    'assessment_attempts',
    'student_progress',
  ];

  const summary: Record<string, { before: number; deleted: number; after: number }> = {};

  for (const target of targetsToClear) {
    if (collectionNames.includes(target)) {
      const coll = db.collection(target);
      const countBefore = await coll.countDocuments();
      const result = await coll.deleteMany({});
      const countAfter = await coll.countDocuments();
      summary[target] = {
        before: countBefore,
        deleted: result.deletedCount,
        after: countAfter,
      };
      logger.info({ summary: summary[target] }, `Cleared documents from '${target}'`);
    } else {
      logger.warn(`'${target}' collection does not exist in 'acedex' (already clean)`);
      summary[target] = { before: 0, deleted: 0, after: 0 };
    }
  }

  // Confirm status of core collections
  const remainingCollections = await db.listCollections().toArray();
  const remainingNames = remainingCollections.map((c) => c.name);

  console.log('\n======================================================');
  console.log('🧹 ACEDEX SAMPLE & TEST DATA PURGE COMPLETED');
  console.log('======================================================');
  console.log(`🎯 Target Database: ${dbName} (Verified Primary Database)`);
  for (const target of targetsToClear) {
    console.log(`🗑️ ${target.padEnd(20)}: ${summary[target].before} items -> ${summary[target].deleted} deleted (Remaining: ${summary[target].after})`);
  }
  console.log('------------------------------------------------------');
  console.log(`🛡️ Preserved Collections: ${remainingNames.join(', ')}`);
  console.log('======================================================\n');

  await mongoose.disconnect();
}

clearAcedexSampleData().catch((err) => {
  logger.error({ err }, 'Failed to clear sample data from acedex');
  process.exit(1);
});
