package com.inmobiliaria.modelo;

import java.io.Serializable;
import java.sql.Timestamp;

import com.inmobiliaria.util.ArchivoUtil;

/**
 * Documento radicado junto con una solicitud de compra o arriendo (tabla
 * documento_solicitud). Relacion 1:N: una solicitud puede traer varios
 * documentos (cedula, carta laboral, certificado de ingresos...).
 *
 * {@code url} es la ruta del archivo subido dentro de
 * {@link ArchivoUtil#CARPETA_DOCUMENTOS}. Los documentos de los datos de
 * prueba traen una ruta ficticia y no tienen archivo.
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

    /** ¿Tiene un archivo subido que se pueda abrir? */
    public boolean tieneArchivo() {
        return ArchivoUtil.esDocumentoSubido(url);
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
