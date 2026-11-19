import mongoose from 'mongoose';
import { env } from '../config/env';
import { logger } from '../common/utils/logger';

/**
 * Migration Script: Clear Sample Questions and Answer Keys from Primary 'acedex' Database
 *
 * Requirements:
 * - Target: Strictly the primary database 'acedex' (NOT 'acedex_collector').
 * - Actions: Clear all documents from 'questions' and 'answer_keys' collections.
 * - Safeguard: Assert database name equals 'acedex', preserve users, subjects, units, progress, and audit collections.
 */
async function clearSampleQuestionsAndAnswerKeys() {
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

  const summary: Record<string, { before: number; deleted: number; after: number }> = {};

  // 1. Clear 'questions'
  if (collectionNames.includes('questions')) {
    const qColl = db.collection('questions');
    const countBefore = await qColl.countDocuments();
    const result = await qColl.deleteMany({});
    const countAfter = await qColl.countDocuments();
    summary['questions'] = {
      before: countBefore,
      deleted: result.deletedCount,
      after: countAfter,
    };
    logger.info({ summary: summary['questions'] }, "Cleared sample documents from 'questions'");
  } else {
    logger.warn("'questions' collection does not exist in 'acedex' (already clean)");
    summary['questions'] = { before: 0, deleted: 0, after: 0 };
  }

  // 2. Clear 'answer_keys'
  if (collectionNames.includes('answer_keys')) {
    const aColl = db.collection('answer_keys');
    const countBefore = await aColl.countDocuments();
    const result = await aColl.deleteMany({});
    const countAfter = await aColl.countDocuments();
    summary['answer_keys'] = {
      before: countBefore,
      deleted: result.deletedCount,
      after: countAfter,
    };
    logger.info({ summary: summary['answer_keys'] }, "Cleared sample documents from 'answer_keys'");
  } else {
    logger.warn("'answer_keys' collection does not exist in 'acedex' (already clean)");
    summary['answer_keys'] = { before: 0, deleted: 0, after: 0 };
  }

  // 3. Confirm status of core collections
  const remainingCollections = await db.listCollections().toArray();
  const remainingNames = remainingCollections.map((c) => c.name);

  console.log('\n======================================================');
  console.log('🧹 SAMPLE QUESTIONS & ANSWER KEYS PURGE COMPLETED');
  console.log('======================================================');
  console.log(`🎯 Target Database: ${dbName} (Verified Primary Database)`);
  console.log(`❓ Questions: ${summary['questions'].before} sample items -> ${summary['questions'].deleted} deleted (Remaining: ${summary['questions'].after})`);
  console.log(`🔑 Answer Keys: ${summary['answer_keys'].before} sample items -> ${summary['answer_keys'].deleted} deleted (Remaining: ${summary['answer_keys'].after})`);
  console.log(`🛡️ Preserved Collections: ${remainingNames.join(', ')}`);
  console.log('======================================================\n');

  await mongoose.disconnect();
}

clearSampleQuestionsAndAnswerKeys().catch((err) => {
  logger.error({ err }, 'Failed to clear sample questions and answer keys');
  process.exit(1);
});
