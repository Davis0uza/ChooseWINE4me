const jwt = require('jsonwebtoken');

// Middleware para verificar o token de autenticação
exports.verifyToken = (req, res, next) => {
  // Obtém o header de autorização (esperado no formato "Bearer <token>")
  const authHeader = req.headers['authorization'];
  console.log(req.headers.authorization);
  if (!authHeader) {
    return res.status(401).json({ error: 'Acesso negado: token não fornecido' });
  }
  const token = authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Acesso negado: token inválido' });
  }
  
  try {
    // Verifica o token usando a chave secreta (configure JWT_SECRET no .env)
    const verified = jwt.verify(token, process.env.JWT_SECRET || 'defaultsecret');
    // Adiciona os dados do token na requisição para uso posterior
    req.user = verified;
    next();
  } catch (err) {
    return res.status(400).json({ error: 'Token inválido' });
  }
};
