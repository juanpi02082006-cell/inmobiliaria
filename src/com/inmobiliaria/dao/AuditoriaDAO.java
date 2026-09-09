package com.inmobiliaria.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;

import com.inmobiliaria.config.ConexionBD;

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
}
