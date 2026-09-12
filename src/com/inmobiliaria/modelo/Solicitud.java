package com.inmobiliaria.modelo;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Solicitud de compra o arriendo radicada por un cliente sobre un inmueble
 * (tabla solicitud), con sus documentos radicados (relacion 1:N con
 * documento_solicitud).
 *
 * HU-10 cubre que el cliente la radique y consulte su estado; HU-11 cubre que
 * el agente la resuelva (aprobar o rechazar), por eso el estado avanza por
 * fuera de esta clase: aqui solo se refleja.
 */
public class Solicitud implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private int idPropiedad;
    private int idCliente;
    private String tipo;
    private String estado;
    private BigDecimal oferta;
    private String comentario;
    private Timestamp fechaRadicacion;
    private Timestamp fechaResolucion;

    /** Documentos radicados. Solo se cargan en el detalle de una solicitud. */
    private List<DocumentoSolicitud> documentos = new ArrayList<DocumentoSolicitud>();

    /** Datos de la propiedad, traidos por JOIN. */
    private String propiedadTitulo;
    private String propiedadDireccion;
    private String propiedadCiudad;
    private String propiedadMatricula;

    /** Datos del cliente, traidos por JOIN (solo los necesita la vista del agente). */
    private String clienteNombre;
    private String clienteCorreo;

    public Solicitud() {
    }

    /** ¿Todavia esta a la espera de que el agente decida? */
    public boolean esGestionable() {
        return "RADICADA".equals(estado) || "EN_REVISION".equals(estado);
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

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public BigDecimal getOferta() {
        return oferta;
    }

    public void setOferta(BigDecimal oferta) {
        this.oferta = oferta;
    }

    public String getComentario() {
        return comentario;
    }

    public void setComentario(String comentario) {
        this.comentario = comentario;
    }

    public Timestamp getFechaRadicacion() {
        return fechaRadicacion;
    }

    public void setFechaRadicacion(Timestamp fechaRadicacion) {
        this.fechaRadicacion = fechaRadicacion;
    }

    public Timestamp getFechaResolucion() {
        return fechaResolucion;
    }

    public void setFechaResolucion(Timestamp fechaResolucion) {
        this.fechaResolucion = fechaResolucion;
    }

    public List<DocumentoSolicitud> getDocumentos() {
        return documentos;
    }

    public void setDocumentos(List<DocumentoSolicitud> documentos) {
        this.documentos = (documentos == null) ? new ArrayList<DocumentoSolicitud>() : documentos;
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
