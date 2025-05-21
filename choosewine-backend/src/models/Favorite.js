const mongoose = require('mongoose');

const FavoriteSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  wine: { type: mongoose.Schema.Types.ObjectId, ref: 'Wine', required: true }
});

module.exports = mongoose.model('Favorite', FavoriteSchema);
