package com.inmobiliaria.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;

import com.inmobiliaria.config.ConexionBD;

/**
 * Consultas de resumen que alimentan los paneles.
 *
 * Son cifras pequenas y de solo lectura; los reportes completos con
 * agregacion llegan en el Sprint 3.
 */
public class ResumenDAO {

    /** Cuenta filas de una tabla del catalogo interno. */
    private int contar(String sql) throws SQLException {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /** Cuenta filas aplicando un parametro entero. */
    private int contar(String sql, int parametro) throws SQLException {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, parametro);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // --- Panel del administrador --------------------------------------------

    public int totalUsuarios() throws SQLException {
        return contar("SELECT COUNT(*) FROM usuario");
    }

    public int totalPropiedades() throws SQLException {
        return contar("SELECT COUNT(*) FROM propiedad WHERE activo = 1");
    }

    public int totalCitas() throws SQLException {
        return contar("SELECT COUNT(*) FROM cita");
    }

    public int totalSolicitudes() throws SQLException {
        return contar("SELECT COUNT(*) FROM solicitud");
    }

    /**
     * Cuantos usuarios hay por rol. Recorre la relacion N:M usuario_rol,
     * asi que un usuario con dos roles se cuenta en los dos.
     */
    public Map<String, Integer> usuariosPorRol() throws SQLException {
        String sql =
            "SELECT r.nombre, COUNT(ur.id_usuario) AS total "
          + "  FROM rol r "
          + "  LEFT JOIN usuario_rol ur ON ur.id_rol = r.id_rol "
          + " GROUP BY r.id_rol, r.nombre "
          + " ORDER BY r.id_rol";

        Map<String, Integer> resultado = new LinkedHashMap<String, Integer>();
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                resultado.put(rs.getString("nombre"), Integer.valueOf(rs.getInt("total")));
            }
        }
        return resultado;
    }

    // --- Panel de la inmobiliaria (agente) ----------------------------------

    /** Propiedades publicadas por la agencia que administra este usuario. */
    public int propiedadesDelAgente(int idUsuario) throws SQLException {
        return contar(
            "SELECT COUNT(*) "
          + "  FROM propiedad p "
          + "  JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria "
          + " WHERE i.id_usuario = ? AND p.activo = 1", idUsuario);
    }

    /** Citas pendientes sobre las propiedades de ese agente. */
    public int citasPendientesDelAgente(int idUsuario) throws SQLException {
        return contar(
            "SELECT COUNT(*) "
          + "  FROM cita c "
          + "  JOIN propiedad p    ON p.id_propiedad = c.id_propiedad "
          + "  JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria "
          + " WHERE i.id_usuario = ? AND c.estado = 'PENDIENTE'", idUsuario);
    }

    /** Solicitudes de compra o arriendo por resolver sobre las propiedades de ese agente. */
    public int solicitudesPendientesDelAgente(int idUsuario) throws SQLException {
        return contar(
            "SELECT COUNT(*) "
          + "  FROM solicitud s "
          + "  JOIN propiedad p    ON p.id_propiedad = s.id_propiedad "
          + "  JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria "
          + " WHERE i.id_usuario = ? AND s.estado IN ('RADICADA','EN_REVISION')", idUsuario);
    }

    /** Nombre de la agencia que administra el usuario, o null si no tiene. */
    public String nombreAgencia(int idUsuario) throws SQLException {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(
                 "SELECT nombre FROM inmobiliaria WHERE id_usuario = ?")) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("nombre") : null;
            }
        }
    }

    // --- Panel del cliente ---------------------------------------------------

    public int citasDelCliente(int idUsuario) throws SQLException {
        return contar("SELECT COUNT(*) FROM cita WHERE id_cliente = ?", idUsuario);
    }

    public int favoritosDelCliente(int idUsuario) throws SQLException {
        return contar("SELECT COUNT(*) FROM favorito WHERE id_usuario = ?", idUsuario);
    }

    public int solicitudesDelCliente(int idUsuario) throws SQLException {
        return contar("SELECT COUNT(*) FROM solicitud WHERE id_cliente = ?", idUsuario);
    }
}
