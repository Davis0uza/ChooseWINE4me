const mongoose = require('mongoose');

const WineSchema = new mongoose.Schema({
  id_wine: { type: Number, required: true, unique: true },
  name: { type: String, required: true },
  thumb: { type: String }, 
  country: { type: String },
  region: { type: String },
  average_rating: { type: Number, default: 0 },
  ratings: { type: Number, default: 0 },
  price: { type: Number, default: 0 },
});

module.exports = mongoose.model('Wine', WineSchema);
