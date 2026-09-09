package com.inmobiliaria.modelo;

import java.io.Serializable;

/**
 * Una foto de la galeria de un inmueble (tabla imagen_propiedad).
 *
 * Es el lado "muchos" de la relacion 1:N con propiedad: la llave foranea
 * id_propiedad vive aqui, con ON DELETE CASCADE, porque una foto sin su
 * inmueble no significa nada.
 *
 * Solo una foto por propiedad deberia tener es_portada = 1; de eso se
 * encarga ImagenDAO al marcar la portada.
 */
public class Imagen implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private int idPropiedad;
    private String url;
    private boolean portada;
    private int orden;

    public Imagen() {
    }

    public Imagen(String url, boolean portada, int orden) {
        this.url = url;
        this.portada = portada;
        this.orden = orden;
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

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public boolean isPortada() {
        return portada;
    }

    public void setPortada(boolean portada) {
        this.portada = portada;
    }

    public int getOrden() {
        return orden;
    }

    public void setOrden(int orden) {
        this.orden = orden;
    }
}
