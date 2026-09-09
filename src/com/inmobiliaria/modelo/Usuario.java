package com.inmobiliaria.modelo;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * Credenciales y estado de la cuenta (tabla usuario).
 *
 * Refleja la separacion 1:1 del modelo: aqui viven solo el correo, el hash y
 * el estado; los datos personales estan en {@link Perfil}.
 *
 * Los roles vienen de la relacion N:M usuario_rol y se guardan en la
 * HttpSession para que el filtro de seguridad decida el acceso.
 *
 * Es Serializable porque se almacena en la sesion HTTP.
 */
public class Usuario implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String correo;
    private String passwordHash;
    private boolean activo;

    /** Roles del usuario (ADMIN, INMOBILIARIA, CLIENTE, VISITANTE). */
    private List<String> roles = new ArrayList<String>();

    /** Datos personales asociados 1:1. Puede ser null si aun no se creo. */
    private Perfil perfil;

    public Usuario() {
    }

    /**
     * Indica si el usuario tiene el rol pedido, sin distinguir mayusculas.
     * Es la comprobacion que usan el filtro y las JSP para armar el menu.
     */
    public boolean tieneRol(String rol) {
        if (rol == null) {
            return false;
        }
        for (String propio : roles) {
            if (propio.equalsIgnoreCase(rol.trim())) {
                return true;
            }
        }
        return false;
    }

    /**
     * Rol principal, usado para decidir a que panel se redirige tras el login.
     * Se toma el de mayor privilegio porque un usuario puede tener varios
     * (en los datos de prueba, el usuario 5 es CLIENTE y VISITANTE a la vez).
     */
    public String rolPrincipal() {
        if (tieneRol("ADMIN")) {
            return "ADMIN";
        }
        if (tieneRol("INMOBILIARIA")) {
            return "INMOBILIARIA";
        }
        if (tieneRol("CLIENTE")) {
            return "CLIENTE";
        }
        return "VISITANTE";
    }

    /** Nombre para saludar en el panel; cae al correo si no hay perfil. */
    public String nombreVisible() {
        if (perfil != null && perfil.getNombres() != null && !perfil.getNombres().isEmpty()) {
            return perfil.getNombres();
        }
        return correo;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }

    public List<String> getRoles() {
        return roles;
    }

    public void setRoles(List<String> roles) {
        this.roles = (roles == null) ? new ArrayList<String>() : roles;
    }

    public Perfil getPerfil() {
        return perfil;
    }

    public void setPerfil(Perfil perfil) {
        this.perfil = perfil;
    }
}
