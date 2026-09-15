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
import com.inmobiliaria.dao.SolicitudDAO;
import com.inmobiliaria.modelo.DocumentoSolicitud;
import com.inmobiliaria.modelo.Solicitud;
import com.inmobiliaria.modelo.Usuario;
import com.inmobiliaria.util.ArchivoUtil;

/**
 * HU-11: resolver solicitudes (lado del agente).
 *
 * El agente revisa las solicitudes de compra o arriendo sobre las
 * propiedades de su agencia, evalua sus documentos y las aprueba o rechaza.
 * Complementa a {@link SolicitudClienteServlet}, que es quien las crea.
 *
 * Ruta protegida por AutenticacionFilter: exige el rol INMOBILIARIA.
 */
@WebServlet(name = "SolicitudAgenteServlet", urlPatterns = {"/panel/inmobiliaria/solicitudes"})
public class SolicitudAgenteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String VISTA_LISTA = "/WEB-INF/vistas/solicitudes-agente.jsp";
    private static final String VISTA_DETALLE = "/WEB-INF/vistas/solicitud-agente-detalle.jsp";

    private final SolicitudDAO solicitudDAO = new SolicitudDAO();
    private final AuditoriaDAO auditoriaDAO = new AuditoriaDAO();

    @Override
    protected void doGet(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        Usuario agente = usuarioEnSesion(peticion);
        int idSolicitud = entero(peticion.getParameter("id"), 0);

        try {
            String accion = valor(peticion.getParameter("accion"));
            if ("ver".equals(accion) && idSolicitud > 0) {
                mostrarDetalle(peticion, respuesta, agente, idSolicitud);
            } else if ("documento".equals(accion) && idSolicitud > 0) {
                abrirDocumento(peticion, respuesta, agente, idSolicitud,
                        entero(peticion.getParameter("idDocumento"), 0));
            } else {
                listar(peticion, respuesta, agente);
            }

        } catch (SQLException e) {
            log("Error de base de datos consultando las solicitudes", e);
            peticion.setAttribute("error", "No fue posible consultar las solicitudes. Intente mas tarde.");
            peticion.setAttribute("solicitudes", new java.util.ArrayList<Solicitud>());
            peticion.setAttribute("titulo", "Solicitudes recibidas");
            peticion.getRequestDispatcher(VISTA_LISTA).forward(peticion, respuesta);
        }
    }

    @Override
    protected void doPost(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        peticion.setCharacterEncoding("UTF-8");

        Usuario agente = usuarioEnSesion(peticion);
        String accion = valor(peticion.getParameter("accion"));
        int idSolicitud = entero(peticion.getParameter("idSolicitud"), 0);
        String volver = peticion.getContextPath()
                + "/panel/inmobiliaria/solicitudes?accion=ver&id=" + idSolicitud;

        try {
            if (idSolicitud <= 0 || !solicitudDAO.perteneceAlAgente(idSolicitud, agente.getId())) {
                denegar(peticion, respuesta);
                return;
            }

            // Una solicitud ya resuelta (APROBADA o RECHAZADA) es un estado
            // final: ni la solicitud ni sus documentos vuelven a cambiar,
            // aunque alguien arme el POST a mano sin pasar por la vista.
            if (!solicitudDAO.esGestionable(idSolicitud)) {
                respuesta.sendRedirect(volver + "&error=resuelta");
                return;
            }

            if ("revisar".equals(accion)) {
                solicitudDAO.cambiarEstado(idSolicitud, "EN_REVISION");
                auditoriaDAO.registrar(agente.getId(), "REVISAR_SOLICITUD",
                        "Solicitud " + idSolicitud + " puesta en revision", peticion.getRemoteAddr());
                respuesta.sendRedirect(volver + "&ok=revision");

            } else if ("aprobar".equals(accion)) {
                solicitudDAO.cambiarEstado(idSolicitud, "APROBADA");
                auditoriaDAO.registrar(agente.getId(), "APROBAR_SOLICITUD",
                        "Solicitud " + idSolicitud + " aprobada", peticion.getRemoteAddr());
                respuesta.sendRedirect(volver + "&ok=aprobada");

            } else if ("rechazar".equals(accion)) {
                solicitudDAO.cambiarEstado(idSolicitud, "RECHAZADA");
                auditoriaDAO.registrar(agente.getId(), "RECHAZAR_SOLICITUD",
                        "Solicitud " + idSolicitud + " rechazada", peticion.getRemoteAddr());
                respuesta.sendRedirect(volver + "&ok=rechazada");

            } else if ("documento-aceptar".equals(accion) || "documento-rechazar".equals(accion)) {
                int idDocumento = entero(peticion.getParameter("idDocumento"), 0);
                String nuevoEstado = "documento-aceptar".equals(accion) ? "ACEPTADO" : "RECHAZADO";
                solicitudDAO.cambiarEstadoDocumento(idDocumento, idSolicitud, nuevoEstado);
                auditoriaDAO.registrar(agente.getId(), "EVALUAR_DOCUMENTO",
                        "Documento " + idDocumento + " de la solicitud " + idSolicitud
                        + " marcado como " + nuevoEstado, peticion.getRemoteAddr());
                respuesta.sendRedirect(volver + "&ok=documento");

            } else {
                respuesta.sendRedirect(volver);
            }

        } catch (SQLException e) {
            log("Error de base de datos resolviendo la solicitud", e);
            respuesta.sendRedirect(volver + "&error=bd");
        }
    }

    private void listar(HttpServletRequest peticion, HttpServletResponse respuesta, Usuario agente)
            throws ServletException, IOException, SQLException {

        peticion.setAttribute("solicitudes", solicitudDAO.listarPorAgente(agente.getId()));
        peticion.setAttribute("titulo", "Solicitudes recibidas");
        peticion.getRequestDispatcher(VISTA_LISTA).forward(peticion, respuesta);
    }

    private void mostrarDetalle(HttpServletRequest peticion, HttpServletResponse respuesta,
                                Usuario agente, int idSolicitud)
            throws ServletException, IOException, SQLException {

        if (!solicitudDAO.perteneceAlAgente(idSolicitud, agente.getId())) {
            denegar(peticion, respuesta);
            return;
        }

        peticion.setAttribute("solicitud", solicitudDAO.buscarPorId(idSolicitud));
        peticion.setAttribute("titulo", "Solicitud #" + idSolicitud);
        peticion.getRequestDispatcher(VISTA_DETALLE).forward(peticion, respuesta);
    }

    /** Abre un documento radicado, solo si la solicitud cae sobre una propiedad de su agencia. */
    private void abrirDocumento(HttpServletRequest peticion, HttpServletResponse respuesta,
                                Usuario agente, int idSolicitud, int idDocumento)
            throws ServletException, IOException, SQLException {

        if (!solicitudDAO.perteneceAlAgente(idSolicitud, agente.getId())) {
            denegar(peticion, respuesta);
            return;
        }

        DocumentoSolicitud d = solicitudDAO.buscarDocumento(idDocumento, idSolicitud);
        if (d == null || !ArchivoUtil.enviarDocumento(getServletContext(), respuesta, d.getUrl(), d.getNombre())) {
            respuesta.sendRedirect(peticion.getContextPath()
                    + "/panel/inmobiliaria/solicitudes?accion=ver&id=" + idSolicitud + "&error=sin-archivo");
        }
    }

    private void denegar(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {
        respuesta.setStatus(HttpServletResponse.SC_FORBIDDEN);
        peticion.setAttribute("rolExigido", "el agente de la propiedad solicitada");
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
