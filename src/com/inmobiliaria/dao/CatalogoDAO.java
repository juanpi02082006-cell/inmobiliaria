package com.inmobiliaria.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.inmobiliaria.config.ConexionBD;
import com.inmobiliaria.modelo.Caracteristica;

/**
 * Lectura de los catalogos del sistema: ciudades, tipos de propiedad y
 * caracteristicas.
 *
 * Alimentan los desplegables del formulario de propiedades. Se leen de la
 * base de datos y no se escriben a mano en las vistas: si el administrador
 * agrega una ciudad, aparece sola en el formulario.
 */
public class CatalogoDAO {

    /**
     * Ciudades disponibles, con el departamento en el texto para distinguir
     * dos ciudades homonimas de departamentos distintos.
     *
     * @return mapa id -> "Ciudad (Departamento)", en orden alfabetico.
     */
    public Map<Integer, String> ciudades() throws SQLException {
        Map<Integer, String> mapa = new LinkedHashMap<Integer, String>();
        String sql = "SELECT id_ciudad, nombre, departamento FROM ciudad "
                   + " ORDER BY departamento, nombre";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                mapa.put(Integer.valueOf(rs.getInt("id_ciudad")),
                         rs.getString("nombre") + " (" + rs.getString("departamento") + ")");
            }
        }
        return mapa;
    }

    /**
     * Tipos de propiedad. Son exactamente cinco: casa, apartamento, local,
     * oficina y terreno, tal como define el enunciado.
     */
    public Map<Integer, String> tipos() throws SQLException {
        Map<Integer, String> mapa = new LinkedHashMap<Integer, String>();
        String sql = "SELECT id_tipo, nombre FROM tipo_propiedad ORDER BY nombre";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                mapa.put(Integer.valueOf(rs.getInt("id_tipo")), rs.getString("nombre"));
            }
        }
        return mapa;
    }

    /** Catalogo completo de caracteristicas, para las casillas del formulario. */
    public List<Caracteristica> caracteristicas() throws SQLException {
        List<Caracteristica> lista = new ArrayList<Caracteristica>();
        String sql = "SELECT id_caracteristica, nombre FROM caracteristica ORDER BY nombre";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(new Caracteristica(rs.getInt("id_caracteristica"),
                                             rs.getString("nombre")));
            }
        }
        return lista;
    }

    /** ¿Existe ese id de ciudad? Se valida en el servidor antes de guardar. */
    public boolean existeCiudad(int idCiudad) throws SQLException {
        return existe("SELECT 1 FROM ciudad WHERE id_ciudad = ?", idCiudad);
    }

    /** ¿Existe ese id de tipo? Impide guardar un tipo fuera del catalogo. */
    public boolean existeTipo(int idTipo) throws SQLException {
        return existe("SELECT 1 FROM tipo_propiedad WHERE id_tipo = ?", idTipo);
    }

    private boolean existe(String sql, int id) throws SQLException {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}
