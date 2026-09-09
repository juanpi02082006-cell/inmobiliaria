package com.inmobiliaria.modelo;

import java.io.Serializable;

/**
 * Una caracteristica del inmueble: piscina, parqueadero, ascensor, gimnasio...
 *
 * Cumple dos papeles segun de donde venga:
 *
 *  - Como fila del catalogo (tabla caracteristica), solo tienen valor el id
 *    y el nombre.
 *  - Como caracteristica ASIGNADA a una propiedad, viene de la tabla puente
 *    propiedad_caracteristica y entonces {@link #getCantidad()} trae el
 *    atributo propio de esa relacion N:M (dos parqueaderos, tres balcones).
 *
 * Ese atributo en la tabla puente es lo que el enunciado pide demostrar:
 * una relacion muchos a muchos que ademas guarda informacion propia.
 */
public class Caracteristica implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String nombre;

    /** Atributo propio de la relacion N:M. Vale 0 si no esta asignada. */
    private int cantidad;

    public Caracteristica() {
    }

    public Caracteristica(int id, String nombre) {
        this.id = id;
        this.nombre = nombre;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public int getCantidad() {
        return cantidad;
    }

    public void setCantidad(int cantidad) {
        this.cantidad = cantidad;
    }
}
