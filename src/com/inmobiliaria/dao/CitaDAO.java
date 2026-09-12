package com.inmobiliaria.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.inmobiliaria.config.ConexionBD;
import com.inmobiliaria.modelo.Cita;

/**
 * Agenda de visitas (HU-09).
 *
 * La restriccion que evita que se crucen las agendas ya vive en la base de
 * datos: UNIQUE (id_propiedad, fecha_hora). Aqui se hace ademas una
 * comprobacion previa para devolver un mensaje claro antes de intentar el
 * INSERT, y se atrapa la violacion por si dos peticiones llegan a la vez.
 */
public class CitaDAO {

    /** Codigo con el que MySQL avisa que se violo una restriccion UNIQUE. */
    private static final int ERROR_DUPLICADO = 1062;

    private static final String SQL_BASE_CLIENTE =
        "SELECT c.id_cita, c.id_propiedad, c.id_cliente, c.fecha_hora, c.estado, "
      + "       c.observaciones, c.fecha_solicitud, "
      + "       p.titulo AS propiedad_titulo, p.direccion AS propiedad_direccion, "
      + "       p.matricula_inmobiliaria AS propiedad_matricula, "
      + "       ciu.nombre AS propiedad_ciudad "
      + "  FROM cita c "
      + "  JOIN propiedad p ON p.id_propiedad = c.id_propiedad "
      + "  JOIN ciudad ciu  ON ciu.id_ciudad  = p.id_ciudad ";

    /**
     * ¿Ya hay una cita activa (no cancelada) para ese inmueble en ese horario?
     * Sirve para mostrar un mensaje amigable antes de intentar guardar.
     */
    public boolean horarioOcupado(int idPropiedad, Timestamp fechaHora) throws SQLException {
        String sql = "SELECT 1 FROM cita "
                   + " WHERE id_propiedad = ? AND fecha_hora = ? AND estado <> 'CANCELADA'";
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idPropiedad);
            ps.setTimestamp(2, fechaHora);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Agenda una visita.
     *
     * @return el id generado.
     * @throws DatoDuplicadoException si el horario ya esta ocupado para ese
     *                                inmueble (UNIQUE id_propiedad + fecha_hora).
     */
    public int agendar(Cita c) throws SQLException, DatoDuplicadoException {
        String sql = "INSERT INTO cita (id_propiedad, id_cliente, fecha_hora, observaciones) "
                   + "VALUES (?,?,?,?)";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, c.getIdPropiedad());
            ps.setInt(2, c.getIdCliente());
            ps.setTimestamp(3, c.getFechaHora());
            ps.setString(4, c.getObservaciones());
            ps.executeUpdate();

