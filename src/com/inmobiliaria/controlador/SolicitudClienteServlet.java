package com.inmobiliaria.controlador;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import com.inmobiliaria.dao.AuditoriaDAO;
import com.inmobiliaria.dao.PropiedadDAO;
import com.inmobiliaria.dao.SolicitudDAO;
import com.inmobiliaria.modelo.DocumentoSolicitud;
import com.inmobiliaria.modelo.Propiedad;
import com.inmobiliaria.modelo.Solicitud;
import com.inmobiliaria.modelo.Usuario;
import com.inmobiliaria.util.ArchivoUtil;
import com.inmobiliaria.util.ArchivoUtil.ArchivoInvalidoException;

/**
 * HU-10: radicar una solicitud de compra o arriendo y consultar su estado
 * (lado del cliente).
 *
 * El tipo de la solicitud no lo elige el cliente: se toma de la operacion
 * del inmueble (VENTA -&gt; COMPRA, ARRIENDO -&gt; ARRIENDO), para que no se
 * pueda radicar, por ejemplo, una compra sobre un inmueble que solo esta en
 * arriendo.
 *
 * Los documentos se suben como archivos (PDF, JPG o PNG) y se guardan fuera
 * del alcance de una URL directa; solo se abren a traves de este servlet o
 * de {@link SolicitudAgenteServlet}, que comprueban antes quien los pide.
 * Solo se agregan o retiran mientras la solicitud espera una decision, y
 * se comprueba aqui, no solo en la vista.
 *
 * Ruta protegida por AutenticacionFilter: exige el rol CLIENTE.
 */
