const admin = require('../config/firebase/firebase');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

exports.loginWithFirebase = async (req, res) => {
  const { idToken } = req.body;

  if (!idToken) {
    return res.status(400).json({ error: 'Token de autenticação não fornecido' });
  }

  try {
    // 1. Verifica o token no Firebase
    console.log('Recebido no backend:', req.body);
    const decoded = await admin.auth().verifyIdToken(idToken);
    const { uid, email, name } = decoded;

    // 2. Procura utilizador local com este email
    let user = await User.findOne({ email });

    // 3. Se não existir, cria
    if (!user) {
      user = await User.create({
        email,
        name: name || 'Sem nome',
        password: '' // Não usamos password local
      });
    }

    // 4. Gera token JWT para sessão local
    const token = jwt.sign(
      { _id: user._id, email: user.email },
      process.env.JWT_SECRET || 'defaultsecret',
      { expiresIn: '7d' }
    );

    return res.json({ user, token });
  } catch (err) {
    console.error('Erro ao verificar token Firebase:', err.message);
    return res.status(401).json({ error: 'Token inválido ou expirado' });
  }
};
