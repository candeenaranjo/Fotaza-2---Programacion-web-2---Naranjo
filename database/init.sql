-- Base de datos
-- Limpiar todo antes de crear
DROP TABLE IF EXISTS mensajes                CASCADE;
DROP TABLE IF EXISTS intereses               CASCADE;
DROP TABLE IF EXISTS coleccion_publicaciones CASCADE;
DROP TABLE IF EXISTS colecciones             CASCADE;
DROP TABLE IF EXISTS notificaciones          CASCADE;
DROP TABLE IF EXISTS seguidores              CASCADE;
DROP TABLE IF EXISTS denuncias_comentario    CASCADE;
DROP TABLE IF EXISTS denuncias_imagen        CASCADE;
DROP TABLE IF EXISTS valoraciones            CASCADE;
DROP TABLE IF EXISTS comentarios             CASCADE;
DROP TABLE IF EXISTS publicacion_etiquetas   CASCADE;
DROP TABLE IF EXISTS etiquetas               CASCADE;
DROP TABLE IF EXISTS imagenes                CASCADE;
DROP TABLE IF EXISTS publicaciones           CASCADE;
DROP TABLE IF EXISTS motivos_denuncia        CASCADE;
DROP TABLE IF EXISTS usuarios                CASCADE;

DROP TYPE IF EXISTS rol_usuario        CASCADE;
DROP TYPE IF EXISTS tipo_licencia      CASCADE;
DROP TYPE IF EXISTS estado_publicacion CASCADE;
DROP TYPE IF EXISTS estado_denuncia    CASCADE;
DROP TYPE IF EXISTS tipo_notificacion  CASCADE;


-- TIPOS ENUM
CREATE TYPE rol_usuario        AS ENUM ('usuario', 'validador', 'admin');
CREATE TYPE tipo_licencia      AS ENUM ('copyright', 'sin_copyright');
CREATE TYPE estado_publicacion AS ENUM ('activa', 'baja', 'en_revision');
CREATE TYPE estado_denuncia    AS ENUM ('pendiente', 'resuelta', 'desestimada');
CREATE TYPE tipo_notificacion  AS ENUM ('comentario', 'valoracion', 'me_interesa', 'nuevo_seguidor');

