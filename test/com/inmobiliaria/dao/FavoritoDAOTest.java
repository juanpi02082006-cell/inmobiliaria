package com.inmobiliaria.dao;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * Pruebas de la capa de datos sobre {@link FavoritoDAO} (HU-08).
 *
 * agregar()/eliminar() SI modifican datos, asi que la pareja usuario-inmueble
 * que se usa aqui se fuerza a "sin favorito" antes y despues de cada prueba,
 * sin importar el resultado. Son ids de los datos de prueba (02_datos.sql)
 * que hoy no tienen esa relacion marcada.
 */
class FavoritoDAOTest {

    private static final int ID_CLIENTE = 6;     // diana.gomez@gmail.com
    private static final int ID_PROPIEDAD = 2;   // no esta en los favoritos de prueba de ese cliente

    private final FavoritoDAO favoritoDAO = new FavoritoDAO();

    @BeforeEach
    @AfterEach
    void asegurarSinFavoritoDePrueba() throws Exception {
        favoritoDAO.eliminar(ID_CLIENTE, ID_PROPIEDAD);
    }

    @Test
    @DisplayName("agregar() deja el inmueble marcado como favorito")
    void agregarMarcaFavorito() throws Exception {
        assertFalse(favoritoDAO.esFavorito(ID_CLIENTE, ID_PROPIEDAD), "no deberia estar marcado antes de la prueba");

        favoritoDAO.agregar(ID_CLIENTE, ID_PROPIEDAD);

        assertTrue(favoritoDAO.esFavorito(ID_CLIENTE, ID_PROPIEDAD));
    }

    @Test
    @DisplayName("agregar() es idempotente: marcarlo dos veces no lanza una excepcion")
    void agregarDosVecesNoFalla() throws Exception {
        favoritoDAO.agregar(ID_CLIENTE, ID_PROPIEDAD);
        favoritoDAO.agregar(ID_CLIENTE, ID_PROPIEDAD);

        assertTrue(favoritoDAO.esFavorito(ID_CLIENTE, ID_PROPIEDAD));
    }

    @Test
    @DisplayName("eliminar() quita la marca y esFavorito vuelve a dar false")
    void eliminarQuitaFavorito() throws Exception {
        favoritoDAO.agregar(ID_CLIENTE, ID_PROPIEDAD);
        assertTrue(favoritoDAO.esFavorito(ID_CLIENTE, ID_PROPIEDAD));

        favoritoDAO.eliminar(ID_CLIENTE, ID_PROPIEDAD);

        assertFalse(favoritoDAO.esFavorito(ID_CLIENTE, ID_PROPIEDAD));
    }

    @Test
    @DisplayName("eliminar() sobre un favorito que no existe no lanza una excepcion")
    void eliminarSinFavoritoNoFalla() throws Exception {
        favoritoDAO.eliminar(ID_CLIENTE, ID_PROPIEDAD);
        assertFalse(favoritoDAO.esFavorito(ID_CLIENTE, ID_PROPIEDAD));
    }

    @Test
    @DisplayName("listarPorCliente incluye el inmueble recien marcado")
    void listarPorClienteIncluyeElRecienMarcado() throws Exception {
        favoritoDAO.agregar(ID_CLIENTE, ID_PROPIEDAD);

        boolean presente = favoritoDAO.listarPorCliente(ID_CLIENTE).stream()
                .anyMatch(p -> p.getId() == ID_PROPIEDAD);

        assertTrue(presente, "el listado de favoritos del cliente deberia incluir la propiedad recien marcada");
    }
}
