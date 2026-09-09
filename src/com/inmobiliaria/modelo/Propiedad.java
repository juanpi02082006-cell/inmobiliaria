package com.inmobiliaria.modelo;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * Inmueble publicado (tabla propiedad).
 *
 * Trae ya resueltos, mediante JOIN, el nombre de la ciudad, el tipo y la
 * inmobiliaria, para que las vistas no tengan que hacer consultas sueltas.
 *
 * El CRUD completo llega en el Sprint 2; por ahora la clase cubre lo que
 * necesita el catalogo publico.
 */
public class Propiedad implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String matricula;
    private String titulo;
    private String descripcion;
    private String direccion;
    private BigDecimal precio;
    private String operacion;
    private BigDecimal areaM2;
    private int habitaciones;
    private int banos;
    private int parqueaderos;
    private String estado;
    private boolean activo = true;

    /** Llaves foraneas. Son las que se escriben al crear o editar. */
    private int idInmobiliaria;
    private int idCiudad;
    private int idTipo;

    /** Datos traidos por JOIN desde ciudad, tipo_propiedad e inmobiliaria. */
    private String ciudad;
    private String tipo;
    private String inmobiliaria;

    /** Imagen de portada (relacion 1:N con imagen_propiedad). */
    private String imagen;

    /** Galeria completa. Solo se carga en la ficha de detalle. */
    private List<Imagen> imagenes = new ArrayList<Imagen>();

    /** Caracteristicas asignadas (relacion N:M). Solo en la ficha de detalle. */
    private List<Caracteristica> caracteristicas = new ArrayList<Caracteristica>();

    public Propiedad() {
    }

    /** Cuantas fotos tiene la galeria. */
    public int totalImagenes() {
        return imagenes.size();
    }

    /** ¿Tiene asignada la caracteristica con ese id? Lo usa el formulario. */
    public boolean tieneCaracteristica(int idCaracteristica) {
        for (Caracteristica c : caracteristicas) {
            if (c.getId() == idCaracteristica) {
                return true;
            }
        }
        return false;
    }

    /** Cantidad asignada de una caracteristica, o 0 si no la tiene. */
    public int cantidadDe(int idCaracteristica) {
        for (Caracteristica c : caracteristicas) {
            if (c.getId() == idCaracteristica) {
                return c.getCantidad();
            }
        }
        return 0;
    }

    /**
     * Codigo visible del inmueble. Se usa la matricula inmobiliaria, que es
     * UNIQUE en el modelo y por tanto identifica el inmueble sin ambiguedad.
     */
    public String getCodigo() {
        return matricula;
    }

    /** Portada, con una imagen por defecto si el inmueble aun no tiene fotos. */
    public String getImagen() {
        return (imagen == null || imagen.isEmpty()) ? "img/casa-barrio.jpg" : imagen;
    }

    public void setImagen(String imagen) {
        this.imagen = imagen;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getMatricula() {
        return matricula;
    }

    public void setMatricula(String matricula) {
        this.matricula = matricula;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public BigDecimal getPrecio() {
        return precio;
    }

    public void setPrecio(BigDecimal precio) {
        this.precio = precio;
    }

    public String getOperacion() {
        return operacion;
    }

    public void setOperacion(String operacion) {
        this.operacion = operacion;
    }

    public BigDecimal getAreaM2() {
        return areaM2;
    }

    public void setAreaM2(BigDecimal areaM2) {
        this.areaM2 = areaM2;
    }

    public int getHabitaciones() {
        return habitaciones;
    }

    public void setHabitaciones(int habitaciones) {
        this.habitaciones = habitaciones;
    }

    public int getBanos() {
        return banos;
    }

    public void setBanos(int banos) {
        this.banos = banos;
    }

    public int getParqueaderos() {
        return parqueaderos;
    }

    public void setParqueaderos(int parqueaderos) {
        this.parqueaderos = parqueaderos;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getCiudad() {
        return ciudad;
    }

    public void setCiudad(String ciudad) {
        this.ciudad = ciudad;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getInmobiliaria() {
        return inmobiliaria;
    }

    public void setInmobiliaria(String inmobiliaria) {
        this.inmobiliaria = inmobiliaria;
    }

    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }

    public int getIdInmobiliaria() {
        return idInmobiliaria;
    }

    public void setIdInmobiliaria(int idInmobiliaria) {
        this.idInmobiliaria = idInmobiliaria;
    }

    public int getIdCiudad() {
        return idCiudad;
    }

    public void setIdCiudad(int idCiudad) {
        this.idCiudad = idCiudad;
    }

    public int getIdTipo() {
        return idTipo;
    }

    public void setIdTipo(int idTipo) {
        this.idTipo = idTipo;
    }

    public List<Imagen> getImagenes() {
        return imagenes;
    }

    public void setImagenes(List<Imagen> imagenes) {
        this.imagenes = (imagenes == null) ? new ArrayList<Imagen>() : imagenes;
    }

    public List<Caracteristica> getCaracteristicas() {
        return caracteristicas;
    }

    public void setCaracteristicas(List<Caracteristica> caracteristicas) {
        this.caracteristicas = (caracteristicas == null)
                ? new ArrayList<Caracteristica>() : caracteristicas;
    }
}
