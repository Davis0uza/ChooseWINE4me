const express = require('express');
const cors = require('cors');
const routes = require('./routes/appRoutes');
const errorMiddleware = require('./middleware/errorMiddleware');    

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Usando as rotas centralizadas
app.use('/', routes);

app.use(errorMiddleware.errorHandler);

module.exports = app;
