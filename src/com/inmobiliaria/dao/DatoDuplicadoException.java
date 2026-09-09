package com.inmobiliaria.dao;

/**
 * Se lanza cuando una insercion choca contra una restriccion UNIQUE.
 *
 * El enunciado exige que la aplicacion capture ese error y muestre un mensaje
 * claro ("el correo ya se encuentra registrado") en lugar de escupir una
 * excepcion de Java al usuario. Esta clase es la traduccion: el DAO atrapa el
 * SQLIntegrityConstraintViolationException de MySQL (codigo 1062), averigua
 * que indice se violo y lanza esto con un texto ya redactado en castellano.
 */
public class DatoDuplicadoException extends Exception {

    private static final long serialVersionUID = 1L;

    /** Campo del formulario al que corresponde el dato repetido. */
    private final String campo;

    public DatoDuplicadoException(String campo, String mensaje) {
        super(mensaje);
        this.campo = campo;
    }

    /** Nombre del campo (por ejemplo "correo" o "documento"). */
    public String getCampo() {
        return campo;
    }
}
