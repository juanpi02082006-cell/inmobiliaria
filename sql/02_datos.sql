-- =============================================================================
--  ARCHIVO : 02_datos.sql  ->  Script DML (datos de prueba)
--  Requisito: minimo 10 registros por tabla principal.
--
--  NOTA SOBRE CONTRASENAS:
--  Todos los usuarios se crean con la contrasena en claro  ->  "password"
--
--  El hash almacenado es PBKDF2WithHmacSHA256 con salt aleatorio, una de las
--  tres funciones que permite el enunciado (BCrypt, PBKDF2 o SHA-256 con salt).
--  Se eligio PBKDF2 porque viene incluido en el JDK: el proyecto no depende de
--  ningun .jar externo y compila en cualquier maquina sin descargar nada.
--
--  Formato:  pbkdf2$<iteraciones>$<salt Base64>$<hash Base64>   (83 caracteres)
--
--  Lo genera y lo verifica com.inmobiliaria.util.PasswordUtil:
--      PasswordUtil.cifrar("password")            -> al registrar
--      PasswordUtil.verificar(clave, hashGuardado) -> al iniciar sesion
--  NUNCA se guarda texto plano.
-- =============================================================================

USE inmobiliaria_db;
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE auditoria;
TRUNCATE TABLE documento_solicitud;
TRUNCATE TABLE solicitud;
TRUNCATE TABLE cita;
TRUNCATE TABLE favorito;
TRUNCATE TABLE propiedad_caracteristica;
TRUNCATE TABLE imagen_propiedad;
TRUNCATE TABLE propiedad;
TRUNCATE TABLE inmobiliaria;
TRUNCATE TABLE tipo_propiedad;
TRUNCATE TABLE ciudad;
TRUNCATE TABLE caracteristica;
TRUNCATE TABLE perfil;
TRUNCATE TABLE usuario_rol;
TRUNCATE TABLE usuario;
TRUNCATE TABLE rol;

SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- ROL
-- -----------------------------------------------------------------------------
INSERT INTO rol (id_rol, nombre, descripcion) VALUES
 (1,'ADMIN',        'Acceso total: usuarios, roles, catalogos y auditoria'),
 (2,'INMOBILIARIA', 'Agente: publica y administra sus propiedades y solicitudes'),
 (3,'CLIENTE',      'Busca propiedades, agenda citas y radica solicitudes'),
 (4,'VISITANTE',    'Usuario registrado sin privilegios adicionales');

-- -----------------------------------------------------------------------------
-- USUARIO  (12 registros)  -- pass en claro: "password"
-- -----------------------------------------------------------------------------
-- Observe que los 12 usuarios tienen la MISMA contrasena ("password") y sin
-- embargo los 12 hashes son DISTINTOS: eso es el salt aleatorio trabajando.
-- Sin salt, doce filas identicas delatarian que todos comparten la clave.
INSERT INTO usuario (id_usuario, correo, password_hash, activo) VALUES
 (1,'admin@inmobiliaria.com',
  'pbkdf2$120000$ld2eN+puBNPJCrKIU+cybw==$SgJkcar3b4h8bbk84NQZ/RLdfJTL5QkNOM66f7WW/QQ=',1),
 (2,'agente.norte@sraiz.com',
  'pbkdf2$120000$fT0cr1O19/PmT353U3qa5w==$AWj2aLHY3wHqLoK4twAWk80Wez6kiEuoqNtNmubp9yY=',1),
 (3,'agente.sur@sraiz.com',
  'pbkdf2$120000$NvohGIow2sI+JbD20BogvQ==$J9wpGS5qO9iM+YX1mAXMCui3Px2S3orY4Ku9gfwBICs=',1),
 (4,'agente.metro@sraiz.com',
  'pbkdf2$120000$oDsGtnAYsm5oeDuxg4d0Og==$/TzfJL5AD2dgmpjKr3iA0V2L/6XvDZNDo3J02pQ3uCc=',1),
 (5,'carlos.perez@gmail.com',
  'pbkdf2$120000$8Cvfr4KEuQWQRarDeTPCxA==$+DjcVzbFKaCmtIiO9yd2ehkpyDCmBNHojg4UWf7leuI=',1),
 (6,'diana.gomez@gmail.com',
  'pbkdf2$120000$hTXFmtr1YGG5nu/tdnv0lQ==$A6hTfX6XR83LyItbccNHhnr7MMqAd6LlLe2Jw+CnP7E=',1),
 (7,'jorge.ruiz@gmail.com',
  'pbkdf2$120000$ev+77AhFK4d9g8P6gCwKBQ==$JbW57AzLLF9Pb5S8gJWG7mgNomNKZVon/KXMLbhOqvQ=',1),
 (8,'laura.mora@gmail.com',
  'pbkdf2$120000$faKngYfHJUxdneWWEzc40w==$w2GWHpZiXtjokgzb6H5cwmGHmSlTHRmesj9UOODzgek=',1),
 (9,'andres.silva@gmail.com',
  'pbkdf2$120000$JoaOCWtfObbTQMprFXuE2Q==$FkJVpV2E3lA9GNLjYpGC6T9sTfiYCTUlyzCZWzQ1mNU=',1),
 (10,'paola.leon@gmail.com',
  'pbkdf2$120000$J/DFGZP0EvY5+/MatrHpsg==$KApv6wg8h5t4SOd5I2zVGe4G8/mC3zHYTMfuR/idxAU=',1),
 (11,'mateo.castro@gmail.com',
  'pbkdf2$120000$I6thHdkCyxKxnqGTBXtVwQ==$8qBvZo0PxgYaGIs5qa8tUkxm6W1jq3mS4Jd4yL7DnSU=',1),
 (12,'visitante@correo.com',
  'pbkdf2$120000$S9l62UnhuzwprLiRGkcgCg==$wM7fV+R2KG6qM5a0rJIrJmxsoepsCnd6smetuoQBROc=',1);

