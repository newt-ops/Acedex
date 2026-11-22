import mongoose from 'mongoose';
import { env } from '../config/env';
import { SubjectModel } from '../modules/curriculum/models/subject.model';
import { UnitModel } from '../modules/curriculum/models/unit.model';
import { QuestionModel } from '../modules/curriculum/models/question.model';
import { AnswerKeyModel } from '../modules/curriculum/models/answer-key.model';

async function check() {
  await mongoose.connect(env.MONGODB_URI);

  const subjectsCount = await SubjectModel.countDocuments();
  const unitsCount = await UnitModel.countDocuments();
  const publishedUnits = await UnitModel.countDocuments({ isPublished: true });
  const questionsCount = await QuestionModel.countDocuments();
  const answerKeysCount = await AnswerKeyModel.countDocuments();

  console.log('=== DATABASE STATUS ===');
  console.log(`Subjects: ${subjectsCount}`);
  console.log(`Total Units: ${unitsCount}`);
  console.log(`Published Units (with 15 Qs): ${publishedUnits}`);
  console.log(`Questions: ${questionsCount}`);
  console.log(`Answer Keys: ${answerKeysCount}`);

  // Breakdown by subject and grade
  const subjects = await SubjectModel.find({}).sort({ order: 1 });
  console.log('\n=== UNITS PER SUBJECT ===');
  for (const s of subjects) {
    const units = await UnitModel.find({ subjectId: s._id }).sort({ grade: 1, unitNumber: 1 });
    const totalQ = await QuestionModel.countDocuments({
      unitId: { $in: units.map((u) => u._id) },
    });
    console.log(
      `- ${s.name} (${s.code}): ${units.length} units, ${totalQ} questions (published: ${units.filter((u) => u.isPublished).length})`
    );
  }

  // Show Grade 12 units specifically
  console.log('\n=== GRADE 12 UNITS ===');
  const g12Units = await UnitModel.find({ grade: 12 })
    .populate('subjectId', 'name code')
    .sort({ 'subjectId.order': 1, unitNumber: 1 });
  for (const u of g12Units) {
    const qCount = await QuestionModel.countDocuments({ unitId: u._id });
    const sName = (u.subjectId as any)?.name ?? 'Unknown';
    console.log(`  G12 ${sName} U${u.unitNumber} (${u.title}): ${qCount} questions, published: ${u.isPublished}`);
  }

  await mongoose.disconnect();
}

check().catch((err) => {
  console.error(err);
  process.exit(1);
});