            try (ResultSet claves = ps.getGeneratedKeys()) {
                if (!claves.next()) {
                    throw new SQLException("La base de datos no devolvio el id de la cita creada.");
                }
                return claves.getInt(1);
            }

        } catch (SQLIntegrityConstraintViolationException e) {
            throw traducirDuplicado(e);
        }
    }

    /** Mis citas (cliente), la mas proxima primero. */
    public List<Cita> listarPorCliente(int idCliente) throws SQLException {
        String sql = SQL_BASE_CLIENTE + " WHERE c.id_cliente = ? ORDER BY c.fecha_hora DESC";

        List<Cita> lista = new ArrayList<Cita>();
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

    /** Citas sobre las propiedades de las agencias que administra este usuario (agente). */
    public List<Cita> listarPorAgente(int idUsuarioAgente) throws SQLException {
        String sql =
            "SELECT c.id_cita, c.id_propiedad, c.id_cliente, c.fecha_hora, c.estado, "
          + "       c.observaciones, c.fecha_solicitud, "
          + "       p.titulo AS propiedad_titulo, p.direccion AS propiedad_direccion, "
          + "       p.matricula_inmobiliaria AS propiedad_matricula, "
          + "       ciu.nombre AS propiedad_ciudad, "
          + "       pf.nombres AS cliente_nombres, pf.apellidos AS cliente_apellidos, "
          + "       u.correo AS cliente_correo "
          + "  FROM cita c "
          + "  JOIN propiedad p    ON p.id_propiedad = c.id_propiedad "
          + "  JOIN ciudad ciu     ON ciu.id_ciudad = p.id_ciudad "
          + "  JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria "
          + "  JOIN usuario u      ON u.id_usuario = c.id_cliente "
          + " LEFT JOIN perfil pf  ON pf.id_usuario = u.id_usuario "
          + " WHERE i.id_usuario = ? "
          + " ORDER BY (c.estado = 'PENDIENTE') DESC, c.fecha_hora";

        List<Cita> lista = new ArrayList<Cita>();
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuarioAgente);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Cita c = mapear(rs);
                    String nombres = rs.getString("cliente_nombres");
                    String apellidos = rs.getString("cliente_apellidos");
                    c.setClienteNombre((nombres == null)
                            ? rs.getString("cliente_correo")
                            : (nombres + " " + apellidos).trim());
                    c.setClienteCorreo(rs.getString("cliente_correo"));
                    lista.add(c);
                }
            }
        }
        return lista;
    }

    /** ¿Esta cita es de este cliente? Evita que cancele o vea la de otro cambiando el id. */
    public boolean perteneceAlCliente(int idCita, int idCliente) throws SQLException {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(
                 "SELECT 1 FROM cita WHERE id_cita = ? AND id_cliente = ?")) {
            ps.setInt(1, idCita);
            ps.setInt(2, idCliente);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** ¿Esta cita cae sobre una propiedad de una agencia que administra este usuario (agente)? */
    public boolean perteneceAlAgente(int idCita, int idUsuarioAgente) throws SQLException {
        String sql = "SELECT 1 FROM cita c "
                   + "  JOIN propiedad p    ON p.id_propiedad = c.id_propiedad "
                   + "  JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria "
                   + " WHERE c.id_cita = ? AND i.id_usuario = ?";
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idCita);
            ps.setInt(2, idUsuarioAgente);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** Cambia el estado de una cita (confirmar, cancelar, marcar realizada). */
    public void cambiarEstado(int idCita, String nuevoEstado) throws SQLException {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(
                 "UPDATE cita SET estado = ? WHERE id_cita = ?")) {
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idCita);
            ps.executeUpdate();
        }
    }

    private Cita mapear(ResultSet rs) throws SQLException {
        Cita c = new Cita();
        c.setId(rs.getInt("id_cita"));
        c.setIdPropiedad(rs.getInt("id_propiedad"));
        c.setIdCliente(rs.getInt("id_cliente"));
        c.setFechaHora(rs.getTimestamp("fecha_hora"));
        c.setEstado(rs.getString("estado"));
        c.setObservaciones(rs.getString("observaciones"));
        c.setFechaSolicitud(rs.getTimestamp("fecha_solicitud"));
        c.setPropiedadTitulo(rs.getString("propiedad_titulo"));
        c.setPropiedadDireccion(rs.getString("propiedad_direccion"));
        c.setPropiedadMatricula(rs.getString("propiedad_matricula"));
        c.setPropiedadCiudad(rs.getString("propiedad_ciudad"));
        return c;
    }

    /**
     * Convierte el error 1062 de MySQL en un mensaje que el usuario entienda.
     * Aqui solo puede violarse un UNIQUE: el de (id_propiedad, fecha_hora).
     */
    private DatoDuplicadoException traducirDuplicado(SQLIntegrityConstraintViolationException e) {
        String detalle = (e.getMessage() == null) ? "" : e.getMessage().toLowerCase();

        if (e.getErrorCode() == ERROR_DUPLICADO || detalle.contains("duplicate")) {
            return new DatoDuplicadoException("fechaHora",
                    "Ese horario ya esta ocupado para este inmueble. Elija otra fecha u hora.");
        }
        return new DatoDuplicadoException(null,
                "Los datos ingresados chocan con un registro que ya existe.");
    }
}
