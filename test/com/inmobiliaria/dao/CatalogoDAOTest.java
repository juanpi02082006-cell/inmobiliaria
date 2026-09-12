package com.inmobiliaria.dao;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.Map;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * Pruebas de la capa de datos sobre {@link CatalogoDAO}.
 *
 * Requieren la base de datos local levantada (la misma que usa la
 * aplicacion: lo que lea db.properties). Son de solo lectura: no modifican
 * ninguna fila, asi que se pueden correr tantas veces como se quiera sin
 * dejar el catalogo distinto de como estaba.
 */
class CatalogoDAOTest {

    private final CatalogoDAO catalogoDAO = new CatalogoDAO();

    @Test
    @DisplayName("el catalogo de ciudades no esta vacio")
    void ciudadesNoEstaVacio() throws Exception {
        Map<Integer, String> ciudades = catalogoDAO.ciudades();
        assertFalse(ciudades.isEmpty(), "deberia haber ciudades de los datos de prueba (02_datos.sql)");
    }

    @Test
    @DisplayName("el enunciado fija exactamente cinco tipos de propiedad")
    void hayExactamenteCincoTiposDePropiedad() throws Exception {
        // Regla de negocio explicita del proyecto: casa, apartamento, local,
        // oficina y terreno. No se agregan tipos nuevos para "llenar filas",
        // ni deberian faltar ni sobrar en el catalogo real.
        Map<Integer, String> tipos = catalogoDAO.tipos();
        assertEquals(5, tipos.size(),
                "el catalogo deberia tener exactamente los 5 tipos que fija el enunciado, tiene: " + tipos.values());
    }

    @Test
    @DisplayName("existeCiudad reconoce una ciudad real y rechaza un id inexistente")
    void existeCiudadDistingueValidoDeInvalido() throws Exception {
        Map<Integer, String> ciudades = catalogoDAO.ciudades();
        int idValido = ciudades.keySet().iterator().next().intValue();

        assertTrue(catalogoDAO.existeCiudad(idValido));
        assertFalse(catalogoDAO.existeCiudad(999999));
    }

    @Test
    @DisplayName("existeTipo reconoce un tipo real y rechaza un id inexistente")
    void existeTipoDistingueValidoDeInvalido() throws Exception {
        Map<Integer, String> tipos = catalogoDAO.tipos();
        int idValido = tipos.keySet().iterator().next().intValue();

        assertTrue(catalogoDAO.existeTipo(idValido));
        assertFalse(catalogoDAO.existeTipo(0));
        assertFalse(catalogoDAO.existeTipo(999999));
    }

    @Test
    @DisplayName("las caracteristicas del catalogo tienen nombre")
    void caracteristicasTienenNombre() throws Exception {
        catalogoDAO.caracteristicas().forEach(c ->
                assertFalse(c.getNombre() == null || c.getNombre().isEmpty(),
                        "la caracteristica id=" + c.getId() + " no deberia tener nombre vacio"));
    }
}
