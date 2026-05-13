const authController = {

  //GET - register
  mostrarRegistro(req, res) {
    // Si ya esta logueado, redirigir a home
    if (req.session.usuario) return res.redirect('/');
    res.render('auth/register', { titulo: 'Crear cuenta' });
  },

  //POST - register
  async registrar(req, res) {
    const { nombre, apellido, username, email, password, confirmar } = req.body;

    // Validaciones BD
    if (!nombre || !apellido || !username || !email || !password) {
      return res.render('auth/register', {
        titulo: 'Crear cuenta',
        error: 'Todos los campos son obligatorios',
        datos: req.body   // para no perder lo que escribió
      });
    }

    if (password !== confirmar) {
      return res.render('auth/register', {
        titulo: 'Crear cuenta',
        error: 'Las contraseñas no coinciden',
        datos: req.body
      });
    }

    console.log('Nuevo usuario:', { nombre, apellido, username, email });
    res.redirect('/login');
  },

  //GET - login
  mostrarLogin(req, res) {
    if (req.session.usuario) return res.redirect('/');
    res.render('auth/login', { titulo: 'Iniciar sesión' });
  },

  //POST - login
  async login(req, res) {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.render('auth/login', {
        titulo: 'Iniciar sesión',
        error: 'Completá todos los campos'
      });
    }

  //pruebas
    if (email === 'test@test.com' && password === '1234') {
      req.session.usuario = {
        id: 1,
        nombre: 'Test',
        username: 'tester',
        rol: 'usuario'
      };
      return res.redirect('/');
    }

    res.render('auth/login', {
      titulo: 'Iniciar sesión',
      error: 'Email o contraseña incorrectos'
    });
  },

  //POST - logout
  logout(req, res) {
    req.session.destroy(() => {
      res.redirect('/login');
    });
  }

};

module.exports = authController;