package com.inmobiliaria.controlador;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.inmobiliaria.dao.AuditoriaDAO;
import com.inmobiliaria.modelo.RegistroAuditoria;

/**
 * HU-13: consultar la auditoria de accesos y cambios.
 *
 * Solo para ADMIN. La ruta cuelga de /panel/admin, asi que
 * AutenticacionFilter ya exige ese rol antes de llegar aqui.
 */
@WebServlet(name = "AuditoriaServlet", urlPatterns = {"/panel/admin/auditoria"})
public class AuditoriaServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String VISTA = "/WEB-INF/vistas/auditoria.jsp";

    /** No tiene sentido traer mas filas de las que alguien va a leer en una pantalla. */
    private static final int LIMITE = 200;

    private final AuditoriaDAO auditoriaDAO = new AuditoriaDAO();

    @Override
    protected void doGet(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        String accion = valor(peticion.getParameter("accion"));
        String correo = valor(peticion.getParameter("correo"));

        try {
            peticion.setAttribute("registros", auditoriaDAO.listar(accion, correo, LIMITE));
            peticion.setAttribute("acciones", auditoriaDAO.accionesDistintas());

        } catch (SQLException e) {
            log("Error de base de datos consultando la auditoria", e);
            peticion.setAttribute("error", "No fue posible consultar la auditoria. Intente mas tarde.");
            peticion.setAttribute("registros", new java.util.ArrayList<RegistroAuditoria>());
            peticion.setAttribute("acciones", new java.util.ArrayList<String>());
        }

        peticion.setAttribute("fAccion", accion);
        peticion.setAttribute("fCorreo", correo);
        peticion.setAttribute("limite", Integer.valueOf(LIMITE));
        peticion.setAttribute("titulo", "Auditoria");
        peticion.getRequestDispatcher(VISTA).forward(peticion, respuesta);
    }

    private String valor(String v) {
        return (v == null) ? "" : v.trim();
    }
}
