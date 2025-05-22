const mongoose = require('mongoose');

const AddressSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  country: { type: String },
  city: { type: String },
  address: { type: String },
  postal: { type: String }
});

module.exports = mongoose.model('Address', AddressSchema);
