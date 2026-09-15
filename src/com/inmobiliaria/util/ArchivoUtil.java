package com.inmobiliaria.util;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

/**
 * Guarda en disco los archivos que suben los formularios ({@code Part} de la
 * Servlet API), en vez de que el usuario elija entre rutas ya existentes.
 *
 * Cierra la deuda tecnica que quedaba abierta desde el Sprint 2: la galeria
 * de imagenes de una propiedad se armaba escogiendo de un {@code &lt;select&gt;}
 * con cuatro fotos fijas del proyecto, y los documentos de una solicitud se
 * registraban escribiendo su nombre y su ubicacion a mano.
 *
 * El archivo se guarda con un nombre generado (UUID), nunca con el nombre
 * que trae el navegador: aceptarlo tal cual permitiria sobrescribir otro
 * archivo del servidor con un nombre como <code>../../WEB-INF/web.xml</code>.
 *
 * Fotos y documentos se guardan en sitios distintos a proposito. Las fotos
 * son publicas y van a {@code img/}. Los documentos (cedulas, extractos,
 * certificados laborales) van a {@link #CARPETA_DOCUMENTOS}, dentro de
 * WEB-INF, que Tomcat nunca sirve por URL: solo se entregan a traves de un
 * servlet que antes comprobo quien los pide.
 */
public final class ArchivoUtil {

    private static final long TAMANO_MAXIMO_BYTES = 5L * 1024 * 1024; // 5 MB

    private static final Set<String> EXTENSIONES_IMAGEN =
            new HashSet<String>(Arrays.asList("jpg", "jpeg", "png", "webp", "gif"));

    /** Carpeta, relativa al contexto web, donde se guardan los documentos de las solicitudes. */
    public static final String CARPETA_DOCUMENTOS = "WEB-INF/documentos";

    /** Extensiones aceptadas para un documento y el tipo de contenido con el que se entregan. */
    private static final Map<String, String> TIPOS_DOCUMENTO = new HashMap<String, String>();
    static {
        TIPOS_DOCUMENTO.put("pdf", "application/pdf");
        TIPOS_DOCUMENTO.put("jpg", "image/jpeg");
        TIPOS_DOCUMENTO.put("jpeg", "image/jpeg");
        TIPOS_DOCUMENTO.put("png", "image/png");
    }

    private static final byte[] FIRMA_PDF = {'%', 'P', 'D', 'F', '-'};
    private static final byte[] FIRMA_JPG = {(byte) 0xFF, (byte) 0xD8, (byte) 0xFF};
    private static final byte[] FIRMA_PNG = {(byte) 0x89, 'P', 'N', 'G', 0x0D, 0x0A, 0x1A, 0x0A};

    private ArchivoUtil() {
    }

    /** Se lanza cuando el archivo subido no es una imagen valida. */
    public static class ArchivoInvalidoException extends Exception {
        private static final long serialVersionUID = 1L;

        public ArchivoInvalidoException(String mensaje) {
            super(mensaje);
        }
    }

    /**
     * Valida y guarda una imagen subida por el usuario.
     *
     * @param parte              el campo de tipo archivo del formulario
     *                           ({@code request.getPart("archivo")}).
     * @param carpetaDestino     ruta absoluta en disco donde guardarla
     *                           (se crea si no existe).
     * @param rutaWebDeLaCarpeta la misma carpeta, pero como ruta relativa al
     *                           contexto web (por ejemplo {@code "img/propiedades"}),
     *                           para poder guardarla en la base de datos y
     *                           servirla luego con {@code &lt;img src&gt;}.
     * @return la ruta relativa completa del archivo guardado.
     * @throws ArchivoInvalidoException si no llego archivo, pesa de mas, o
     *                                  no es una imagen (por extension y por
     *                                  tipo de contenido).
     * @throws IOException si fallo la escritura en disco.
     */
    public static String guardarImagen(Part parte, String carpetaDestino, String rutaWebDeLaCarpeta)
            throws ArchivoInvalidoException, IOException {

        if (parte == null || parte.getSize() == 0) {
            throw new ArchivoInvalidoException("Seleccione una imagen para subir.");
        }
        if (parte.getSize() > TAMANO_MAXIMO_BYTES) {
            throw new ArchivoInvalidoException("La imagen no puede superar los 5 MB.");
        }

        String extension = extensionDe(parte.getSubmittedFileName());
        if (!EXTENSIONES_IMAGEN.contains(extension)) {
            throw new ArchivoInvalidoException(
                    "Solo se aceptan imagenes JPG, PNG, WEBP o GIF.");
        }

        String tipoContenido = parte.getContentType();
        if (tipoContenido == null || !tipoContenido.toLowerCase().startsWith("image/")) {
            throw new ArchivoInvalidoException("El archivo elegido no parece ser una imagen.");
        }

        return rutaWebDeLaCarpeta + "/" + escribir(parte, carpetaDestino, extension);
    }

