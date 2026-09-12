<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.dao.ResumenDAO" %>
<%@ page import="java.util.Map" %>
<%--
    Panel del ADMINISTRADOR.

    Solo llega aqui quien tiene el rol ADMIN: AutenticacionFilter bloquea la
    ruta /panel/admin antes de que se ejecute una sola linea de esta pagina.
--%>
<%
    request.setAttribute("titulo", "Panel del administrador");

    ResumenDAO resumen = new ResumenDAO();
    int totalUsuarios    = resumen.totalUsuarios();
    int totalPropiedades = resumen.totalPropiedades();
    int totalCitas       = resumen.totalCitas();
    int totalSolicitudes = resumen.totalSolicitudes();
    Map<String, Integer> porRol = resumen.usuariosPorRol();
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<div class="d-flex flex-wrap align-items-center gap-3 mb-4">
    <span class="sr-marca-icono-sm"><i class="bi bi-shield-lock"></i></span>
    <div class="flex-grow-1">
        <h1 class="h3 mb-1">Panel del administrador</h1>
        <p class="text-secondary mb-0">
            Bienvenido, <strong><%= Html.esc(usuarioSesion.nombreVisible()) %></strong>.
            Acceso total al sistema.
        </p>
    </div>
    <span class="badge text-bg-danger fs-6"><i class="bi bi-shield-lock me-1"></i>ADMIN</span>
</div>

<%-- ============ Cifras ============ --%>
<div class="row g-3 mb-4">
    <div class="col-6 col-lg-3">
        <a class="sr-stat" href="<%= ctx %>/panel/admin/usuarios">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body d-flex align-items-center gap-3">
                    <span class="sr-stat-icono"><i class="bi bi-people"></i></span>
                    <div>
                        <div class="text-secondary small text-uppercase">Usuarios</div>
                        <div class="h3 fw-bold mb-0"><%= totalUsuarios %></div>
                    </div>
                </div>
            </div>
        </a>
    </div>
    <div class="col-6 col-lg-3">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body d-flex align-items-center gap-3">
                <span class="sr-stat-icono"><i class="bi bi-houses"></i></span>
                <div>
                    <div class="text-secondary small text-uppercase">Propiedades activas</div>
                    <div class="h3 fw-bold mb-0"><%= totalPropiedades %></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-6 col-lg-3">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body d-flex align-items-center gap-3">
                <span class="sr-stat-icono"><i class="bi bi-calendar-check"></i></span>
                <div>
                    <div class="text-secondary small text-uppercase">Citas</div>
                    <div class="h3 fw-bold mb-0"><%= totalCitas %></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-6 col-lg-3">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body d-flex align-items-center gap-3">
                <span class="sr-stat-icono"><i class="bi bi-file-earmark-check"></i></span>
                <div>
                    <div class="text-secondary small text-uppercase">Solicitudes</div>
                    <div class="h3 fw-bold mb-0"><%= totalSolicitudes %></div>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- ============ Modulos ============ --%>
<div class="row g-3 mb-4">
    <div class="col-sm-6 col-lg-4">
        <a class="sr-modulo" href="<%= ctx %>/panel/admin/usuarios">
            <div class="sr-modulo-tarjeta card border-0 shadow-sm h-100">
                <div class="card-body d-flex flex-column">
                    <span class="sr-modulo-icono mb-3"><i class="bi bi-people"></i></span>
                    <div class="fw-semibold mb-1">Usuarios y roles</div>
                    <p class="text-secondary small mb-0">
                        Asignar permisos (relacion N:M) y activar o inactivar cuentas.
                    </p>
                </div>
            </div>
        </a>
    </div>
    <div class="col-sm-6 col-lg-4">
        <a class="sr-modulo" href="<%= ctx %>/panel/admin/catalogos">
            <div class="sr-modulo-tarjeta card border-0 shadow-sm h-100">
                <div class="card-body d-flex flex-column">
                    <span class="sr-modulo-icono mb-3"><i class="bi bi-tags"></i></span>
                    <div class="fw-semibold mb-1">Catalogos</div>
                    <p class="text-secondary small mb-0">
                        Parametrizar ciudades y caracteristicas del sistema.
                    </p>
                </div>
            </div>
        </a>
    </div>
    <div class="col-sm-6 col-lg-4">
        <a class="sr-modulo" href="<%= ctx %>/panel/admin/reportes">
            <div class="sr-modulo-tarjeta card border-0 shadow-sm h-100">
                <div class="card-body d-flex flex-column">
                    <span class="sr-modulo-icono mb-3"><i class="bi bi-bar-chart"></i></span>
                    <div class="fw-semibold mb-1">Reportes</div>
                    <p class="text-secondary small mb-0">
                        Propiedades por ciudad y por estado, con agregaciones.
                    </p>
                </div>
            </div>
        </a>
    </div>
    <div class="col-sm-6 col-lg-4">
        <a class="sr-modulo" href="<%= ctx %>/panel/admin/auditoria">
            <div class="sr-modulo-tarjeta card border-0 shadow-sm h-100">
                <div class="card-body d-flex flex-column">
                    <span class="sr-modulo-icono mb-3"><i class="bi bi-clock-history"></i></span>
                    <div class="fw-semibold mb-1">Auditoria</div>
                    <p class="text-secondary small mb-0">
                        Consultar el registro de accesos y cambios del sistema.
                    </p>
                </div>
            </div>
        </a>
    </div>
    <div class="col-sm-6 col-lg-4">
        <a class="sr-modulo" href="<%= ctx %>/panel/perfil">
            <div class="sr-modulo-tarjeta card border-0 shadow-sm h-100">
                <div class="card-body d-flex flex-column">
                    <span class="sr-modulo-icono mb-3"><i class="bi bi-person-gear"></i></span>
                    <div class="fw-semibold mb-1">Mi perfil</div>
                    <p class="text-secondary small mb-0">
                        Editar sus propios datos personales.
                    </p>
                </div>
            </div>
        </a>
    </div>
</div>

<%-- ============ Usuarios por rol ============ --%>
<div class="card border-0 shadow-sm">
    <div class="card-header bg-white fw-semibold">
        Usuarios por rol
        <span class="text-secondary fw-normal small">(relacion N:M usuario_rol)</span>
    </div>
    <div class="table-responsive">
        <table class="table align-middle mb-0">
            <tbody>
<%  for (Map.Entry<String, Integer> fila : porRol.entrySet()) { %>
                <tr>
                    <td><%= fila.getKey() %></td>
                    <td class="text-end" style="width:1%">
                        <span class="badge text-bg-secondary rounded-pill"><%= fila.getValue() %></span>
                    </td>
                </tr>
<%  } %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
