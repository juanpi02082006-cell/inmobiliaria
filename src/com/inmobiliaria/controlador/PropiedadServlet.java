package com.inmobiliaria.controlador;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.inmobiliaria.dao.AuditoriaDAO;
import com.inmobiliaria.dao.CatalogoDAO;
import com.inmobiliaria.dao.DatoDuplicadoException;
import com.inmobiliaria.dao.ImagenDAO;
import com.inmobiliaria.dao.PropiedadDAO;
import com.inmobiliaria.modelo.Propiedad;
import com.inmobiliaria.modelo.Usuario;

/**
 * Gestion de propiedades del agente inmobiliario: alta, edicion, baja logica,
 * galeria de imagenes y caracteristicas.
 *
 * Un controlador por entidad, como pide el enunciado.
 *
 * SEGURIDAD. AutenticacionFilter ya garantiza que quien llega aqui tiene el
 * rol INMOBILIARIA, porque la ruta cuelga de /panel/inmobiliaria. Pero eso
 * solo protege la seccion, no el registro: sin una comprobacion mas, un
 * agente podria editar los inmuebles de otra agencia cambiando el id en la
 * URL. De eso se encarga {@link #exigirPropiedad}.
 *
 * Las vistas viven en /WEB-INF/vistas/, donde Tomcat no las sirve
 * directamente: solo se alcanzan por forward desde este servlet.
 */
