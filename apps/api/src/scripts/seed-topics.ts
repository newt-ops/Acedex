import mongoose from 'mongoose';
import { env } from '../config/env';
import { TopicBankParserService } from '../modules/topics/topic-bank-parser.service';
import { logger } from '../common/utils/logger';

async function main() {
  logger.info('Connecting to MongoDB Atlas for topic bank seeding...');
  await mongoose.connect(env.MONGODB_URI);
  logger.info('Connected to MongoDB Atlas');

  const startTime = Date.now();
  const report = await TopicBankParserService.seedTopicsFromDisk();
  const durationSec = ((Date.now() - startTime) / 1000).toFixed(2);

  console.log('\n=========================================');
  console.log('✅ TOPIC BANK SEEDING COMPLETED');
  console.log('=========================================');
  console.log(`⏱️ Duration: ${durationSec}s`);
  console.log(`📁 Topic Sources Scanned: ${report.filesScanned} (${report.sourceMode})`);
  console.log(`📚 Subjects Seeded: ${report.subjectsSeeded.join(', ') || 'None'}`);
  console.log(`🧩 Cross-Grade Topic Modules Upserted: ${report.modulesUpserted}`);
  console.log('=========================================\n');

  await mongoose.disconnect();
}

main().catch((err) => {
  logger.error({ err }, 'Topic bank seeding failed');
  process.exit(1);
});
