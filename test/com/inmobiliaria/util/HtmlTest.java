package com.inmobiliaria.util;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * Pruebas de seguridad de {@link Html}: es la defensa contra el XSS
 * almacenado que describe su propio javadoc (y que motivo el commit
 * "fix: corrige XSS almacenado y el parseo de decimales"). Si esc() deja de
 * escapar alguno de estos caracteres, cualquier campo de texto libre
 * (titulo de un inmueble, nombre de perfil...) vuelve a ser un vector de
 * ataque.
 */
class HtmlTest {

    @Test
    @DisplayName("null se convierte en cadena vacia, no en \"null\"")
    void nuloDaVacio() {
        assertEquals("", Html.esc(null));
    }

    @Test
    @DisplayName("texto sin caracteres especiales queda igual")
    void textoPlanoQuedaIgual() {
        assertEquals("Apartamento en Cabecera", Html.esc("Apartamento en Cabecera"));
    }

    @Test
    @DisplayName("escapa las etiquetas para que no se interpreten como HTML")
    void escapaEtiquetas() {
        String resultado = Html.esc("<script>alert(1)</script>");
        assertFalse(resultado.contains("<"), "no debe quedar un '<' sin escapar: " + resultado);
        assertFalse(resultado.contains(">"), "no debe quedar un '>' sin escapar: " + resultado);
        assertEquals("&lt;script&gt;alert(1)&lt;/script&gt;", resultado);
    }

    @Test
    @DisplayName("el payload de XSS del javadoc de Html queda inofensivo")
    void payloadDelJavadocQuedaEscapado() {
        // Este es literalmente el ejemplo que usa Html.java para explicar por
        // que existe la clase: un <img onerror> en el titulo de un inmueble.
        String payload = "<img src=x onerror=alert(1)>";
        String resultado = Html.esc(payload);

        assertFalse(resultado.contains("<img"), resultado);
        assertTrue(resultado.startsWith("&lt;img"), resultado);
    }

    @Test
    @DisplayName("escapa comillas dobles y simples, no solo las etiquetas")
    void escapaComillas() {
        String resultado = Html.esc("\" onmouseover=\"alert(1)\" data-x='y'");
        assertFalse(resultado.contains("\""), resultado);
        assertFalse(resultado.contains("'"), resultado);
    }

    @Test
    @DisplayName("escapa el ampersand sin escapar dos veces las entidades ya generadas")
    void escapaAmpersand() {
        assertEquals("Tom &amp; Jerry", Html.esc("Tom & Jerry"));
    }

    @Test
    @DisplayName("js(): null se convierte en cadena vacia")
    void jsNuloDaVacio() {
        assertEquals("", Html.js(null));
    }

    @Test
    @DisplayName("js(): escapa comillas y barra invertida para no romper el string de JS")
    void jsEscapaComillasYBarra() {
        // Escapar una comilla es anteponerle una barra invertida, no borrarla:
        // \' sigue siendo una comilla valida dentro del string de JS. Por eso
        // se compara contra el resultado completo en vez de buscar que la
        // comilla "desaparezca".
        String resultado = Html.js("O'Brien dijo \"hola\" y usa \\backslash");
        assertEquals("O\\'Brien dijo \\\"hola\\\" y usa \\\\backslash", resultado);
    }

    @Test
    @DisplayName("js(): corta un </script> para que no cierre el bloque antes de tiempo")
    void jsCortaCierreDeScript() {
        String resultado = Html.js("</script><script>alert(1)</script>");
        assertFalse(resultado.contains("<"), resultado);
        assertFalse(resultado.contains(">"), resultado);
    }
}
