const mongoose = require('mongoose');

const RatingSchema = new mongoose.Schema({
  id_rating: { type: Number, required: true, unique: true },
  id_user: { type: Number, required: true },
  id_wine: { type: Number, required: true },
  rating: { type: Number, required: true },
  comment: { type: String },
});

module.exports = mongoose.model('Rating', RatingSchema);
