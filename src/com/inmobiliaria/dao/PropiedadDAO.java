package com.inmobiliaria.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.inmobiliaria.config.ConexionBD;
import com.inmobiliaria.modelo.Caracteristica;
import com.inmobiliaria.modelo.Imagen;
import com.inmobiliaria.modelo.Propiedad;

/**
 * Consulta del catalogo publico de propiedades.
 *
 * El CRUD completo (crear, editar, baja logica, galeria y caracteristicas)
 * corresponde al Sprint 2. Aqui esta lo que necesita el visitante: listar y
 * filtrar el catalogo.
 */
public class PropiedadDAO {

    /**
     * Consulta base del catalogo.
     *
     * Es la "consulta obligatoria 1" del enunciado: INNER JOIN entre cuatro
     * tablas (propiedad, ciudad, tipo_propiedad e inmobiliaria) mas un
     * LEFT JOIN a imagen_propiedad para traer la portada, que puede no existir.
     */
    private static final String SQL_BASE =
        "SELECT p.id_propiedad, p.matricula_inmobiliaria, p.titulo, p.descripcion, "
      + "       p.direccion, p.precio, p.operacion, p.area_m2, p.habitaciones, "
      + "       p.banos, p.parqueaderos, p.estado, p.activo, "
      + "       p.id_inmobiliaria, p.id_ciudad, p.id_tipo, "
      + "       c.nombre  AS ciudad, "
      + "       t.nombre  AS tipo, "
      + "       i.nombre  AS inmobiliaria, "
      + "       img.url   AS portada "
      + "  FROM propiedad p "
      + "  JOIN ciudad         c ON c.id_ciudad       = p.id_ciudad "
      + "  JOIN tipo_propiedad t ON t.id_tipo         = p.id_tipo "
      + "  JOIN inmobiliaria   i ON i.id_inmobiliaria = p.id_inmobiliaria "
      + "  LEFT JOIN imagen_propiedad img "
      + "         ON img.id_propiedad = p.id_propiedad AND img.es_portada = 1 "
      + " WHERE p.activo = 1 ";

    /** Catalogo completo de inmuebles activos. */
    public List<Propiedad> listar() throws SQLException {
        return filtrar(null, null, null, null);
    }

