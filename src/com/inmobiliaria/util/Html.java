package com.inmobiliaria.util;

/**
 * Escape de texto para imprimirlo dentro de HTML.
 *
 * POR QUE EXISTE ESTA CLASE
 *
 * Una expresion JSP como <%= propiedad.getTitulo() %> escribe el texto TAL
 * CUAL en la pagina. Si un agente publica un inmueble titulado
 *
 *     &lt;img src=x onerror=alert(1)&gt;
 *
 * ese HTML se ejecuta en el navegador de todo el que vea el catalogo. Es un
 * XSS almacenado: el ataque queda guardado en la base de datos y se dispara
 * cada vez que alguien abre la pagina.
 *
 * El caso grave no es el catalogo publico sino el cruce de roles: un CLIENTE
 * que escriba eso en su nombre de perfil consigue que el codigo se ejecute
 * en la sesion del ADMINISTRADOR cuando este abre la lista de usuarios.
 *
 * Los PreparedStatement protegen la base de datos de la inyeccion SQL, pero
 * no protegen la pagina: el dato entra limpio y sale peligroso. La defensa
 * va en la salida, y es esta.
 *
 * REGLA: todo texto que haya escrito una persona se imprime con Html.esc().
 * Los numeros y los valores de un ENUM de la base no lo necesitan, pero
 * tampoco estorba.
 */
public final class Html {

    private Html() {
    }

    /**
     * Convierte los caracteres con significado en HTML a sus entidades.
     *
     * Sirve tanto para el cuerpo de la pagina como para el interior de un
     * atributo, porque escapa tambien las comillas simples y dobles: sin eso,
     * un valor podria cerrar el atributo y agregar otro (por ejemplo
     * onmouseover) sin necesidad de un solo signo mayor que.
     *
     * @param valor cualquier objeto; null se convierte en cadena vacia.
     */
    public static String esc(Object valor) {
        if (valor == null) {
            return "";
        }

        String texto = valor.toString();
        StringBuilder salida = new StringBuilder(texto.length() + 16);

        for (int i = 0; i < texto.length(); i++) {
            char c = texto.charAt(i);
            switch (c) {
                case '&':  salida.append("&amp;");  break;
                case '<':  salida.append("&lt;");   break;
                case '>':  salida.append("&gt;");   break;
                case '"':  salida.append("&quot;"); break;
                case '\'': salida.append("&#39;");  break;
                default:   salida.append(c);
            }
        }
        return salida.toString();
    }

    /**
     * Escape para texto que se mete dentro de una cadena de JavaScript, como
     * el mensaje de un confirm(). Ahi las entidades HTML no sirven: hay que
     * escapar la comilla y la barra invertida, y cortar las etiquetas para
     * que un &lt;/script&gt; no cierre el bloque antes de tiempo.
     */
    public static String js(Object valor) {
        if (valor == null) {
            return "";
        }

        String texto = valor.toString();
        StringBuilder salida = new StringBuilder(texto.length() + 16);

        for (int i = 0; i < texto.length(); i++) {
            char c = texto.charAt(i);
            switch (c) {
                case '\'': salida.append("\\'");   break;
                case '"':  salida.append("\\\"");  break;
                case '\\': salida.append("\\\\");  break;
                case '\n': salida.append("\\n");   break;
                case '\r': salida.append("\\r");   break;
                case '<':  salida.append("\\u003C"); break;
                case '>':  salida.append("\\u003E"); break;
                default:   salida.append(c);
            }
        }
        return salida.toString();
    }
}
