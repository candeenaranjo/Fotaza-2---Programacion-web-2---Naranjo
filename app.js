require('dotenv').config();
const express = require('express');
const session = require('express-session');
const path = require('path');

const app = express();
const PORT = 3000;

//motor de plantillas
app.set('view engine', 'pug');
app.set('views', path.join(__dirname, 'src/views'));

//middlewares
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

//sesiones 
app.use(session({
  secret: process.env.SESSION_SECRET || 'secreto_temporal',
  resave: false,
  saveUninitialized: false,
  cookie: { maxAge: 1000 * 60 * 60 * 24 }
}));

//usuario disponible 
app.use((req, res, next) => {
  res.locals.usuarioActual = req.session.usuario || null;
  next();
});

//rutas
const routes = require('./src/routes/index');
app.use('/', routes);

app.listen(PORT, () => {
  console.log(`Servidor en http://localhost:${PORT}`);
});