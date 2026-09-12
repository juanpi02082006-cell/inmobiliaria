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
import com.inmobiliaria.dao.CitaDAO;
import com.inmobiliaria.modelo.Cita;
import com.inmobiliaria.modelo.Usuario;

/**
 * HU-09: agenda de visitas (lado del agente).
 *
 * El agente ve las citas solicitadas sobre las propiedades de su agencia y
 * las confirma o cancela. Complementa a {@link CitaClienteServlet}, que es
 * quien las crea.
 *
 * Ruta protegida por AutenticacionFilter: exige el rol INMOBILIARIA.
 */
@WebServlet(name = "CitaAgenteServlet", urlPatterns = {"/panel/inmobiliaria/citas"})
public class CitaAgenteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String VISTA_LISTA = "/WEB-INF/vistas/citas-agente.jsp";

    private final CitaDAO citaDAO = new CitaDAO();
    private final AuditoriaDAO auditoriaDAO = new AuditoriaDAO();

    @Override
    protected void doGet(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        Usuario agente = usuarioEnSesion(peticion);

        try {
            peticion.setAttribute("citas", citaDAO.listarPorAgente(agente.getId()));
            peticion.setAttribute("titulo", "Citas agendadas");
            peticion.getRequestDispatcher(VISTA_LISTA).forward(peticion, respuesta);

        } catch (SQLException e) {
            log("Error de base de datos consultando las citas", e);
            peticion.setAttribute("error", "No fue posible consultar las citas. Intente mas tarde.");
            peticion.setAttribute("citas", new java.util.ArrayList<Cita>());
            peticion.setAttribute("titulo", "Citas agendadas");
            peticion.getRequestDispatcher(VISTA_LISTA).forward(peticion, respuesta);
        }
    }

    @Override
    protected void doPost(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        peticion.setCharacterEncoding("UTF-8");

        Usuario agente = usuarioEnSesion(peticion);
        String accion = valor(peticion.getParameter("accion"));
        String base = peticion.getContextPath() + "/panel/inmobiliaria/citas";

        int idCita = entero(peticion.getParameter("idCita"), 0);

        try {
            if (idCita <= 0 || !citaDAO.perteneceAlAgente(idCita, agente.getId())) {
                denegar(peticion, respuesta);
                return;
            }

            if ("confirmar".equals(accion)) {
                citaDAO.cambiarEstado(idCita, "CONFIRMADA");
                auditoriaDAO.registrar(agente.getId(), "CONFIRMAR_CITA",
                        "Cita " + idCita + " confirmada por el agente", peticion.getRemoteAddr());
                respuesta.sendRedirect(base + "?ok=confirmada");

            } else if ("cancelar".equals(accion)) {
                citaDAO.cambiarEstado(idCita, "CANCELADA");
                auditoriaDAO.registrar(agente.getId(), "CANCELAR_CITA",
                        "Cita " + idCita + " cancelada por el agente", peticion.getRemoteAddr());
                respuesta.sendRedirect(base + "?ok=cancelada");

            } else if ("realizada".equals(accion)) {
                citaDAO.cambiarEstado(idCita, "REALIZADA");
                auditoriaDAO.registrar(agente.getId(), "MARCAR_CITA_REALIZADA",
                        "Cita " + idCita + " marcada como realizada", peticion.getRemoteAddr());
                respuesta.sendRedirect(base + "?ok=realizada");

            } else {
                respuesta.sendRedirect(base);
            }

        } catch (SQLException e) {
            log("Error de base de datos gestionando la cita", e);
            respuesta.sendRedirect(base + "?error=bd");
        }
    }

    private void denegar(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {
        respuesta.setStatus(HttpServletResponse.SC_FORBIDDEN);
        peticion.setAttribute("rolExigido", "el agente de la propiedad citada");
        peticion.getRequestDispatcher("/acceso-denegado.jsp").forward(peticion, respuesta);
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

    private int entero(String v, int porDefecto) {
        try {
            return Integer.parseInt(valor(v));
        } catch (NumberFormatException e) {
            return porDefecto;
        }
    }
}
