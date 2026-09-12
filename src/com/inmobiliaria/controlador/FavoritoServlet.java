package com.inmobiliaria.controlador;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.inmobiliaria.dao.FavoritoDAO;
import com.inmobiliaria.modelo.Propiedad;
import com.inmobiliaria.modelo.Usuario;

/**
 * HU-08: marcar y consultar favoritos.
 *
 * Relacion N:M usuario &harr; propiedad. El cliente los marca desde la ficha
 * de detalle y los consulta en un listado propio, para no tener que volver a
 * buscar el inmueble en el catalogo.
 *
 * Ruta protegida por AutenticacionFilter: exige el rol CLIENTE.
 */
@WebServlet(name = "FavoritoServlet", urlPatterns = {"/panel/cliente/favoritos"})
public class FavoritoServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String VISTA_LISTA = "/WEB-INF/vistas/favoritos.jsp";

    private final FavoritoDAO favoritoDAO = new FavoritoDAO();

    @Override
    protected void doGet(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        Usuario cliente = usuarioEnSesion(peticion);

        try {
            peticion.setAttribute("favoritos", favoritoDAO.listarPorCliente(cliente.getId()));
            peticion.setAttribute("titulo", "Mis favoritos");
            peticion.getRequestDispatcher(VISTA_LISTA).forward(peticion, respuesta);

        } catch (SQLException e) {
            log("Error de base de datos consultando los favoritos", e);
            peticion.setAttribute("error", "No fue posible consultar sus favoritos. Intente mas tarde.");
            peticion.setAttribute("favoritos", new java.util.ArrayList<Propiedad>());
            peticion.setAttribute("titulo", "Mis favoritos");
            peticion.getRequestDispatcher(VISTA_LISTA).forward(peticion, respuesta);
        }
    }

    /**
     * Agrega o quita un favorito y vuelve a la pagina desde la que se llamo
     * (la ficha del inmueble o el propio listado de favoritos), para que el
     * boton funcione igual de bien desde los dos sitios.
     */
    @Override
    protected void doPost(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        peticion.setCharacterEncoding("UTF-8");

        Usuario cliente = usuarioEnSesion(peticion);
        String accion = valor(peticion.getParameter("accion"));
        int idPropiedad = entero(peticion.getParameter("idPropiedad"), 0);
        String volver = destinoSeguro(peticion);

        try {
            if (idPropiedad > 0 && "agregar".equals(accion)) {
                favoritoDAO.agregar(cliente.getId(), idPropiedad);
            } else if (idPropiedad > 0 && "quitar".equals(accion)) {
                favoritoDAO.eliminar(cliente.getId(), idPropiedad);
            }
            respuesta.sendRedirect(volver);

        } catch (SQLException e) {
            log("Error de base de datos actualizando favoritos", e);
            respuesta.sendRedirect(volver);
        }
    }

    /**
     * El destino tras la operacion viene en un campo del formulario, pero
     * solo se acepta si es una ruta interna de la aplicacion: evita que
     * alguien arme un enlace que redirija a un sitio externo (open redirect).
     */
    private String destinoSeguro(HttpServletRequest peticion) {
        String ctx = peticion.getContextPath();
        String volver = valor(peticion.getParameter("volver"));
        if (volver.startsWith(ctx + "/") || volver.equals(ctx)) {
            return volver;
        }
        return ctx + "/panel/cliente/favoritos";
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
