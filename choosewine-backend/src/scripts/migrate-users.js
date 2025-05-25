// scripts/migrate-users.js
require('dotenv').config();
const mongoose = require('mongoose');
const User     = require('../models/User');

async function migrate() {
  await mongoose.connect(process.env.MONGODB_URI);
  const res = await User.updateMany(
    { provider: { $exists: false } },
    { $set: { provider: 'local' } }
  );
  console.log(`Migrated ${res.modifiedCount} users to provider:local`);
  process.exit(0);
}

migrate().catch(err=>{
  console.error(err);
  process.exit(1);
});
