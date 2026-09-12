package com.inmobiliaria.controlador;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.inmobiliaria.dao.ReporteDAO;

/**
 * HU-12: reporte de propiedades por ciudad y por estado, generado con
 * consultas de agregacion.
 *
 * Solo para ADMIN. La ruta cuelga de /panel/admin, asi que
 * AutenticacionFilter ya exige ese rol antes de llegar aqui.
 */
@WebServlet(name = "ReporteServlet", urlPatterns = {"/panel/admin/reportes"})
public class ReporteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String VISTA = "/WEB-INF/vistas/reportes.jsp";

    private final ReporteDAO reporteDAO = new ReporteDAO();

    @Override
    protected void doGet(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        try {
            peticion.setAttribute("resumenCiudad", reporteDAO.resumenPorCiudad());
            peticion.setAttribute("conteoEstado", reporteDAO.conteoPorEstado());
            peticion.setAttribute("matriz", reporteDAO.matrizCiudadEstado());

        } catch (SQLException e) {
            log("Error de base de datos generando el reporte", e);
            peticion.setAttribute("error", "No fue posible generar el reporte. Intente mas tarde.");
            peticion.setAttribute("resumenCiudad", new java.util.ArrayList<Object>());
            peticion.setAttribute("conteoEstado", new java.util.LinkedHashMap<String, Integer>());
            peticion.setAttribute("matriz", new java.util.LinkedHashMap<String, Object>());
        }

        peticion.setAttribute("titulo", "Reportes");
        peticion.getRequestDispatcher(VISTA).forward(peticion, respuesta);
    }
}