-- USUARIOS
CREATE TABLE IF NOT EXISTS usuarios (
  id            SERIAL       PRIMARY KEY,
  nombre        VARCHAR(50)  NOT NULL,
  apellido      VARCHAR(50)  NOT NULL,
  username      VARCHAR(30)  NOT NULL UNIQUE,
  email         VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  avatar        VARCHAR(255) DEFAULT NULL,
  bajas         SMALLINT     NOT NULL DEFAULT 0 CHECK (bajas >= 0),
  estado        VARCHAR(10)  NOT NULL DEFAULT 'activo'
                             CHECK (estado IN ('activo', 'inactivo')),
  rol           rol_usuario  NOT NULL DEFAULT 'usuario',
  creado_en     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- MOTIVOS DE DENUNCIA
CREATE TABLE IF NOT EXISTS motivos_denuncia (
  id          SERIAL       PRIMARY KEY,
  descripcion VARCHAR(100) NOT NULL UNIQUE
);

-- PUBLICACIONES
CREATE TABLE IF NOT EXISTS publicaciones (
  id                  SERIAL             PRIMARY KEY,
  titulo              VARCHAR(150)       NOT NULL,
  id_usuario          INT                NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  descripcion         TEXT               DEFAULT NULL,
  comentarios_activos BOOLEAN            NOT NULL DEFAULT TRUE,
  estado              estado_publicacion NOT NULL DEFAULT 'activa',
  fecha               TIMESTAMP          NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- IMAGENES
CREATE TABLE IF NOT EXISTS imagenes (
  id             SERIAL        PRIMARY KEY,
  id_publicacion INT           NOT NULL REFERENCES publicaciones(id) ON DELETE CASCADE,
  url            VARCHAR(255)  NOT NULL,
  licencia       tipo_licencia NOT NULL DEFAULT 'sin_copyright',
  marca_agua     VARCHAR(100)  DEFAULT NULL
);

-- ETIQUETAS
CREATE TABLE IF NOT EXISTS etiquetas (
  id     SERIAL      PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE
);

-- PUBLICACION/ETIQUETA (N:M)
CREATE TABLE IF NOT EXISTS publicacion_etiquetas (
  id_publicacion INT NOT NULL REFERENCES publicaciones(id) ON DELETE CASCADE,
  id_etiqueta    INT NOT NULL REFERENCES etiquetas(id)     ON DELETE CASCADE,
  PRIMARY KEY (id_publicacion, id_etiqueta)
);

-- COMENTARIOS
CREATE TABLE IF NOT EXISTS comentarios (
  id         SERIAL    PRIMARY KEY,
  id_imagen  INT       NOT NULL REFERENCES imagenes(id)  ON DELETE CASCADE,
  id_usuario INT       NOT NULL REFERENCES usuarios(id)  ON DELETE CASCADE,
  texto      TEXT      NOT NULL,
  fecha      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- VALORACIONES
CREATE TABLE IF NOT EXISTS valoraciones (
  id         SERIAL   PRIMARY KEY,
  id_imagen  INT      NOT NULL REFERENCES imagenes(id)  ON DELETE CASCADE,
  id_usuario INT      NOT NULL REFERENCES usuarios(id)  ON DELETE CASCADE,
  puntuacion SMALLINT NOT NULL CHECK (puntuacion BETWEEN 1 AND 5),
  UNIQUE (id_imagen, id_usuario)
);

-- DENUNCIAS DE IMAGEN
CREATE TABLE IF NOT EXISTS denuncias_imagen (
  id            SERIAL          PRIMARY KEY,
  id_imagen     INT             NOT NULL REFERENCES imagenes(id)          ON DELETE CASCADE,
  id_usuario    INT             NOT NULL REFERENCES usuarios(id)          ON DELETE CASCADE,
  id_motivo     INT             NOT NULL REFERENCES motivos_denuncia(id),
  justificacion TEXT            NOT NULL,
  estado        estado_denuncia NOT NULL DEFAULT 'pendiente',
  fecha         TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (id_imagen, id_usuario)
);

-- DENUNCIAS DE COMENTARIO
CREATE TABLE IF NOT EXISTS denuncias_comentario (
  id            SERIAL          PRIMARY KEY,
  id_comentario INT             NOT NULL REFERENCES comentarios(id)       ON DELETE CASCADE,
  id_usuario    INT             NOT NULL REFERENCES usuarios(id)          ON DELETE CASCADE,
  id_motivo     INT             NOT NULL REFERENCES motivos_denuncia(id),
  justificacion TEXT            NOT NULL,
  estado        estado_denuncia NOT NULL DEFAULT 'pendiente',
  fecha         TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (id_comentario, id_usuario)
);

-- SEGUIDORES (N:M)
CREATE TABLE IF NOT EXISTS seguidores (
  id_seguidor INT       NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  id_seguido  INT       NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  fecha       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_seguidor, id_seguido),
  CHECK (id_seguidor <> id_seguido)
);

-- NOTIFICACIONES
CREATE TABLE IF NOT EXISTS notificaciones (
  id               SERIAL            PRIMARY KEY,
  id_usuario       INT               NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  tipo             tipo_notificacion NOT NULL,
  id_usuario_actor INT               NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  id_referencia    INT               DEFAULT NULL,
  leida            BOOLEAN           NOT NULL DEFAULT FALSE,
  fecha            TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- COLECCIONES
CREATE TABLE IF NOT EXISTS colecciones (
  id         SERIAL       PRIMARY KEY,
  id_usuario INT          NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  nombre     VARCHAR(100) NOT NULL,
  creado_en  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (id_usuario, nombre)
);

-- COLECCION/PUBLICACION (N:M) 
CREATE TABLE IF NOT EXISTS coleccion_publicaciones (
  id_coleccion   INT NOT NULL REFERENCES colecciones(id)   ON DELETE CASCADE,
  id_publicacion INT NOT NULL REFERENCES publicaciones(id) ON DELETE CASCADE,
  PRIMARY KEY (id_coleccion, id_publicacion)
);

-- INTERESES
CREATE TABLE IF NOT EXISTS intereses (
  id         SERIAL    PRIMARY KEY,
  id_usuario INT       NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  id_imagen  INT       NOT NULL REFERENCES imagenes(id) ON DELETE CASCADE,
  fecha      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (id_usuario, id_imagen)
);

-- MENSAJES
CREATE TABLE IF NOT EXISTS mensajes (
  id           SERIAL    PRIMARY KEY,
  id_remitente INT       NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  id_receptor  INT       NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  id_imagen    INT       NOT NULL REFERENCES imagenes(id) ON DELETE CASCADE,
  contenido    TEXT      NOT NULL,
  leido        BOOLEAN   NOT NULL DEFAULT FALSE,
  fecha        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (id_remitente <> id_receptor)
);

--DATOS INICIALES
INSERT INTO motivos_denuncia (descripcion) VALUES
  ('Contenido inapropiado'),
  ('Spam o publicidad'),
  ('Derechos de autor'),
  ('Acoso o bullying'),
  ('Información falsa');