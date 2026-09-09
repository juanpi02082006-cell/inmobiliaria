package com.inmobiliaria.config;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Punto unico de acceso a la base de datos.
 *
 * El enunciado exige que la cadena de conexion este centralizada y sea
 * configurable, y que no se repita en cada clase. Esta clase es la unica del
 * proyecto que conoce la URL, el usuario y la clave: los lee de
 * db.properties (que se copia a WEB-INF/classes al compilar) y los expone
 * al resto de la aplicacion mediante {@link #obtener()}.
 *
 * Cambiar entre la instancia local y la instancia en linea es cuestion de
 * editar db.perfil en el archivo de propiedades; no se recompila nada.
 */
public final class ConexionBD {

    private static final String ARCHIVO_CONFIG = "db.properties";

    private static String url;
    private static String usuario;
    private static String password;
    private static String driver;

    /** Error ocurrido al cargar la configuracion, si lo hubo. */
    private static ExceptionInInitializerError errorCarga;

    static {
        cargarConfiguracion();
    }

    /** Clase de utilidad: no se instancia. */
    private ConexionBD() {
    }

    /**
     * Lee db.properties desde el classpath y deja preparados los datos del
     * perfil activo. Se ejecuta una sola vez, al cargar la clase.
     */
    private static void cargarConfiguracion() {
        Properties props = new Properties();
        InputStream entrada = ConexionBD.class.getClassLoader()
                .getResourceAsStream(ARCHIVO_CONFIG);

        if (entrada == null) {
            errorCarga = new ExceptionInInitializerError(
                    "No se encontro " + ARCHIVO_CONFIG + " en el classpath "
                    + "(deberia estar en WEB-INF/classes).");
            return;
        }

        try {
            props.load(entrada);
        } catch (IOException e) {
            errorCarga = new ExceptionInInitializerError(
                    "No se pudo leer " + ARCHIVO_CONFIG + ": " + e.getMessage());
            return;
        } finally {
            cerrarSilencioso(entrada);
        }

        // El perfil decide de que juego de propiedades se toman los datos.
        String perfil = props.getProperty("db.perfil", "local").trim();

        driver   = props.getProperty("db." + perfil + ".driver");
        url      = props.getProperty("db." + perfil + ".url");
        usuario  = props.getProperty("db." + perfil + ".usuario");
        password = props.getProperty("db." + perfil + ".password", "");

        if (url == null || driver == null) {
            errorCarga = new ExceptionInInitializerError(
                    "El perfil '" + perfil + "' no esta definido en " + ARCHIVO_CONFIG);
            return;
        }

        try {
            // Con JDBC 4 el driver se auto-registra, pero cargarlo de forma
            // explicita da un mensaje claro si falta el .jar del conector.
            Class.forName(driver);
        } catch (ClassNotFoundException e) {
            errorCarga = new ExceptionInInitializerError(
                    "No se encontro el driver JDBC '" + driver + "'. "
                    + "Verifique que mysql-connector-j este en WEB-INF/lib o en tomcat/lib.");
        }
    }

    /**
     * Entrega una conexion nueva a la base de datos configurada.
     * Quien la pide es responsable de cerrarla (idealmente con try-with-resources).
     *
     * @throws SQLException si la configuracion es invalida o el motor no responde.
     */
    public static Connection obtener() throws SQLException {
        if (errorCarga != null) {
            throw new SQLException(errorCarga.getMessage(), errorCarga);
        }
        return DriverManager.getConnection(url, usuario, password);
    }

    /**
     * Comprueba que la base de datos este accesible. Lo usa la pagina de
     * diagnostico para avisar en castellano si MySQL esta apagado, en lugar
     * de mostrar una traza de Java al usuario final.
     */
    public static boolean probarConexion() {
        try (Connection cn = obtener()) {
            return cn != null && !cn.isClosed();
        } catch (SQLException e) {
            return false;
        }
    }

    /** URL activa, sin credenciales. Util para mostrar en diagnostico. */
    public static String urlActiva() {
        return url == null ? "(sin configurar)" : url;
    }

    private static void cerrarSilencioso(InputStream entrada) {
        try {
            entrada.close();
        } catch (IOException ignorada) {
            // Cerrar el archivo de configuracion no puede tumbar la aplicacion.
        }
    }
}
