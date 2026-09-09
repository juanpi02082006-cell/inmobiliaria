# Diccionario de datos - inmobiliaria_db

Motor: MySQL 8 / MariaDB (XAMPP). Codificacion `utf8mb4_unicode_ci`. Modelo en 3FN.

## Tipos de relacion (para la sustentacion)

| Tipo | Se materializa en | Como |
|------|-------------------|------|
| 1:1  | `usuario` <-> `perfil` | `perfil.id_usuario` con restriccion `UNIQUE` (`uq_perfil_id_usuario`) |
| 1:N  | `inmobiliaria` -> `propiedad`; `propiedad` -> `imagen_propiedad`; `propiedad` -> `cita`; `usuario(cliente)` -> `cita`; `solicitud` -> `documento_solicitud` | La FK vive en el lado "muchos" con `ON DELETE`/`ON UPDATE` definidos |
| N:M  | `usuario` <-> `rol` (puente `usuario_rol`); `propiedad` <-> `caracteristica` (puente `propiedad_caracteristica`); `usuario` <-> `propiedad` (puente `favorito`) | Tabla intermedia con **PK compuesta** y atributos propios (`fecha_asignacion`, `cantidad`, `fecha_agregado`) |

## Restricciones UNIQUE (minimo 3 exigidas)

| Campo | Constraint | Motivo |
|-------|-----------|--------|
| `usuario.correo` | `uq_usuario_correo` | Es la credencial de ingreso, no puede duplicarse |
| `propiedad.matricula_inmobiliaria` | `uq_propiedad_matricula` | Identifica cada inmueble, evita publicaciones duplicadas |
| `perfil.id_usuario` | `uq_perfil_id_usuario` | Sostiene la relacion 1:1 |
| `usuario_rol(id_usuario,id_rol)` | PK compuesta | Evita roles repetidos en la relacion N:M |
| `cita(id_propiedad,fecha_hora)` | `uq_cita_propiedad_horario` | Impide dos visitas al mismo inmueble en el mismo horario |
| `perfil.documento`, `ciudad(nombre,departamento)`, `inmobiliaria.nit`, `tipo_propiedad.nombre`, `caracteristica.nombre`, `rol.nombre` | varios | Integridad de catalogos |

> La aplicacion Java debe capturar `SQLIntegrityConstraintViolationException` (codigo MySQL 1062) y mostrar un mensaje claro, p. ej. "El correo ya se encuentra registrado".

## Acciones referenciales - justificacion

- `usuario_rol`, `perfil`, `favorito`, `imagen_propiedad`, `propiedad_caracteristica`, `cita`, `solicitud`, `documento_solicitud`: **ON DELETE CASCADE**. Son datos dependientes: si se elimina el padre, no tienen sentido por si solos.
- `propiedad` -> `inmobiliaria` / `ciudad` / `tipo_propiedad`: **ON DELETE RESTRICT**. No se debe borrar un catalogo o una agencia con propiedades asociadas; primero se reasignan o se dan de baja.
- `auditoria.id_usuario`: **ON DELETE SET NULL**. El registro historico se conserva aunque el usuario desaparezca.
- Todas las FK: **ON UPDATE CASCADE** para propagar cambios de llave.

## Tablas

### rol
| Columna | Tipo | Nulo | Clave | Descripcion |
|---------|------|------|-------|-------------|
| id_rol | INT AI | No | PK | Identificador |
| nombre | VARCHAR(30) | No | UQ | ADMIN, INMOBILIARIA, CLIENTE, VISITANTE |
| descripcion | VARCHAR(150) | Si | | Descripcion del rol |

### usuario
| Columna | Tipo | Nulo | Clave | Descripcion |
|---------|------|------|-------|-------------|
| id_usuario | INT AI | No | PK | Identificador |
| correo | VARCHAR(120) | No | UQ | Credencial de ingreso |
| password_hash | VARCHAR(100) | No | | Hash BCrypt de la contrasena |
| activo | TINYINT(1) | No | | 1 activo / 0 inactivo (baja logica) |
| intentos_fallidos | INT | No | | Contador para bloqueo temporal |
| bloqueado_hasta | DATETIME | Si | | Fin del bloqueo por intentos fallidos |
| fecha_registro | DATETIME | No | | Alta de la cuenta |
| ultimo_acceso | DATETIME | Si | | Ultimo login correcto |

### usuario_rol  (N:M)
| Columna | Tipo | Nulo | Clave | Descripcion |
|---------|------|------|-------|-------------|
| id_usuario | INT | No | PK, FK->usuario | |
| id_rol | INT | No | PK, FK->rol | |
| fecha_asignacion | DATETIME | No | | Cuando se asigno el rol |

### perfil  (1:1 con usuario)
| Columna | Tipo | Nulo | Clave | Descripcion |
|---------|------|------|-------|-------------|
| id_perfil | INT AI | No | PK | |
| id_usuario | INT | No | UQ, FK->usuario | Garantiza el 1:1 |
| nombres | VARCHAR(60) | No | | |
| apellidos | VARCHAR(60) | No | | |
| documento | VARCHAR(20) | No | UQ | Documento de identidad |
| telefono | VARCHAR(20) | Si | | |
| direccion | VARCHAR(150) | Si | | |
| foto_url | VARCHAR(255) | Si | | Foto de perfil |

