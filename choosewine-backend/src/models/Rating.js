const mongoose = require('mongoose');

const RatingSchema = new mongoose.Schema({
  user: { type: Number, required: true }, // ou podes mudar para ObjectId se usares _id no User
  wine: { type: mongoose.Schema.Types.ObjectId, ref: 'Wine', required: true },
  rating: { type: Number, required: true },
  comment: { type: String }
});

module.exports = mongoose.model('Rating', RatingSchema);
