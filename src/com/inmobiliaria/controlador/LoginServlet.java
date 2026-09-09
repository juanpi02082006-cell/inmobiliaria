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
 * Inicio de sesion.
 *
 * Valida las credenciales contra la base de datos, guarda el usuario y sus
 * roles en la HttpSession y redirige al panel que corresponde al rol.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /** Nombre con el que el usuario autenticado vive en la sesion. */
    public static final String USUARIO_EN_SESION = "usuarioSesion";

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();
    private final AuditoriaDAO auditoriaDAO = new AuditoriaDAO();

    /** Entrar por GET a /login no tiene sentido: se muestra el formulario. */
    @Override
    protected void doGet(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {
        respuesta.sendRedirect(peticion.getContextPath() + "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        peticion.setCharacterEncoding("UTF-8");

        String correo = limpiar(peticion.getParameter("email"));
        String password = peticion.getParameter("password");
        String ip = peticion.getRemoteAddr();

        // --- Validacion de formato, antes de tocar la base de datos ---------
        if (correo.isEmpty() || password == null || password.isEmpty()) {
            volverAlFormulario(peticion, respuesta, correo,
                    "Escriba su correo y su contrasena.");
            return;
        }

        try {
            // --- Bloqueo temporal por intentos fallidos --------------------
            if (usuarioDAO.estaBloqueado(correo)) {
                auditoriaDAO.registrar(null, "LOGIN_BLOQUEADO", "Cuenta bloqueada: " + correo, ip);
                volverAlFormulario(peticion, respuesta, correo,
                        "La cuenta esta bloqueada temporalmente por varios intentos fallidos. "
                        + "Intente de nuevo en 15 minutos.");
                return;
            }

            Usuario usuario = usuarioDAO.autenticar(correo, password);

            // Credenciales incorrectas. El mensaje es el mismo tanto si el
            // correo no existe como si la clave esta mal, para no revelar
            // cuales correos estan registrados.
            if (usuario == null) {
                auditoriaDAO.registrar(null, "LOGIN_FAIL", "Credenciales invalidas: " + correo, ip);
                volverAlFormulario(peticion, respuesta, correo,
                        "Correo o contrasena incorrectos.");
                return;
            }

            // Cuenta desactivada por el administrador.
            if (!usuario.isActivo()) {
                auditoriaDAO.registrar(usuario.getId(), "LOGIN_INACTIVO",
                        "Cuenta inactiva: " + correo, ip);
                volverAlFormulario(peticion, respuesta, correo,
                        "Su cuenta esta inactiva. Comuniquese con el administrador.");
                return;
            }

            abrirSesion(peticion, usuario);
            auditoriaDAO.registrar(usuario.getId(), "LOGIN_OK",
                    "Ingreso como " + usuario.rolPrincipal(), ip);

            respuesta.sendRedirect(peticion.getContextPath() + rutaSegunRol(usuario));

        } catch (SQLException e) {
            // El usuario no tiene por que ver una traza de Java.
            log("Error de base de datos al autenticar a " + correo, e);
            volverAlFormulario(peticion, respuesta, correo,
                    "No fue posible conectar con la base de datos. Intente mas tarde.");
        }
    }

    /**
     * Crea la sesion del usuario.
     *
     * Se invalida primero la sesion anterior y se pide una nueva para evitar
     * la fijacion de sesion: si alguien indujo un JSESSIONID antes del login,
     * ese identificador deja de servir.
     */
    private void abrirSesion(HttpServletRequest peticion, Usuario usuario) {
        HttpSession anterior = peticion.getSession(false);
        if (anterior != null) {
            anterior.invalidate();
        }

        HttpSession sesion = peticion.getSession(true);
        sesion.setAttribute(USUARIO_EN_SESION, usuario);
        sesion.setMaxInactiveInterval(30 * 60); // 30 minutos
    }

    /** Panel de destino segun el rol de mayor privilegio. */
    private String rutaSegunRol(Usuario usuario) {
        String rol = usuario.rolPrincipal();
        if ("ADMIN".equals(rol)) {
            return "/panel/admin.jsp";
        }
        if ("INMOBILIARIA".equals(rol)) {
            return "/panel/inmobiliaria.jsp";
        }
        if ("CLIENTE".equals(rol)) {
            return "/panel/cliente.jsp";
        }
        return "/index.jsp";
    }

    /** Vuelve al formulario conservando el correo escrito y mostrando el error. */
    private void volverAlFormulario(HttpServletRequest peticion, HttpServletResponse respuesta,
                                    String correo, String mensaje)
            throws ServletException, IOException {
        peticion.setAttribute("error", mensaje);
        peticion.setAttribute("email", correo);
        peticion.getRequestDispatcher("/login.jsp").forward(peticion, respuesta);
    }

    private String limpiar(String valor) {
        return (valor == null) ? "" : valor.trim();
    }
}
