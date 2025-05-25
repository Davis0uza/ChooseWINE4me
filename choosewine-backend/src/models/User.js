// models/User.js
const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  email:    { type: String, required: true, unique: true },
  name:     { type: String, required: true },
  // só obrigatório para contas locais
  password: {
    type: String,
    required: function() { return this.provider === 'local'; }
  },
  provider: {
    type: String,
    enum: ['local','firebase'],
    default: 'local'
  },
  // só uso para social login
  firebaseUid: {
    type: String,
    unique: true,
    sparse: true
  },
  photo:    { type: String },
  createdAt:{ type: Date, default: Date.now }
});

module.exports = mongoose.model('User', UserSchema);
