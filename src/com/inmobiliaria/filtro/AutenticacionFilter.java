package com.inmobiliaria.filtro;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.inmobiliaria.controlador.LoginServlet;
import com.inmobiliaria.modelo.Usuario;

/**
 * Control de acceso del lado del servidor.
 *
 * El enunciado es explicito: ocultar un boton en la vista NO es control de
 * acceso. Este filtro es la barrera real. Se aplica a todas las peticiones y
 * decide en tres pasos:
 *
 *   1. Si la ruta es publica, deja pasar.
 *   2. Si no hay sesion iniciada, manda al login.
 *   3. Si hay sesion pero el rol no alcanza, manda a acceso-denegado.
 *
 * Escribir la URL a mano en la barra del navegador no sirve de nada: la
 * peticion pasa por aqui igual.
 */
@WebFilter(filterName = "AutenticacionFilter", urlPatterns = {"/*"})
public class AutenticacionFilter implements Filter {

    /**
     * Rutas accesibles sin iniciar sesion (el rol VISITANTE del enunciado).
     * Se comparan con startsWith sobre la ruta relativa al contexto.
     */
    private static final String[] RUTAS_PUBLICAS = {
        "/index.jsp",
        "/login.jsp",
        "/registro.jsp",
        "/propiedades.jsp",
        "/acceso-denegado.jsp",
        "/login",           // servlet que procesa el formulario
        "/registro",        // servlet que procesa el formulario
        "/logout",
        "/css/",
        "/js/",
        "/img/",
        "/favicon.ico"
    };

    /**
     * Rutas protegidas y el rol que exige cada una.
     *
     * Se usa LinkedHashMap porque el orden importa: las reglas mas
     * especificas van primero. "/panel/admin" debe evaluarse antes que
     * "/panel/", que es la regla general.
     */
    private static final Map<String, String> REGLAS = new LinkedHashMap<String, String>();
    static {
        REGLAS.put("/panel/admin",         "ADMIN");
        REGLAS.put("/panel/inmobiliaria",  "INMOBILIARIA");
        REGLAS.put("/panel/cliente",       "CLIENTE");
        REGLAS.put("/panel/",              null);  // null = basta con estar autenticado
    }

    @Override
    public void init(FilterConfig config) throws ServletException {
        // Sin configuracion externa: las reglas viven en el codigo para que
        // queden versionadas junto a las rutas que protegen.
    }

    @Override
    public void doFilter(ServletRequest peticionGenerica, ServletResponse respuestaGenerica,
                         FilterChain cadena) throws IOException, ServletException {

        HttpServletRequest peticion = (HttpServletRequest) peticionGenerica;
        HttpServletResponse respuesta = (HttpServletResponse) respuestaGenerica;

        String contexto = peticion.getContextPath();
        String ruta = peticion.getRequestURI().substring(contexto.length());

        // La raiz de la aplicacion es publica.
        if (ruta.isEmpty() || "/".equals(ruta)) {
            cadena.doFilter(peticion, respuesta);
            return;
        }

        // --- Paso 1: rutas publicas -----------------------------------------
        if (esPublica(ruta)) {
            cadena.doFilter(peticion, respuesta);
            return;
        }

        String rolExigido = rolQueExige(ruta);

        // Ruta que no esta en las reglas: no es publica ni protegida de forma
        // explicita. Se deja pasar (paginas sueltas del proyecto) pero solo
        // despues de haber descartado las privadas conocidas.
        if (rolExigido == null && !estaProtegida(ruta)) {
            cadena.doFilter(peticion, respuesta);
            return;
        }

        Usuario usuario = usuarioEnSesion(peticion);

        // --- Paso 2: no hay sesion ------------------------------------------
        if (usuario == null) {
            // Se recuerda a donde queria ir para llevarlo alli tras el login.
            respuesta.sendRedirect(contexto + "/login.jsp?motivo=sesion");
            return;
        }

        // --- Paso 3: hay sesion pero el rol no alcanza -----------------------
        if (rolExigido != null && !usuario.tieneRol(rolExigido)) {
            respuesta.setStatus(HttpServletResponse.SC_FORBIDDEN);
            peticion.setAttribute("rutaSolicitada", ruta);
            peticion.setAttribute("rolExigido", rolExigido);
            peticion.getRequestDispatcher("/acceso-denegado.jsp").forward(peticion, respuesta);
            return;
        }

        cadena.doFilter(peticion, respuesta);
    }

    @Override
    public void destroy() {
        // No hay recursos que liberar.
    }

    /** ¿La ruta esta en la lista blanca? */
    private boolean esPublica(String ruta) {
        for (String publica : RUTAS_PUBLICAS) {
            if (ruta.equals(publica) || ruta.startsWith(publica)) {
                return true;
            }
        }
        return false;
    }

    /** Rol exigido por la primera regla que coincida, o null si no aplica ninguna. */
    private String rolQueExige(String ruta) {
        for (Map.Entry<String, String> regla : REGLAS.entrySet()) {
            if (ruta.startsWith(regla.getKey())) {
                return regla.getValue();
            }
        }
        return null;
    }

    /** ¿La ruta cae bajo alguna regla, aunque esa regla no exija un rol concreto? */
    private boolean estaProtegida(String ruta) {
        for (String prefijo : REGLAS.keySet()) {
            if (ruta.startsWith(prefijo)) {
                return true;
            }
        }
        return false;
    }

    /** Usuario autenticado, o null si no hay sesion activa. */
    private Usuario usuarioEnSesion(HttpServletRequest peticion) {
        HttpSession sesion = peticion.getSession(false);
        if (sesion == null) {
            return null;
        }
        Object enSesion = sesion.getAttribute(LoginServlet.USUARIO_EN_SESION);
        return (enSesion instanceof Usuario) ? (Usuario) enSesion : null;
    }
}
