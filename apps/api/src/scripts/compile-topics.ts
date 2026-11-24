import mongoose from 'mongoose';
import { env } from '../config/env';
import { TopicBankParserService } from '../modules/topics/topic-bank-parser.service';
import { logger } from '../common/utils/logger';

async function main() {
  logger.info('Connecting to MongoDB Atlas for official unit title hydration...');
  await mongoose.connect(env.MONGODB_URI);

  const startTime = Date.now();
  const report = await TopicBankParserService.compileTopicBankToJson();
  const durationSec = ((Date.now() - startTime) / 1000).toFixed(2);

  console.log('\n=========================================');
  console.log('✅ TOPIC BANK JSON COMPILATION COMPLETED');
  console.log('=========================================');
  console.log(`⏱️ Duration: ${durationSec}s`);
  console.log(`📄 Markdown Files Scanned: ${report.markdownFilesScanned}`);
  console.log(`📦 JSON Files Written: ${report.jsonFilesWritten.join(', ') || 'None'}`);
  console.log(
    `🛡️ Curated JSON Preserved: ${report.existingJsonPreserved.join(', ') || 'None'}`
  );
  console.log(`🏷️ Unit Titles Hydrated from DB: ${report.unitTitlesHydratedFromDb}`);
  console.log(`🧩 Total Validated Topic Modules: ${report.totalModulesCompiled}`);
  console.log('=========================================\n');

  await mongoose.disconnect();
}

main().catch((err) => {
  logger.error({ err }, 'Topic bank JSON compilation failed');
  process.exit(1);
});
