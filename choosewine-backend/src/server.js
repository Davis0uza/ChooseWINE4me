const app = require('./app');
const connectDB = require('./config/database');
require('dotenv').config({ path: '../.env' });

const PORT = process.env.PORT || 3000;

connectDB(); // Conecta ao MongoDB

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