    /**
     * Catalogo con filtros opcionales.
     *
     * Los filtros se van agregando al WHERE solo si vienen con valor, y
     * siempre como parametros de PreparedStatement: nunca se concatena lo que
     * escribio el usuario dentro del SQL.
     *
     * @param tipo   nombre del tipo de propiedad; null o vacio = todos.
     * @param ciudad nombre de la ciudad; null o vacio = todas.
     * @param min    precio minimo; null = sin tope inferior.
     * @param max    precio maximo; null = sin tope superior.
     */
    public List<Propiedad> filtrar(String tipo, String ciudad, BigDecimal min, BigDecimal max)
            throws SQLException {

        StringBuilder sql = new StringBuilder(SQL_BASE);
        List<Object> parametros = new ArrayList<Object>();

        if (tieneValor(tipo)) {
            sql.append(" AND t.nombre = ? ");
            parametros.add(tipo.trim());
        }
        if (tieneValor(ciudad)) {
            sql.append(" AND c.nombre = ? ");
            parametros.add(ciudad.trim());
        }
        if (min != null) {
            sql.append(" AND p.precio >= ? ");
            parametros.add(min);
        }
        if (max != null) {
            sql.append(" AND p.precio <= ? ");
            parametros.add(max);
        }

        sql.append(" ORDER BY p.fecha_publicacion DESC ");

        List<Propiedad> resultado = new ArrayList<Propiedad>();

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql.toString())) {

            for (int i = 0; i < parametros.size(); i++) {
                ps.setObject(i + 1, parametros.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    resultado.add(mapear(rs));
                }
            }
        }
        return resultado;
    }

    /** Las N propiedades mas recientes, para las destacadas de la landing. */
    public List<Propiedad> destacadas(int cuantas) throws SQLException {
        String sql = SQL_BASE + " AND p.estado = 'DISPONIBLE' "
                   + " ORDER BY p.fecha_publicacion DESC LIMIT ?";

        List<Propiedad> resultado = new ArrayList<Propiedad>();
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, cuantas);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    resultado.add(mapear(rs));
                }
            }
        }
        return resultado;
    }

    /** Nombres de ciudad que tienen al menos una propiedad activa. */
    public List<String> ciudadesConPropiedades() throws SQLException {
        return listarNombres(
            "SELECT DISTINCT c.nombre FROM ciudad c "
          + "  JOIN propiedad p ON p.id_ciudad = c.id_ciudad "
          + " WHERE p.activo = 1 ORDER BY c.nombre");
    }

    /** Tipos de propiedad que tienen al menos un inmueble activo. */
    public List<String> tiposConPropiedades() throws SQLException {
        return listarNombres(
            "SELECT DISTINCT t.nombre FROM tipo_propiedad t "
          + "  JOIN propiedad p ON p.id_tipo = t.id_tipo "
          + " WHERE p.activo = 1 ORDER BY t.nombre");
    }

    private List<String> listarNombres(String sql) throws SQLException {
        List<String> nombres = new ArrayList<String>();
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                nombres.add(rs.getString(1));
            }
        }
        return nombres;
    }

    /** Traslada una fila del ResultSet al objeto de dominio. */
    private Propiedad mapear(ResultSet rs) throws SQLException {
        Propiedad p = new Propiedad();
        p.setId(rs.getInt("id_propiedad"));
        p.setMatricula(rs.getString("matricula_inmobiliaria"));
        p.setTitulo(rs.getString("titulo"));
        p.setDescripcion(rs.getString("descripcion"));
        p.setDireccion(rs.getString("direccion"));
        p.setPrecio(rs.getBigDecimal("precio"));
        p.setOperacion(rs.getString("operacion"));
        p.setAreaM2(rs.getBigDecimal("area_m2"));
        p.setHabitaciones(rs.getInt("habitaciones"));
        p.setBanos(rs.getInt("banos"));
        p.setParqueaderos(rs.getInt("parqueaderos"));
        p.setEstado(rs.getString("estado"));
        p.setActivo(rs.getBoolean("activo"));
        p.setIdInmobiliaria(rs.getInt("id_inmobiliaria"));
        p.setIdCiudad(rs.getInt("id_ciudad"));
        p.setIdTipo(rs.getInt("id_tipo"));
        p.setCiudad(rs.getString("ciudad"));
        p.setTipo(rs.getString("tipo"));
        p.setInmobiliaria(rs.getString("inmobiliaria"));
        p.setImagen(rs.getString("portada"));
        return p;
    }

    private boolean tieneValor(String texto) {
        return texto != null && !texto.trim().isEmpty();
    }

    // =========================================================================
    //  Lectura de una propiedad concreta
    // =========================================================================

    /**
     * Trae una propiedad con su galeria y sus caracteristicas cargadas.
     *
     * @param incluirInactivas true para que el agente pueda ver y reactivar
     *                         las que dio de baja; false para el publico.
     * @return la propiedad, o null si no existe (o esta inactiva y no se
     *         pidieron las inactivas).
     */
    public Propiedad buscarPorId(int idPropiedad, boolean incluirInactivas) throws SQLException {
        String sql = SQL_BASE.replace(" WHERE p.activo = 1 ",
                incluirInactivas ? " WHERE 1 = 1 " : " WHERE p.activo = 1 ")
                + " AND p.id_propiedad = ?";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, idPropiedad);

            Propiedad p;
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                p = mapear(rs);
            }

            p.setImagenes(cargarImagenes(cn, idPropiedad));
            p.setCaracteristicas(cargarCaracteristicas(cn, idPropiedad));
            return p;
        }
    }

    /** Galeria completa de un inmueble (1:N), la portada primero. */
    private List<Imagen> cargarImagenes(Connection cn, int idPropiedad) throws SQLException {
        String sql = "SELECT id_imagen, id_propiedad, url, es_portada, orden "
                   + "  FROM imagen_propiedad WHERE id_propiedad = ? "
                   + " ORDER BY es_portada DESC, orden, id_imagen";

        List<Imagen> lista = new ArrayList<Imagen>();
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idPropiedad);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Imagen img = new Imagen();
                    img.setId(rs.getInt("id_imagen"));
                    img.setIdPropiedad(rs.getInt("id_propiedad"));
                    img.setUrl(rs.getString("url"));
                    img.setPortada(rs.getBoolean("es_portada"));
                    img.setOrden(rs.getInt("orden"));
                    lista.add(img);
                }
            }
        }
        return lista;
    }

    /**
     * Caracteristicas asignadas al inmueble. Resuelve la relacion N:M pasando
     * por la tabla puente y trae tambien su atributo propio, la cantidad.
     */
    private List<Caracteristica> cargarCaracteristicas(Connection cn, int idPropiedad)
            throws SQLException {
        String sql = "SELECT c.id_caracteristica, c.nombre, pc.cantidad "
                   + "  FROM caracteristica c "
                   + "  JOIN propiedad_caracteristica pc ON pc.id_caracteristica = c.id_caracteristica "
                   + " WHERE pc.id_propiedad = ? ORDER BY c.nombre";

        List<Caracteristica> lista = new ArrayList<Caracteristica>();
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idPropiedad);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Caracteristica c = new Caracteristica();
                    c.setId(rs.getInt("id_caracteristica"));
                    c.setNombre(rs.getString("nombre"));
                    c.setCantidad(rs.getInt("cantidad"));
                    lista.add(c);
                }
            }
        }
        return lista;
    }

    // =========================================================================
    //  Propiedad del inmueble (quien puede tocarlo)
    // =========================================================================

    /**
     * Id de la agencia que administra este usuario, o 0 si no administra
     * ninguna. Se necesita para saber a nombre de quien se publica.
     */
    public int inmobiliariaDelUsuario(int idUsuario) throws SQLException {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(
                 "SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ? "
               + " ORDER BY id_inmobiliaria LIMIT 1")) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /**
     * ¿Este inmueble pertenece a una agencia que administra este usuario?
     *
     * Es la comprobacion que impide que un agente edite las propiedades de
     * otra inmobiliaria cambiando el id en la URL. El filtro de rutas protege
     * la seccion; esto protege el registro concreto.
     */
    public boolean perteneceAlUsuario(int idPropiedad, int idUsuario) throws SQLException {
        String sql = "SELECT 1 FROM propiedad p "
                   + "  JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria "
                   + " WHERE p.id_propiedad = ? AND i.id_usuario = ?";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idPropiedad);
            ps.setInt(2, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** Inmuebles de las agencias que administra este usuario, activos e inactivos. */
    public List<Propiedad> listarPorAgente(int idUsuario) throws SQLException {
        String sql = SQL_BASE.replace(" WHERE p.activo = 1 ", " WHERE 1 = 1 ")
                   + " AND i.id_usuario = ? ORDER BY p.activo DESC, p.fecha_publicacion DESC";

        List<Propiedad> lista = new ArrayList<Propiedad>();
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapear(rs));
                }
            }
        }
        return lista;
    }

    // =========================================================================
    //  Escritura
    // =========================================================================

    /** Codigo con el que MySQL avisa que se violo una restriccion UNIQUE. */
    private static final int ERROR_DUPLICADO = 1062;

    /**
     * Da de alta un inmueble.
     *
     * @return el id generado.
     * @throws DatoDuplicadoException si la matricula inmobiliaria ya existe.
     */
    public int crear(Propiedad p) throws SQLException, DatoDuplicadoException {
        String sql =
            "INSERT INTO propiedad (id_inmobiliaria, id_ciudad, id_tipo, "
          + " matricula_inmobiliaria, titulo, descripcion, direccion, precio, "
          + " operacion, area_m2, habitaciones, banos, parqueaderos, estado, activo) "
          + "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,1)";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            rellenar(ps, p);
            ps.executeUpdate();

            try (ResultSet claves = ps.getGeneratedKeys()) {
                if (!claves.next()) {
                    throw new SQLException("La base de datos no devolvio el id del inmueble creado.");
                }
                return claves.getInt(1);
            }

        } catch (SQLIntegrityConstraintViolationException e) {
            throw traducirDuplicado(e);
        }
    }

    /**
     * Actualiza un inmueble existente. No toca el campo activo: la baja
     * logica tiene su propio metodo.
     */
    public void actualizar(Propiedad p) throws SQLException, DatoDuplicadoException {
        String sql =
            "UPDATE propiedad SET id_inmobiliaria = ?, id_ciudad = ?, id_tipo = ?, "
          + " matricula_inmobiliaria = ?, titulo = ?, descripcion = ?, direccion = ?, "
          + " precio = ?, operacion = ?, area_m2 = ?, habitaciones = ?, banos = ?, "
          + " parqueaderos = ?, estado = ? "
          + " WHERE id_propiedad = ?";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            rellenar(ps, p);
            ps.setInt(15, p.getId());
            ps.executeUpdate();

        } catch (SQLIntegrityConstraintViolationException e) {
            throw traducirDuplicado(e);
        }
    }

    /** Los catorce parametros comunes a crear y actualizar, en el mismo orden. */
    private void rellenar(PreparedStatement ps, Propiedad p) throws SQLException {
        ps.setInt(1, p.getIdInmobiliaria());
        ps.setInt(2, p.getIdCiudad());
        ps.setInt(3, p.getIdTipo());
        ps.setString(4, p.getMatricula());
        ps.setString(5, p.getTitulo());
        ps.setString(6, p.getDescripcion());
        ps.setString(7, p.getDireccion());
        ps.setBigDecimal(8, p.getPrecio());
        ps.setString(9, p.getOperacion());
        ps.setBigDecimal(10, p.getAreaM2());
        ps.setInt(11, p.getHabitaciones());
        ps.setInt(12, p.getBanos());
        ps.setInt(13, p.getParqueaderos());
        ps.setString(14, p.getEstado());
    }

    /**
     * Baja logica: el inmueble desaparece del catalogo pero la fila se
     * conserva, junto con sus citas y solicitudes historicas.
     */
    public void darDeBaja(int idPropiedad) throws SQLException {
        cambiarActivo(idPropiedad, false);
    }

    /** Vuelve a publicar un inmueble que estaba dado de baja. */
    public void reactivar(int idPropiedad) throws SQLException {
        cambiarActivo(idPropiedad, true);
    }

    private void cambiarActivo(int idPropiedad, boolean activo) throws SQLException {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(
                 "UPDATE propiedad SET activo = ? WHERE id_propiedad = ?")) {
            ps.setBoolean(1, activo);
            ps.setInt(2, idPropiedad);
            ps.executeUpdate();
        }
    }

    /**
     * Reemplaza las caracteristicas del inmueble (relacion N:M).
     *
     * Se borran las que tenia y se insertan las nuevas dentro de una sola
     * transaccion, para que nunca quede a medias. Cada fila lleva su atributo
     * propio: la cantidad.
     *
     * @param ids       caracteristicas marcadas en el formulario.
     * @param cantidades cantidad para cada una, en el mismo orden.
     */
    public void guardarCaracteristicas(int idPropiedad, int[] ids, int[] cantidades)
            throws SQLException {

        Connection cn = null;
        try {
            cn = ConexionBD.obtener();
            cn.setAutoCommit(false);

            try (PreparedStatement borrar = cn.prepareStatement(
                     "DELETE FROM propiedad_caracteristica WHERE id_propiedad = ?")) {
                borrar.setInt(1, idPropiedad);
                borrar.executeUpdate();
            }

            if (ids != null && ids.length > 0) {
                try (PreparedStatement ins = cn.prepareStatement(
                         "INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica, cantidad) "
                       + "VALUES (?,?,?)")) {
                    for (int i = 0; i < ids.length; i++) {
                        int cantidad = (cantidades != null && i < cantidades.length && cantidades[i] > 0)
                                ? cantidades[i] : 1;
                        ins.setInt(1, idPropiedad);
                        ins.setInt(2, ids[i]);
                        ins.setInt(3, cantidad);
                        ins.addBatch();
                    }
                    ins.executeBatch();
                }
            }

            cn.commit();

        } catch (SQLException e) {
            if (cn != null) {
                try { cn.rollback(); } catch (SQLException ignorada) { /* se cierra igual */ }
            }
            throw e;
        } finally {
            if (cn != null) {
                try { cn.setAutoCommit(true); cn.close(); } catch (SQLException ignorada) { }
            }
        }
    }

    /**
     * Convierte el error 1062 de MySQL en un mensaje que el usuario entienda,
     * tal como exige el enunciado para las restricciones UNIQUE.
     */
    private DatoDuplicadoException traducirDuplicado(SQLIntegrityConstraintViolationException e) {
        String detalle = (e.getMessage() == null) ? "" : e.getMessage().toLowerCase();

        if (e.getErrorCode() == ERROR_DUPLICADO || detalle.contains("duplicate")) {
            if (detalle.contains("matricula")) {
                return new DatoDuplicadoException("matricula",
                        "Ya existe un inmueble publicado con esa matricula inmobiliaria.");
            }
        }
        return new DatoDuplicadoException(null,
                "Los datos ingresados chocan con un registro que ya existe.");
    }
}