-- -----------------------------------------------------------------------------
-- USUARIO_ROL  (N:M)  -- el usuario 5 tiene 2 roles (CLIENTE + VISITANTE)
-- -----------------------------------------------------------------------------
INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
 (1,1),
 (2,2),(3,2),(4,2),
 (5,3),(6,3),(7,3),(8,3),(9,3),(10,3),(11,3),
 (5,4),(12,4);

-- -----------------------------------------------------------------------------
-- PERFIL  (1:1)  -- 12 registros
-- -----------------------------------------------------------------------------
INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) VALUES
 (1,'Julian','Jaimes',   '1098765432','3001112233','Calle 9 # 23-55, Bucaramanga'),
 (2,'Marcela','Ortiz',   '1098111222','3002223344','Cra 33 # 45-10, Bucaramanga'),
 (3,'Ricardo','Nino',    '1098333444','3003334455','Cll 200 # 20-30, Floridablanca'),
 (4,'Sandra','Vega',     '1098555666','3004445566','Cra 7 # 10-20, Giron'),
 (5,'Carlos','Perez',    '1095000111','3011000111','Cll 45 # 12-08, Bucaramanga'),
 (6,'Diana','Gomez',     '1095000222','3011000222','Cra 15 # 30-40, Bucaramanga'),
 (7,'Jorge','Ruiz',      '1095000333','3011000333','Cll 105 # 25-11, Floridablanca'),
 (8,'Laura','Mora',      '1095000444','3011000444','Cra 5 # 8-19, Giron'),
 (9,'Andres','Silva',    '1095000555','3011000555','Cll 56 # 18-22, Bucaramanga'),
 (10,'Paola','Leon',     '1095000666','3011000666','Cra 27 # 52-30, Bucaramanga'),
 (11,'Mateo','Castro',   '1095000777','3011000777','Cll 90 # 40-15, Floridablanca'),
 (12,'Visitante','Demo', '1095000888','3011000888','N/A');

-- -----------------------------------------------------------------------------
-- CIUDAD  (10 registros)
-- -----------------------------------------------------------------------------
INSERT INTO ciudad (id_ciudad, nombre, departamento) VALUES
 (1,'Bucaramanga','Santander'),
 (2,'Floridablanca','Santander'),
 (3,'Giron','Santander'),
 (4,'Piedecuesta','Santander'),
 (5,'Barrancabermeja','Santander'),
 (6,'Bogota','Cundinamarca'),
 (7,'Medellin','Antioquia'),
 (8,'Cali','Valle del Cauca'),
 (9,'Cucuta','Norte de Santander'),
 (10,'Barranquilla','Atlantico');

-- -----------------------------------------------------------------------------
-- TIPO_PROPIEDAD
-- -----------------------------------------------------------------------------
INSERT INTO tipo_propiedad (id_tipo, nombre) VALUES
 (1,'Casa'),(2,'Apartamento'),(3,'Local'),(4,'Oficina'),(5,'Terreno'),
 (6,'Bodega'),(7,'Finca'),(8,'Apartaestudio'),(9,'Consultorio'),(10,'Penthouse');

