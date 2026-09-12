package com.inmobiliaria.modelo;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Documento radicado junto con una solicitud de compra o arriendo (tabla
 * documento_solicitud). Relacion 1:N: una solicitud puede traer varios
 * documentos (cedula, carta laboral, certificado de ingresos...).
 *
 * La subida real de archivos es deuda tecnica pendiente (igual que la
 * galeria de imagenes): por ahora el cliente indica el nombre y la
 * ubicacion del documento en lugar de subir el archivo.
 */
public class DocumentoSolicitud implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private int idSolicitud;
    private String nombre;
    private String url;
    private String estado;
    private Timestamp fechaCarga;

    public DocumentoSolicitud() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getIdSolicitud() {
        return idSolicitud;
    }

    public void setIdSolicitud(int idSolicitud) {
        this.idSolicitud = idSolicitud;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public Timestamp getFechaCarga() {
        return fechaCarga;
    }

    public void setFechaCarga(Timestamp fechaCarga) {
        this.fechaCarga = fechaCarga;
    }
}
