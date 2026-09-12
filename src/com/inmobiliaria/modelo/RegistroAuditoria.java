package com.inmobiliaria.modelo;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Una fila de la bitacora de auditoria (tabla auditoria): quien hizo que,
 * cuando y desde donde. HU-13 le da al administrador una pantalla para
 * consultarla en vez de tener que abrir la base de datos directamente.
 */
public class RegistroAuditoria implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private Integer idUsuario;
    private String correoUsuario;
    private String accion;
    private String detalle;
    private String ip;
    private Timestamp fecha;

    public RegistroAuditoria() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Integer getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(Integer idUsuario) {
        this.idUsuario = idUsuario;
    }

    /** Correo de quien hizo la accion, o null si fue un intento anonimo. */
    public String getCorreoUsuario() {
        return correoUsuario;
    }

    public void setCorreoUsuario(String correoUsuario) {
        this.correoUsuario = correoUsuario;
    }

    public String getAccion() {
        return accion;
    }

    public void setAccion(String accion) {
        this.accion = accion;
    }

    public String getDetalle() {
        return detalle;
    }

    public void setDetalle(String detalle) {
        this.detalle = detalle;
    }

    public String getIp() {
        return ip;
    }

    public void setIp(String ip) {
        this.ip = ip;
    }

    public Timestamp getFecha() {
        return fecha;
    }

    public void setFecha(Timestamp fecha) {
        this.fecha = fecha;
    }
}