-- -----------------------------------------------------------------------------
-- CARACTERISTICA
-- -----------------------------------------------------------------------------
INSERT INTO caracteristica (id_caracteristica, nombre) VALUES
 (1,'Piscina'),(2,'Parqueadero'),(3,'Ascensor'),(4,'Gimnasio'),(5,'Porteria 24h'),
 (6,'Balcon'),(7,'Zona BBQ'),(8,'Deposito'),(9,'Aire acondicionado'),(10,'Jardin');

-- -----------------------------------------------------------------------------
-- INMOBILIARIA  (10 registros)  -- FK a usuarios con rol INMOBILIARIA
-- -----------------------------------------------------------------------------
INSERT INTO inmobiliaria (id_inmobiliaria, id_usuario, nombre, nit, telefono, direccion) VALUES
 (1,2,'Santander Raiz Norte',   '900111001-1','6076550001','Cra 33 # 45-10, Bucaramanga'),
 (2,3,'Santander Raiz Sur',     '900111002-2','6076550002','Cll 200 # 20-30, Floridablanca'),
 (3,4,'Santander Raiz Metro',   '900111003-3','6076550003','Cra 7 # 10-20, Giron'),
 (4,2,'Inversiones Cabecera',   '900111004-4','6076550004','Cra 35 # 48-20, Bucaramanga'),
 (5,3,'Habitat Floridablanca',  '900111005-5','6076550005','Cll 5 # 8-40, Floridablanca'),
 (6,4,'Giron Propiedades',      '900111006-6','6076550006','Cra 25 # 30-10, Giron'),
 (7,2,'Vivienda Piedecuesta',   '900111007-7','6076550007','Cll 6 # 9-15, Piedecuesta'),
 (8,3,'Oriente Inmobiliario',   '900111008-8','6076550008','Cra 15 # 22-33, Bucaramanga'),
 (9,4,'Metropolitana Bienes',   '900111009-9','6076550009','Cll 56 # 17-05, Bucaramanga'),
 (10,2,'Capital Inmuebles',     '900111010-0','6076550010','Cra 27 # 52-18, Bucaramanga');

-- -----------------------------------------------------------------------------
-- PROPIEDAD  (12 registros)
-- -----------------------------------------------------------------------------
INSERT INTO propiedad
 (id_propiedad,id_inmobiliaria,id_ciudad,id_tipo,matricula_inmobiliaria,titulo,descripcion,direccion,precio,operacion,area_m2,habitaciones,banos,parqueaderos,estado) VALUES
 (1,1,1,1,'MI-300-001','Casa moderna en el norte','Casa de 2 pisos, iluminada, patio interno','Calle 32 # 15-48, Bucaramanga',420000000,'VENTA',180.00,4,3,2,'DISPONIBLE'),
 (2,1,1,2,'MI-300-002','Apartamento en Cabecera','Apto remodelado cerca a centros comerciales','Cra 35 # 48-12, Bucaramanga',285000000,'VENTA',96.00,3,2,1,'DISPONIBLE'),
 (3,2,2,3,'MI-300-003','Local comercial en Florida','Local sobre via principal, alto flujo','Avenida 1 # 24-60, Floridablanca',360000000,'VENTA',120.00,0,2,4,'DISPONIBLE'),
 (4,3,3,2,'MI-300-004','Apartamento vista parque','Vista abierta, conjunto con porteria','Diagonal 5 # 9-21, Giron',245000000,'ARRIENDO',82.00,2,2,1,'DISPONIBLE'),
 (5,2,2,1,'MI-300-005','Casa familiar La Florida','Casa amplia en sector residencial','Sector La Florida, Floridablanca',530000000,'VENTA',210.00,5,4,3,'DISPONIBLE'),
 (6,4,1,4,'MI-300-006','Oficina centro empresarial','Oficina con divisiones y sala de juntas','Centro Empresarial, Bucaramanga',390000000,'ARRIENDO',160.00,0,3,4,'DISPONIBLE'),
 (7,5,2,8,'MI-300-007','Apartaestudio economico','Ideal para estudiantes, amoblado','Cll 5 # 8-40, Floridablanca',95000000,'ARRIENDO',35.00,1,1,0,'DISPONIBLE'),
 (8,6,3,1,'MI-300-008','Casa campestre Giron','Casa con jardin amplio y zona BBQ','Vereda Acapulco, Giron',610000000,'VENTA',260.00,4,3,2,'RESERVADA'),
 (9,7,4,5,'MI-300-009','Lote urbano Piedecuesta','Terreno plano listo para construir','Cll 6 # 9-15, Piedecuesta',180000000,'VENTA',300.00,0,0,0,'DISPONIBLE'),
 (10,8,1,10,'MI-300-010','Penthouse El Prado','Penthouse con terraza y jacuzzi','Cra 15 # 22-33, Bucaramanga',890000000,'VENTA',220.00,3,4,3,'DISPONIBLE'),
 (11,9,1,2,'MI-300-011','Apartamento Real de Minas','Apto 3 alcobas, conjunto cerrado','Cll 56 # 17-05, Bucaramanga',260000000,'VENTA',88.00,3,2,1,'VENDIDA'),
 (12,10,1,3,'MI-300-012','Local Cabecera cuarta etapa','Local esquinero con vitrina','Cra 27 # 52-18, Bucaramanga',320000000,'ARRIENDO',75.00,0,1,1,'DISPONIBLE');

