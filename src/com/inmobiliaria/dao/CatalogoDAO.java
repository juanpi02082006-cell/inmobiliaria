package com.inmobiliaria.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.inmobiliaria.config.ConexionBD;
import com.inmobiliaria.modelo.Caracteristica;

/**
 * Lectura de los catalogos del sistema: ciudades, tipos de propiedad y
 * caracteristicas.
 *
 * Alimentan los desplegables del formulario de propiedades. Se leen de la
 * base de datos y no se escriben a mano en las vistas: si el administrador
 * agrega una ciudad, aparece sola en el formulario.
 */
public class CatalogoDAO {

    /**
     * Ciudades disponibles, con el departamento en el texto para distinguir
     * dos ciudades homonimas de departamentos distintos.
     *
     * @return mapa id -> "Ciudad (Departamento)", en orden alfabetico.
     */
    public Map<Integer, String> ciudades() throws SQLException {
        Map<Integer, String> mapa = new LinkedHashMap<Integer, String>();
        String sql = "SELECT id_ciudad, nombre, departamento FROM ciudad "
                   + " ORDER BY departamento, nombre";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                mapa.put(Integer.valueOf(rs.getInt("id_ciudad")),
                         rs.getString("nombre") + " (" + rs.getString("departamento") + ")");
            }
        }
        return mapa;
    }

    /**
     * Tipos de propiedad. Son exactamente cinco: casa, apartamento, local,
     * oficina y terreno, tal como define el enunciado.
     */
    public Map<Integer, String> tipos() throws SQLException {
        Map<Integer, String> mapa = new LinkedHashMap<Integer, String>();
        String sql = "SELECT id_tipo, nombre FROM tipo_propiedad ORDER BY nombre";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                mapa.put(Integer.valueOf(rs.getInt("id_tipo")), rs.getString("nombre"));
            }
        }
        return mapa;
    }

    /** Catalogo completo de caracteristicas, para las casillas del formulario. */
    public List<Caracteristica> caracteristicas() throws SQLException {
        List<Caracteristica> lista = new ArrayList<Caracteristica>();
        String sql = "SELECT id_caracteristica, nombre FROM caracteristica ORDER BY nombre";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(new Caracteristica(rs.getInt("id_caracteristica"),
                                             rs.getString("nombre")));
            }
        }
        return lista;
    }

    /** ¿Existe ese id de ciudad? Se valida en el servidor antes de guardar. */
    public boolean existeCiudad(int idCiudad) throws SQLException {
        return existe("SELECT 1 FROM ciudad WHERE id_ciudad = ?", idCiudad);
    }

    /** ¿Existe ese id de tipo? Impide guardar un tipo fuera del catalogo. */
    public boolean existeTipo(int idTipo) throws SQLException {
        return existe("SELECT 1 FROM tipo_propiedad WHERE id_tipo = ?", idTipo);
    }

    private boolean existe(String sql, int id) throws SQLException {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // =========================================================================
    //  Escritura - solo para el administrador (HU-19)
    //
    //  Los tipos de propiedad NO se administran: el enunciado fija cinco
    //  (casa, apartamento, local, oficina y terreno) y agregar otros seria
    //  salirse del alcance del sistema.
    // =========================================================================

    /** Codigo con el que MySQL avisa que se violo una restriccion UNIQUE. */
    private static final int ERROR_DUPLICADO = 1062;

    /** Codigo con el que MySQL rechaza borrar una fila referenciada. */
    private static final int ERROR_REFERENCIADA = 1451;

    // --- Ciudades ------------------------------------------------------------

    /** Ciudades con cuantas propiedades las usan, para el panel del admin. */
    public List<Object[]> ciudadesConUso() throws SQLException {
        String sql = "SELECT c.id_ciudad, c.nombre, c.departamento, COUNT(p.id_propiedad) AS usos "
                   + "  FROM ciudad c "
                   + "  LEFT JOIN propiedad p ON p.id_ciudad = c.id_ciudad "
                   + " GROUP BY c.id_ciudad, c.nombre, c.departamento "
                   + " ORDER BY c.departamento, c.nombre";

        List<Object[]> lista = new ArrayList<Object[]>();
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(new Object[]{
                    Integer.valueOf(rs.getInt("id_ciudad")),
                    rs.getString("nombre"),
                    rs.getString("departamento"),
                    Integer.valueOf(rs.getInt("usos"))
                });
            }
        }
        return lista;
    }

    /**
     * Agrega una ciudad.
     *
     * @throws DatoDuplicadoException si ya existe esa ciudad en ese
     *         departamento. Lo garantiza el UNIQUE (nombre, departamento):
     *         puede haber dos ciudades con el mismo nombre siempre que sean
     *         de departamentos distintos.
     */
    public void crearCiudad(String nombre, String departamento)
            throws SQLException, DatoDuplicadoException {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(
                 "INSERT INTO ciudad (nombre, departamento) VALUES (?,?)")) {
            ps.setString(1, nombre);
            ps.setString(2, departamento);
            ps.executeUpdate();
        } catch (SQLIntegrityConstraintViolationException e) {
            throw duplicadoCiudad(e);
        }
    }

    /** Renombra una ciudad. Las propiedades la siguen apuntando por su id. */
    public void actualizarCiudad(int id, String nombre, String departamento)
            throws SQLException, DatoDuplicadoException {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(
                 "UPDATE ciudad SET nombre = ?, departamento = ? WHERE id_ciudad = ?")) {
            ps.setString(1, nombre);
            ps.setString(2, departamento);
            ps.setInt(3, id);
            ps.executeUpdate();
        } catch (SQLIntegrityConstraintViolationException e) {
            throw duplicadoCiudad(e);
        }
    }

    /**
     * Elimina una ciudad.
     *
     * La llave foranea propiedad.id_ciudad esta declarada ON DELETE RESTRICT,
     * asi que el motor rechaza borrar una ciudad que tenga inmuebles. Se
     * captura ese rechazo y se traduce, en lugar de mostrar el error de MySQL.
     */
    public void eliminarCiudad(int id) throws SQLException, DatoDuplicadoException {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(
                 "DELETE FROM ciudad WHERE id_ciudad = ?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLIntegrityConstraintViolationException e) {
            if (e.getErrorCode() == ERROR_REFERENCIADA) {
                throw new DatoDuplicadoException("ciudad",
                        "No se puede eliminar esa ciudad porque tiene inmuebles publicados. "
                      + "Muevalos a otra ciudad primero.");
            }
            throw e;
        }
    }

    // --- Caracteristicas -----------------------------------------------------

    /** Caracteristicas con cuantas propiedades las tienen asignadas. */
    public List<Object[]> caracteristicasConUso() throws SQLException {
        String sql = "SELECT c.id_caracteristica, c.nombre, COUNT(pc.id_propiedad) AS usos "
                   + "  FROM caracteristica c "
                   + "  LEFT JOIN propiedad_caracteristica pc "
                   + "         ON pc.id_caracteristica = c.id_caracteristica "
                   + " GROUP BY c.id_caracteristica, c.nombre "
                   + " ORDER BY c.nombre";

        List<Object[]> lista = new ArrayList<Object[]>();
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(new Object[]{
                    Integer.valueOf(rs.getInt("id_caracteristica")),
                    rs.getString("nombre"),
                    Integer.valueOf(rs.getInt("usos"))
                });
            }
        }
        return lista;
    }

    public void crearCaracteristica(String nombre) throws SQLException, DatoDuplicadoException {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(
                 "INSERT INTO caracteristica (nombre) VALUES (?)")) {
            ps.setString(1, nombre);
            ps.executeUpdate();
        } catch (SQLIntegrityConstraintViolationException e) {
            throw duplicadaCaracteristica(e);
        }
    }

    public void actualizarCaracteristica(int id, String nombre)
            throws SQLException, DatoDuplicadoException {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(
                 "UPDATE caracteristica SET nombre = ? WHERE id_caracteristica = ?")) {
            ps.setString(1, nombre);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (SQLIntegrityConstraintViolationException e) {
            throw duplicadaCaracteristica(e);
        }
    }

    /**
     * Elimina una caracteristica del catalogo.
     *
     * Aqui la llave foranea es ON DELETE CASCADE, no RESTRICT: el motor no
     * protesta y ademas retira la caracteristica de todos los inmuebles que
     * la tuvieran. Como el motor no avisa, el aviso lo da la interfaz: la
     * vista muestra a cuantos inmuebles afecta antes de confirmar.
     */
    public void eliminarCaracteristica(int id) throws SQLException {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(
                 "DELETE FROM caracteristica WHERE id_caracteristica = ?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // --- Traduccion de errores ------------------------------------------------

    private DatoDuplicadoException duplicadoCiudad(SQLIntegrityConstraintViolationException e) {
        if (e.getErrorCode() == ERROR_DUPLICADO) {
            return new DatoDuplicadoException("ciudad",
                    "Esa ciudad ya esta registrada en ese departamento.");
        }
        return new DatoDuplicadoException("ciudad",
                "No fue posible guardar la ciudad: los datos chocan con un registro existente.");
    }

    private DatoDuplicadoException duplicadaCaracteristica(SQLIntegrityConstraintViolationException e) {
        if (e.getErrorCode() == ERROR_DUPLICADO) {
            return new DatoDuplicadoException("caracteristica",
                    "Ya existe una caracteristica con ese nombre.");
        }
        return new DatoDuplicadoException("caracteristica",
                "No fue posible guardar la caracteristica.");
    }
}
