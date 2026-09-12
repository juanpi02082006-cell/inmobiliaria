<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.dao.ResumenDAO" %>
<%@ page import="com.inmobiliaria.modelo.Perfil" %>
<%--
    Panel del CLIENTE.
    Ruta protegida por AutenticacionFilter: exige el rol CLIENTE.
--%>
<%
    request.setAttribute("titulo", "Mi cuenta");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    ResumenDAO resumenCliente = new ResumenDAO();
    int misCitas       = resumenCliente.citasDelCliente(usuarioSesion.getId());
    int misFavoritos   = resumenCliente.favoritosDelCliente(usuarioSesion.getId());
    int misSolicitudes = resumenCliente.solicitudesDelCliente(usuarioSesion.getId());
    Perfil miPerfil    = usuarioSesion.getPerfil();
%>

<div class="d-flex flex-wrap justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 mb-1">Mi cuenta</h1>
        <p class="text-secondary mb-0">Hola, <strong><%= Html.esc(usuarioSesion.nombreVisible()) %></strong>.</p>
    </div>
    <span class="badge text-bg-success fs-6"><i class="bi bi-person-check me-1"></i>CLIENTE</span>
</div>

<div class="row g-3 mb-4">
    <div class="col-4">
        <a class="text-decoration-none text-reset" href="<%= ctx %>/panel/cliente/citas">
        <div class="card border-0 shadow-sm h-100 text-center">
            <div class="card-body">
                <div class="text-secondary small text-uppercase">Citas</div>
                <div class="display-6 fw-bold"><%= misCitas %></div>
            </div>
        </div>
        </a>
    </div>
    <div class="col-4">
        <a class="text-decoration-none text-reset" href="<%= ctx %>/panel/cliente/favoritos">
        <div class="card border-0 shadow-sm h-100 text-center">
            <div class="card-body">
                <div class="text-secondary small text-uppercase">Favoritos</div>
                <div class="display-6 fw-bold"><%= misFavoritos %></div>
            </div>
        </div>
        </a>
    </div>
    <div class="col-4">
        <div class="card border-0 shadow-sm h-100 text-center">
            <div class="card-body">
                <div class="text-secondary small text-uppercase">Solicitudes</div>
                <div class="display-6 fw-bold"><%= misSolicitudes %></div>
            </div>
        </div>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-header bg-white fw-semibold">
        Mis datos
        <span class="text-secondary fw-normal small">(relacion 1:1 usuario &harr; perfil)</span>
    </div>
    <div class="card-body">
<%  if (miPerfil == null) { %>
        <p class="text-secondary mb-0">Aun no ha completado su perfil.</p>
<%  } else { %>
        <dl class="row mb-0">
            <dt class="col-sm-3">Nombre</dt>
            <dd class="col-sm-9"><%= Html.esc(miPerfil.nombreCompleto()) %></dd>

            <dt class="col-sm-3">Documento</dt>
            <dd class="col-sm-9"><%= Html.esc(miPerfil.getDocumento()) %></dd>

            <dt class="col-sm-3">Correo</dt>
            <dd class="col-sm-9"><%= Html.esc(usuarioSesion.getCorreo()) %></dd>

            <dt class="col-sm-3">Telefono</dt>
            <dd class="col-sm-9"><%= Html.esc((miPerfil.getTelefono() == null) ? "-" : miPerfil.getTelefono()) %></dd>

            <dt class="col-sm-3">Direccion</dt>
            <dd class="col-sm-9"><%= Html.esc((miPerfil.getDireccion() == null) ? "-" : miPerfil.getDireccion()) %></dd>
        </dl>
<%  } %>
        <hr>
        <div class="d-grid gap-2 d-md-flex">
            <a class="btn btn-primary" href="<%= ctx %>/panel/perfil">
                <i class="bi bi-person-gear me-1"></i>Editar mi perfil
            </a>
            <a class="btn btn-outline-primary" href="<%= ctx %>/catalogo">
                <i class="bi bi-search me-1"></i>Buscar propiedades
            </a>
            <a class="btn btn-outline-primary" href="<%= ctx %>/panel/cliente/citas">
                <i class="bi bi-calendar-check me-1"></i>Mis citas
            </a>
            <a class="btn btn-outline-primary" href="<%= ctx %>/panel/cliente/favoritos">
                <i class="bi bi-heart me-1"></i>Mis favoritos
            </a>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
