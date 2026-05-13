//requerimiento de logearse
function soloAutenticados(req, res, next) {
  if (req.session.usuario) return next();
  res.redirect('/login');
}

//requerimiento del rol
function soloValidador(req, res, next) {
  if (req.session.usuario?.rol === 'validador') return next();
  res.status(403).render('error', { mensaje: 'Acceso denegado' });
}

module.exports = { soloAutenticados, soloValidador };