package com.inmobiliaria.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import com.inmobiliaria.config.ConexionBD;
import com.inmobiliaria.modelo.DocumentoSolicitud;
import com.inmobiliaria.modelo.Solicitud;

/**
 * Solicitudes de compra o arriendo y sus documentos radicados (HU-10).
 *
 * A diferencia de la cita, la solicitud no tiene una restriccion UNIQUE que
 * evite duplicados: un cliente puede radicar mas de una solicitud sobre el
 * mismo inmueble (por ejemplo, si la primera fue rechazada y quiere ofrecer
 * otras condiciones).
 */
public class SolicitudDAO {

    private static final String SQL_BASE_CLIENTE =
        "SELECT s.id_solicitud, s.id_propiedad, s.id_cliente, s.tipo, s.estado, "
      + "       s.oferta, s.comentario, s.fecha_radicacion, s.fecha_resolucion, "
      + "       p.titulo AS propiedad_titulo, p.direccion AS propiedad_direccion, "
      + "       p.matricula_inmobiliaria AS propiedad_matricula, "
      + "       ciu.nombre AS propiedad_ciudad "
      + "  FROM solicitud s "
      + "  JOIN propiedad p ON p.id_propiedad = s.id_propiedad "
      + "  JOIN ciudad ciu  ON ciu.id_ciudad  = p.id_ciudad ";

    /**
     * Radica una solicitud.
     *
     * @return el id generado.
     */
    public int radicar(Solicitud s) throws SQLException {
        String sql = "INSERT INTO solicitud (id_propiedad, id_cliente, tipo, oferta, comentario) "
                   + "VALUES (?,?,?,?,?)";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, s.getIdPropiedad());
            ps.setInt(2, s.getIdCliente());
            ps.setString(3, s.getTipo());
            if (s.getOferta() == null) {
                ps.setNull(4, Types.DECIMAL);
            } else {
                ps.setBigDecimal(4, s.getOferta());
            }
            ps.setString(5, s.getComentario());
            ps.executeUpdate();

            try (ResultSet claves = ps.getGeneratedKeys()) {
                if (!claves.next()) {
                    throw new SQLException("La base de datos no devolvio el id de la solicitud creada.");
                }
                return claves.getInt(1);
            }
        }
    }

    /** Agrega un documento radicado a una solicitud. */
    public void agregarDocumento(int idSolicitud, String nombre, String url) throws SQLException {
        String sql = "INSERT INTO documento_solicitud (id_solicitud, nombre, url) VALUES (?,?,?)";
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idSolicitud);
            ps.setString(2, nombre);
            ps.setString(3, url);
            ps.executeUpdate();
        }
    }

    /** Quita un documento que todavia no ha sido evaluado por el agente. */
    public void eliminarDocumento(int idDocumento, int idSolicitud) throws SQLException {
        String sql = "DELETE FROM documento_solicitud WHERE id_documento = ? AND id_solicitud = ?";
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idDocumento);
            ps.setInt(2, idSolicitud);
            ps.executeUpdate();
        }
    }

    /** Mis solicitudes (cliente), la mas reciente primero. */
    public List<Solicitud> listarPorCliente(int idCliente) throws SQLException {
        String sql = SQL_BASE_CLIENTE + " WHERE s.id_cliente = ? ORDER BY s.fecha_radicacion DESC";

        List<Solicitud> lista = new ArrayList<Solicitud>();
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idCliente);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapear(rs));
                }
            }
        }
        return lista;
    }

    /** Una solicitud con sus documentos cargados, o null si no existe. */
    public Solicitud buscarPorId(int idSolicitud) throws SQLException {
        String sql = SQL_BASE_CLIENTE + " WHERE s.id_solicitud = ?";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idSolicitud);

            Solicitud s;
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                s = mapear(rs);
            }
            s.setDocumentos(cargarDocumentos(cn, idSolicitud));
            return s;
        }
    }

    private List<DocumentoSolicitud> cargarDocumentos(Connection cn, int idSolicitud) throws SQLException {
        String sql = "SELECT id_documento, id_solicitud, nombre, url, estado, fecha_carga "
                   + "  FROM documento_solicitud WHERE id_solicitud = ? ORDER BY fecha_carga, id_documento";

        List<DocumentoSolicitud> lista = new ArrayList<DocumentoSolicitud>();
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idSolicitud);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DocumentoSolicitud d = new DocumentoSolicitud();
                    d.setId(rs.getInt("id_documento"));
                    d.setIdSolicitud(rs.getInt("id_solicitud"));
                    d.setNombre(rs.getString("nombre"));
                    d.setUrl(rs.getString("url"));
                    d.setEstado(rs.getString("estado"));
                    d.setFechaCarga(rs.getTimestamp("fecha_carga"));
                    lista.add(d);
                }
            }
        }
        return lista;
    }

    /** ¿Esta solicitud es de este cliente? Evita que consulte o edite la de otro cambiando el id. */
    public boolean perteneceAlCliente(int idSolicitud, int idCliente) throws SQLException {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(
                 "SELECT 1 FROM solicitud WHERE id_solicitud = ? AND id_cliente = ?")) {
            ps.setInt(1, idSolicitud);
            ps.setInt(2, idCliente);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private Solicitud mapear(ResultSet rs) throws SQLException {
        Solicitud s = new Solicitud();
        s.setId(rs.getInt("id_solicitud"));
        s.setIdPropiedad(rs.getInt("id_propiedad"));
        s.setIdCliente(rs.getInt("id_cliente"));
        s.setTipo(rs.getString("tipo"));
        s.setEstado(rs.getString("estado"));
        s.setOferta(rs.getBigDecimal("oferta"));
        s.setComentario(rs.getString("comentario"));
        s.setFechaRadicacion(rs.getTimestamp("fecha_radicacion"));
        s.setFechaResolucion(rs.getTimestamp("fecha_resolucion"));
        s.setPropiedadTitulo(rs.getString("propiedad_titulo"));
        s.setPropiedadDireccion(rs.getString("propiedad_direccion"));
        s.setPropiedadMatricula(rs.getString("propiedad_matricula"));
        s.setPropiedadCiudad(rs.getString("propiedad_ciudad"));
        return s;
    }
}
