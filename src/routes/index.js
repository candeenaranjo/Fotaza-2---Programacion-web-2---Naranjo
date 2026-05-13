const express = require('express');
const router = express.Router();

const authRoutes = require('./authRoutes');

//ruta home
router.get('/', (req, res) => {
  res.render('index', { titulo: 'Fotaza 2 - Inicio' });
});

//montar rutas de auth
router.use('/', authRoutes);

module.exports = router;