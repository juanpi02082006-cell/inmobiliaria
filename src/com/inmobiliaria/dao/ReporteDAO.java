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
import com.inmobiliaria.modelo.ResumenCiudad;

/**
 * Reporte de propiedades por ciudad y por estado (HU-12), generado con
 * consultas de agregacion (COUNT, AVG, MIN, MAX agrupados con GROUP BY) en
 * lugar de traer las filas completas y sumarlas en Java.
 *
 * Solo cuenta el catalogo activo: un inmueble dado de baja ya no aporta al
 * negocio y sesgaria el reporte si se incluyera.
 */
public class ReporteDAO {

    /** Los cuatro estados posibles de un inmueble, en el orden del ciclo de vida. */
    private static final String[] ESTADOS = {"DISPONIBLE", "RESERVADA", "VENDIDA", "ARRENDADA"};

    /**
     * Cuantas propiedades activas hay por ciudad, con el precio minimo,
     * maximo y promedio de cada una. La ciudad con mas inmuebles primero.
     */
    public List<ResumenCiudad> resumenPorCiudad() throws SQLException {
        String sql =
            "SELECT c.nombre AS ciudad, COUNT(*) AS total, "
          + "       AVG(p.precio) AS precio_promedio, "
          + "       MIN(p.precio) AS precio_minimo, "
          + "       MAX(p.precio) AS precio_maximo "
          + "  FROM propiedad p "
          + "  JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
          + " WHERE p.activo = 1 "
          + " GROUP BY c.id_ciudad, c.nombre "
          + " ORDER BY total DESC, ciudad";

        List<ResumenCiudad> lista = new ArrayList<ResumenCiudad>();
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ResumenCiudad r = new ResumenCiudad();
                r.setCiudad(rs.getString("ciudad"));
                r.setTotal(rs.getInt("total"));
                r.setPrecioPromedio(rs.getBigDecimal("precio_promedio"));
                r.setPrecioMinimo(rs.getBigDecimal("precio_minimo"));
                r.setPrecioMaximo(rs.getBigDecimal("precio_maximo"));
                lista.add(r);
            }
        }
        return lista;
    }

    /** Cuantas propiedades activas hay por estado (disponible, reservada, vendida, arrendada). */
    public Map<String, Integer> conteoPorEstado() throws SQLException {
        String sql = "SELECT estado, COUNT(*) AS total FROM propiedad "
                   + " WHERE activo = 1 GROUP BY estado";

        // Se arranca en cero para que un estado sin inmuebles (por ejemplo,
        // ninguno vendido todavia) aparezca igual en el reporte.
        Map<String, Integer> conteos = new LinkedHashMap<String, Integer>();
        for (String estado : ESTADOS) {
            conteos.put(estado, Integer.valueOf(0));
        }

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                conteos.put(rs.getString("estado"), Integer.valueOf(rs.getInt("total")));
            }
        }
        return conteos;
    }

    /**
     * Cruce ciudad x estado: cuantas propiedades activas hay de cada estado
     * en cada ciudad. Es el mismo reporte de {@link #resumenPorCiudad()}
     * desagregado por estado, para ver por ejemplo en que ciudad hay mas
     * inventario vendido frente a disponible.
     *
     * @return un mapa ordenado ciudad -&gt; (estado -&gt; total), con las
     *         cuatro claves de estado siempre presentes (0 si no hay ninguna).
     */
    public Map<String, Map<String, Integer>> matrizCiudadEstado() throws SQLException {
        String sql =
            "SELECT c.nombre AS ciudad, p.estado, COUNT(*) AS total "
          + "  FROM propiedad p "
          + "  JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
          + " WHERE p.activo = 1 "
          + " GROUP BY c.id_ciudad, c.nombre, p.estado "
          + " ORDER BY ciudad";

        Map<String, Map<String, Integer>> matriz = new LinkedHashMap<String, Map<String, Integer>>();
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String ciudad = rs.getString("ciudad");
                Map<String, Integer> fila = matriz.get(ciudad);
                if (fila == null) {
                    fila = filaEnCeros();
                    matriz.put(ciudad, fila);
                }
                fila.put(rs.getString("estado"), Integer.valueOf(rs.getInt("total")));
            }
        }
        return matriz;
    }

    private Map<String, Integer> filaEnCeros() {
        Map<String, Integer> fila = new LinkedHashMap<String, Integer>();
        for (String estado : ESTADOS) {
            fila.put(estado, Integer.valueOf(0));
        }
        return fila;
    }
}
