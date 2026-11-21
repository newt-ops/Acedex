import mongoose from 'mongoose';
import { env } from '../config/env';

async function main() {
  await mongoose.connect(env.MONGODB_URI);
  console.log('Connected to MongoDB Atlas');

  const collection = mongoose.connection.collection('users');
  const users = await collection.find({ acedexId: { $exists: false } }).toArray();
  console.log(`Found ${users.length} users without acedexId`);

  for (const u of users) {
    const randomSuffix = Math.floor(1000 + Math.random() * 9000);
    const acedexId = `ACX-26-${randomSuffix}`;
    await collection.updateOne({ _id: u._id }, { $set: { acedexId } });
    console.log(`Updated user ${u._id} with ${acedexId}`);
  }

  console.log('Backfill completed successfully');
  await mongoose.disconnect();
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
