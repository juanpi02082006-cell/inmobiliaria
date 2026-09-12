package com.inmobiliaria.util;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * Pruebas de seguridad de {@link PasswordUtil}: el cifrado PBKDF2 de las
 * contrasenas. Nunca se compara con un valor fijo esperado porque el salt es
 * aleatorio en cada llamada; lo que se prueba es la propiedad que importa:
 * cifrar-y-verificar siempre coincide, y nada mas coincide con eso.
 */
class PasswordUtilTest {

    @Test
    @DisplayName("una contrasena cifrada se verifica correctamente contra si misma")
    void cifrarYVerificarCoinciden() {
        String hash = PasswordUtil.cifrar("MiClaveSegura123");
        assertTrue(PasswordUtil.verificar("MiClaveSegura123", hash));
    }

    @Test
    @DisplayName("una contrasena distinta no verifica contra el hash")
    void contrasenaIncorrectaNoVerifica() {
        String hash = PasswordUtil.cifrar("MiClaveSegura123");
        assertFalse(PasswordUtil.verificar("otra-clave", hash));
    }

    @Test
    @DisplayName("dos cifrados de la misma contrasena dan hashes distintos (salt aleatorio)")
    void mismaContrasenaDaHashesDistintos() {
        String hash1 = PasswordUtil.cifrar("password");
        String hash2 = PasswordUtil.cifrar("password");

        assertNotEquals(hash1, hash2,
                "si dos usuarios con la misma clave tuvieran el mismo hash, "
                + "una tabla rainbow rompería las dos cuentas a la vez");

        // Pero las dos siguen verificando correctamente la misma clave.
        assertTrue(PasswordUtil.verificar("password", hash1));
        assertTrue(PasswordUtil.verificar("password", hash2));
    }

    @Test
    @DisplayName("no se puede cifrar una contrasena vacia o nula")
    void noCifraContrasenaVacia() {
        assertThrows(IllegalArgumentException.class, () -> PasswordUtil.cifrar(""));
        assertThrows(IllegalArgumentException.class, () -> PasswordUtil.cifrar(null));
    }

    @Test
    @DisplayName("verificar() no lanza excepcion con entradas nulas: simplemente rechaza")
    void verificarConNulosNoLanza() {
        String hash = PasswordUtil.cifrar("password");
        assertFalse(PasswordUtil.verificar(null, hash));
        assertFalse(PasswordUtil.verificar("password", null));
        assertFalse(PasswordUtil.verificar(null, null));
    }

    @Test
    @DisplayName("un hash con un formato que no se reconoce se rechaza sin lanzar excepcion")
    void hashConFormatoInvalidoSeRechaza() {
        assertFalse(PasswordUtil.verificar("password", "esto-no-es-un-hash-pbkdf2"));
        assertFalse(PasswordUtil.verificar("password", "pbkdf2$no-numero$abc$def"));
        assertFalse(PasswordUtil.verificar("password", "otroformato$120000$abc$def"));
    }
}
