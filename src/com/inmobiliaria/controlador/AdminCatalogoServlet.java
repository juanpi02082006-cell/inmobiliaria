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
import com.inmobiliaria.dao.CatalogoDAO;
import com.inmobiliaria.dao.DatoDuplicadoException;
import com.inmobiliaria.modelo.Usuario;

/**
 * Parametrizacion de los catalogos del sistema (HU-19).
 *
 * El enunciado se lo asigna al administrador: "parametriza los catalogos del
 * sistema (tipos de propiedad, ciudades, caracteristicas)".
 *
 * Se administran ciudades y caracteristicas. Los TIPOS DE PROPIEDAD no: el
 * enunciado fija cinco (casa, apartamento, local, oficina y terreno) y
 * permitir otros seria salirse del alcance declarado del sistema. La pantalla
 * los muestra, pero solo para consulta.
 *
 * Solo para ADMIN. La ruta cuelga de /panel/admin, asi que AutenticacionFilter
 * ya exige ese rol antes de llegar aqui.
 */
@WebServlet(name = "AdminCatalogoServlet", urlPatterns = {"/panel/admin/catalogos"})
public class AdminCatalogoServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String VISTA = "/WEB-INF/vistas/catalogo-admin.jsp";

    private final CatalogoDAO catalogoDAO = new CatalogoDAO();
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
        String base = peticion.getContextPath() + "/panel/admin/catalogos";

        try {
            if ("ciudad-crear".equals(accion)) {
                crearCiudad(peticion, respuesta, admin, base);

            } else if ("ciudad-editar".equals(accion)) {
                editarCiudad(peticion, respuesta, admin, base);

            } else if ("ciudad-eliminar".equals(accion)) {
                eliminarCiudad(peticion, respuesta, admin, base);

            } else if ("caracteristica-crear".equals(accion)) {
                crearCaracteristica(peticion, respuesta, admin, base);

            } else if ("caracteristica-editar".equals(accion)) {
                editarCaracteristica(peticion, respuesta, admin, base);

            } else if ("caracteristica-eliminar".equals(accion)) {
                eliminarCaracteristica(peticion, respuesta, admin, base);

            } else {
                respuesta.sendRedirect(base);
            }

        } catch (SQLException e) {
            log("Error de base de datos parametrizando catalogos", e);
            mostrar(peticion, respuesta, "No fue posible guardar los cambios. Intente mas tarde.");
        }
    }

    // =========================================================================
    //  Ciudades
    // =========================================================================

    private void crearCiudad(HttpServletRequest peticion, HttpServletResponse respuesta,
                             Usuario admin, String base)
            throws ServletException, IOException, SQLException {

        String nombre = valor(peticion.getParameter("nombre"));
        String departamento = valor(peticion.getParameter("departamento"));

        String error = validarCiudad(nombre, departamento);
        if (error != null) {
            mostrar(peticion, respuesta, error);
            return;
        }

        try {
            catalogoDAO.crearCiudad(nombre, departamento);
            auditar(peticion, admin, "CREAR_CIUDAD", nombre + " (" + departamento + ")");
            respuesta.sendRedirect(base + "?ok=ciudad-creada");
        } catch (DatoDuplicadoException e) {
            mostrar(peticion, respuesta, e.getMessage());
        }
    }

    private void editarCiudad(HttpServletRequest peticion, HttpServletResponse respuesta,
                              Usuario admin, String base)
            throws ServletException, IOException, SQLException {

        int id = entero(peticion.getParameter("id"));
        String nombre = valor(peticion.getParameter("nombre"));
        String departamento = valor(peticion.getParameter("departamento"));

        if (id <= 0) {
            respuesta.sendRedirect(base);
            return;
        }

        String error = validarCiudad(nombre, departamento);
        if (error != null) {
            mostrar(peticion, respuesta, error);
            return;
        }

        try {
            catalogoDAO.actualizarCiudad(id, nombre, departamento);
            auditar(peticion, admin, "EDITAR_CIUDAD", nombre + " (" + departamento + ")");
            respuesta.sendRedirect(base + "?ok=ciudad-editada");
        } catch (DatoDuplicadoException e) {
            mostrar(peticion, respuesta, e.getMessage());
        }
    }

    private void eliminarCiudad(HttpServletRequest peticion, HttpServletResponse respuesta,
                                Usuario admin, String base)
            throws ServletException, IOException, SQLException {

        int id = entero(peticion.getParameter("id"));
        if (id <= 0) {
            respuesta.sendRedirect(base);
            return;
        }

        try {
            catalogoDAO.eliminarCiudad(id);
            auditar(peticion, admin, "ELIMINAR_CIUDAD", "id " + id);
            respuesta.sendRedirect(base + "?ok=ciudad-eliminada");
        } catch (DatoDuplicadoException e) {
            // La llave foranea es RESTRICT: el motor protege los inmuebles.
            mostrar(peticion, respuesta, e.getMessage());
        }
    }

    private String validarCiudad(String nombre, String departamento) {
        if (nombre.isEmpty() || departamento.isEmpty()) {
            return "El nombre de la ciudad y el departamento son obligatorios.";
        }
        if (nombre.length() > 60 || departamento.length() > 60) {
            return "El nombre y el departamento no pueden superar los 60 caracteres.";
        }
        return null;
    }

    // =========================================================================
    //  Caracteristicas
    // =========================================================================

    private void crearCaracteristica(HttpServletRequest peticion, HttpServletResponse respuesta,
                                     Usuario admin, String base)
            throws ServletException, IOException, SQLException {

        String nombre = valor(peticion.getParameter("nombre"));

        String error = validarCaracteristica(nombre);
        if (error != null) {
            mostrar(peticion, respuesta, error);
            return;
        }

        try {
            catalogoDAO.crearCaracteristica(nombre);
            auditar(peticion, admin, "CREAR_CARACTERISTICA", nombre);
            respuesta.sendRedirect(base + "?ok=caracteristica-creada");
        } catch (DatoDuplicadoException e) {
            mostrar(peticion, respuesta, e.getMessage());
        }
    }

    private void editarCaracteristica(HttpServletRequest peticion, HttpServletResponse respuesta,
                                      Usuario admin, String base)
            throws ServletException, IOException, SQLException {

        int id = entero(peticion.getParameter("id"));
        String nombre = valor(peticion.getParameter("nombre"));

        if (id <= 0) {
            respuesta.sendRedirect(base);
            return;
        }

        String error = validarCaracteristica(nombre);
        if (error != null) {
            mostrar(peticion, respuesta, error);
            return;
        }

        try {
            catalogoDAO.actualizarCaracteristica(id, nombre);
            auditar(peticion, admin, "EDITAR_CARACTERISTICA", nombre);
            respuesta.sendRedirect(base + "?ok=caracteristica-editada");
        } catch (DatoDuplicadoException e) {
            mostrar(peticion, respuesta, e.getMessage());
        }
    }

    private void eliminarCaracteristica(HttpServletRequest peticion, HttpServletResponse respuesta,
                                        Usuario admin, String base)
            throws ServletException, IOException, SQLException {

        int id = entero(peticion.getParameter("id"));
        if (id <= 0) {
            respuesta.sendRedirect(base);
            return;
        }

        // Aqui la llave foranea es CASCADE: borrar la caracteristica la retira
        // de todos los inmuebles que la tuvieran. La vista ya advirtio a
        // cuantos afecta antes de confirmar.
        catalogoDAO.eliminarCaracteristica(id);
        auditar(peticion, admin, "ELIMINAR_CARACTERISTICA", "id " + id);
        respuesta.sendRedirect(base + "?ok=caracteristica-eliminada");
    }

    private String validarCaracteristica(String nombre) {
        if (nombre.isEmpty()) {
            return "El nombre de la caracteristica es obligatorio.";
        }
        if (nombre.length() > 50) {
            return "El nombre no puede superar los 50 caracteres.";
        }
        return null;
    }

    // =========================================================================

    private void mostrar(HttpServletRequest peticion, HttpServletResponse respuesta, String error)
            throws ServletException, IOException {
        try {
            peticion.setAttribute("ciudades", catalogoDAO.ciudadesConUso());
            peticion.setAttribute("caracteristicas", catalogoDAO.caracteristicasConUso());
            peticion.setAttribute("tipos", catalogoDAO.tipos());
        } catch (SQLException e) {
            log("Error de base de datos listando catalogos", e);
            peticion.setAttribute("ciudades", new java.util.ArrayList<Object[]>());
            peticion.setAttribute("caracteristicas", new java.util.ArrayList<Object[]>());
            peticion.setAttribute("tipos", new java.util.LinkedHashMap<Integer, String>());
            if (error == null) {
                error = "No fue posible consultar los catalogos.";
            }
        }
        peticion.setAttribute("error", error);
        peticion.setAttribute("titulo", "Catalogos del sistema");
        peticion.getRequestDispatcher(VISTA).forward(peticion, respuesta);
    }

    private void auditar(HttpServletRequest peticion, Usuario admin, String accion, String detalle) {
        auditoriaDAO.registrar(admin == null ? null : Integer.valueOf(admin.getId()),
                accion, detalle, peticion.getRemoteAddr());
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
}
