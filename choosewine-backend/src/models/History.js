const mongoose = require('mongoose');

const HistorySchema = new mongoose.Schema({
  id_history: { type: Number, required: true, unique: true },
  id_user: { type: Number, required: true },
  accessed_at: { type: Date, default: Date.now },
});

module.exports = mongoose.model('History', HistorySchema);