@WebServlet(name = "PropiedadServlet", urlPatterns = {"/panel/inmobiliaria/propiedades"})
public class PropiedadServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String VISTA_LISTA = "/WEB-INF/vistas/propiedad-lista.jsp";
    private static final String VISTA_FORM = "/WEB-INF/vistas/propiedad-form.jsp";

    private final PropiedadDAO propiedadDAO = new PropiedadDAO();
    private final ImagenDAO imagenDAO = new ImagenDAO();
    private final CatalogoDAO catalogoDAO = new CatalogoDAO();
    private final AuditoriaDAO auditoriaDAO = new AuditoriaDAO();

    // =========================================================================
    //  GET  -  listar, formulario de alta, formulario de edicion
    // =========================================================================

    @Override
    protected void doGet(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        Usuario agente = usuarioEnSesion(peticion);
        String accion = valor(peticion.getParameter("accion"));

        try {
            if ("nueva".equals(accion)) {
                mostrarFormulario(peticion, respuesta, null);

            } else if ("editar".equals(accion)) {
                Propiedad p = exigirPropiedad(peticion, respuesta, agente);
                if (p == null) {
                    return;
                }
                mostrarFormulario(peticion, respuesta, p);

            } else {
                listar(peticion, respuesta, agente);
            }

        } catch (SQLException e) {
            log("Error de base de datos gestionando propiedades", e);
            fallar(peticion, respuesta, agente,
                   "No fue posible consultar la base de datos. Intente mas tarde.");
        }
    }

    // =========================================================================
    //  POST  -  guardar, baja, reactivar, galeria
    // =========================================================================

    @Override
    protected void doPost(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        peticion.setCharacterEncoding("UTF-8");

        Usuario agente = usuarioEnSesion(peticion);
        String accion = valor(peticion.getParameter("accion"));
        String base = peticion.getContextPath() + "/panel/inmobiliaria/propiedades";

        try {
            if ("guardar".equals(accion)) {
                guardar(peticion, respuesta, agente);
                return;
            }

            // El resto de acciones operan sobre un inmueble que ya existe.
            Propiedad p = exigirPropiedad(peticion, respuesta, agente);
            if (p == null) {
                return;
            }

            if ("baja".equals(accion)) {
                propiedadDAO.darDeBaja(p.getId());
                auditar(peticion, agente, "BAJA_PROPIEDAD", p);
                respuesta.sendRedirect(base + "?ok=baja");

            } else if ("reactivar".equals(accion)) {
                propiedadDAO.reactivar(p.getId());
                auditar(peticion, agente, "REACTIVAR_PROPIEDAD", p);
                respuesta.sendRedirect(base + "?ok=reactivada");

            } else if ("imagen-agregar".equals(accion)) {
                String url = valor(peticion.getParameter("url"));
                if (!url.isEmpty()) {
                    imagenDAO.agregar(p.getId(), url);
                }
                respuesta.sendRedirect(base + "?accion=editar&id=" + p.getId() + "&ok=imagen");

            } else if ("imagen-eliminar".equals(accion)) {
                imagenDAO.eliminar(entero(peticion.getParameter("idImagen"), 0), p.getId());
                respuesta.sendRedirect(base + "?accion=editar&id=" + p.getId() + "&ok=imagen-fuera");

            } else if ("imagen-portada".equals(accion)) {
                imagenDAO.marcarPortada(entero(peticion.getParameter("idImagen"), 0), p.getId());
                respuesta.sendRedirect(base + "?accion=editar&id=" + p.getId() + "&ok=portada");

            } else {
                respuesta.sendRedirect(base);
            }

        } catch (SQLException e) {
            log("Error de base de datos gestionando propiedades", e);
            fallar(peticion, respuesta, agente,
                   "No fue posible guardar los cambios. Intente mas tarde.");
        }
    }

    // =========================================================================
    //  Operaciones
    // =========================================================================

    private void listar(HttpServletRequest peticion, HttpServletResponse respuesta, Usuario agente)
            throws ServletException, IOException, SQLException {

        peticion.setAttribute("propiedades", propiedadDAO.listarPorAgente(agente.getId()));
        peticion.setAttribute("titulo", "Mis propiedades");
        peticion.getRequestDispatcher(VISTA_LISTA).forward(peticion, respuesta);
    }

    /**
     * Pinta el formulario. Con {@code p} en null es un alta; con un inmueble
     * cargado es una edicion.
     */
    private void mostrarFormulario(HttpServletRequest peticion, HttpServletResponse respuesta,
                                   Propiedad p)
            throws ServletException, IOException, SQLException {

        peticion.setAttribute("propiedad", p);
        peticion.setAttribute("ciudades", catalogoDAO.ciudades());
        peticion.setAttribute("tipos", catalogoDAO.tipos());
        peticion.setAttribute("catalogoCaracteristicas", catalogoDAO.caracteristicas());
        peticion.setAttribute("titulo", (p == null) ? "Publicar propiedad" : "Editar propiedad");
        peticion.getRequestDispatcher(VISTA_FORM).forward(peticion, respuesta);
    }

    /** Alta o edicion, segun venga o no un id. */
    private void guardar(HttpServletRequest peticion, HttpServletResponse respuesta, Usuario agente)
            throws ServletException, IOException, SQLException {

        int id = entero(peticion.getParameter("id"), 0);
        boolean esEdicion = id > 0;

        // En una edicion hay que comprobar que el inmueble sea suyo ANTES de
        // escribir nada.
        if (esEdicion && !propiedadDAO.perteneceAlUsuario(id, agente.getId())) {
            denegar(peticion, respuesta, id);
            return;
        }

        Propiedad p = leerFormulario(peticion, id);

        String error = validar(p);
        if (error != null) {
            volverAlFormulario(peticion, respuesta, p, error);
            return;
        }

        // La agencia no se lee del formulario: se toma de la sesion, para que
        // nadie pueda publicar a nombre de otra inmobiliaria.
        int idInmobiliaria = propiedadDAO.inmobiliariaDelUsuario(agente.getId());
        if (idInmobiliaria == 0) {
            volverAlFormulario(peticion, respuesta, p,
                    "Su usuario no tiene una inmobiliaria asociada. Avise al administrador.");
            return;
        }
        p.setIdInmobiliaria(idInmobiliaria);

        try {
            if (esEdicion) {
                propiedadDAO.actualizar(p);
            } else {
                id = propiedadDAO.crear(p);
                p.setId(id);
            }

            int[] marcadas = enteros(peticion.getParameterValues("caracteristicas"));
            propiedadDAO.guardarCaracteristicas(id, marcadas, cantidadesDe(peticion, marcadas));

            auditar(peticion, agente, esEdicion ? "EDITAR_PROPIEDAD" : "CREAR_PROPIEDAD", p);

            respuesta.sendRedirect(peticion.getContextPath()
                    + "/panel/inmobiliaria/propiedades?accion=editar&id=" + id
                    + "&ok=" + (esEdicion ? "editada" : "creada"));

        } catch (DatoDuplicadoException e) {
            // Aqui aterriza la violacion del UNIQUE de matricula_inmobiliaria,
            // ya traducida a castellano.
            volverAlFormulario(peticion, respuesta, p, e.getMessage());
        }
    }

    // =========================================================================
    //  Lectura y validacion del formulario
    // =========================================================================

    private Propiedad leerFormulario(HttpServletRequest peticion, int id) {
        Propiedad p = new Propiedad();
        p.setId(id);
        p.setMatricula(valor(peticion.getParameter("matricula")));
        p.setTitulo(valor(peticion.getParameter("titulo")));
        p.setDescripcion(valor(peticion.getParameter("descripcion")));
        p.setDireccion(valor(peticion.getParameter("direccion")));
        p.setOperacion(valor(peticion.getParameter("operacion")));
        p.setEstado(valor(peticion.getParameter("estado")));
        p.setIdCiudad(entero(peticion.getParameter("idCiudad"), 0));
        p.setIdTipo(entero(peticion.getParameter("idTipo"), 0));
        p.setHabitaciones(entero(peticion.getParameter("habitaciones"), 0));
        p.setBanos(entero(peticion.getParameter("banos"), 0));
        p.setParqueaderos(entero(peticion.getParameter("parqueaderos"), 0));
        p.setPrecio(decimal(peticion.getParameter("precio")));
        p.setAreaM2(decimal(peticion.getParameter("areaM2")));
        return p;
    }

    /**
     * Validacion del lado del servidor.
     *
     * El formulario ya valida en el navegador, pero eso se salta con
     * cualquier herramienta. La que cuenta es esta.
     *
     * @return el mensaje de error, o null si todo esta bien.
     */
    private String validar(Propiedad p) throws SQLException {
        if (p.getMatricula().isEmpty() || p.getTitulo().isEmpty() || p.getDireccion().isEmpty()) {
            return "La matricula, el titulo y la direccion son obligatorios.";
        }
        if (p.getMatricula().length() > 30) {
            return "La matricula no puede superar los 30 caracteres.";
        }
        if (p.getTitulo().length() > 150 || p.getDireccion().length() > 150) {
            return "El titulo y la direccion no pueden superar los 150 caracteres.";
        }
        if (p.getPrecio() == null || p.getPrecio().signum() <= 0) {
            return "El precio debe ser un numero mayor que cero.";
        }
        if (p.getAreaM2() == null || p.getAreaM2().signum() <= 0) {
            return "El area debe ser un numero mayor que cero.";
        }
        if (p.getHabitaciones() < 0 || p.getBanos() < 0 || p.getParqueaderos() < 0) {
            return "Las habitaciones, banos y parqueaderos no pueden ser negativos.";
        }
        if (!"VENTA".equals(p.getOperacion()) && !"ARRIENDO".equals(p.getOperacion())) {
            return "La operacion debe ser venta o arriendo.";
        }
        if (!esEstadoValido(p.getEstado())) {
            return "El estado del inmueble no es valido.";
        }
        // Los catalogos se comprueban contra la base: asi no se puede guardar
        // un tipo o una ciudad que no existan manipulando el formulario.
        if (!catalogoDAO.existeCiudad(p.getIdCiudad())) {
            return "Seleccione una ciudad valida.";
        }
        if (!catalogoDAO.existeTipo(p.getIdTipo())) {
            return "Seleccione un tipo de propiedad valido.";
        }
        return null;
    }

    private boolean esEstadoValido(String estado) {
        return "DISPONIBLE".equals(estado) || "RESERVADA".equals(estado)
            || "VENDIDA".equals(estado) || "ARRENDADA".equals(estado);
    }

    // =========================================================================
    //  Apoyo
    // =========================================================================

    /**
     * Carga el inmueble del parametro id y comprueba que sea del agente.
     *
     * Si no existe o es de otra agencia, responde acceso denegado y devuelve
     * null: quien llame debe salir de inmediato.
     */
    private Propiedad exigirPropiedad(HttpServletRequest peticion, HttpServletResponse respuesta,
                                      Usuario agente)
            throws ServletException, IOException, SQLException {

        int id = entero(peticion.getParameter("id"), 0);

        if (id <= 0 || !propiedadDAO.perteneceAlUsuario(id, agente.getId())) {
            denegar(peticion, respuesta, id);
            return null;
        }
        return propiedadDAO.buscarPorId(id, true);
    }

    private void denegar(HttpServletRequest peticion, HttpServletResponse respuesta, int id)
            throws ServletException, IOException {
        respuesta.setStatus(HttpServletResponse.SC_FORBIDDEN);
        peticion.setAttribute("rutaSolicitada", "/panel/inmobiliaria/propiedades?id=" + id);
        peticion.setAttribute("rolExigido", "el propietario del inmueble");
        peticion.getRequestDispatcher("/acceso-denegado.jsp").forward(peticion, respuesta);
    }

    private void volverAlFormulario(HttpServletRequest peticion, HttpServletResponse respuesta,
                                    Propiedad p, String mensaje)
            throws ServletException, IOException, SQLException {
        peticion.setAttribute("error", mensaje);
        mostrarFormulario(peticion, respuesta, p);
    }

    private void fallar(HttpServletRequest peticion, HttpServletResponse respuesta,
                        Usuario agente, String mensaje)
            throws ServletException, IOException {
        peticion.setAttribute("error", mensaje);
        peticion.setAttribute("propiedades", new java.util.ArrayList<Propiedad>());
        peticion.setAttribute("titulo", "Mis propiedades");
        peticion.getRequestDispatcher(VISTA_LISTA).forward(peticion, respuesta);
    }

    private void auditar(HttpServletRequest peticion, Usuario agente, String accion, Propiedad p) {
        auditoriaDAO.registrar(agente.getId(), accion,
                "Inmueble " + p.getMatricula() + " (" + p.getTitulo() + ")",
                peticion.getRemoteAddr());
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

    /** Convierte a BigDecimal aceptando puntos de miles y coma decimal. */
    private BigDecimal decimal(String v) {
        String limpio = valor(v).replace(".", "").replace(",", ".");
        if (limpio.isEmpty()) {
            return null;
        }
        try {
            return new BigDecimal(limpio);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private int[] enteros(String[] valores) {
        if (valores == null) {
            return new int[0];
        }
        int[] r = new int[valores.length];
        for (int i = 0; i < valores.length; i++) {
            r[i] = entero(valores[i], 0);
        }
        return r;
    }

    /**
     * Cantidad de cada caracteristica marcada.
     *
     * El formulario nombra cada campo numerico como cantidad_&lt;id&gt; en lugar de
     * mandarlos todos con el mismo nombre. La razon es que una casilla sin
     * marcar NO se envia, pero su campo numerico si: leerlos por posicion
     * desalinearia las dos listas y una caracteristica terminaria con la
     * cantidad de otra.
     */
    private int[] cantidadesDe(HttpServletRequest peticion, int[] marcadas) {
        int[] cantidades = new int[marcadas.length];
        for (int i = 0; i < marcadas.length; i++) {
            int c = entero(peticion.getParameter("cantidad_" + marcadas[i]), 1);
            cantidades[i] = (c < 1) ? 1 : c;
        }
        return cantidades;
    }
}
