// authMiddleware.js

require('dotenv').config();
const jwt = require('jsonwebtoken');

const INTERNAL_SERVICE_KEY = process.env.INTERNAL_SERVICE_KEY;  // chave secreta fixa

/**
 * Middleware de autenticação:
 * 1) Se vier o header X-Service-Key correto, libera o request sem JWT
 * 2) Caso contrário, exige um Bearer token JWT válido
 */
function verifyToken(req, res, next) {
  // 1) Bypass com chave interna
  const serviceKey = req.header('x-service-key');
  if (serviceKey && serviceKey === INTERNAL_SERVICE_KEY) {
    return next();
  }

  // 2) Verifica header Authorization
  const authHeader = req.header('authorization');
  if (!authHeader) {
    return res.status(401).json({ error: 'Acesso negado: token não fornecido' });
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return res.status(401).json({ error: 'Acesso negado: formato de token inválido' });
  }

  const token = parts[1];
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.user = payload;
    return next();
  } catch (err) {
    return res.status(403).json({ error: 'Token inválido ou expirado' });
  }
}

module.exports = { verifyToken };
