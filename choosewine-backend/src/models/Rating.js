// models/Rating.js
const mongoose = require('mongoose');

const RatingSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,  // MUDOU: agora é ObjectId
    ref: 'User',                           // refere ao model User
    required: true
  },
  wine: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Wine',
    required: true
  },
  rating: {
    type: Number,
    required: true
  },
  comment: {
    type: String
  }
},
{
  timestamps: true // opcional, caso queira createdAt/updatedAt
});

module.exports = mongoose.model('Rating', RatingSchema);