@WebServlet(name = "SolicitudClienteServlet", urlPatterns = {"/panel/cliente/solicitudes"})
@MultipartConfig(maxFileSize = 5L * 1024 * 1024, maxRequestSize = 6L * 1024 * 1024)
public class SolicitudClienteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String VISTA_LISTA = "/WEB-INF/vistas/solicitudes-cliente.jsp";
    private static final String VISTA_FORM = "/WEB-INF/vistas/solicitud-form.jsp";
    private static final String VISTA_DETALLE = "/WEB-INF/vistas/solicitud-detalle.jsp";

    private final SolicitudDAO solicitudDAO = new SolicitudDAO();
    private final PropiedadDAO propiedadDAO = new PropiedadDAO();
    private final AuditoriaDAO auditoriaDAO = new AuditoriaDAO();

    // =========================================================================
    //  GET  -  mis solicitudes, formulario para radicar, ver el detalle
    // =========================================================================

    @Override
    protected void doGet(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        Usuario cliente = usuarioEnSesion(peticion);
        String accion = valor(peticion.getParameter("accion"));

        try {
            if ("nueva".equals(accion)) {
                mostrarFormulario(peticion, respuesta, entero(peticion.getParameter("idPropiedad"), 0), null);

            } else if ("ver".equals(accion)) {
                mostrarDetalle(peticion, respuesta, cliente, entero(peticion.getParameter("id"), 0));

            } else if ("documento".equals(accion)) {
                abrirDocumento(peticion, respuesta, cliente, entero(peticion.getParameter("id"), 0),
                        entero(peticion.getParameter("idDocumento"), 0));

            } else {
                listar(peticion, respuesta, cliente);
            }

        } catch (SQLException e) {
            log("Error de base de datos gestionando solicitudes", e);
            peticion.setAttribute("error", "No fue posible consultar sus solicitudes. Intente mas tarde.");
            peticion.setAttribute("solicitudes", new java.util.ArrayList<Solicitud>());
            peticion.setAttribute("titulo", "Mis solicitudes");
            peticion.getRequestDispatcher(VISTA_LISTA).forward(peticion, respuesta);
        }
    }

    // =========================================================================
    //  POST  -  radicar, agregar y quitar documentos
    // =========================================================================

    @Override
    protected void doPost(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        peticion.setCharacterEncoding("UTF-8");

        Usuario cliente = usuarioEnSesion(peticion);
        String accion = valor(peticion.getParameter("accion"));
        String base = peticion.getContextPath() + "/panel/cliente/solicitudes";

        try {
            if ("radicar".equals(accion)) {
                radicar(peticion, respuesta, cliente);
                return;
            }

            // El resto de acciones operan sobre una solicitud que ya existe y es del cliente.
            int idSolicitud = entero(peticion.getParameter("idSolicitud"), 0);
            if (idSolicitud <= 0 || !solicitudDAO.perteneceAlCliente(idSolicitud, cliente.getId())) {
                denegar(peticion, respuesta);
                return;
            }

            String volver = base + "?accion=ver&id=" + idSolicitud;

            // Una solicitud ya resuelta no admite mas documentos ni retirar
            // los que tiene, aunque el POST se arme a mano sin pasar por la vista.
            if (accion.startsWith("documento-") && !solicitudDAO.esGestionable(idSolicitud)) {
                respuesta.sendRedirect(volver + "&error=resuelta");
                return;
            }

            if ("documento-agregar".equals(accion)) {
                agregarDocumento(peticion, respuesta, cliente, idSolicitud, volver);

            } else if ("documento-eliminar".equals(accion)) {
                retirarDocumento(respuesta, idSolicitud,
                        entero(peticion.getParameter("idDocumento"), 0), volver);

            } else {
                respuesta.sendRedirect(base);
            }

        } catch (SQLException e) {
            log("Error de base de datos gestionando solicitudes", e);
            respuesta.sendRedirect(base + "?error=bd");
        }
    }

    // =========================================================================
    //  Operaciones
    // =========================================================================

    private void listar(HttpServletRequest peticion, HttpServletResponse respuesta, Usuario cliente)
            throws ServletException, IOException, SQLException {

        peticion.setAttribute("solicitudes", solicitudDAO.listarPorCliente(cliente.getId()));
        peticion.setAttribute("titulo", "Mis solicitudes");
        peticion.getRequestDispatcher(VISTA_LISTA).forward(peticion, respuesta);
    }

    private void mostrarFormulario(HttpServletRequest peticion, HttpServletResponse respuesta,
                                   int idPropiedad, String error)
            throws ServletException, IOException, SQLException {

        Propiedad p = (idPropiedad > 0) ? propiedadDAO.buscarPorId(idPropiedad, false) : null;

        if (p == null || !esNegociable(p)) {
            peticion.setAttribute("error", "Ese inmueble ya no esta disponible para radicar una solicitud.");
            listar(peticion, respuesta, usuarioEnSesion(peticion));
            return;
        }

        peticion.setAttribute("propiedad", p);
        peticion.setAttribute("tipoSolicitud", tipoSegunOperacion(p));
        peticion.setAttribute("error", error);
        peticion.setAttribute("titulo", "Radicar solicitud");
        peticion.getRequestDispatcher(VISTA_FORM).forward(peticion, respuesta);
    }

    private void mostrarDetalle(HttpServletRequest peticion, HttpServletResponse respuesta,
                                Usuario cliente, int idSolicitud)
            throws ServletException, IOException, SQLException {

        if (idSolicitud <= 0 || !solicitudDAO.perteneceAlCliente(idSolicitud, cliente.getId())) {
            denegar(peticion, respuesta);
            return;
        }

        Solicitud s = solicitudDAO.buscarPorId(idSolicitud);
        peticion.setAttribute("solicitud", s);
        peticion.setAttribute("titulo", "Solicitud #" + idSolicitud);
        peticion.getRequestDispatcher(VISTA_DETALLE).forward(peticion, respuesta);
    }

    private void radicar(HttpServletRequest peticion, HttpServletResponse respuesta, Usuario cliente)
            throws ServletException, IOException, SQLException {

        int idPropiedad = entero(peticion.getParameter("idPropiedad"), 0);
        Propiedad p = (idPropiedad > 0) ? propiedadDAO.buscarPorId(idPropiedad, false) : null;

        if (p == null || !esNegociable(p)) {
            peticion.setAttribute("error", "Ese inmueble ya no esta disponible para radicar una solicitud.");
            listar(peticion, respuesta, cliente);
            return;
        }

        BigDecimal oferta = decimal(peticion.getParameter("oferta"));
        String comentario = valor(peticion.getParameter("comentario"));

        String error = validar(peticion.getParameter("oferta"), oferta, comentario);
        if (error != null) {
            peticion.setAttribute("propiedad", p);
            peticion.setAttribute("tipoSolicitud", tipoSegunOperacion(p));
            peticion.setAttribute("error", error);
            peticion.setAttribute("titulo", "Radicar solicitud");
            peticion.getRequestDispatcher(VISTA_FORM).forward(peticion, respuesta);
            return;
        }

        Solicitud s = new Solicitud();
        s.setIdPropiedad(idPropiedad);
        s.setIdCliente(cliente.getId());
        s.setTipo(tipoSegunOperacion(p));
        s.setOferta(oferta);
        s.setComentario(comentario.isEmpty() ? null : comentario);

        int id = solicitudDAO.radicar(s);
        auditoriaDAO.registrar(cliente.getId(), "RADICAR_SOLICITUD",
                s.getTipo() + " sobre " + p.getTitulo() + " (" + p.getMatricula() + ")",
                peticion.getRemoteAddr());

        respuesta.sendRedirect(peticion.getContextPath()
                + "/panel/cliente/solicitudes?accion=ver&id=" + id + "&ok=radicada");
    }

    /**
     * Sube un documento. El archivo se escribe en disco antes que la fila, y
     * si la fila no se puede guardar se borra el archivo, para no dejar
     * documentos personales huerfanos en el servidor.
     */
    private void agregarDocumento(HttpServletRequest peticion, HttpServletResponse respuesta,
                                  Usuario cliente, int idSolicitud, String volver)
            throws ServletException, IOException, SQLException {

        // Si el archivo pasa del limite de @MultipartConfig, Tomcat no puede
        // leer el cuerpo y getPart lanza IllegalStateException. Por eso el
        // formulario manda accion e idSolicitud en la URL: siguen llegando.
        Part parte;
        try {
            parte = peticion.getPart("archivo");
        } catch (IllegalStateException e) {
            respuesta.sendRedirect(volver + "&error=archivo-grande");
            return;
        }

        String nombre = valor(peticion.getParameter("nombre"));
        if (nombre.isEmpty()) {
            respuesta.sendRedirect(volver + "&error=documento");
            return;
        }
        if (nombre.length() > 120) {
            respuesta.sendRedirect(volver + "&error=documento-largo");
            return;
        }

        String ruta;
        try {
            ruta = ArchivoUtil.guardarDocumento(getServletContext(), parte);
        } catch (ArchivoInvalidoException e) {
            respuesta.sendRedirect(volver + "&errorArchivo="
                    + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            return;
        }

        try {
            solicitudDAO.agregarDocumento(idSolicitud, nombre, ruta);
        } catch (SQLException e) {
            ArchivoUtil.borrarDocumento(getServletContext(), ruta);
            throw e;
        }

        auditoriaDAO.registrar(cliente.getId(), "SUBIR_DOCUMENTO",
                nombre + " en la solicitud " + idSolicitud, peticion.getRemoteAddr());
        respuesta.sendRedirect(volver + "&ok=documento");
    }

    /** Retira un documento que la agencia todavia no ha evaluado, con su archivo. */
    private void retirarDocumento(HttpServletResponse respuesta, int idSolicitud, int idDocumento,
                                  String volver) throws IOException, SQLException {

        DocumentoSolicitud d = solicitudDAO.buscarDocumento(idDocumento, idSolicitud);
        if (d == null || !solicitudDAO.eliminarDocumento(idDocumento, idSolicitud)) {
            respuesta.sendRedirect(volver + "&error=documento-evaluado");
            return;
        }
        ArchivoUtil.borrarDocumento(getServletContext(), d.getUrl());
        respuesta.sendRedirect(volver + "&ok=documento-fuera");
    }

    private void abrirDocumento(HttpServletRequest peticion, HttpServletResponse respuesta,
                                Usuario cliente, int idSolicitud, int idDocumento)
            throws ServletException, IOException, SQLException {

        if (idSolicitud <= 0 || !solicitudDAO.perteneceAlCliente(idSolicitud, cliente.getId())) {
            denegar(peticion, respuesta);
            return;
        }

        DocumentoSolicitud d = solicitudDAO.buscarDocumento(idDocumento, idSolicitud);
        if (d == null || !ArchivoUtil.enviarDocumento(getServletContext(), respuesta, d.getUrl(), d.getNombre())) {
            respuesta.sendRedirect(peticion.getContextPath()
                    + "/panel/cliente/solicitudes?accion=ver&id=" + idSolicitud + "&error=sin-archivo");
        }
    }

    /** Solo tiene sentido radicar sobre un inmueble activo que sigue en negociacion. */
    private boolean esNegociable(Propiedad p) {
        return p.isActivo() && ("DISPONIBLE".equals(p.getEstado()) || "RESERVADA".equals(p.getEstado()));
    }

    /** El tipo de la solicitud lo decide la operacion del inmueble, no el cliente. */
    private String tipoSegunOperacion(Propiedad p) {
        return "ARRIENDO".equals(p.getOperacion()) ? "ARRIENDO" : "COMPRA";
    }

    private String validar(String ofertaTexto, BigDecimal oferta, String comentario) {
        if (!valor(ofertaTexto).isEmpty() && oferta == null) {
            return "La oferta debe ser un numero valido.";
        }
        if (oferta != null && oferta.signum() <= 0) {
            return "La oferta debe ser mayor que cero.";
        }
        if (comentario.length() > 255) {
            return "El comentario no puede superar los 255 caracteres.";
        }
        return null;
    }

    // =========================================================================
    //  Apoyo
    // =========================================================================

    private void denegar(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {
        respuesta.setStatus(HttpServletResponse.SC_FORBIDDEN);
        peticion.setAttribute("rolExigido", "el cliente que radico la solicitud");
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
     * Acepta las dos notaciones: el punto decimal que envia un input
     * type="number" y la notacion colombiana con punto de miles y coma
     * decimal. La coma es la que distingue una de otra.
     */
    private BigDecimal decimal(String v) {
        String limpio = valor(v);
        if (limpio.isEmpty()) {
            return null;
        }
        if (limpio.indexOf(',') >= 0) {
            limpio = limpio.replace(".", "").replace(",", ".");
        }
        try {
            return new BigDecimal(limpio);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
