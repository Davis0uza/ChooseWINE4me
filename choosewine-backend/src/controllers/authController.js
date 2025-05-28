// controllers/authController.js
const admin = require('../config/firebase/firebase');
const jwt   = require('jsonwebtoken');
const User  = require('../models/User');

exports.loginWithFirebase = async (req, res) => {
  const { idToken } = req.body;
  if (!idToken) {
    return res.status(400).json({ error: 'Token de autenticação não fornecido' });
  }

  try {
    // 1️⃣ valida no Firebase
    const decoded = await admin.auth().verifyIdToken(idToken);
    const { uid, email, name, picture } = decoded;

    // 2️⃣ procura por firebaseUid ou email
    let user = await User.findOne({ firebaseUid: uid });
    if (!user) {
      user = await User.findOne({ email });
    }

    // 3️⃣ cria se não existir
    if (!user) {
      user = await User.create({
        email,
        name: name || 'Sem nome',
        provider: 'firebase',
        firebaseUid: uid,
        photo: picture
      });
    } else if (user.provider === 'local') {
      // 4️⃣ se era local, associa firebaseUid
      user.provider = 'firebase';
      user.firebaseUid = uid;
      await user.save();
    }

    // 5️⃣ gera o JWT local
    const token = jwt.sign(
      { _id: user._id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    // 6️⃣ devolve só o que precisas no cliente
    return res.json({
      token,
      userId: user._id.toString(),
      user: {
        email: user.email,
        name:  user.name,
        photo: user.photo,
        provider: user.provider
      }
    });
  } catch (err) {
    console.error('Erro ao verificar token Firebase:', err);
    return res.status(401).json({ error: 'Token inválido ou expirado' });
  }
};