    /**
     * Valida y guarda un documento de una solicitud en {@link #CARPETA_DOCUMENTOS}.
     *
     * Ademas de la extension se revisan los primeros bytes del archivo: el
     * agente va a abrir estos documentos, y un ejecutable renombrado a
     * {@code .pdf} (con el tipo de contenido falseado, que lo decide quien
     * envia la peticion) no debe llegar a su navegador.
     *
     * @return la ruta relativa al contexto web con la que se registra en la base de datos.
     * @throws ArchivoInvalidoException si no llego archivo, pesa de mas, o
     *                                  no es un PDF, JPG o PNG de verdad.
     * @throws IOException si fallo la escritura en disco.
     */
    public static String guardarDocumento(ServletContext contexto, Part parte)
            throws ArchivoInvalidoException, IOException {

        if (parte == null || parte.getSize() == 0) {
            throw new ArchivoInvalidoException("Seleccione el archivo del documento.");
        }
        if (parte.getSize() > TAMANO_MAXIMO_BYTES) {
            throw new ArchivoInvalidoException("El documento no puede superar los 5 MB.");
        }

        String extension = extensionDe(parte.getSubmittedFileName());
        if (!TIPOS_DOCUMENTO.containsKey(extension)) {
            throw new ArchivoInvalidoException("Solo se aceptan documentos PDF, JPG o PNG.");
        }
        if (!tieneFirmaDe(parte, extension)) {
            throw new ArchivoInvalidoException(
                    "El contenido del archivo no corresponde a un " + extension.toUpperCase() + ".");
        }

        String carpeta = contexto.getRealPath("/" + CARPETA_DOCUMENTOS);
        return CARPETA_DOCUMENTOS + "/" + escribir(parte, carpeta, extension);
    }

    /**
     * Entrega al navegador un documento guardado con {@link #guardarDocumento}.
     * Quien llama ya debe haber comprobado que el usuario puede verlo.
     *
     * @param rutaGuardada  la ruta registrada en la base de datos.
     * @param nombreVisible el nombre con el que el navegador lo muestra o descarga.
     * @return false si el archivo no existe o la ruta no apunta a la carpeta
     *         de documentos (en ese caso no se escribio nada en la respuesta).
     */
    public static boolean enviarDocumento(ServletContext contexto, HttpServletResponse respuesta,
                                          String rutaGuardada, String nombreVisible) throws IOException {

        File archivo = documentoEnDisco(contexto, rutaGuardada);
        if (archivo == null) {
            return false;
        }

        String extension = extensionDe(archivo.getName());
        String nombre = (nombreVisible == null || nombreVisible.trim().isEmpty())
                ? "documento" : nombreVisible.trim();
        if (!nombre.toLowerCase().endsWith("." + extension)) {
            nombre = nombre + "." + extension;
        }

        respuesta.setContentType(TIPOS_DOCUMENTO.get(extension));
        respuesta.setContentLengthLong(archivo.length());
        // Es un dato personal: que no quede en la cache de un equipo compartido.
        respuesta.setHeader("Cache-Control", "private, no-store");
        // El navegador no debe adivinar otro tipo de contenido que el declarado.
        respuesta.setHeader("X-Content-Type-Options", "nosniff");
        respuesta.setHeader("Content-Disposition", "inline; filename=\""
                + nombre.replaceAll("[^A-Za-z0-9._ -]", "_") + "\"; filename*=UTF-8''"
                + URLEncoder.encode(nombre, "UTF-8").replace("+", "%20"));

        try (OutputStream salida = respuesta.getOutputStream()) {
            Files.copy(archivo.toPath(), salida);
        }
        return true;
    }

