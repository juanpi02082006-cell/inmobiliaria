package com.inmobiliaria.controlador;

import java.io.IOException;
import java.sql.SQLException;
import java.util.regex.Pattern;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.inmobiliaria.dao.AuditoriaDAO;
import com.inmobiliaria.dao.DatoDuplicadoException;
import com.inmobiliaria.dao.UsuarioDAO;
import com.inmobiliaria.modelo.Perfil;

/**
 * Registro de usuarios nuevos.
 *
 * Crea de una sola vez la fila de credenciales (usuario), la de datos
 * personales (perfil, relacion 1:1) y la del rol CLIENTE (usuario_rol,
 * relacion N:M). El DAO lo hace dentro de una transaccion.
 *
 * Aqui se cumple el requisito del enunciado sobre las restricciones UNIQUE:
 * si el correo o el documento ya existen, se atrapa la excepcion y se muestra
 * un mensaje claro en el formulario, nunca una traza de Java.
 */
@WebServlet(name = "RegistroServlet", urlPatterns = {"/registro"})
public class RegistroServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /** Formato razonable de correo; el mismo criterio del CHECK en la tabla. */
    private static final Pattern CORREO_VALIDO =
            Pattern.compile("^[\\w.+-]+@[\\w-]+\\.[\\w.-]{2,}$");

    /** Solo digitos, entre 6 y 20: cedulas y NIT colombianos. */
    private static final Pattern DOCUMENTO_VALIDO = Pattern.compile("^\\d{6,20}$");

    /** Telefono opcional: digitos, espacios, guiones y un + inicial. */
    private static final Pattern TELEFONO_VALIDO = Pattern.compile("^\\+?[\\d\\s-]{7,20}$");

    private static final int MIN_PASSWORD = 8;

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();
    private final AuditoriaDAO auditoriaDAO = new AuditoriaDAO();

    @Override
    protected void doGet(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {
        respuesta.sendRedirect(peticion.getContextPath() + "/registro.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest peticion, HttpServletResponse respuesta)
            throws ServletException, IOException {

        peticion.setCharacterEncoding("UTF-8");

        String nombres   = limpiar(peticion.getParameter("nombres"));
        String apellidos = limpiar(peticion.getParameter("apellidos"));
        String documento = limpiar(peticion.getParameter("documento"));
        String correo    = limpiar(peticion.getParameter("email")).toLowerCase();
        String telefono  = limpiar(peticion.getParameter("telefono"));
        String direccion = limpiar(peticion.getParameter("direccion"));
        String password  = peticion.getParameter("password");
        String password2 = peticion.getParameter("password2");

        String error = validar(nombres, apellidos, documento, correo, telefono, password, password2);
        if (error != null) {
            volverAlFormulario(peticion, respuesta, error);
            return;
        }

        Perfil perfil = new Perfil();
        perfil.setNombres(nombres);
        perfil.setApellidos(apellidos);
        perfil.setDocumento(documento);
        perfil.setTelefono(telefono.isEmpty() ? null : telefono);
        perfil.setDireccion(direccion.isEmpty() ? null : direccion);

        try {
            int idUsuario = usuarioDAO.registrar(correo, password, perfil);

            auditoriaDAO.registrar(idUsuario, "REGISTRO",
                    "Cuenta creada: " + correo, peticion.getRemoteAddr());

            // Se envia al login con el aviso de exito. No se inicia sesion
            // automaticamente: el usuario debe probar sus credenciales.
            respuesta.sendRedirect(peticion.getContextPath() + "/login.jsp?success=1");

        } catch (DatoDuplicadoException e) {
            // Este es el caso que exige el enunciado: la violacion de la
            // restriccion UNIQUE llega traducida a castellano.
            volverAlFormulario(peticion, respuesta, e.getMessage());

        } catch (SQLException e) {
            log("Error de base de datos al registrar a " + correo, e);
            volverAlFormulario(peticion, respuesta,
                    "No fue posible completar el registro. Intente mas tarde.");
        }
    }

    /**
     * Validaciones del lado del servidor.
     *
     * El formulario ya valida en el navegador, pero eso se puede saltar con
     * cualquier herramienta: la validacion que cuenta es esta.
     *
     * @return el mensaje de error, o null si todo esta bien.
     */
    private String validar(String nombres, String apellidos, String documento,
                           String correo, String telefono, String password, String password2) {

        if (nombres.isEmpty() || apellidos.isEmpty() || documento.isEmpty()
                || correo.isEmpty() || password == null || password.isEmpty()) {
            return "Complete los campos obligatorios: nombres, apellidos, documento, correo y contrasena.";
        }
        if (nombres.length() > 60 || apellidos.length() > 60) {
            return "Los nombres y apellidos no pueden superar los 60 caracteres.";
        }
        if (!CORREO_VALIDO.matcher(correo).matches() || correo.length() > 120) {
            return "El correo no tiene un formato valido.";
        }
        if (!DOCUMENTO_VALIDO.matcher(documento).matches()) {
            return "El documento debe tener entre 6 y 20 digitos, sin puntos ni espacios.";
        }
        if (!telefono.isEmpty() && !TELEFONO_VALIDO.matcher(telefono).matches()) {
            return "El telefono no tiene un formato valido.";
        }
        if (password.length() < MIN_PASSWORD) {
            return "La contrasena debe tener al menos " + MIN_PASSWORD + " caracteres.";
        }
        if (!password.equals(password2)) {
            return "Las dos contrasenas no coinciden.";
        }
        return null;
    }

    /**
     * Reenvia al formulario con el error y con lo que el usuario ya habia
     * escrito, para que no tenga que llenarlo todo otra vez. La contrasena
     * nunca se devuelve.
     */
    private void volverAlFormulario(HttpServletRequest peticion, HttpServletResponse respuesta,
                                    String mensaje)
            throws ServletException, IOException {
        peticion.setAttribute("error", mensaje);
        peticion.getRequestDispatcher("/registro.jsp").forward(peticion, respuesta);
    }

    private String limpiar(String valor) {
        return (valor == null) ? "" : valor.trim();
    }
}
