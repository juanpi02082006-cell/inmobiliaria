package com.inmobiliaria.dao;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import com.inmobiliaria.config.ConexionBD;
import com.inmobiliaria.modelo.Usuario;

/**
 * Pruebas de seguridad y de capa de datos sobre {@link UsuarioDAO#autenticar}:
 * es la puerta de entrada de todo el sistema de roles.
 *
 * autenticar() SI tiene efectos secundarios (cuenta los intentos fallidos
 * para el bloqueo temporal), asi que estas pruebas guardan el estado del
 * usuario de prueba antes de tocarlo y lo restauran despues, sin importar si
 * la prueba paso o fallo. Correr la clase muchas veces seguidas nunca deberia
 * terminar bloqueando la cuenta usada en los datos de prueba.
 */
class UsuarioDAOTest {

    /** Cliente de los datos de prueba (02_datos.sql), contrasena "password". */
    private static final String CORREO_VALIDO = "carlos.perez@gmail.com";
    private static final String PASSWORD_VALIDA = "password";

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    private int intentosOriginales;
    private Timestamp bloqueoOriginal;

    @BeforeEach
    void guardarEstadoOriginal() throws Exception {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(
                 "SELECT intentos_fallidos, bloqueado_hasta FROM usuario WHERE correo = ?")) {
            ps.setString(1, CORREO_VALIDO);
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next(), "el usuario de prueba " + CORREO_VALIDO + " deberia existir (02_datos.sql)");
                intentosOriginales = rs.getInt("intentos_fallidos");
                bloqueoOriginal = rs.getTimestamp("bloqueado_hasta");
            }
        }
    }

    @AfterEach
    void restaurarEstadoOriginal() throws Exception {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(
                 "UPDATE usuario SET intentos_fallidos = ?, bloqueado_hasta = ? WHERE correo = ?")) {
            ps.setInt(1, intentosOriginales);
            ps.setTimestamp(2, bloqueoOriginal);
            ps.setString(3, CORREO_VALIDO);
            ps.executeUpdate();
        }
    }

    @Test
    @DisplayName("credenciales correctas autentican y devuelven los roles del usuario")
    void credencialesCorrectasAutentican() throws Exception {
        Usuario u = usuarioDAO.autenticar(CORREO_VALIDO, PASSWORD_VALIDA);

        assertNotNull(u, "deberia autenticar con la contrasena correcta");
        assertEquals(CORREO_VALIDO, u.getCorreo());
        assertFalse(u.getRoles().isEmpty(), "deberia traer al menos un rol (relacion N:M usuario_rol)");
    }

    @Test
    @DisplayName("contrasena incorrecta no autentica, aunque el correo exista")
    void contrasenaIncorrectaNoAutentica() throws Exception {
        Usuario u = usuarioDAO.autenticar(CORREO_VALIDO, "esta-no-es-la-clave");
        assertNull(u, "no deberia autenticar con una contrasena incorrecta");
    }

    @Test
    @DisplayName("un correo que no existe no autentica y no revienta con una excepcion")
    void correoInexistenteNoAutentica() throws Exception {
        Usuario u = usuarioDAO.autenticar("nadie-registrado@correo-falso.com", "cualquiera");
        assertNull(u);
    }

    @Test
    @DisplayName("el usuario de prueba no deberia estar bloqueado en condiciones normales")
    void usuarioDePruebaNoEstaBloqueado() throws Exception {
        assertFalse(usuarioDAO.estaBloqueado(CORREO_VALIDO));
    }
}
