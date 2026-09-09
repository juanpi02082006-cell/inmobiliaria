package com.inmobiliaria.modelo;

import java.io.Serializable;

/**
 * Datos personales del usuario (tabla perfil).
 *
 * Es el lado "debil" de la relacion 1:1 con usuario. La restriccion
 * UNIQUE sobre perfil.id_usuario es lo que garantiza que un usuario no pueda
 * tener dos perfiles; sin ese UNIQUE la relacion seria 1:N.
 *
 * Se separo de {@link Usuario} para que la tabla de credenciales quede
 * minima: al autenticar solo se leen correo, hash y estado.
 */
public class Perfil implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private int idUsuario;
    private String nombres;
    private String apellidos;
    private String documento;
    private String telefono;
    private String direccion;
    private String fotoUrl;

    public Perfil() {
    }

    /** Nombre completo para mostrar en los paneles. */
    public String nombreCompleto() {
        String n = (nombres == null) ? "" : nombres;
        String a = (apellidos == null) ? "" : apellidos;
        return (n + " " + a).trim();
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public String getNombres() {
        return nombres;
    }

    public void setNombres(String nombres) {
        this.nombres = nombres;
    }

    public String getApellidos() {
        return apellidos;
    }

    public void setApellidos(String apellidos) {
        this.apellidos = apellidos;
    }

    public String getDocumento() {
        return documento;
    }

    public void setDocumento(String documento) {
        this.documento = documento;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public String getFotoUrl() {
        return fotoUrl;
    }

    public void setFotoUrl(String fotoUrl) {
        this.fotoUrl = fotoUrl;
    }
}
