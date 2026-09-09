package com.inmobiliaria.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.inmobiliaria.config.ConexionBD;

/**
 * Galeria de imagenes de un inmueble: el lado "muchos" de la relacion 1:N
 * entre propiedad e imagen_propiedad.
 *
 * Las fotos se guardan como rutas (por ejemplo img/casa-barrio.jpg), no como
 * binarios dentro de la base de datos.
 */
public class ImagenDAO {

    /**
     * Agrega una foto al final de la galeria.
     *
     * Si es la primera del inmueble queda marcada como portada
     * automaticamente, para que la tarjeta del catalogo nunca salga sin foto.
     */
    public void agregar(int idPropiedad, String url) throws SQLException {
        try (Connection cn = ConexionBD.obtener()) {

            boolean esLaPrimera = contar(cn, idPropiedad) == 0;
            int siguiente = siguienteOrden(cn, idPropiedad);

            try (PreparedStatement ps = cn.prepareStatement(
                     "INSERT INTO imagen_propiedad (id_propiedad, url, es_portada, orden) "
                   + "VALUES (?,?,?,?)")) {
                ps.setInt(1, idPropiedad);
                ps.setString(2, url);
                ps.setBoolean(3, esLaPrimera);
                ps.setInt(4, siguiente);
                ps.executeUpdate();
            }
        }
    }

    /**
     * Elimina una foto.
     *
     * Si la borrada era la portada, se asciende la mas antigua de las que
     * quedan, para que el inmueble no se quede sin imagen de portada.
     */
    public void eliminar(int idImagen, int idPropiedad) throws SQLException {
        try (Connection cn = ConexionBD.obtener()) {

            boolean eraPortada;
            try (PreparedStatement ps = cn.prepareStatement(
                     "SELECT es_portada FROM imagen_propiedad WHERE id_imagen = ? AND id_propiedad = ?")) {
                ps.setInt(1, idImagen);
                ps.setInt(2, idPropiedad);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return;  // no existe o no es de este inmueble
                    }
                    eraPortada = rs.getBoolean(1);
                }
            }

            try (PreparedStatement ps = cn.prepareStatement(
                     "DELETE FROM imagen_propiedad WHERE id_imagen = ? AND id_propiedad = ?")) {
                ps.setInt(1, idImagen);
                ps.setInt(2, idPropiedad);
                ps.executeUpdate();
            }

            if (eraPortada) {
                try (PreparedStatement ps = cn.prepareStatement(
                         "UPDATE imagen_propiedad SET es_portada = 1 "
                       + " WHERE id_propiedad = ? ORDER BY orden, id_imagen LIMIT 1")) {
                    ps.setInt(1, idPropiedad);
                    ps.executeUpdate();
                }
            }
        }
    }

    /**
     * Marca una foto como portada y quita la marca a las demas.
     *
     * Las dos sentencias van en una transaccion: si fallara la segunda, el
     * inmueble quedaria con dos portadas.
     */
    public void marcarPortada(int idImagen, int idPropiedad) throws SQLException {
        Connection cn = null;
        try {
            cn = ConexionBD.obtener();
            cn.setAutoCommit(false);

            try (PreparedStatement ps = cn.prepareStatement(
                     "UPDATE imagen_propiedad SET es_portada = 0 WHERE id_propiedad = ?")) {
                ps.setInt(1, idPropiedad);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = cn.prepareStatement(
                     "UPDATE imagen_propiedad SET es_portada = 1 "
                   + " WHERE id_imagen = ? AND id_propiedad = ?")) {
                ps.setInt(1, idImagen);
                ps.setInt(2, idPropiedad);
                ps.executeUpdate();
            }

            cn.commit();

        } catch (SQLException e) {
            if (cn != null) {
                try { cn.rollback(); } catch (SQLException ignorada) { }
            }
            throw e;
        } finally {
            if (cn != null) {
                try { cn.setAutoCommit(true); cn.close(); } catch (SQLException ignorada) { }
            }
        }
    }

    private int contar(Connection cn, int idPropiedad) throws SQLException {
        try (PreparedStatement ps = cn.prepareStatement(
                 "SELECT COUNT(*) FROM imagen_propiedad WHERE id_propiedad = ?")) {
            ps.setInt(1, idPropiedad);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    private int siguienteOrden(Connection cn, int idPropiedad) throws SQLException {
        try (PreparedStatement ps = cn.prepareStatement(
                 "SELECT COALESCE(MAX(orden), 0) + 1 FROM imagen_propiedad WHERE id_propiedad = ?")) {
            ps.setInt(1, idPropiedad);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 1;
            }
        }
    }
}
