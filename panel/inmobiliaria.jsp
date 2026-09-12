<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.dao.ResumenDAO" %>
<%--
    Panel de la INMOBILIARIA (agente).
    Ruta protegida por AutenticacionFilter: exige el rol INMOBILIARIA.
--%>
<%
    request.setAttribute("titulo", "Panel de la inmobiliaria");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    ResumenDAO resumenAgente = new ResumenDAO();
    int misPropiedades       = resumenAgente.propiedadesDelAgente(usuarioSesion.getId());
    int citasPendientes      = resumenAgente.citasPendientesDelAgente(usuarioSesion.getId());
    int solicitudesPendientes = resumenAgente.solicitudesPendientesDelAgente(usuarioSesion.getId());
    String agencia            = resumenAgente.nombreAgencia(usuarioSesion.getId());
%>

<div class="d-flex flex-wrap justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 mb-1">Panel de la inmobiliaria</h1>
        <p class="text-secondary mb-0">
            <%= Html.esc((agencia == null) ? "Sin agencia asociada" : agencia) %> &middot;
            agente <strong><%= Html.esc(usuarioSesion.nombreVisible()) %></strong>
        </p>
    </div>
    <span class="badge text-bg-primary fs-6"><i class="bi bi-house-gear me-1"></i>INMOBILIARIA</span>
</div>

<div class="row g-3 mb-4">
    <div class="col-sm-4">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body">
                <div class="text-secondary small text-uppercase">Mis propiedades activas</div>
                <div class="display-6 fw-bold"><%= misPropiedades %></div>
                <div class="text-secondary small">Relacion 1:N inmobiliaria &rarr; propiedad</div>
            </div>
        </div>
    </div>
    <div class="col-sm-4">
        <a class="text-decoration-none text-reset" href="<%= ctx %>/panel/inmobiliaria/citas">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body">
                <div class="text-secondary small text-uppercase">Citas pendientes</div>
                <div class="display-6 fw-bold"><%= citasPendientes %></div>
                <div class="text-secondary small">Visitas por confirmar</div>
            </div>
        </div>
        </a>
    </div>
    <div class="col-sm-4">
        <a class="text-decoration-none text-reset" href="<%= ctx %>/panel/inmobiliaria/solicitudes">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body">
                <div class="text-secondary small text-uppercase">Solicitudes por resolver</div>
                <div class="display-6 fw-bold"><%= solicitudesPendientes %></div>
                <div class="text-secondary small">Compra o arriendo</div>
            </div>
        </div>
        </a>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-header bg-white fw-semibold">Modulos</div>
    <div class="card-body">
        <div class="d-grid gap-2 d-md-flex">
            <a class="btn btn-primary" href="<%= ctx %>/panel/inmobiliaria/propiedades">
                <i class="bi bi-houses me-1"></i>Gestionar mis propiedades
            </a>
            <a class="btn btn-outline-primary" href="<%= ctx %>/panel/inmobiliaria/propiedades?accion=nueva">
                <i class="bi bi-plus-lg me-1"></i>Publicar una nueva
            </a>
            <a class="btn btn-outline-primary" href="<%= ctx %>/panel/inmobiliaria/citas">
                <i class="bi bi-calendar-check me-1"></i>Gestionar citas
            </a>
            <a class="btn btn-outline-primary" href="<%= ctx %>/panel/inmobiliaria/solicitudes">
                <i class="bi bi-file-earmark-check me-1"></i>Resolver solicitudes
            </a>
        </div>
        <p class="text-secondary small mb-0 mt-3">
            Desde ahi administra tambien la galeria de imagenes (1:N) y las
            caracteristicas del inmueble (N:M).
        </p>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
