package com.inmobiliaria.controlador;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.inmobiliaria.dao.PropiedadDAO;
import com.inmobiliaria.modelo.Propiedad;

/**
 * Catalogo publico de propiedades: el listado con filtros y la ficha de
 * detalle de cada inmueble.
 *
 * Es una ruta publica, para el visitante sin cuenta, tal como pide el
 * enunciado. Lo que se reserva a los usuarios autenticados son las acciones
 * sobre el inmueble (agendar una visita, marcarlo como favorito) y los datos
 * de contacto completos de la agencia.
 *
 * Se separo del acceso directo a la JSP para cumplir el patron MVC: la vista
 * ya no llama al DAO, solo pinta lo que el controlador le deja.
 */
@WebServlet(name = "CatalogoServlet", urlPatterns = {"/catalogo"})
public class CatalogoServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String VISTA_LISTA = "/WEB-INF/vistas/catalogo.jsp";
    private static final String VISTA_DETALLE = "/WEB-INF/vistas/detalle.jsp";

    private final PropiedadDAO propiedadDAO = new PropiedadDAO();

    @Override
    protected void doGet(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        peticion.setCharacterEncoding("UTF-8");

        try {
            int id = entero(peticion.getParameter("id"));

            if (id > 0) {
                mostrarDetalle(peticion, respuesta, id);
            } else {
                mostrarListado(peticion, respuesta);
            }

        } catch (SQLException e) {
            log("Error de base de datos consultando el catalogo", e);
            peticion.setAttribute("error",
                    "No fue posible consultar el catalogo. Intente mas tarde.");
            peticion.setAttribute("propiedades", new java.util.ArrayList<Propiedad>());
            peticion.setAttribute("ciudades", new java.util.ArrayList<String>());
            peticion.setAttribute("tipos", new java.util.ArrayList<String>());
            peticion.setAttribute("titulo", "Propiedades");
            peticion.getRequestDispatcher(VISTA_LISTA).forward(peticion, respuesta);
        }
    }

    /** Listado con los filtros que venga en la peticion. */
    private void mostrarListado(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException, SQLException {

        String tipo = valor(peticion.getParameter("tipo"));
        String ciudad = valor(peticion.getParameter("ciudad"));
        BigDecimal min = decimal(peticion.getParameter("minPrecio"));
        BigDecimal max = decimal(peticion.getParameter("maxPrecio"));

        peticion.setAttribute("propiedades", propiedadDAO.filtrar(tipo, ciudad, min, max));
        peticion.setAttribute("ciudades", propiedadDAO.ciudadesConPropiedades());
        peticion.setAttribute("tipos", propiedadDAO.tiposConPropiedades());

        peticion.setAttribute("fTipo", tipo);
        peticion.setAttribute("fCiudad", ciudad);
        peticion.setAttribute("fMin", valor(peticion.getParameter("minPrecio")));
        peticion.setAttribute("fMax", valor(peticion.getParameter("maxPrecio")));

        peticion.setAttribute("titulo", "Propiedades");
        peticion.getRequestDispatcher(VISTA_LISTA).forward(peticion, respuesta);
    }

    /**
     * Ficha de detalle con la galeria completa y las caracteristicas.
     *
     * Se piden solo los inmuebles activos: uno dado de baja no debe poder
     * consultarse por su id desde fuera.
     */
    private void mostrarDetalle(HttpServletRequest peticion, HttpServletResponse respuesta,
                                int id)
            throws ServletException, IOException, SQLException {

        Propiedad p = propiedadDAO.buscarPorId(id, false);

        if (p == null) {
            respuesta.setStatus(HttpServletResponse.SC_NOT_FOUND);
            peticion.setAttribute("titulo", "Inmueble no disponible");
            peticion.getRequestDispatcher(VISTA_DETALLE).forward(peticion, respuesta);
            return;
        }

        peticion.setAttribute("propiedad", p);
        peticion.setAttribute("similares", propiedadDAO.similares(p, 3));
        peticion.setAttribute("titulo", p.getTitulo());
        peticion.getRequestDispatcher(VISTA_DETALLE).forward(peticion, respuesta);
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

    /** Acepta el precio con puntos de miles y coma decimal. */
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
}
