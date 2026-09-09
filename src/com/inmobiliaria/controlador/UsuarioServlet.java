package com.inmobiliaria.controlador;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.inmobiliaria.dao.AuditoriaDAO;
import com.inmobiliaria.dao.UsuarioDAO;
import com.inmobiliaria.modelo.Usuario;

/**
 * Administracion de usuarios: asignar y revocar roles, activar e inactivar
 * cuentas.
 *
 * Solo para el rol ADMIN. La ruta cuelga de /panel/admin, asi que
 * AutenticacionFilter ya exige ese rol antes de llegar aqui.
 *
 * Dos reglas impiden que el administrador se deje a si mismo o al sistema
 * sin salida: no puede inactivar su propia cuenta ni quitarse el rol ADMIN,
 * y no se puede dejar el sistema sin ningun administrador activo.
 */
@WebServlet(name = "UsuarioServlet", urlPatterns = {"/panel/admin/usuarios"})
public class UsuarioServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String VISTA = "/WEB-INF/vistas/usuario-lista.jsp";

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();
    private final AuditoriaDAO auditoriaDAO = new AuditoriaDAO();

    @Override
    protected void doGet(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {
        mostrar(peticion, respuesta, null);
    }

    @Override
    protected void doPost(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        peticion.setCharacterEncoding("UTF-8");

        Usuario admin = usuarioEnSesion(peticion);
        String accion = valor(peticion.getParameter("accion"));
        int idUsuario = entero(peticion.getParameter("id"));
        String base = peticion.getContextPath() + "/panel/admin/usuarios";

        if (idUsuario <= 0) {
            respuesta.sendRedirect(base);
            return;
        }

        try {
            if ("roles".equals(accion)) {
                asignarRoles(peticion, respuesta, admin, idUsuario, base);

            } else if ("activar".equals(accion) || "inactivar".equals(accion)) {
                cambiarEstado(peticion, respuesta, admin, idUsuario,
                              "activar".equals(accion), base);

            } else {
                respuesta.sendRedirect(base);
            }

        } catch (SQLException e) {
            log("Error de base de datos administrando usuarios", e);
            mostrar(peticion, respuesta, "No fue posible guardar los cambios. Intente mas tarde.");
        }
    }

    // =========================================================================

    private void asignarRoles(HttpServletRequest peticion, HttpServletResponse respuesta,
                              Usuario admin, int idUsuario, String base)
            throws ServletException, IOException, SQLException {

        int[] roles = enteros(peticion.getParameterValues("roles"));

        if (roles.length == 0) {
            mostrar(peticion, respuesta, "Un usuario debe conservar al menos un rol.");
            return;
        }

        Usuario destino = usuarioDAO.buscarPorId(idUsuario);
        if (destino == null) {
            respuesta.sendRedirect(base);
            return;
        }

        // El administrador no puede quitarse a si mismo el rol ADMIN: se
        // quedaria fuera de esta misma pantalla al recargar.
        if (destino.getId() == admin.getId() && destino.tieneRol("ADMIN") && !contiene(roles, idRolAdmin())) {
            mostrar(peticion, respuesta,
                    "No puede quitarse a si mismo el rol de administrador.");
            return;
        }

        usuarioDAO.asignarRoles(idUsuario, roles);

        auditoriaDAO.registrar(admin.getId(), "ASIGNAR_ROL",
                "Cambio los roles de " + destino.getCorreo(), peticion.getRemoteAddr());

        respuesta.sendRedirect(base + "?ok=roles");
    }

    private void cambiarEstado(HttpServletRequest peticion, HttpServletResponse respuesta,
                               Usuario admin, int idUsuario, boolean activar, String base)
            throws ServletException, IOException, SQLException {

        Usuario destino = usuarioDAO.buscarPorId(idUsuario);
        if (destino == null) {
            respuesta.sendRedirect(base);
            return;
        }

        if (!activar) {
            if (destino.getId() == admin.getId()) {
                mostrar(peticion, respuesta, "No puede inactivar su propia cuenta.");
                return;
            }
            // Si es el ultimo administrador activo, nadie podria volver a
            // entrar a la administracion.
            if (destino.tieneRol("ADMIN") && usuarioDAO.cuantosConRol("ADMIN") <= 1) {
                mostrar(peticion, respuesta,
                        "No puede inactivar al unico administrador activo del sistema.");
                return;
            }
        }

        usuarioDAO.cambiarEstado(idUsuario, activar);

        auditoriaDAO.registrar(admin.getId(), activar ? "ACTIVAR_CUENTA" : "INACTIVAR_CUENTA",
                destino.getCorreo(), peticion.getRemoteAddr());

        respuesta.sendRedirect(base + "?ok=" + (activar ? "activada" : "inactivada"));
    }

    // =========================================================================

    private void mostrar(HttpServletRequest peticion, HttpServletResponse respuesta, String error)
            throws ServletException, IOException {
        try {
            peticion.setAttribute("usuarios", usuarioDAO.listarTodos());
            peticion.setAttribute("catalogoRoles", usuarioDAO.roles());
        } catch (SQLException e) {
            log("Error de base de datos listando usuarios", e);
            peticion.setAttribute("usuarios", new java.util.ArrayList<Usuario>());
            peticion.setAttribute("catalogoRoles", new java.util.LinkedHashMap<Integer, String>());
            if (error == null) {
                error = "No fue posible consultar los usuarios.";
            }
        }
        peticion.setAttribute("error", error);
        peticion.setAttribute("titulo", "Usuarios y roles");
        peticion.getRequestDispatcher(VISTA).forward(peticion, respuesta);
    }

    /** Id del rol ADMIN en el catalogo. */
    private int idRolAdmin() throws SQLException {
        for (java.util.Map.Entry<Integer, String> e : usuarioDAO.roles().entrySet()) {
            if ("ADMIN".equalsIgnoreCase(e.getValue())) {
                return e.getKey().intValue();
            }
        }
        return 0;
    }

    private boolean contiene(int[] valores, int buscado) {
        for (int v : valores) {
            if (v == buscado) {
                return true;
            }
        }
        return false;
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

    private int entero(String v) {
        try {
            return Integer.parseInt(valor(v));
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private int[] enteros(String[] valores) {
        if (valores == null) {
            return new int[0];
        }
        int[] r = new int[valores.length];
        for (int i = 0; i < valores.length; i++) {
            r[i] = entero(valores[i]);
        }
        return r;
    }
}
