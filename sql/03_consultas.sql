-- =============================================================================
--  ARCHIVO : 03_consultas.sql  ->  Consultas obligatorias (minimo 5)
--  Ejecutar sobre inmobiliaria con los datos de 02_datos.sql cargados.
-- =============================================================================
USE inmobiliaria;

-- -----------------------------------------------------------------------------
-- CONSULTA 1  -  INNER JOIN entre 4 tablas
-- Catalogo publico: propiedades disponibles con su tipo, ciudad e inmobiliaria.
-- -----------------------------------------------------------------------------
SELECT  p.id_propiedad,
        p.titulo,
        tp.nombre        AS tipo,
        c.nombre         AS ciudad,
        c.departamento,
        i.nombre         AS inmobiliaria,
        p.precio,
        p.operacion
FROM    propiedad p
        INNER JOIN tipo_propiedad tp ON tp.id_tipo        = p.id_tipo
        INNER JOIN ciudad         c  ON c.id_ciudad       = p.id_ciudad
        INNER JOIN inmobiliaria   i  ON i.id_inmobiliaria = p.id_inmobiliaria
WHERE   p.activo = 1
  AND   p.estado = 'DISPONIBLE'
ORDER BY c.nombre, p.precio;

-- -----------------------------------------------------------------------------
-- CONSULTA 2  -  INNER JOIN entre 5 tablas
-- Agenda de citas: quien visita, que propiedad y de que inmobiliaria.
-- -----------------------------------------------------------------------------
SELECT  ci.id_cita,
        ci.fecha_hora,
        ci.estado,
        CONCAT(pe.nombres,' ',pe.apellidos) AS cliente,
        u.correo                            AS correo_cliente,
        p.titulo                            AS propiedad,
        inm.nombre                          AS inmobiliaria
FROM    cita ci
        INNER JOIN usuario   u   ON u.id_usuario       = ci.id_cliente
        INNER JOIN perfil    pe  ON pe.id_usuario      = u.id_usuario
        INNER JOIN propiedad p   ON p.id_propiedad     = ci.id_propiedad
        INNER JOIN inmobiliaria inm ON inm.id_inmobiliaria = p.id_inmobiliaria
ORDER BY ci.fecha_hora;

-- -----------------------------------------------------------------------------
-- CONSULTA 3  -  Relacion N:M resuelta (propiedad <-> caracteristica)
-- Lista de caracteristicas de cada propiedad (tabla puente).
-- -----------------------------------------------------------------------------
SELECT  p.id_propiedad,
        p.titulo,
        GROUP_CONCAT(car.nombre ORDER BY car.nombre SEPARATOR ', ') AS caracteristicas,
        COUNT(*) AS total_caracteristicas
FROM    propiedad p
        INNER JOIN propiedad_caracteristica pc ON pc.id_propiedad      = p.id_propiedad
        INNER JOIN caracteristica          car ON car.id_caracteristica = pc.id_caracteristica
GROUP BY p.id_propiedad, p.titulo
ORDER BY total_caracteristicas DESC;

-- Variante N:M: roles de cada usuario
SELECT  u.id_usuario,
        u.correo,
        GROUP_CONCAT(r.nombre ORDER BY r.nombre SEPARATOR ', ') AS roles
FROM    usuario u
        INNER JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario
        INNER JOIN rol         r  ON r.id_rol      = ur.id_rol
GROUP BY u.id_usuario, u.correo
ORDER BY u.id_usuario;

-- -----------------------------------------------------------------------------
-- CONSULTA 4  -  LEFT JOIN
-- Propiedades que AUN NO tienen citas agendadas.
-- -----------------------------------------------------------------------------
SELECT  p.id_propiedad,
        p.titulo,
        c.nombre AS ciudad,
        p.estado,
        COUNT(ci.id_cita) AS num_citas
FROM    propiedad p
        LEFT JOIN cita ci ON ci.id_propiedad = p.id_propiedad
        INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad
GROUP BY p.id_propiedad, p.titulo, c.nombre, p.estado
HAVING  num_citas = 0
ORDER BY p.id_propiedad;

-- -----------------------------------------------------------------------------
-- CONSULTA 5  -  Agregacion con GROUP BY + HAVING
-- Reporte: propiedades disponibles por ciudad (solo ciudades con 2 o mas).
-- -----------------------------------------------------------------------------
SELECT  c.nombre AS ciudad,
        c.departamento,
        COUNT(p.id_propiedad)                              AS total_propiedades,
        SUM(p.estado = 'DISPONIBLE')                       AS disponibles,
        ROUND(AVG(p.precio),0)                             AS precio_promedio,
        MIN(p.precio)                                      AS precio_min,
        MAX(p.precio)                                      AS precio_max
FROM    ciudad c
        INNER JOIN propiedad p ON p.id_ciudad = c.id_ciudad
GROUP BY c.id_ciudad, c.nombre, c.departamento
HAVING  total_propiedades >= 2
ORDER BY total_propiedades DESC;

-- -----------------------------------------------------------------------------
-- CONSULTA 6 (extra)  -  Reporte de citas por estado
-- -----------------------------------------------------------------------------
SELECT  estado,
        COUNT(*) AS total
FROM    cita
GROUP BY estado
ORDER BY total DESC;

-- -----------------------------------------------------------------------------
-- CONSULTA 7 (extra)  -  Solicitudes por inmobiliaria y estado
-- -----------------------------------------------------------------------------
SELECT  inm.nombre AS inmobiliaria,
        s.estado,
        COUNT(*)   AS total_solicitudes,
        ROUND(AVG(s.oferta),0) AS oferta_promedio
FROM    solicitud s
        INNER JOIN propiedad    p   ON p.id_propiedad     = s.id_propiedad
        INNER JOIN inmobiliaria inm ON inm.id_inmobiliaria = p.id_inmobiliaria
GROUP BY inm.nombre, s.estado
ORDER BY inm.nombre, s.estado;
