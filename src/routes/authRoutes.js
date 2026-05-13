const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

//formulario de registro
router.get('/register', authController.mostrarRegistro);
//procesar registro
router.post('/register', authController.registrar);
//mostrar formulario de login
router.get('/login', authController.mostrarLogin);
//procesar login
router.post('/login', authController.login);
//cerrar sesion
router.post('/logout', authController.logout);

module.exports = router;