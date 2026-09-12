package com.inmobiliaria.modelo;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Una fila del reporte de propiedades por ciudad (HU-12): cuantas hay y como
 * se comporta el precio en esa ciudad. Cada campo, salvo el nombre de la
 * ciudad, sale de una funcion de agregacion distinta (COUNT, AVG, MIN, MAX)
 * sobre el mismo GROUP BY.
 */
public class ResumenCiudad implements Serializable {

    private static final long serialVersionUID = 1L;

    private String ciudad;
    private int total;
    private BigDecimal precioPromedio;
    private BigDecimal precioMinimo;
    private BigDecimal precioMaximo;

    public ResumenCiudad() {
    }

    public String getCiudad() {
        return ciudad;
    }

    public void setCiudad(String ciudad) {
        this.ciudad = ciudad;
    }

    public int getTotal() {
        return total;
    }

    public void setTotal(int total) {
        this.total = total;
    }

    public BigDecimal getPrecioPromedio() {
        return precioPromedio;
    }

    public void setPrecioPromedio(BigDecimal precioPromedio) {
        this.precioPromedio = precioPromedio;
    }

    public BigDecimal getPrecioMinimo() {
        return precioMinimo;
    }

    public void setPrecioMinimo(BigDecimal precioMinimo) {
        this.precioMinimo = precioMinimo;
    }

    public BigDecimal getPrecioMaximo() {
        return precioMaximo;
    }

    public void setPrecioMaximo(BigDecimal precioMaximo) {
        this.precioMaximo = precioMaximo;
    }
}
