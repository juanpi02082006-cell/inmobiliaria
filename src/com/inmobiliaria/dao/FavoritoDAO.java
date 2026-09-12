package com.inmobiliaria.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.ArrayList;
import java.util.List;

import com.inmobiliaria.config.ConexionBD;
import com.inmobiliaria.modelo.Propiedad;

/**
 * Favoritos del cliente (HU-08): relacion N:M usuario &harr; propiedad, con
 * la fecha en que se agrego como atributo propio de la tabla puente.
 */
public class FavoritoDAO {

    /** Codigo con el que MySQL avisa que se violo una restriccion UNIQUE (aqui, la PK compuesta). */
    private static final int ERROR_DUPLICADO = 1062;

    /**
     * Agrega un inmueble a los favoritos del cliente.
     *
     * Es idempotente: si ya estaba marcado, la violacion de la PK compuesta
     * (id_usuario, id_propiedad) se atrapa y se ignora en lugar de
     * propagarse, porque volver a pulsar "guardar" no es un error para
     * quien usa la aplicacion.
     */
    public void agregar(int idUsuario, int idPropiedad) throws SQLException {
        String sql = "INSERT INTO favorito (id_usuario, id_propiedad) VALUES (?, ?)";
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setInt(2, idPropiedad);
            ps.executeUpdate();
        } catch (SQLIntegrityConstraintViolationException e) {
            if (e.getErrorCode() != ERROR_DUPLICADO) {
                throw e;
            }
            // Ya era favorito: nada que hacer.
        }
    }

    /** Quita un inmueble de los favoritos del cliente. No falla si no estaba. */
    public void eliminar(int idUsuario, int idPropiedad) throws SQLException {
        String sql = "DELETE FROM favorito WHERE id_usuario = ? AND id_propiedad = ?";
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setInt(2, idPropiedad);
            ps.executeUpdate();
        }
    }

    /** ¿Este cliente ya tiene este inmueble en sus favoritos? Lo usa la ficha de detalle. */
    public boolean esFavorito(int idUsuario, int idPropiedad) throws SQLException {
        String sql = "SELECT 1 FROM favorito WHERE id_usuario = ? AND id_propiedad = ?";
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setInt(2, idPropiedad);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Inmuebles que el cliente marco como favoritos, el mas reciente primero.
     *
     * Solo los que siguen activos: uno dado de baja desaparece del catalogo
     * publico y tambien de esta lista, igual que en el resto de la aplicacion.
     */
    public List<Propiedad> listarPorCliente(int idUsuario) throws SQLException {
        String sql =
            "SELECT p.id_propiedad, p.matricula_inmobiliaria, p.titulo, p.direccion, "
          + "       p.precio, p.operacion, p.area_m2, p.habitaciones, p.banos, "
          + "       p.parqueaderos, p.estado, "
          + "       c.nombre AS ciudad, t.nombre AS tipo, "
          + "       img.url AS portada "
          + "  FROM favorito f "
          + "  JOIN propiedad p ON p.id_propiedad = f.id_propiedad "
          + "  JOIN ciudad c         ON c.id_ciudad = p.id_ciudad "
          + "  JOIN tipo_propiedad t ON t.id_tipo   = p.id_tipo "
          + "  LEFT JOIN imagen_propiedad img "
          + "         ON img.id_propiedad = p.id_propiedad AND img.es_portada = 1 "
          + " WHERE f.id_usuario = ? AND p.activo = 1 "
          + " ORDER BY f.fecha_agregado DESC";

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

    private Propiedad mapear(ResultSet rs) throws SQLException {
        Propiedad p = new Propiedad();
        p.setId(rs.getInt("id_propiedad"));
        p.setMatricula(rs.getString("matricula_inmobiliaria"));
        p.setTitulo(rs.getString("titulo"));
        p.setDireccion(rs.getString("direccion"));
        p.setPrecio(rs.getBigDecimal("precio"));
        p.setOperacion(rs.getString("operacion"));
        p.setAreaM2(rs.getBigDecimal("area_m2"));
        p.setHabitaciones(rs.getInt("habitaciones"));
        p.setBanos(rs.getInt("banos"));
        p.setParqueaderos(rs.getInt("parqueaderos"));
        p.setEstado(rs.getString("estado"));
        p.setCiudad(rs.getString("ciudad"));
        p.setTipo(rs.getString("tipo"));
        p.setImagen(rs.getString("portada"));
        return p;
    }
}
