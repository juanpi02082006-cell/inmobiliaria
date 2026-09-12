package com.inmobiliaria.modelo;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Visita agendada por un cliente sobre un inmueble (tabla cita).
 *
 * Relaciones 1:N: un cliente puede tener muchas citas y una propiedad puede
 * recibir muchas citas, pero nunca dos en el mismo horario exacto (restriccion
 * UNIQUE sobre id_propiedad + fecha_hora, que impide que se crucen las
 * agendas).
 *
 * Trae ya resueltos por JOIN algunos datos de la propiedad y del cliente,
 * para que las vistas de "mis citas" (cliente) y "citas por atender" (agente)
 * no necesiten consultas sueltas.
 */
public class Cita implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private int idPropiedad;
    private int idCliente;
    private Timestamp fechaHora;
    private String estado;
    private String observaciones;
    private Timestamp fechaSolicitud;

    /** Datos de la propiedad, traidos por JOIN. */
    private String propiedadTitulo;
    private String propiedadDireccion;
    private String propiedadCiudad;
    private String propiedadMatricula;

    /** Datos del cliente, traidos por JOIN (solo los necesita la vista del agente). */
    private String clienteNombre;
    private String clienteCorreo;

    public Cita() {
    }

    /** ¿Todavia se puede actuar sobre ella (confirmar o cancelar)? */
    public boolean esGestionable() {
        return "PENDIENTE".equals(estado) || "CONFIRMADA".equals(estado);
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getIdPropiedad() {
        return idPropiedad;
    }

    public void setIdPropiedad(int idPropiedad) {
        this.idPropiedad = idPropiedad;
    }

    public int getIdCliente() {
        return idCliente;
    }

    public void setIdCliente(int idCliente) {
        this.idCliente = idCliente;
    }

    public Timestamp getFechaHora() {
        return fechaHora;
    }

    public void setFechaHora(Timestamp fechaHora) {
        this.fechaHora = fechaHora;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getObservaciones() {
        return observaciones;
    }

    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }

    public Timestamp getFechaSolicitud() {
        return fechaSolicitud;
    }

    public void setFechaSolicitud(Timestamp fechaSolicitud) {
        this.fechaSolicitud = fechaSolicitud;
    }

    public String getPropiedadTitulo() {
        return propiedadTitulo;
    }

    public void setPropiedadTitulo(String propiedadTitulo) {
        this.propiedadTitulo = propiedadTitulo;
    }

    public String getPropiedadDireccion() {
        return propiedadDireccion;
    }

    public void setPropiedadDireccion(String propiedadDireccion) {
        this.propiedadDireccion = propiedadDireccion;
    }

    public String getPropiedadCiudad() {
        return propiedadCiudad;
    }

    public void setPropiedadCiudad(String propiedadCiudad) {
        this.propiedadCiudad = propiedadCiudad;
    }

    public String getPropiedadMatricula() {
        return propiedadMatricula;
    }

    public void setPropiedadMatricula(String propiedadMatricula) {
        this.propiedadMatricula = propiedadMatricula;
    }

    public String getClienteNombre() {
        return clienteNombre;
    }

    public void setClienteNombre(String clienteNombre) {
        this.clienteNombre = clienteNombre;
    }

    public String getClienteCorreo() {
        return clienteCorreo;
    }

    public void setClienteCorreo(String clienteCorreo) {
        this.clienteCorreo = clienteCorreo;
    }
}
