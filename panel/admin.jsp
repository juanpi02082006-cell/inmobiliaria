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

<div class="d-flex flex-wrap justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 mb-1">Panel del administrador</h1>
        <p class="text-secondary mb-0">
            Bienvenido, <strong><%= usuarioSesion.nombreVisible() %></strong>.
            Acceso total al sistema.
        </p>
    </div>
    <span class="badge text-bg-danger fs-6"><i class="bi bi-shield-lock me-1"></i>ADMIN</span>
</div>

<div class="row g-3 mb-4">
    <div class="col-6 col-lg-3">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body">
                <div class="text-secondary small text-uppercase">Usuarios</div>
                <div class="display-6 fw-bold"><%= totalUsuarios %></div>
            </div>
        </div>
    </div>
    <div class="col-6 col-lg-3">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body">
                <div class="text-secondary small text-uppercase">Propiedades activas</div>
                <div class="display-6 fw-bold"><%= totalPropiedades %></div>
            </div>
        </div>
    </div>
    <div class="col-6 col-lg-3">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body">
                <div class="text-secondary small text-uppercase">Citas</div>
                <div class="display-6 fw-bold"><%= totalCitas %></div>
            </div>
        </div>
    </div>
    <div class="col-6 col-lg-3">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body">
                <div class="text-secondary small text-uppercase">Solicitudes</div>
                <div class="display-6 fw-bold"><%= totalSolicitudes %></div>
            </div>
        </div>
    </div>
</div>

<div class="row g-3">
    <div class="col-lg-5">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white fw-semibold">
                Usuarios por rol
                <span class="text-secondary fw-normal small">(relacion N:M usuario_rol)</span>
            </div>
            <ul class="list-group list-group-flush">
<%  for (Map.Entry<String, Integer> fila : porRol.entrySet()) { %>
                <li class="list-group-item d-flex justify-content-between align-items-center">
                    <%= fila.getKey() %>
                    <span class="badge text-bg-secondary rounded-pill"><%= fila.getValue() %></span>
                </li>
<%  } %>
            </ul>
        </div>
    </div>

    <div class="col-lg-7">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white fw-semibold">Modulos</div>
            <div class="card-body">
                <div class="d-grid gap-2 d-md-flex">
                    <a class="btn btn-primary" href="<%= ctx %>/panel/admin/usuarios">
                        <i class="bi bi-people me-1"></i>Usuarios y roles
                    </a>
                    <a class="btn btn-outline-primary" href="<%= ctx %>/panel/admin/catalogos">
                        <i class="bi bi-tags me-1"></i>Catalogos
                    </a>
                    <a class="btn btn-outline-primary" href="<%= ctx %>/panel/perfil">
                        <i class="bi bi-person-gear me-1"></i>Mi perfil
                    </a>
                    <button class="btn btn-outline-secondary" disabled>
                        Auditoria <span class="badge text-bg-light">Sprint 3</span>
                    </button>
                </div>
                <p class="text-secondary small mb-0 mt-3">
                    Desde usuarios y roles asigna permisos (relacion N:M) y activa
                    o inactiva cuentas.
                </p>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
