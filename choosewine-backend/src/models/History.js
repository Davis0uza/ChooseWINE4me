const mongoose = require('mongoose');

const HistorySchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  wine: { type: mongoose.Schema.Types.ObjectId, ref: 'Wine', required: true },
  accessed_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('History', HistorySchema);
