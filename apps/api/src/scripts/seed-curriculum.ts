import mongoose from 'mongoose';
import { env } from '../config/env';
import { CurriculumSeederService } from '../modules/curriculum/curriculum-seeder.service';
import { logger } from '../common/utils/logger';

async function main() {
  logger.info('Connecting to MongoDB Atlas for curriculum seeding...');
  await mongoose.connect(env.MONGODB_URI);
  logger.info('Connected to MongoDB Atlas');

  const startTime = Date.now();
  const report = await CurriculumSeederService.seedCurriculum();
  const durationSec = ((Date.now() - startTime) / 1000).toFixed(2);

  console.log('\n=========================================');
  console.log('✅ CURRICULUM SEEDING COMPLETED');
  console.log('=========================================');
  console.log(`⏱️ Duration: ${durationSec}s`);
  console.log(`📁 Files Scanned: ${report.totalFilesScanned}`);
  console.log(`📚 Subjects Seeded: ${report.subjectsUpserted}`);
  console.log(`📖 Total Units: ${report.unitsUpserted}`);
  console.log(`  └─ Published Units (15 Questions): ${report.publishedUnits}`);
  console.log(`  └─ Draft Units (Pending Questions): ${report.draftUnits}`);
  console.log(`❓ Questions Upserted: ${report.questionsUpserted}`);
  console.log(`🔑 Answer Keys Isolated: ${report.answerKeysUpserted}`);
  console.log('=========================================\n');

  await mongoose.disconnect();
}

main().catch((err) => {
  logger.error({ err }, 'Curriculum seeding failed');
  process.exit(1);
});
