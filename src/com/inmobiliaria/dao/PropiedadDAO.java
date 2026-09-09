package com.inmobiliaria.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.inmobiliaria.config.ConexionBD;
import com.inmobiliaria.modelo.Propiedad;

/**
 * Consulta del catalogo publico de propiedades.
 *
 * El CRUD completo (crear, editar, baja logica, galeria y caracteristicas)
 * corresponde al Sprint 2. Aqui esta lo que necesita el visitante: listar y
 * filtrar el catalogo.
 */
public class PropiedadDAO {

    /**
     * Consulta base del catalogo.
     *
     * Es la "consulta obligatoria 1" del enunciado: INNER JOIN entre cuatro
     * tablas (propiedad, ciudad, tipo_propiedad e inmobiliaria) mas un
     * LEFT JOIN a imagen_propiedad para traer la portada, que puede no existir.
     */
    private static final String SQL_BASE =
        "SELECT p.id_propiedad, p.matricula_inmobiliaria, p.titulo, p.descripcion, "
      + "       p.direccion, p.precio, p.operacion, p.area_m2, p.habitaciones, "
      + "       p.banos, p.parqueaderos, p.estado, "
      + "       c.nombre  AS ciudad, "
      + "       t.nombre  AS tipo, "
      + "       i.nombre  AS inmobiliaria, "
      + "       img.url   AS portada "
      + "  FROM propiedad p "
      + "  JOIN ciudad         c ON c.id_ciudad       = p.id_ciudad "
      + "  JOIN tipo_propiedad t ON t.id_tipo         = p.id_tipo "
      + "  JOIN inmobiliaria   i ON i.id_inmobiliaria = p.id_inmobiliaria "
      + "  LEFT JOIN imagen_propiedad img "
      + "         ON img.id_propiedad = p.id_propiedad AND img.es_portada = 1 "
      + " WHERE p.activo = 1 ";

    /** Catalogo completo de inmuebles activos. */
    public List<Propiedad> listar() throws SQLException {
        return filtrar(null, null, null, null);
    }

    /**
     * Catalogo con filtros opcionales.
     *
     * Los filtros se van agregando al WHERE solo si vienen con valor, y
     * siempre como parametros de PreparedStatement: nunca se concatena lo que
     * escribio el usuario dentro del SQL.
     *
     * @param tipo   nombre del tipo de propiedad; null o vacio = todos.
     * @param ciudad nombre de la ciudad; null o vacio = todas.
     * @param min    precio minimo; null = sin tope inferior.
     * @param max    precio maximo; null = sin tope superior.
     */
    public List<Propiedad> filtrar(String tipo, String ciudad, BigDecimal min, BigDecimal max)
            throws SQLException {

        StringBuilder sql = new StringBuilder(SQL_BASE);
        List<Object> parametros = new ArrayList<Object>();

        if (tieneValor(tipo)) {
            sql.append(" AND t.nombre = ? ");
            parametros.add(tipo.trim());
        }
        if (tieneValor(ciudad)) {
            sql.append(" AND c.nombre = ? ");
            parametros.add(ciudad.trim());
        }
        if (min != null) {
            sql.append(" AND p.precio >= ? ");
            parametros.add(min);
        }
        if (max != null) {
            sql.append(" AND p.precio <= ? ");
            parametros.add(max);
        }

        sql.append(" ORDER BY p.fecha_publicacion DESC ");

        List<Propiedad> resultado = new ArrayList<Propiedad>();

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql.toString())) {

            for (int i = 0; i < parametros.size(); i++) {
                ps.setObject(i + 1, parametros.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    resultado.add(mapear(rs));
                }
            }
        }
        return resultado;
    }

    /** Las N propiedades mas recientes, para las destacadas de la landing. */
    public List<Propiedad> destacadas(int cuantas) throws SQLException {
        String sql = SQL_BASE + " AND p.estado = 'DISPONIBLE' "
                   + " ORDER BY p.fecha_publicacion DESC LIMIT ?";

        List<Propiedad> resultado = new ArrayList<Propiedad>();
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, cuantas);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    resultado.add(mapear(rs));
                }
            }
        }
        return resultado;
    }

    /** Nombres de ciudad que tienen al menos una propiedad activa. */
    public List<String> ciudadesConPropiedades() throws SQLException {
        return listarNombres(
            "SELECT DISTINCT c.nombre FROM ciudad c "
          + "  JOIN propiedad p ON p.id_ciudad = c.id_ciudad "
          + " WHERE p.activo = 1 ORDER BY c.nombre");
    }

    /** Tipos de propiedad que tienen al menos un inmueble activo. */
    public List<String> tiposConPropiedades() throws SQLException {
        return listarNombres(
            "SELECT DISTINCT t.nombre FROM tipo_propiedad t "
          + "  JOIN propiedad p ON p.id_tipo = t.id_tipo "
          + " WHERE p.activo = 1 ORDER BY t.nombre");
    }

    private List<String> listarNombres(String sql) throws SQLException {
        List<String> nombres = new ArrayList<String>();
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                nombres.add(rs.getString(1));
            }
        }
        return nombres;
    }

    /** Traslada una fila del ResultSet al objeto de dominio. */
    private Propiedad mapear(ResultSet rs) throws SQLException {
        Propiedad p = new Propiedad();
        p.setId(rs.getInt("id_propiedad"));
        p.setMatricula(rs.getString("matricula_inmobiliaria"));
        p.setTitulo(rs.getString("titulo"));
        p.setDescripcion(rs.getString("descripcion"));
        p.setDireccion(rs.getString("direccion"));
        p.setPrecio(rs.getBigDecimal("precio"));
        p.setOperacion(rs.getString("operacion"));
        p.setAreaM2(rs.getBigDecimal("area_m2"));
        p.setHabitaciones(rs.getInt("habitaciones"));
        p.setBanos(rs.getInt("banos"));
        p.setParqueaderos(rs.getInt("parqueaderos"));
        p.setEstado(rs.getString("estado"));
        p.setCiudad(rs.getString("ciudad"));
        p.setTipo(rs.getString("tipo"));
        p.setInmobiliaria(rs.getString("inmobiliaria"));
        p.setImagen(rs.getString("portada"));
        return p;
    }

    private boolean tieneValor(String texto) {
        return texto != null && !texto.trim().isEmpty();
    }
}