### ciudad
| id_ciudad INT AI PK | nombre VARCHAR(60) | departamento VARCHAR(60) | UQ(nombre,departamento) |

### tipo_propiedad
| id_tipo INT AI PK | nombre VARCHAR(40) UQ |

### inmobiliaria
| Columna | Tipo | Nulo | Clave | Descripcion |
|---------|------|------|-------|-------------|
| id_inmobiliaria | INT AI | No | PK | |
| id_usuario | INT | No | FK->usuario | Agente que la administra (rol INMOBILIARIA) |
| nombre | VARCHAR(120) | No | | |
| nit | VARCHAR(20) | No | UQ | |
| telefono | VARCHAR(20) | Si | | |
| direccion | VARCHAR(150) | Si | | |
| activo | TINYINT(1) | No | | Baja logica |

### propiedad
| Columna | Tipo | Nulo | Clave | Descripcion |
|---------|------|------|-------|-------------|
| id_propiedad | INT AI | No | PK | |
| id_inmobiliaria | INT | No | FK | Dueno de la publicacion (1:N) |
| id_ciudad | INT | No | FK | |
| id_tipo | INT | No | FK | |
| matricula_inmobiliaria | VARCHAR(30) | No | UQ | Matricula unica del inmueble |
| titulo | VARCHAR(150) | No | | |
| descripcion | TEXT | Si | | |
| direccion | VARCHAR(150) | No | | |
| precio | DECIMAL(15,2) | No | CHECK > 0 | |
| operacion | ENUM(VENTA,ARRIENDO) | No | | |
| area_m2 | DECIMAL(8,2) | No | CHECK > 0 | |
| habitaciones / banos / parqueaderos | INT | No | | |
| estado | ENUM(DISPONIBLE,RESERVADA,VENDIDA,ARRENDADA) | No | | |
| activo | TINYINT(1) | No | | Baja logica del inmueble |
| fecha_publicacion | DATETIME | No | | |

### imagen_propiedad  (1:N)
| id_imagen INT AI PK | id_propiedad INT FK | url VARCHAR(255) | es_portada TINYINT | orden INT |

### caracteristica
| id_caracteristica INT AI PK | nombre VARCHAR(50) UQ |

### propiedad_caracteristica  (N:M)
| id_propiedad INT PK,FK | id_caracteristica INT PK,FK | cantidad INT |

### favorito  (N:M)
| id_usuario INT PK,FK | id_propiedad INT PK,FK | fecha_agregado DATETIME |

### cita
| Columna | Tipo | Nulo | Clave | Descripcion |
|---------|------|------|-------|-------------|
| id_cita | INT AI | No | PK | |
| id_propiedad | INT | No | FK | |
| id_cliente | INT | No | FK->usuario | |
| fecha_hora | DATETIME | No | UQ(id_propiedad,fecha_hora) | |
| estado | ENUM(PENDIENTE,CONFIRMADA,CANCELADA,REALIZADA) | No | | |
| observaciones | VARCHAR(255) | Si | | |
| fecha_solicitud | DATETIME | No | | |

### solicitud
| id_solicitud INT AI PK | id_propiedad INT FK | id_cliente INT FK | tipo ENUM(COMPRA,ARRIENDO) | estado ENUM(RADICADA,EN_REVISION,APROBADA,RECHAZADA) | oferta DECIMAL(15,2) | comentario VARCHAR(255) | fecha_radicacion DATETIME | fecha_resolucion DATETIME |

### documento_solicitud  (1:N)
| id_documento INT AI PK | id_solicitud INT FK | nombre VARCHAR(120) | url VARCHAR(255) | estado ENUM(PENDIENTE,ACEPTADO,RECHAZADO) | fecha_carga DATETIME |

### auditoria
| id_auditoria INT AI PK | id_usuario INT FK (SET NULL) | accion VARCHAR(80) | entidad VARCHAR(40) | id_entidad INT | detalle VARCHAR(255) | ip VARCHAR(45) | fecha DATETIME |

## Como cargar

```bash
cd c:\xampp\mysql\bin
mysql -u root -p < "c:\xampp\tomcat\webapps\inmobiliaria\sql\01_esquema.sql"
mysql -u root -p inmobiliaria_db < "c:\xampp\tomcat\webapps\inmobiliaria\sql\02_datos.sql"
mysql -u root -p inmobiliaria_db < "c:\xampp\tomcat\webapps\inmobiliaria\sql\03_consultas.sql"
```

O desde phpMyAdmin: importar los archivos en ese orden.

## Usuarios de prueba (contrasena en claro: `password`)

| Correo | Rol |
|--------|-----|
| admin@inmobiliaria.com | ADMIN |
| agente.norte@sraiz.com | INMOBILIARIA |
| carlos.perez@gmail.com | CLIENTE (+ VISITANTE) |
| visitante@correo.com | VISITANTE |
