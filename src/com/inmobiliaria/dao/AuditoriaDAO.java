package com.inmobiliaria.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import com.inmobiliaria.config.ConexionBD;
import com.inmobiliaria.modelo.RegistroAuditoria;

/**
 * Registro de actividad en la tabla auditoria.
 *
 * Es el "valor agregado" que sugiere el enunciado: dejar rastro de los accesos
 * y los cambios para que el administrador pueda revisarlos despues.
 *
 * Ninguna operacion de auditoria debe tumbar la operacion real: si falla el
 * insert, se anota en el log del servidor y la aplicacion sigue. Por eso los
 * metodos no propagan SQLException.
 */
public class AuditoriaDAO {

    /**
     * Deja constancia de una accion.
     *
     * @param idUsuario quien la ejecuto; null si fue un intento anonimo
     *                  (por ejemplo un login fallido con un correo inexistente).
     * @param accion    codigo corto: LOGIN_OK, LOGIN_FAIL, LOGOUT, REGISTRO...
     * @param detalle   texto libre con el contexto.
     * @param ip        direccion desde la que se hizo la peticion.
     */
    public void registrar(Integer idUsuario, String accion, String detalle, String ip) {
        String sql = "INSERT INTO auditoria (id_usuario, accion, detalle, ip) VALUES (?, ?, ?, ?)";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            if (idUsuario == null) {
                ps.setNull(1, Types.INTEGER);
            } else {
                ps.setInt(1, idUsuario.intValue());
            }
            ps.setString(2, accion);
            ps.setString(3, recortar(detalle, 255));
            ps.setString(4, recortar(ip, 45));

            ps.executeUpdate();

        } catch (SQLException e) {
            // La auditoria es un apoyo, no el negocio: si falla, se anota en el
            // log de Tomcat pero el usuario no se entera ni pierde su operacion.
            System.err.println("[auditoria] no se pudo registrar '" + accion + "': " + e.getMessage());
        }
    }

    /** Evita que un texto largo reviente el ancho de la columna. */
    private String recortar(String texto, int max) {
        if (texto == null) {
            return null;
        }
        return (texto.length() <= max) ? texto : texto.substring(0, max);
    }

    // =========================================================================
    //  Consulta (HU-13)
    // =========================================================================

    /**
     * Bitacora con filtros opcionales, la mas reciente primero.
     *
     * @param accion código exacto de la accion (LOGIN_OK, CREAR_PROPIEDAD...);
     *               null o vacio para todas.
     * @param correo correo del usuario, con coincidencia parcial (LIKE);
     *               null o vacio para todos, incluidos los intentos anonimos.
     * @param limite maximo de filas a traer, para no cargar toda la tabla.
     */
    public List<RegistroAuditoria> listar(String accion, String correo, int limite) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT a.id_auditoria, a.id_usuario, u.correo, a.accion, a.detalle, a.ip, a.fecha "
          + "  FROM auditoria a "
          + "  LEFT JOIN usuario u ON u.id_usuario = a.id_usuario "
          + " WHERE 1 = 1 ");

        List<Object> parametros = new ArrayList<Object>();

        if (accion != null && !accion.trim().isEmpty()) {
            sql.append(" AND a.accion = ? ");
            parametros.add(accion.trim());
        }
        if (correo != null && !correo.trim().isEmpty()) {
            sql.append(" AND u.correo LIKE ? ");
            parametros.add("%" + correo.trim() + "%");
        }

        sql.append(" ORDER BY a.fecha DESC LIMIT ?");
        parametros.add(Integer.valueOf(limite));

        List<RegistroAuditoria> lista = new ArrayList<RegistroAuditoria>();
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql.toString())) {

            for (int i = 0; i < parametros.size(); i++) {
                ps.setObject(i + 1, parametros.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RegistroAuditoria r = new RegistroAuditoria();
                    r.setId(rs.getInt("id_auditoria"));
                    int idUsuario = rs.getInt("id_usuario");
                    r.setIdUsuario(rs.wasNull() ? null : Integer.valueOf(idUsuario));
                    r.setCorreoUsuario(rs.getString("correo"));
                    r.setAccion(rs.getString("accion"));
                    r.setDetalle(rs.getString("detalle"));
                    r.setIp(rs.getString("ip"));
                    r.setFecha(rs.getTimestamp("fecha"));
                    lista.add(r);
                }
            }
        }
        return lista;
    }

    /** Codigos de accion distintos que ya aparecen en la bitacora, para armar el filtro. */
    public List<String> accionesDistintas() throws SQLException {
        List<String> acciones = new ArrayList<String>();
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(
                 "SELECT DISTINCT accion FROM auditoria ORDER BY accion");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                acciones.add(rs.getString(1));
            }
        }
        return acciones;
    }
}
