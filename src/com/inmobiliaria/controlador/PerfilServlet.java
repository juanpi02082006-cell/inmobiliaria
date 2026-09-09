package com.inmobiliaria.controlador;

import java.io.IOException;
import java.sql.SQLException;
import java.util.regex.Pattern;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.inmobiliaria.dao.AuditoriaDAO;
import com.inmobiliaria.dao.DatoDuplicadoException;
import com.inmobiliaria.dao.UsuarioDAO;
import com.inmobiliaria.modelo.Perfil;
import com.inmobiliaria.modelo.Usuario;

/**
 * Perfil del usuario: sus datos personales y su contrasena.
 *
 * Es la cara visible de la relacion 1:1 entre usuario y perfil. La cuenta
 * (correo, estado) vive en usuario; lo que se edita aqui vive en perfil.
 *
 * Cualquier usuario autenticado edita SU perfil y solo el suyo: el id se
 * toma de la sesion y nunca del formulario, asi que no hay forma de editar
 * el perfil de otra persona.
 */
@WebServlet(name = "PerfilServlet", urlPatterns = {"/panel/perfil"})
public class PerfilServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String VISTA = "/WEB-INF/vistas/perfil.jsp";

    private static final Pattern DOCUMENTO_VALIDO = Pattern.compile("^\\d{6,20}$");
    private static final Pattern TELEFONO_VALIDO = Pattern.compile("^\\+?[\\d\\s-]{7,20}$");
    private static final int MIN_PASSWORD = 8;

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();
    private final AuditoriaDAO auditoriaDAO = new AuditoriaDAO();

    @Override
    protected void doGet(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {
        mostrar(peticion, respuesta, null, null);
    }

    @Override
    protected void doPost(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        peticion.setCharacterEncoding("UTF-8");

        Usuario usuario = usuarioEnSesion(peticion);
        String accion = valor(peticion.getParameter("accion"));

        if ("password".equals(accion)) {
            cambiarPassword(peticion, respuesta, usuario);
        } else {
            guardarDatos(peticion, respuesta, usuario);
        }
    }

    // =========================================================================

    /** Guarda nombres, apellidos, documento, telefono y direccion. */
    private void guardarDatos(HttpServletRequest peticion, HttpServletResponse respuesta,
                              Usuario usuario)
            throws ServletException, IOException {

        Perfil p = new Perfil();
        p.setNombres(valor(peticion.getParameter("nombres")));
        p.setApellidos(valor(peticion.getParameter("apellidos")));
        p.setDocumento(valor(peticion.getParameter("documento")));
        p.setTelefono(vacioANull(peticion.getParameter("telefono")));
        p.setDireccion(vacioANull(peticion.getParameter("direccion")));

        String error = validar(p);
        if (error != null) {
            mostrar(peticion, respuesta, error, null);
            return;
        }

        try {
            usuarioDAO.guardarPerfil(usuario.getId(), p);

            // La sesion guarda una copia del usuario: hay que refrescarla o
            // el nombre del menu seguiria mostrando el valor viejo.
            refrescarSesion(peticion, usuario.getId());

            auditoriaDAO.registrar(usuario.getId(), "EDITAR_PERFIL",
                    "Actualizo sus datos personales", peticion.getRemoteAddr());

            mostrar(peticion, respuesta, null, "Sus datos se guardaron correctamente.");

        } catch (DatoDuplicadoException e) {
            mostrar(peticion, respuesta, e.getMessage(), null);

        } catch (SQLException e) {
            log("Error de base de datos guardando el perfil", e);
            mostrar(peticion, respuesta,
                    "No fue posible guardar sus datos. Intente mas tarde.", null);
        }
    }

    /** Cambia la contrasena tras comprobar la actual. */
    private void cambiarPassword(HttpServletRequest peticion, HttpServletResponse respuesta,
                                 Usuario usuario)
            throws ServletException, IOException {

        String actual = peticion.getParameter("passwordActual");
        String nueva = peticion.getParameter("passwordNueva");
        String repetida = peticion.getParameter("passwordRepetida");

        if (actual == null || actual.isEmpty() || nueva == null || nueva.isEmpty()) {
            mostrar(peticion, respuesta, "Escriba su contrasena actual y la nueva.", null);
            return;
        }
        if (nueva.length() < MIN_PASSWORD) {
            mostrar(peticion, respuesta,
                    "La nueva contrasena debe tener al menos " + MIN_PASSWORD + " caracteres.", null);
            return;
        }
        if (!nueva.equals(repetida)) {
            mostrar(peticion, respuesta, "Las dos contrasenas nuevas no coinciden.", null);
            return;
        }

        try {
            if (!usuarioDAO.cambiarPassword(usuario.getId(), actual, nueva)) {
                auditoriaDAO.registrar(usuario.getId(), "CAMBIO_PASSWORD_FALLIDO",
                        "Contrasena actual incorrecta", peticion.getRemoteAddr());
                mostrar(peticion, respuesta, "Su contrasena actual no es correcta.", null);
                return;
            }

            auditoriaDAO.registrar(usuario.getId(), "CAMBIO_PASSWORD",
                    "Cambio su contrasena", peticion.getRemoteAddr());
            mostrar(peticion, respuesta, null, "Su contrasena se cambio correctamente.");

        } catch (SQLException e) {
            log("Error de base de datos cambiando la contrasena", e);
            mostrar(peticion, respuesta,
                    "No fue posible cambiar la contrasena. Intente mas tarde.", null);
        }
    }

    // =========================================================================

    private void mostrar(HttpServletRequest peticion, HttpServletResponse respuesta,
                         String error, String aviso)
            throws ServletException, IOException {

        peticion.setAttribute("error", error);
        peticion.setAttribute("aviso", aviso);
        peticion.setAttribute("titulo", "Mi perfil");
        peticion.getRequestDispatcher(VISTA).forward(peticion, respuesta);
    }

    private String validar(Perfil p) {
        if (p.getNombres().isEmpty() || p.getApellidos().isEmpty() || p.getDocumento().isEmpty()) {
            return "Los nombres, apellidos y documento son obligatorios.";
        }
        if (p.getNombres().length() > 60 || p.getApellidos().length() > 60) {
            return "Los nombres y apellidos no pueden superar los 60 caracteres.";
        }
        if (!DOCUMENTO_VALIDO.matcher(p.getDocumento()).matches()) {
            return "El documento debe tener entre 6 y 20 digitos, sin puntos ni espacios.";
        }
        if (p.getTelefono() != null && !TELEFONO_VALIDO.matcher(p.getTelefono()).matches()) {
            return "El telefono no tiene un formato valido.";
        }
        if (p.getDireccion() != null && p.getDireccion().length() > 150) {
            return "La direccion no puede superar los 150 caracteres.";
        }
        return null;
    }

    /** Vuelve a leer el usuario y lo deja en la sesion con los datos frescos. */
    private void refrescarSesion(HttpServletRequest peticion, int idUsuario) throws SQLException {
        Usuario actualizado = usuarioDAO.buscarPorId(idUsuario);
        if (actualizado != null) {
            HttpSession sesion = peticion.getSession(false);
            if (sesion != null) {
                sesion.setAttribute(LoginServlet.USUARIO_EN_SESION, actualizado);
            }
        }
    }

    private Usuario usuarioEnSesion(HttpServletRequest peticion) {
        HttpSession sesion = peticion.getSession(false);
        if (sesion == null) {
            return null;
        }
        Object o = sesion.getAttribute(LoginServlet.USUARIO_EN_SESION);
        return (o instanceof Usuario) ? (Usuario) o : null;
    }

    private String valor(String v) {
        return (v == null) ? "" : v.trim();
    }

    private String vacioANull(String v) {
        String limpio = valor(v);
        return limpio.isEmpty() ? null : limpio;
    }
}
