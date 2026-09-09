package com.inmobiliaria.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.inmobiliaria.config.ConexionBD;
import com.inmobiliaria.modelo.Perfil;
import com.inmobiliaria.modelo.Usuario;
import com.inmobiliaria.util.PasswordUtil;

/**
 * Acceso a datos de usuario, perfil y roles.
 *
 * Toda la capa de datos usa PreparedStatement con parametros, nunca
 * concatenacion de cadenas: eso cierra la puerta a la inyeccion SQL.
 * La conexion siempre se pide a {@link ConexionBD}, de modo que la URL no
 * aparece en ninguna parte de esta clase.
 */
public class UsuarioDAO {

    /** Codigo que devuelve MySQL cuando se viola una restriccion UNIQUE. */
    private static final int ERROR_DUPLICADO = 1062;

    /** Intentos fallidos consecutivos antes de bloquear la cuenta. */
    private static final int MAX_INTENTOS = 5;

    /** Minutos que dura el bloqueo temporal. */
    private static final int MINUTOS_BLOQUEO = 15;

    // -------------------------------------------------------------------------
    // Consulta
    // -------------------------------------------------------------------------

    /**
     * Busca un usuario por su correo (la credencial de ingreso, UNIQUE).
     *
     * @return el usuario con sus roles y su perfil cargados, o null si no existe.
     */
    public Usuario buscarPorCorreo(String correo) throws SQLException {
        String sql =
            "SELECT u.id_usuario, u.correo, u.password_hash, u.activo, "
          + "       u.intentos_fallidos, u.bloqueado_hasta "
          + "  FROM usuario u "
          + " WHERE u.correo = ?";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, correo);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                Usuario u = new Usuario();
                u.setId(rs.getInt("id_usuario"));
                u.setCorreo(rs.getString("correo"));
                u.setPasswordHash(rs.getString("password_hash"));
                u.setActivo(rs.getBoolean("activo"));
                u.setRoles(cargarRoles(cn, u.getId()));
                u.setPerfil(cargarPerfil(cn, u.getId()));
                return u;
            }
        }
    }

    /** ¿Ya hay una cuenta con ese correo? Se usa para avisar antes de insertar. */
    public boolean existeCorreo(String correo) throws SQLException {
        String sql = "SELECT 1 FROM usuario WHERE correo = ?";
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, correo);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Roles del usuario. Resuelve la relacion N:M pasando por usuario_rol.
     */
    private List<String> cargarRoles(Connection cn, int idUsuario) throws SQLException {
        String sql =
            "SELECT r.nombre "
          + "  FROM rol r "
          + "  JOIN usuario_rol ur ON ur.id_rol = r.id_rol "
          + " WHERE ur.id_usuario = ?";

        List<String> roles = new ArrayList<String>();
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    roles.add(rs.getString("nombre"));
                }
            }
        }
        return roles;
    }

    /** Perfil asociado 1:1. Devuelve null si el usuario aun no lo completo. */
    private Perfil cargarPerfil(Connection cn, int idUsuario) throws SQLException {
        String sql =
            "SELECT id_perfil, id_usuario, nombres, apellidos, documento, "
          + "       telefono, direccion, foto_url "
          + "  FROM perfil WHERE id_usuario = ?";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                Perfil p = new Perfil();
                p.setId(rs.getInt("id_perfil"));
                p.setIdUsuario(rs.getInt("id_usuario"));
                p.setNombres(rs.getString("nombres"));
                p.setApellidos(rs.getString("apellidos"));
                p.setDocumento(rs.getString("documento"));
                p.setTelefono(rs.getString("telefono"));
                p.setDireccion(rs.getString("direccion"));
                p.setFotoUrl(rs.getString("foto_url"));
                return p;
            }
        }
    }

    // -------------------------------------------------------------------------
    // Autenticacion
    // -------------------------------------------------------------------------

    /**
     * Valida las credenciales contra la base de datos.
     *
     * La contrasena nunca se compara en claro: se recalcula el PBKDF2 con el
     * salt guardado y se comparan los hashes.
     *
     * @return el usuario autenticado, o null si el correo no existe o la clave
     *         no coincide. Se devuelve lo mismo en ambos casos a proposito,
     *         para no revelar si un correo esta registrado.
     */
    public Usuario autenticar(String correo, String passwordEnClaro) throws SQLException {
        Usuario u = buscarPorCorreo(correo);

        if (u == null) {
            return null;
        }

        if (PasswordUtil.verificar(passwordEnClaro, u.getPasswordHash())) {
            reiniciarIntentos(u.getId());
            return u;
        }

        registrarIntentoFallido(u.getId());
        return null;
    }

    /**
     * ¿La cuenta esta bloqueada temporalmente por intentos fallidos?
     * Valor agregado sugerido por el enunciado.
     */
    public boolean estaBloqueado(String correo) throws SQLException {
        String sql =
            "SELECT bloqueado_hasta FROM usuario "
          + " WHERE correo = ? AND bloqueado_hasta IS NOT NULL "
          + "   AND bloqueado_hasta > NOW()";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, correo);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** Suma un intento fallido y bloquea la cuenta al llegar al tope. */
    private void registrarIntentoFallido(int idUsuario) throws SQLException {
        String sql =
            "UPDATE usuario "
          + "   SET intentos_fallidos = intentos_fallidos + 1, "
          + "       bloqueado_hasta = CASE "
          + "            WHEN intentos_fallidos + 1 >= ? "
          + "            THEN DATE_ADD(NOW(), INTERVAL ? MINUTE) "
          + "            ELSE bloqueado_hasta END "
          + " WHERE id_usuario = ?";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, MAX_INTENTOS);
            ps.setInt(2, MINUTOS_BLOQUEO);
            ps.setInt(3, idUsuario);
            ps.executeUpdate();
        }
    }

    /** Login correcto: se limpia el contador y se anota el ultimo acceso. */
    private void reiniciarIntentos(int idUsuario) throws SQLException {
        String sql =
            "UPDATE usuario "
          + "   SET intentos_fallidos = 0, bloqueado_hasta = NULL, ultimo_acceso = ? "
          + " WHERE id_usuario = ?";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
            ps.setInt(2, idUsuario);
            ps.executeUpdate();
        }
    }

    // -------------------------------------------------------------------------
    // Registro
    // -------------------------------------------------------------------------

    /**
     * Crea una cuenta nueva: fila en usuario, fila en perfil (1:1) y fila en
     * usuario_rol (N:M) con el rol CLIENTE.
     *
     * Las tres insercciones van en una sola transaccion. Si cualquiera falla se
     * deshacen todas, de modo que nunca queda un usuario sin perfil ni sin rol.
     *
     * @return el id del usuario creado.
     * @throws DatoDuplicadoException si el correo o el documento ya existen.
     */
    public int registrar(String correo, String passwordEnClaro, Perfil perfil)
            throws SQLException, DatoDuplicadoException {

        String sqlUsuario = "INSERT INTO usuario (correo, password_hash, activo) VALUES (?, ?, 1)";
        String sqlPerfil  = "INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) "
                          + "VALUES (?, ?, ?, ?, ?, ?)";
        String sqlRol     = "INSERT INTO usuario_rol (id_usuario, id_rol) "
                          + "SELECT ?, id_rol FROM rol WHERE nombre = ?";

        Connection cn = null;
        try {
            cn = ConexionBD.obtener();
            cn.setAutoCommit(false);

            int idUsuario;

            // 1) Credenciales. La clave se cifra aqui: en claro no sale del servlet.
            try (PreparedStatement ps = cn.prepareStatement(sqlUsuario, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, correo);
                ps.setString(2, PasswordUtil.cifrar(passwordEnClaro));
                ps.executeUpdate();

                try (ResultSet claves = ps.getGeneratedKeys()) {
                    if (!claves.next()) {
                        throw new SQLException("La base de datos no devolvio el id del usuario creado.");
                    }
                    idUsuario = claves.getInt(1);
                }
            }

            // 2) Datos personales (relacion 1:1).
            try (PreparedStatement ps = cn.prepareStatement(sqlPerfil)) {
                ps.setInt(1, idUsuario);
                ps.setString(2, perfil.getNombres());
                ps.setString(3, perfil.getApellidos());
                ps.setString(4, perfil.getDocumento());
                ps.setString(5, perfil.getTelefono());
                ps.setString(6, perfil.getDireccion());
                ps.executeUpdate();
            }

            // 3) Rol por defecto (relacion N:M). Quien se registra es CLIENTE;
            //    solo el administrador puede otorgar ADMIN o INMOBILIARIA.
            try (PreparedStatement ps = cn.prepareStatement(sqlRol)) {
                ps.setInt(1, idUsuario);
                ps.setString(2, "CLIENTE");
                ps.executeUpdate();
            }

            cn.commit();
            return idUsuario;

        } catch (SQLIntegrityConstraintViolationException e) {
            deshacer(cn);
            throw traducirDuplicado(e);

        } catch (SQLException e) {
            deshacer(cn);
            throw e;

        } finally {
            cerrar(cn);
        }
    }

    /**
     * Convierte el error 1062 de MySQL en un mensaje que el usuario entienda.
     *
     * El texto de MySQL nombra el indice que se violo (uq_usuario_correo,
     * uq_perfil_documento...), asi que se usa eso para saber que campo repitio.
     */
    private DatoDuplicadoException traducirDuplicado(SQLIntegrityConstraintViolationException e) {
        String detalle = (e.getMessage() == null) ? "" : e.getMessage().toLowerCase();

        if (e.getErrorCode() == ERROR_DUPLICADO || detalle.contains("duplicate")) {
            if (detalle.contains("correo")) {
                return new DatoDuplicadoException("correo",
                        "El correo ya se encuentra registrado. Inicie sesion o use otro correo.");
            }
            if (detalle.contains("documento")) {
                return new DatoDuplicadoException("documento",
                        "Ese numero de documento ya esta registrado por otra cuenta.");
            }
        }
        return new DatoDuplicadoException(null,
                "Los datos ingresados ya existen en el sistema. Revise el correo y el documento.");
    }

    // -------------------------------------------------------------------------
    // Perfil (relacion 1:1)
    // -------------------------------------------------------------------------

    /**
     * Actualiza los datos personales del usuario.
     *
     * Si el usuario todavia no tiene perfil se crea; de ahi el INSERT ...
     * ON DUPLICATE KEY UPDATE, que se apoya en el UNIQUE de perfil.id_usuario,
     * el mismo que sostiene la relacion 1:1.
     *
     * @throws DatoDuplicadoException si el documento ya lo tiene otra cuenta.
     */
    public void guardarPerfil(int idUsuario, Perfil perfil)
            throws SQLException, DatoDuplicadoException {

        String sql =
            "INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) "
          + "VALUES (?,?,?,?,?,?) "
          + "ON DUPLICATE KEY UPDATE nombres = VALUES(nombres), apellidos = VALUES(apellidos), "
          + "   documento = VALUES(documento), telefono = VALUES(telefono), "
          + "   direccion = VALUES(direccion)";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, idUsuario);
            ps.setString(2, perfil.getNombres());
            ps.setString(3, perfil.getApellidos());
            ps.setString(4, perfil.getDocumento());
            ps.setString(5, perfil.getTelefono());
            ps.setString(6, perfil.getDireccion());
            ps.executeUpdate();

        } catch (SQLIntegrityConstraintViolationException e) {
            throw traducirDuplicado(e);
        }
    }

    /**
     * Cambia la contrasena comprobando primero la actual.
     *
     * @return false si la contrasena actual no coincide.
     */
    public boolean cambiarPassword(int idUsuario, String actual, String nueva) throws SQLException {
        Usuario u = buscarPorId(idUsuario);
        if (u == null || !PasswordUtil.verificar(actual, u.getPasswordHash())) {
            return false;
        }

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(
                 "UPDATE usuario SET password_hash = ? WHERE id_usuario = ?")) {
            ps.setString(1, PasswordUtil.cifrar(nueva));
            ps.setInt(2, idUsuario);
            ps.executeUpdate();
        }
        return true;
    }

    /** Igual que buscarPorCorreo pero por id. */
    public Usuario buscarPorId(int idUsuario) throws SQLException {
        String sql = "SELECT id_usuario, correo, password_hash, activo FROM usuario WHERE id_usuario = ?";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                Usuario u = new Usuario();
                u.setId(rs.getInt("id_usuario"));
                u.setCorreo(rs.getString("correo"));
                u.setPasswordHash(rs.getString("password_hash"));
                u.setActivo(rs.getBoolean("activo"));
                u.setRoles(cargarRoles(cn, u.getId()));
                u.setPerfil(cargarPerfil(cn, u.getId()));
                return u;
            }
        }
    }

    // -------------------------------------------------------------------------
    // Administracion de usuarios y roles (N:M)
    // -------------------------------------------------------------------------

    /** Todos los usuarios con su perfil y sus roles, para el panel del admin. */
    public List<Usuario> listarTodos() throws SQLException {
        String sql = "SELECT id_usuario, correo, password_hash, activo FROM usuario ORDER BY id_usuario";

        List<Usuario> lista = new ArrayList<Usuario>();
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Usuario u = new Usuario();
                u.setId(rs.getInt("id_usuario"));
                u.setCorreo(rs.getString("correo"));
                u.setActivo(rs.getBoolean("activo"));
                lista.add(u);
            }
        }

        // Los roles y el perfil se cargan en una segunda pasada para no
        // mantener abierto el ResultSet mientras se hacen otras consultas.
        try (Connection cn = ConexionBD.obtener()) {
            for (Usuario u : lista) {
                u.setRoles(cargarRoles(cn, u.getId()));
                u.setPerfil(cargarPerfil(cn, u.getId()));
            }
        }
        return lista;
    }

    /** Catalogo de roles del sistema: id -> nombre. */
    public Map<Integer, String> roles() throws SQLException {
        Map<Integer, String> mapa = new LinkedHashMap<Integer, String>();
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement("SELECT id_rol, nombre FROM rol ORDER BY id_rol");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                mapa.put(Integer.valueOf(rs.getInt("id_rol")), rs.getString("nombre"));
            }
        }
        return mapa;
    }

    /**
     * Reemplaza los roles de un usuario (relacion N:M usuario_rol).
     *
     * Se borran los que tenia y se insertan los nuevos en una sola
     * transaccion, para que nunca quede sin ninguno a medio camino.
     */
    public void asignarRoles(int idUsuario, int[] idsRol) throws SQLException {
        Connection cn = null;
        try {
            cn = ConexionBD.obtener();
            cn.setAutoCommit(false);

            try (PreparedStatement borrar = cn.prepareStatement(
                     "DELETE FROM usuario_rol WHERE id_usuario = ?")) {
                borrar.setInt(1, idUsuario);
                borrar.executeUpdate();
            }

            if (idsRol != null && idsRol.length > 0) {
                try (PreparedStatement ins = cn.prepareStatement(
                         "INSERT INTO usuario_rol (id_usuario, id_rol) VALUES (?,?)")) {
                    for (int idRol : idsRol) {
                        ins.setInt(1, idUsuario);
                        ins.setInt(2, idRol);
                        ins.addBatch();
                    }
                    ins.executeBatch();
                }
            }

            cn.commit();

        } catch (SQLException e) {
            if (cn != null) {
                try { cn.rollback(); } catch (SQLException ignorada) { }
            }
            throw e;
        } finally {
            if (cn != null) {
                try { cn.setAutoCommit(true); cn.close(); } catch (SQLException ignorada) { }
            }
        }
    }

    /** Activa o inactiva una cuenta (baja logica del usuario). */
    public void cambiarEstado(int idUsuario, boolean activo) throws SQLException {
        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(
                 "UPDATE usuario SET activo = ?, intentos_fallidos = 0, bloqueado_hasta = NULL "
               + " WHERE id_usuario = ?")) {
            ps.setBoolean(1, activo);
            ps.setInt(2, idUsuario);
            ps.executeUpdate();
        }
    }

    /** Cuantas cuentas activas tienen el rol indicado. */
    public int cuantosConRol(String rol) throws SQLException {
        String sql = "SELECT COUNT(*) FROM usuario u "
                   + "  JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario "
                   + "  JOIN rol r ON r.id_rol = ur.id_rol "
                   + " WHERE r.nombre = ? AND u.activo = 1";

        try (Connection cn = ConexionBD.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, rol);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    private void deshacer(Connection cn) {
        if (cn == null) {
            return;
        }
        try {
            cn.rollback();
        } catch (SQLException ignorada) {
            // Si el rollback falla, la conexion se cierra igual y la
            // transaccion queda abortada por el motor.
        }
    }

    private void cerrar(Connection cn) {
        if (cn == null) {
            return;
        }
        try {
            cn.setAutoCommit(true);
            cn.close();
        } catch (SQLException ignorada) {
            // Nada util que hacer al cerrar.
        }
    }
}