    /** Borra del disco un documento guardado con {@link #guardarDocumento}; no falla si ya no estaba. */
    public static void borrarDocumento(ServletContext contexto, String rutaGuardada) {
        try {
            File archivo = documentoEnDisco(contexto, rutaGuardada);
            if (archivo != null && !archivo.delete()) {
                contexto.log("No se pudo borrar el documento " + archivo.getAbsolutePath());
            }
        } catch (IOException e) {
            contexto.log("No se pudo borrar el documento " + rutaGuardada, e);
        }
    }

    /** ¿La ruta registrada apunta a un archivo subido por la aplicacion (y no, por ejemplo, a un dato de prueba)? */
    public static boolean esDocumentoSubido(String rutaGuardada) {
        return rutaGuardada != null && rutaGuardada.startsWith(CARPETA_DOCUMENTOS + "/");
    }

    /**
     * El archivo en disco de un documento, o null si no existe o si la ruta
     * se sale de {@link #CARPETA_DOCUMENTOS}. La ruta viene de la base de
     * datos, pero se comprueba igual: nunca se entrega un archivo de fuera
     * de esa carpeta.
     */
    private static File documentoEnDisco(ServletContext contexto, String rutaGuardada) throws IOException {
        if (!esDocumentoSubido(rutaGuardada)) {
            return null;
        }
        String carpeta = contexto.getRealPath("/" + CARPETA_DOCUMENTOS);
        if (carpeta == null) {
            return null;
        }
        File raiz = new File(carpeta).getCanonicalFile();
        File archivo = new File(raiz, rutaGuardada.substring(CARPETA_DOCUMENTOS.length() + 1))
                .getCanonicalFile();

        boolean dentroDeLaCarpeta = raiz.equals(archivo.getParentFile());
        return (dentroDeLaCarpeta && archivo.isFile()) ? archivo : null;
    }

    /** ¿Los primeros bytes del archivo corresponden al formato que dice su extension? */
    private static boolean tieneFirmaDe(Part parte, String extension) throws IOException {
        byte[] firma = "pdf".equals(extension) ? FIRMA_PDF
                     : "png".equals(extension) ? FIRMA_PNG
                     : FIRMA_JPG;

        byte[] inicio = new byte[firma.length];
        int leidos = 0;
        try (InputStream entrada = parte.getInputStream()) {
            while (leidos < inicio.length) {
                int n = entrada.read(inicio, leidos, inicio.length - leidos);
                if (n < 0) {
                    break;
                }
                leidos += n;
            }
        }
        return leidos == firma.length && Arrays.equals(inicio, firma);
    }

    /** Escribe el archivo con un nombre generado y devuelve ese nombre. */
    private static String escribir(Part parte, String carpetaDestino, String extension) throws IOException {
        File carpeta = new File(carpetaDestino);
        if (!carpeta.exists() && !carpeta.mkdirs()) {
            throw new IOException("No se pudo crear la carpeta de destino: " + carpetaDestino);
        }

        String nombreUnico = UUID.randomUUID().toString() + "." + extension;
        File destino = new File(carpeta, nombreUnico);

        try (InputStream entrada = parte.getInputStream()) {
            Files.copy(entrada, destino.toPath(), StandardCopyOption.REPLACE_EXISTING);
        }
        return nombreUnico;
    }

    /** La extension en minusculas, sin el punto; cadena vacia si no tiene. */
    private static String extensionDe(String nombreArchivo) {
        if (nombreArchivo == null) {
            return "";
        }
        int punto = nombreArchivo.lastIndexOf('.');
        return (punto < 0 || punto == nombreArchivo.length() - 1)
                ? "" : nombreArchivo.substring(punto + 1).toLowerCase();
    }
}
