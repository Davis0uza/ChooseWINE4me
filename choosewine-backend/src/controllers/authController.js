// controllers/authController.js
const admin = require('../config/firebase/firebase');
const jwt   = require('jsonwebtoken');
const User  = require('../models/User');
const bcrypt = require('bcrypt');
const axios = require('axios');  

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




// … o resto do ficheiro permanece igual …

// POST /auth/email
exports.loginWithEmail = async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res
      .status(400)
      .json({ error: 'Email e password são obrigatórios' });
  }

  try {
    // 1️⃣ encontra o user local
    const user = await User.findOne({ email });
    if (!user || user.provider !== 'local') {
      return res
        .status(401)
        .json({ error: 'Credenciais inválidas' });
    }

    // 2️⃣ verifica a password
    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
      return res
        .status(401)
        .json({ error: 'Credenciais inválidas' });
    }

    // 3️⃣ gera o JWT da aplicação
    const token = jwt.sign(
      { _id: user._id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' },
    );

    // 4️⃣ devolve o token e o mongoUid
    return res.json({
      token,
      userId: user._id.toString(),
      user: {
        email:    user.email,
        name:     user.name,
        photo:    user.photo,
        provider: user.provider,
      }
    });
  } catch (err) {
    console.error('Erro no login por email:', err);
    return res
      .status(500)
      .json({ error: 'Erro interno no servidor' });
  }
};

exports.proxyImage = async (req, res) => {
  const { url } = req.query;
  if (!url) {
    return res.status(400).json({ error: 'Missing url query parameter' });
  }
  try {
    const response = await axios.get(url, { responseType: 'arraybuffer' });
    return res
      .header('Content-Type', response.headers['content-type'])
      .send(response.data);
  } catch (err) {
    console.error('Erro no proxy de imagem:', err.message);
    return res.status(502).json({ error: 'Image proxy error' });
  }
};