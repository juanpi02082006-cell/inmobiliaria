package com.inmobiliaria.controlador;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.inmobiliaria.dao.AuditoriaDAO;
import com.inmobiliaria.dao.CitaDAO;
import com.inmobiliaria.dao.DatoDuplicadoException;
import com.inmobiliaria.dao.PropiedadDAO;
import com.inmobiliaria.modelo.Cita;
import com.inmobiliaria.modelo.Propiedad;
import com.inmobiliaria.modelo.Usuario;

/**
 * HU-09: agendar cita (lado del cliente).
 *
 * El cliente solicita una visita a un inmueble en un horario disponible. La
 * restriccion que evita que se crucen las agendas (dos visitas al mismo
 * inmueble en el mismo horario) vive en la base como UNIQUE
 * (id_propiedad, fecha_hora); este servlet la comprueba antes de guardar
 * para dar un mensaje claro, y esta preparado para el caso en que dos
 * peticiones lleguen a la vez y la comprobacion previa no alcance.
 *
 * Ruta protegida por AutenticacionFilter: exige el rol CLIENTE.
 */
@WebServlet(name = "CitaClienteServlet", urlPatterns = {"/panel/cliente/citas"})
public class CitaClienteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String VISTA_LISTA = "/WEB-INF/vistas/citas-cliente.jsp";
    private static final String VISTA_FORM = "/WEB-INF/vistas/citas-form.jsp";

    private final CitaDAO citaDAO = new CitaDAO();
    private final PropiedadDAO propiedadDAO = new PropiedadDAO();
    private final AuditoriaDAO auditoriaDAO = new AuditoriaDAO();

    // =========================================================================
    //  GET  -  mis citas, formulario para agendar
    // =========================================================================

    @Override
    protected void doGet(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        Usuario cliente = usuarioEnSesion(peticion);
        String accion = valor(peticion.getParameter("accion"));

        try {
            if ("nueva".equals(accion)) {
                mostrarFormulario(peticion, respuesta, entero(peticion.getParameter("idPropiedad"), 0), null);
            } else {
                listar(peticion, respuesta, cliente);
            }

        } catch (SQLException e) {
            log("Error de base de datos gestionando citas", e);
            peticion.setAttribute("error", "No fue posible consultar sus citas. Intente mas tarde.");
            peticion.setAttribute("citas", new java.util.ArrayList<Cita>());
            peticion.setAttribute("titulo", "Mis citas");
            peticion.getRequestDispatcher(VISTA_LISTA).forward(peticion, respuesta);
        }
    }

    // =========================================================================
    //  POST  -  agendar, cancelar
    // =========================================================================

    @Override
    protected void doPost(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        peticion.setCharacterEncoding("UTF-8");

        Usuario cliente = usuarioEnSesion(peticion);
        String accion = valor(peticion.getParameter("accion"));
        String base = peticion.getContextPath() + "/panel/cliente/citas";

        try {
            if ("agendar".equals(accion)) {
                agendar(peticion, respuesta, cliente);

            } else if ("cancelar".equals(accion)) {
                int idCita = entero(peticion.getParameter("idCita"), 0);
                if (idCita <= 0 || !citaDAO.perteneceAlCliente(idCita, cliente.getId())) {
                    denegar(peticion, respuesta);
                    return;
                }
                citaDAO.cambiarEstado(idCita, "CANCELADA");
                auditoriaDAO.registrar(cliente.getId(), "CANCELAR_CITA",
                        "Cita " + idCita + " cancelada por el cliente", peticion.getRemoteAddr());
                respuesta.sendRedirect(base + "?ok=cancelada");

            } else {
                respuesta.sendRedirect(base);
            }

        } catch (SQLException e) {
            log("Error de base de datos gestionando citas", e);
            respuesta.sendRedirect(base + "?error=bd");
        }
    }

    // =========================================================================
    //  Operaciones
    // =========================================================================

    private void listar(HttpServletRequest peticion, HttpServletResponse respuesta, Usuario cliente)
            throws ServletException, IOException, SQLException {

        peticion.setAttribute("citas", citaDAO.listarPorCliente(cliente.getId()));
        peticion.setAttribute("titulo", "Mis citas");
        peticion.getRequestDispatcher(VISTA_LISTA).forward(peticion, respuesta);
    }

    private void mostrarFormulario(HttpServletRequest peticion, HttpServletResponse respuesta,
                                   int idPropiedad, String error)
            throws ServletException, IOException, SQLException {

        Propiedad p = (idPropiedad > 0) ? propiedadDAO.buscarPorId(idPropiedad, false) : null;

        if (p == null || !esVisitable(p)) {
            peticion.setAttribute("error",
                    "Ese inmueble ya no esta disponible para agendar una visita.");
            peticion.setAttribute("citas", citaDAO.listarPorCliente(usuarioEnSesion(peticion).getId()));
            peticion.setAttribute("titulo", "Mis citas");
            peticion.getRequestDispatcher(VISTA_LISTA).forward(peticion, respuesta);
            return;
        }

        peticion.setAttribute("propiedad", p);
        peticion.setAttribute("error", error);
        peticion.setAttribute("titulo", "Agendar visita");
        peticion.getRequestDispatcher(VISTA_FORM).forward(peticion, respuesta);
    }

    private void agendar(HttpServletRequest peticion, HttpServletResponse respuesta, Usuario cliente)
            throws ServletException, IOException, SQLException {

        int idPropiedad = entero(peticion.getParameter("idPropiedad"), 0);
        Propiedad p = (idPropiedad > 0) ? propiedadDAO.buscarPorId(idPropiedad, false) : null;

        if (p == null || !esVisitable(p)) {
            peticion.setAttribute("error", "Ese inmueble ya no esta disponible para agendar una visita.");
            peticion.setAttribute("citas", citaDAO.listarPorCliente(cliente.getId()));
            peticion.setAttribute("titulo", "Mis citas");
            peticion.getRequestDispatcher(VISTA_LISTA).forward(peticion, respuesta);
            return;
        }

        Timestamp fechaHora = fechaHora(peticion.getParameter("fechaHora"));
        String observaciones = valor(peticion.getParameter("observaciones"));

        String error = validar(fechaHora, observaciones);
        if (error == null && citaDAO.horarioOcupado(idPropiedad, fechaHora)) {
            error = "Ese horario ya esta ocupado para este inmueble. Elija otra fecha u hora.";
        }
        if (error != null) {
            peticion.setAttribute("propiedad", p);
            peticion.setAttribute("error", error);
            peticion.setAttribute("titulo", "Agendar visita");
            peticion.getRequestDispatcher(VISTA_FORM).forward(peticion, respuesta);
            return;
        }

        Cita c = new Cita();
        c.setIdPropiedad(idPropiedad);
        c.setIdCliente(cliente.getId());
        c.setFechaHora(fechaHora);
        c.setObservaciones(observaciones.isEmpty() ? null : observaciones);

        try {
            citaDAO.agendar(c);
            auditoriaDAO.registrar(cliente.getId(), "AGENDAR_CITA",
                    "Visita a " + p.getTitulo() + " (" + p.getMatricula() + ")",
                    peticion.getRemoteAddr());
            respuesta.sendRedirect(peticion.getContextPath() + "/panel/cliente/citas?ok=agendada");

        } catch (DatoDuplicadoException e) {
            peticion.setAttribute("propiedad", p);
            peticion.setAttribute("error", e.getMessage());
            peticion.setAttribute("titulo", "Agendar visita");
            peticion.getRequestDispatcher(VISTA_FORM).forward(peticion, respuesta);
        }
    }

    /** Solo tiene sentido agendar una visita a un inmueble activo que aun se puede negociar. */
    private boolean esVisitable(Propiedad p) {
        return p.isActivo() && ("DISPONIBLE".equals(p.getEstado()) || "RESERVADA".equals(p.getEstado()));
    }

    private String validar(Timestamp fechaHora, String observaciones) {
        if (fechaHora == null) {
            return "Indique una fecha y hora validas para la visita.";
        }
        if (fechaHora.getTime() <= System.currentTimeMillis()) {
            return "La visita debe agendarse en una fecha y hora futuras.";
        }
        if (observaciones.length() > 255) {
            return "Las observaciones no pueden superar los 255 caracteres.";
        }
        return null;
    }

    // =========================================================================
    //  Apoyo
    // =========================================================================

    private void denegar(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {
        respuesta.setStatus(HttpServletResponse.SC_FORBIDDEN);
        peticion.setAttribute("rolExigido", "el cliente que agendo la cita");
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

    /**
     * Convierte el valor de un input type="datetime-local" ("2026-09-20T15:30")
     * a Timestamp. Devuelve null si el formato no es el esperado.
     */
    private Timestamp fechaHora(String v) {
        String texto = valor(v);
        if (texto.length() != 16 || texto.charAt(10) != 'T') {
            return null;
        }
        try {
            return Timestamp.valueOf(texto.replace('T', ' ') + ":00");
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
