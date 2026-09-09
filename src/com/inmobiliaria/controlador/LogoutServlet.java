package com.inmobiliaria.controlador;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.inmobiliaria.dao.AuditoriaDAO;
import com.inmobiliaria.modelo.Usuario;

/**
 * Cierre de sesion.
 *
 * Destruye la sesion en el servidor (no basta con borrar la cookie en el
 * navegador) y devuelve al usuario a la pagina publica.
 */
@WebServlet(name = "LogoutServlet", urlPatterns = {"/logout"})
public class LogoutServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final AuditoriaDAO auditoriaDAO = new AuditoriaDAO();

    @Override
    protected void doGet(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {
        cerrarSesion(peticion, respuesta);
    }

    @Override
    protected void doPost(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {
        cerrarSesion(peticion, respuesta);
    }

    private void cerrarSesion(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws IOException {

        HttpSession sesion = peticion.getSession(false);

        if (sesion != null) {
            Object enSesion = sesion.getAttribute(LoginServlet.USUARIO_EN_SESION);
            if (enSesion instanceof Usuario) {
                Usuario usuario = (Usuario) enSesion;
                auditoriaDAO.registrar(usuario.getId(), "LOGOUT",
                        "Cierre de sesion de " + usuario.getCorreo(), peticion.getRemoteAddr());
            }
            // Invalidar borra todos los atributos en el servidor: aunque
            // alguien conserve el JSESSIONID, ya no sirve para nada.
            sesion.invalidate();
        }

        respuesta.sendRedirect(peticion.getContextPath() + "/index.jsp?sesion=cerrada");
    }
}
