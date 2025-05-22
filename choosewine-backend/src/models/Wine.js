const mongoose = require('mongoose');

const WineSchema = new mongoose.Schema({
  url: { type: String },
  name: { type: String, required: true },
  type: { type: String }, // ex: "Red", "White", "Sparkling", etc.
  rating: { type: Number },
  country: { type: String },
  winery: { type: String },
  alcoholLevel: { type: Number },
  image: { type: String },
  price: { type: Number },
  year: { type: String }
}, {
  timestamps: true
});

module.exports = mongoose.model('Wine', WineSchema);
