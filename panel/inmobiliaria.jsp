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
    int misPropiedades  = resumenAgente.propiedadesDelAgente(usuarioSesion.getId());
    int citasPendientes = resumenAgente.citasPendientesDelAgente(usuarioSesion.getId());
    String agencia      = resumenAgente.nombreAgencia(usuarioSesion.getId());
%>

<div class="d-flex flex-wrap justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 mb-1">Panel de la inmobiliaria</h1>
        <p class="text-secondary mb-0">
            <%= (agencia == null) ? "Sin agencia asociada" : agencia %> &middot;
            agente <strong><%= usuarioSesion.nombreVisible() %></strong>
        </p>
    </div>
    <span class="badge text-bg-primary fs-6"><i class="bi bi-house-gear me-1"></i>INMOBILIARIA</span>
</div>

<div class="row g-3 mb-4">
    <div class="col-sm-6">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body">
                <div class="text-secondary small text-uppercase">Mis propiedades activas</div>
                <div class="display-6 fw-bold"><%= misPropiedades %></div>
                <div class="text-secondary small">Relacion 1:N inmobiliaria &rarr; propiedad</div>
            </div>
        </div>
    </div>
    <div class="col-sm-6">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body">
                <div class="text-secondary small text-uppercase">Citas pendientes</div>
                <div class="display-6 fw-bold"><%= citasPendientes %></div>
                <div class="text-secondary small">Visitas por confirmar</div>
            </div>
        </div>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-header bg-white fw-semibold">Modulos</div>
    <div class="card-body">
        <p class="text-secondary small">
            La publicacion y edicion de propiedades llega en el Sprint 2;
            la atencion de citas y solicitudes, en el Sprint 3.
        </p>
        <div class="d-grid gap-2 d-md-flex">
            <button class="btn btn-outline-secondary btn-sm" disabled>
                Publicar propiedad <span class="badge text-bg-light">Sprint 2</span>
            </button>
            <button class="btn btn-outline-secondary btn-sm" disabled>
                Galeria y caracteristicas <span class="badge text-bg-light">Sprint 2</span>
            </button>
            <button class="btn btn-outline-secondary btn-sm" disabled>
                Citas y solicitudes <span class="badge text-bg-light">Sprint 3</span>
            </button>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
