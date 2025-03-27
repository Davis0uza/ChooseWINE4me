const mongoose = require('mongoose');

const FavoriteSchema = new mongoose.Schema({
  id_fav: { type: Number, required: true, unique: true },
  id_wine: { type: Number, required: true },
  id_user: { type: Number, required: true },
});

module.exports = mongoose.model('Favorite', FavoriteSchema);
