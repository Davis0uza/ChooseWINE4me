const mongoose = require('mongoose');

const AddressSchema = new mongoose.Schema({
  id_address: { type: Number, required: true, unique: true },
  id_user: { type: Number, required: true },
  country: { type: String },
  city: { type: String },
  address: { type: String },
  postal: { type: String }
});

module.exports = mongoose.model('Address', AddressSchema);
