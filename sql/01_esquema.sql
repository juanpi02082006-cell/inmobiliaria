-- =============================================================================
--  PROYECTO: Sistema web Inmobiliaria "Santander Raiz"
--  ARCHIVO : 01_esquema.sql  ->  Script DDL (estructura de la base de datos)
--  MOTOR   : MySQL 8 / MariaDB 10.4+ (XAMPP)
--  NORMAL. : Modelo relacional normalizado hasta 3FN
--
--  Relaciones exigidas:
--    * 1:1  -> usuario  <-> perfil            (perfil.id_usuario UNIQUE)
--    * 1:N  -> inmobiliaria -> propiedad,  propiedad -> imagen_propiedad,
--              cliente(usuario) -> cita,   propiedad -> cita
--    * N:M  -> usuario <-> rol               (tabla puente usuario_rol)
--              propiedad <-> caracteristica  (tabla puente propiedad_caracteristica)
--
--  Restricciones UNIQUE principales:
--    * usuario.correo
--    * propiedad.matricula_inmobiliaria
--    * perfil.id_usuario
--    * usuario_rol(id_usuario, id_rol)  (PK compuesta)
--    * cita(id_propiedad, fecha_hora)   (evita doble agenda en el mismo horario)
-- =============================================================================

DROP DATABASE IF EXISTS inmobiliaria_db;
CREATE DATABASE inmobiliaria_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE inmobiliaria_db;

SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------------------------
-- 1. ROL  (catalogo de roles del sistema)
-- -----------------------------------------------------------------------------
CREATE TABLE rol (
    id_rol       INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(30)  NOT NULL,
    descripcion  VARCHAR(150) NULL,
    CONSTRAINT uq_rol_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 2. USUARIO  (solo credenciales y estado de la cuenta)
--    La contrasena se guarda SIEMPRE cifrada (BCrypt) -> nunca en texto plano.
-- -----------------------------------------------------------------------------
CREATE TABLE usuario (
    id_usuario        INT AUTO_INCREMENT PRIMARY KEY,
    correo            VARCHAR(120) NOT NULL,
    password_hash     VARCHAR(100) NOT NULL,          -- hash BCrypt ($2a$...)
    activo            TINYINT(1)   NOT NULL DEFAULT 1, -- baja logica de la cuenta
    intentos_fallidos INT          NOT NULL DEFAULT 0, -- valor agregado: bloqueo
    bloqueado_hasta   DATETIME     NULL,
    fecha_registro    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso     DATETIME     NULL,
    CONSTRAINT uq_usuario_correo UNIQUE (correo),
    CONSTRAINT chk_usuario_correo CHECK (correo LIKE '%_@_%._%')
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 3. USUARIO_ROL  (N:M usuario <-> rol) - PK compuesta + atributo propio
-- -----------------------------------------------------------------------------
CREATE TABLE usuario_rol (
    id_usuario       INT NOT NULL,
    id_rol           INT NOT NULL,
    fecha_asignacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario, id_rol),
    CONSTRAINT fk_ur_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ur_rol FOREIGN KEY (id_rol) REFERENCES rol(id_rol)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 4. PERFIL  (1:1 con usuario) - datos personales
--    id_usuario UNIQUE => un usuario no puede tener dos perfiles.
-- -----------------------------------------------------------------------------
CREATE TABLE perfil (
    id_perfil     INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario    INT          NOT NULL,
    nombres       VARCHAR(60)  NOT NULL,
    apellidos     VARCHAR(60)  NOT NULL,
    documento     VARCHAR(20)  NOT NULL,
    telefono      VARCHAR(20)  NULL,
    direccion     VARCHAR(150) NULL,
    foto_url      VARCHAR(255) NULL,
    CONSTRAINT uq_perfil_id_usuario UNIQUE (id_usuario),   -- garantiza el 1:1
    CONSTRAINT uq_perfil_documento  UNIQUE (documento),
    CONSTRAINT fk_perfil_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 5. CIUDAD  (catalogo)
-- -----------------------------------------------------------------------------
CREATE TABLE ciudad (
    id_ciudad     INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(60) NOT NULL,
    departamento  VARCHAR(60) NOT NULL,
    CONSTRAINT uq_ciudad UNIQUE (nombre, departamento)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 6. TIPO_PROPIEDAD  (catalogo: casa, apartamento, local, oficina, terreno)
-- -----------------------------------------------------------------------------
CREATE TABLE tipo_propiedad (
    id_tipo   INT AUTO_INCREMENT PRIMARY KEY,
    nombre    VARCHAR(40) NOT NULL,
    CONSTRAINT uq_tipo_propiedad UNIQUE (nombre)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 7. INMOBILIARIA (agencia).  Cada agencia la administra un usuario (agente).
-- -----------------------------------------------------------------------------
CREATE TABLE inmobiliaria (
    id_inmobiliaria INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario      INT          NOT NULL,   -- usuario con rol INMOBILIARIA
    nombre          VARCHAR(120) NOT NULL,
    nit             VARCHAR(20)  NOT NULL,
    telefono        VARCHAR(20)  NULL,
    direccion       VARCHAR(150) NULL,
    activo          TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT uq_inmobiliaria_nit UNIQUE (nit),
    CONSTRAINT fk_inmobiliaria_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 8. PROPIEDAD  (nucleo del negocio)
--    1:N  inmobiliaria -> propiedad
--    N:1  propiedad -> ciudad, propiedad -> tipo_propiedad
--    baja logica con el campo "activo"
-- -----------------------------------------------------------------------------
CREATE TABLE propiedad (
    id_propiedad           INT AUTO_INCREMENT PRIMARY KEY,
    id_inmobiliaria        INT            NOT NULL,
    id_ciudad              INT            NOT NULL,
    id_tipo                INT            NOT NULL,
    matricula_inmobiliaria VARCHAR(30)    NOT NULL,
    titulo                 VARCHAR(150)   NOT NULL,
    descripcion            TEXT           NULL,
    direccion              VARCHAR(150)   NOT NULL,
    precio                 DECIMAL(15,2)  NOT NULL,
    operacion              ENUM('VENTA','ARRIENDO') NOT NULL DEFAULT 'VENTA',
    area_m2                DECIMAL(8,2)   NOT NULL,
    habitaciones           INT            NOT NULL DEFAULT 0,
    banos                  INT            NOT NULL DEFAULT 0,
    parqueaderos           INT            NOT NULL DEFAULT 0,
    estado                 ENUM('DISPONIBLE','RESERVADA','VENDIDA','ARRENDADA') NOT NULL DEFAULT 'DISPONIBLE',
    activo                 TINYINT(1)     NOT NULL DEFAULT 1,
    fecha_publicacion      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_propiedad_matricula UNIQUE (matricula_inmobiliaria),
    CONSTRAINT chk_propiedad_precio CHECK (precio > 0),
    CONSTRAINT chk_propiedad_area   CHECK (area_m2 > 0),
    CONSTRAINT fk_propiedad_inmobiliaria FOREIGN KEY (id_inmobiliaria) REFERENCES inmobiliaria(id_inmobiliaria)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_propiedad_ciudad FOREIGN KEY (id_ciudad) REFERENCES ciudad(id_ciudad)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_propiedad_tipo FOREIGN KEY (id_tipo) REFERENCES tipo_propiedad(id_tipo)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 9. IMAGEN_PROPIEDAD  (1:N  propiedad -> imagenes de la galeria)
-- -----------------------------------------------------------------------------
CREATE TABLE imagen_propiedad (
    id_imagen    INT AUTO_INCREMENT PRIMARY KEY,
    id_propiedad INT          NOT NULL,
    url          VARCHAR(255) NOT NULL,
    es_portada   TINYINT(1)   NOT NULL DEFAULT 0,
    orden        INT          NOT NULL DEFAULT 1,
    CONSTRAINT fk_imagen_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 10. CARACTERISTICA  (catalogo: piscina, parqueadero, ascensor, gimnasio...)
-- -----------------------------------------------------------------------------
CREATE TABLE caracteristica (
    id_caracteristica INT AUTO_INCREMENT PRIMARY KEY,
    nombre            VARCHAR(50) NOT NULL,
    CONSTRAINT uq_caracteristica UNIQUE (nombre)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 11. PROPIEDAD_CARACTERISTICA  (N:M) - PK compuesta + atributo propio
-- -----------------------------------------------------------------------------
CREATE TABLE propiedad_caracteristica (
    id_propiedad      INT NOT NULL,
    id_caracteristica INT NOT NULL,
    cantidad          INT NOT NULL DEFAULT 1,
    PRIMARY KEY (id_propiedad, id_caracteristica),
    CONSTRAINT fk_pc_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pc_caracteristica FOREIGN KEY (id_caracteristica) REFERENCES caracteristica(id_caracteristica)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 12. FAVORITO  (N:M  cliente(usuario) <-> propiedad)
-- -----------------------------------------------------------------------------
CREATE TABLE favorito (
    id_usuario     INT NOT NULL,
    id_propiedad   INT NOT NULL,
    fecha_agregado DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario, id_propiedad),
    CONSTRAINT fk_favorito_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_favorito_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 13. CITA  (1:N cliente -> citas ; 1:N propiedad -> citas)
--     UNIQUE (id_propiedad, fecha_hora) -> no dos visitas al mismo inmueble
--     en el mismo horario.
-- -----------------------------------------------------------------------------
CREATE TABLE cita (
    id_cita       INT AUTO_INCREMENT PRIMARY KEY,
    id_propiedad  INT      NOT NULL,
    id_cliente    INT      NOT NULL,   -- usuario con rol CLIENTE
    fecha_hora    DATETIME NOT NULL,
    estado        ENUM('PENDIENTE','CONFIRMADA','CANCELADA','REALIZADA') NOT NULL DEFAULT 'PENDIENTE',
    observaciones VARCHAR(255) NULL,
    fecha_solicitud DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_cita_propiedad_horario UNIQUE (id_propiedad, fecha_hora),
    CONSTRAINT fk_cita_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cita_cliente FOREIGN KEY (id_cliente) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 14. SOLICITUD  (compra o arriendo radicada por un cliente sobre una propiedad)
-- -----------------------------------------------------------------------------
CREATE TABLE solicitud (
    id_solicitud   INT AUTO_INCREMENT PRIMARY KEY,
    id_propiedad   INT      NOT NULL,
    id_cliente     INT      NOT NULL,
    tipo           ENUM('COMPRA','ARRIENDO') NOT NULL,
    estado         ENUM('RADICADA','EN_REVISION','APROBADA','RECHAZADA') NOT NULL DEFAULT 'RADICADA',
    oferta         DECIMAL(15,2) NULL,
    comentario     VARCHAR(255)  NULL,
    fecha_radicacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_resolucion DATETIME NULL,
    CONSTRAINT fk_solicitud_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_solicitud_cliente FOREIGN KEY (id_cliente) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 15. DOCUMENTO_SOLICITUD  (1:N  solicitud -> documentos radicados)
-- -----------------------------------------------------------------------------
CREATE TABLE documento_solicitud (
    id_documento  INT AUTO_INCREMENT PRIMARY KEY,
    id_solicitud  INT          NOT NULL,
    nombre        VARCHAR(120) NOT NULL,
    url           VARCHAR(255) NOT NULL,
    estado        ENUM('PENDIENTE','ACEPTADO','RECHAZADO') NOT NULL DEFAULT 'PENDIENTE',
    fecha_carga   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_documento_solicitud FOREIGN KEY (id_solicitud) REFERENCES solicitud(id_solicitud)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 16. AUDITORIA  (registro de accesos y cambios del sistema)
-- -----------------------------------------------------------------------------
CREATE TABLE auditoria (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario   INT          NULL,       -- puede ser NULL: intento anonimo
    accion       VARCHAR(80)  NOT NULL,   -- LOGIN_OK, LOGIN_FAIL, CREAR_PROPIEDAD...
    entidad      VARCHAR(40)  NULL,
    id_entidad   INT          NULL,
    detalle      VARCHAR(255) NULL,
    ip           VARCHAR(45)  NULL,
    fecha        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_auditoria_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- Indices de apoyo para los filtros de busqueda y reportes
-- -----------------------------------------------------------------------------
CREATE INDEX idx_propiedad_ciudad   ON propiedad (id_ciudad);
CREATE INDEX idx_propiedad_tipo     ON propiedad (id_tipo);
CREATE INDEX idx_propiedad_precio   ON propiedad (precio);
CREATE INDEX idx_propiedad_estado   ON propiedad (estado);
CREATE INDEX idx_cita_estado        ON cita (estado);
CREATE INDEX idx_solicitud_estado   ON solicitud (estado);
CREATE INDEX idx_auditoria_fecha    ON auditoria (fecha);

SET FOREIGN_KEY_CHECKS = 1;