-- -----------------------------------------------------------------------------
-- IMAGEN_PROPIEDAD  (16 registros)
-- -----------------------------------------------------------------------------
INSERT INTO imagen_propiedad (id_propiedad,url,es_portada,orden) VALUES
 (1,'img/casa-barrio.jpg',1,1),(1,'img/bucaramanga.jpg',0,2),
 (2,'img/apartamento-cabecera.jpg',1,1),(2,'img/apartamento-cacique.jpg',0,2),
 (3,'img/apartamento-cacique.jpg',1,1),
 (4,'img/apartamento-cabecera.jpg',1,1),(4,'img/bucaramanga.jpg',0,2),
 (5,'img/casa-barrio.jpg',1,1),
 (6,'img/apartamento-cacique.jpg',1,1),
 (7,'img/apartamento-cabecera.jpg',1,1),
 (8,'img/casa-barrio.jpg',1,1),(8,'img/bucaramanga.jpg',0,2),
 (9,'img/bucaramanga.jpg',1,1),
 (10,'img/apartamento-cacique.jpg',1,1),
 (11,'img/apartamento-cabecera.jpg',1,1),
 (12,'img/apartamento-cacique.jpg',1,1);

-- -----------------------------------------------------------------------------
-- PROPIEDAD_CARACTERISTICA  (N:M)  (20 registros)
-- -----------------------------------------------------------------------------
INSERT INTO propiedad_caracteristica (id_propiedad,id_caracteristica,cantidad) VALUES
 (1,2,2),(1,10,1),(1,7,1),
 (2,2,1),(2,3,1),(2,5,1),(2,6,1),
 (3,2,4),(3,9,2),
 (4,2,1),(4,5,1),(4,6,1),
 (5,1,1),(5,2,3),(5,10,1),(5,7,1),
 (6,2,4),(6,3,1),(6,9,3),
 (8,1,1),(8,10,1),(8,7,1),
 (10,1,1),(10,3,1),(10,4,1),(10,5,1),(10,6,1);

-- -----------------------------------------------------------------------------
-- FAVORITO  (N:M cliente<->propiedad)  (12 registros)
-- -----------------------------------------------------------------------------
INSERT INTO favorito (id_usuario,id_propiedad) VALUES
 (5,1),(5,2),(5,10),
 (6,3),(6,5),
 (7,4),(7,7),
 (8,8),(8,1),
 (9,10),(10,6),(11,9);

-- -----------------------------------------------------------------------------
-- CITA  (12 registros)  -- UNIQUE(id_propiedad, fecha_hora)
-- -----------------------------------------------------------------------------
INSERT INTO cita (id_propiedad,id_cliente,fecha_hora,estado,observaciones) VALUES
 (1,5,'2026-09-15 10:00:00','CONFIRMADA','Cliente interesado en compra'),
 (1,6,'2026-09-15 15:00:00','PENDIENTE',NULL),
 (2,5,'2026-09-16 09:00:00','REALIZADA','Visito con familia'),
 (3,6,'2026-09-16 11:00:00','CONFIRMADA',NULL),
 (4,7,'2026-09-17 14:00:00','PENDIENTE','Consulta arriendo'),
 (5,8,'2026-09-18 10:30:00','CANCELADA','Reprogramar'),
 (6,9,'2026-09-18 16:00:00','CONFIRMADA',NULL),
 (7,7,'2026-09-19 08:00:00','REALIZADA',NULL),
 (8,8,'2026-09-19 17:00:00','PENDIENTE','Interes alto'),
 (10,9,'2026-09-20 12:00:00','CONFIRMADA','Cliente premium'),
 (10,10,'2026-09-21 12:00:00','PENDIENTE',NULL),
 (12,11,'2026-09-22 09:30:00','PENDIENTE','Local para negocio');

