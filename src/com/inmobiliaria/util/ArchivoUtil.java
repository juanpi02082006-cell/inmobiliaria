package com.inmobiliaria.util;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

import javax.servlet.http.Part;

/**
 * Guarda en disco los archivos que suben los formularios ({@code Part} de la
 * Servlet API), en vez de que el usuario elija entre rutas ya existentes.
 *
 * Cierra la deuda tecnica que quedaba abierta desde el Sprint 2: la galeria
 * de imagenes de una propiedad se armaba escogiendo de un {@code &lt;select&gt;}
 * con cuatro fotos fijas del proyecto.
 *
 * El archivo se guarda con un nombre generado (UUID), nunca con el nombre
 * que trae el navegador: aceptarlo tal cual permitiria sobrescribir otro
 * archivo del servidor con un nombre como <code>../../WEB-INF/web.xml</code>.
 */
public final class ArchivoUtil {

    private static final long TAMANO_MAXIMO_BYTES = 5L * 1024 * 1024; // 5 MB

    private static final Set<String> EXTENSIONES_IMAGEN =
            new HashSet<String>(Arrays.asList("jpg", "jpeg", "png", "webp", "gif"));

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

        File carpeta = new File(carpetaDestino);
        if (!carpeta.exists() && !carpeta.mkdirs()) {
            throw new IOException("No se pudo crear la carpeta de destino: " + carpetaDestino);
        }

        String nombreUnico = UUID.randomUUID().toString() + "." + extension;
        File destino = new File(carpeta, nombreUnico);

        try (InputStream entrada = parte.getInputStream()) {
            Files.copy(entrada, destino.toPath(), StandardCopyOption.REPLACE_EXISTING);
        }

        return rutaWebDeLaCarpeta + "/" + nombreUnico;
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
