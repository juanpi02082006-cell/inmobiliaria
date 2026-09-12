package com.inmobiliaria.dao;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.List;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import com.inmobiliaria.modelo.Propiedad;

/**
 * Pruebas de la capa de datos sobre {@link PropiedadDAO}.
 *
 * Requieren la base de datos local levantada. Son de solo lectura sobre el
 * catalogo publico: no dan de alta ni modifican ningun inmueble.
 */
class PropiedadDAOTest {

    private final PropiedadDAO propiedadDAO = new PropiedadDAO();

    @Test
    @DisplayName("listar() solo trae inmuebles activos")
    void listarSoloTraeActivos() throws Exception {
        List<Propiedad> propiedades = propiedadDAO.listar();
        assertFalse(propiedades.isEmpty(), "deberian existir propiedades de los datos de prueba");
        propiedades.forEach(p -> assertTrue(p.isActivo(),
                "el catalogo publico no deberia devolver la propiedad " + p.getId() + ", que esta de baja"));
    }

    @Test
    @DisplayName("buscarPorId con un id inexistente devuelve null, no una excepcion")
    void buscarPorIdInexistenteDevuelveNull() throws Exception {
        assertNull(propiedadDAO.buscarPorId(999999, false));
        assertNull(propiedadDAO.buscarPorId(999999, true));
    }

    @Test
    @DisplayName("buscarPorId trae la propiedad con su ciudad y su tipo ya resueltos")
    void buscarPorIdResuelveCiudadYTipo() throws Exception {
        Propiedad cualquiera = propiedadDAO.listar().get(0);

        Propiedad p = propiedadDAO.buscarPorId(cualquiera.getId(), false);

        assertFalse(p.getCiudad() == null || p.getCiudad().isEmpty(), "deberia traer el nombre de la ciudad por JOIN");
        assertFalse(p.getTipo() == null || p.getTipo().isEmpty(), "deberia traer el nombre del tipo por JOIN");
    }

    @Test
    @DisplayName("filtrar por un tipo que no existe no revienta: devuelve una lista vacia")
    void filtrarPorTipoInexistenteDevuelveVacio() throws Exception {
        List<Propiedad> resultado = propiedadDAO.filtrar("TipoQueNoExiste", null, null, null);
        assertTrue(resultado.isEmpty());
    }
}
