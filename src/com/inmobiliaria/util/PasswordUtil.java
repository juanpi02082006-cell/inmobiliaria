package com.inmobiliaria.util;

import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/**
 * Cifrado de contrasenas con PBKDF2 + salt aleatorio.
 *
 * El enunciado permite BCrypt, PBKDF2 o SHA-256 con salt, y prohibe guardar
 * la clave en texto plano. Se eligio PBKDF2WithHmacSHA256 porque viene dentro
 * del JDK: el proyecto no depende de ningun .jar externo y compila en
 * cualquier maquina sin descargar nada.
 *
 * Formato guardado en usuario.password_hash (83 caracteres, cabe en VARCHAR(100)):
 *
 *     pbkdf2$120000$&lt;salt en Base64&gt;$&lt;hash en Base64&gt;
 *
 * El salt es distinto para cada usuario, de modo que dos personas con la misma
 * contrasena producen hashes diferentes y las tablas rainbow no sirven.
 */
public final class PasswordUtil {

    private static final String ALGORITMO = "PBKDF2WithHmacSHA256";
    private static final String PREFIJO = "pbkdf2";
    private static final int ITERACIONES = 120000;
    private static final int BYTES_SALT = 16;
    private static final int BITS_CLAVE = 256;

    private static final SecureRandom ALEATORIO = new SecureRandom();

    private PasswordUtil() {
    }

    /**
     * Cifra una contrasena en claro generando un salt nuevo.
     *
     * @param passwordEnClaro la contrasena tal como la escribio el usuario.
     * @return la cadena lista para guardar en la columna password_hash.
     */
    public static String cifrar(String passwordEnClaro) {
        if (passwordEnClaro == null || passwordEnClaro.isEmpty()) {
            throw new IllegalArgumentException("La contrasena no puede estar vacia.");
        }

        byte[] salt = new byte[BYTES_SALT];
        ALEATORIO.nextBytes(salt);

        byte[] hash = derivar(passwordEnClaro.toCharArray(), salt, ITERACIONES);

        Base64.Encoder b64 = Base64.getEncoder();
        return PREFIJO + "$" + ITERACIONES
                + "$" + b64.encodeToString(salt)
                + "$" + b64.encodeToString(hash);
    }

    /**
     * Verifica una contrasena contra el hash almacenado.
     *
     * @param passwordEnClaro lo que escribio el usuario en el formulario.
     * @param hashAlmacenado  el valor de usuario.password_hash.
     * @return true solo si coinciden.
     */
    public static boolean verificar(String passwordEnClaro, String hashAlmacenado) {
        if (passwordEnClaro == null || hashAlmacenado == null) {
            return false;
        }

        String[] partes = hashAlmacenado.split("\\$");
        if (partes.length != 4 || !PREFIJO.equals(partes[0])) {
            // Hash con un formato que no reconocemos: se rechaza el acceso.
            return false;
        }

        try {
            int iteraciones = Integer.parseInt(partes[1]);
            Base64.Decoder b64 = Base64.getDecoder();
            byte[] salt = b64.decode(partes[2]);
            byte[] esperado = b64.decode(partes[3]);

            byte[] calculado = derivar(passwordEnClaro.toCharArray(), salt, iteraciones);
            return sonIguales(esperado, calculado);
        } catch (IllegalArgumentException e) {
            // Numero de iteraciones o Base64 corrupto en la base de datos.
            return false;
        }
    }

    /** Aplica PBKDF2 sobre la contrasena con el salt y las iteraciones dados. */
    private static byte[] derivar(char[] password, byte[] salt, int iteraciones) {
        PBEKeySpec spec = new PBEKeySpec(password, salt, iteraciones, BITS_CLAVE);
        try {
            return SecretKeyFactory.getInstance(ALGORITMO).generateSecret(spec).getEncoded();
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new IllegalStateException("No se pudo aplicar " + ALGORITMO, e);
        } finally {
            spec.clearPassword();
        }
    }

    /**
     * Compara dos arreglos en tiempo constante.
     *
     * Un equals normal corta en el primer byte distinto, y medir ese tiempo
     * permitiria adivinar el hash byte a byte. Aqui siempre se recorren los
     * dos arreglos completos.
     */
    private static boolean sonIguales(byte[] a, byte[] b) {
        if (a.length != b.length) {
            return false;
        }
        int diferencia = 0;
        for (int i = 0; i < a.length; i++) {
            diferencia |= a[i] ^ b[i];
        }
        return diferencia == 0;
    }

    /**
     * Utilidad de linea de comandos para generar los hashes de los datos de
     * prueba de 02_datos.sql:
     *
     *     java -cp WEB-INF/classes com.inmobiliaria.util.PasswordUtil password
     */
    public static void main(String[] args) {
        String clave = (args.length > 0) ? args[0] : "password";
        System.out.println(cifrar(clave));
    }
}
