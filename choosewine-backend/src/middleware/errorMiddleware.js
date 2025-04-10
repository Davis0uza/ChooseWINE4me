// Middleware para tratamento centralizado de erros
exports.errorHandler = (err, req, res, next) => {
    console.error(err.stack);
    res.status(err.status || 500).json({
      message: err.message,
      // Em produção, pode-se ocultar detalhes do erro
      error: process.env.NODE_ENV === 'production' ? {} : err
    });
  };
  