-- -----------------------------------------------------------------------------
-- SOLICITUD  (10 registros)
-- -----------------------------------------------------------------------------
INSERT INTO solicitud (id_propiedad,id_cliente,tipo,estado,oferta,comentario,fecha_resolucion) VALUES
 (1,5,'COMPRA','EN_REVISION',410000000,'Oferta sujeta a credito',NULL),
 (2,6,'COMPRA','APROBADA',285000000,'Pago de contado','2026-09-05 10:00:00'),
 (3,6,'ARRIENDO','RADICADA',NULL,'Solicita canon mensual',NULL),
 (4,7,'ARRIENDO','APROBADA',2500000,'Contrato 12 meses','2026-09-06 09:00:00'),
 (5,8,'COMPRA','RECHAZADA',480000000,'Oferta muy baja','2026-09-07 16:00:00'),
 (7,7,'ARRIENDO','EN_REVISION',1200000,NULL,NULL),
 (8,8,'COMPRA','RADICADA',600000000,'Pendiente documentos',NULL),
 (10,9,'COMPRA','EN_REVISION',870000000,'Solicita avaluo',NULL),
 (11,10,'COMPRA','APROBADA',260000000,'Negocio cerrado','2026-09-08 11:00:00'),
 (12,11,'ARRIENDO','RADICADA',NULL,'Local comercial',NULL);

-- -----------------------------------------------------------------------------
-- DOCUMENTO_SOLICITUD  (12 registros)
-- -----------------------------------------------------------------------------
INSERT INTO documento_solicitud (id_solicitud,nombre,url,estado) VALUES
 (1,'Cedula.pdf','docs/1-cedula.pdf','ACEPTADO'),
 (1,'Certificado laboral.pdf','docs/1-laboral.pdf','PENDIENTE'),
 (2,'Cedula.pdf','docs/2-cedula.pdf','ACEPTADO'),
 (2,'Extractos bancarios.pdf','docs/2-extractos.pdf','ACEPTADO'),
 (3,'Cedula.pdf','docs/3-cedula.pdf','PENDIENTE'),
 (4,'Contrato firmado.pdf','docs/4-contrato.pdf','ACEPTADO'),
 (5,'Carta oferta.pdf','docs/5-oferta.pdf','RECHAZADO'),
 (6,'Cedula.pdf','docs/6-cedula.pdf','PENDIENTE'),
 (7,'Certificado ingresos.pdf','docs/7-ingresos.pdf','PENDIENTE'),
 (8,'Cedula.pdf','docs/8-cedula.pdf','PENDIENTE'),
 (9,'Promesa compraventa.pdf','docs/9-promesa.pdf','ACEPTADO'),
 (10,'Camara comercio.pdf','docs/10-camara.pdf','PENDIENTE');

-- -----------------------------------------------------------------------------
-- AUDITORIA  (12 registros)
-- -----------------------------------------------------------------------------
INSERT INTO auditoria (id_usuario,accion,entidad,id_entidad,detalle,ip) VALUES
 (1,'LOGIN_OK','usuario',1,'Inicio de sesion administrador','127.0.0.1'),
 (2,'LOGIN_OK','usuario',2,'Inicio de sesion agente','127.0.0.1'),
 (2,'CREAR_PROPIEDAD','propiedad',1,'Alta de propiedad MI-300-001','127.0.0.1'),
 (2,'CREAR_PROPIEDAD','propiedad',2,'Alta de propiedad MI-300-002','127.0.0.1'),
 (3,'EDITAR_PROPIEDAD','propiedad',3,'Cambio de precio','127.0.0.1'),
 (5,'LOGIN_FAIL','usuario',5,'Contrasena incorrecta','190.0.0.5'),
 (5,'LOGIN_OK','usuario',5,'Inicio de sesion cliente','190.0.0.5'),
 (5,'CREAR_CITA','cita',1,'Agenda visita propiedad 1','190.0.0.5'),
 (6,'CREAR_SOLICITUD','solicitud',2,'Radica solicitud de compra','190.0.0.6'),
 (3,'APROBAR_SOLICITUD','solicitud',2,'Solicitud aprobada','127.0.0.1'),
 (NULL,'ACCESO_DENEGADO','ruta',NULL,'Intento a /admin sin sesion','45.10.20.30'),
 (1,'ASIGNAR_ROL','usuario_rol',5,'Asigna rol CLIENTE al usuario 5','127.0.0.1');
