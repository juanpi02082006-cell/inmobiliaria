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
    int misPropiedades        = resumenAgente.propiedadesDelAgente(usuarioSesion.getId());
    int citasPendientes       = resumenAgente.citasPendientesDelAgente(usuarioSesion.getId());
    int solicitudesPendientes = resumenAgente.solicitudesPendientesDelAgente(usuarioSesion.getId());
    String agencia            = resumenAgente.nombreAgencia(usuarioSesion.getId());
%>

<div class="d-flex flex-wrap align-items-center gap-3 mb-4">
    <span class="sr-marca-icono-sm"><i class="bi bi-house-gear"></i></span>
    <div class="flex-grow-1">
        <h1 class="h3 mb-1">Panel de la inmobiliaria</h1>
        <p class="text-secondary mb-0">
            <%= Html.esc((agencia == null) ? "Sin agencia asociada" : agencia) %> &middot;
            agente <strong><%= Html.esc(usuarioSesion.nombreVisible()) %></strong>
        </p>
    </div>
    <span class="badge text-bg-primary fs-6"><i class="bi bi-house-gear me-1"></i>INMOBILIARIA</span>
</div>

<%-- ============ Cifras: las pendientes se resaltan cuando hay algo por atender ============ --%>
<div class="row g-3 mb-4">
    <div class="col-sm-4">
        <a class="sr-stat" href="<%= ctx %>/panel/inmobiliaria/propiedades">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body d-flex align-items-center gap-3">
                    <span class="sr-stat-icono"><i class="bi bi-houses"></i></span>
                    <div>
                        <div class="text-secondary small text-uppercase">Propiedades activas</div>
                        <div class="h3 fw-bold mb-0"><%= misPropiedades %></div>
                    </div>
                </div>
            </div>
        </a>
    </div>
    <div class="col-sm-4">
        <a class="sr-stat" href="<%= ctx %>/panel/inmobiliaria/citas">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body d-flex align-items-center gap-3">
                    <span class="sr-stat-icono<%= citasPendientes > 0 ? " sr-stat-alerta" : "" %>">
                        <i class="bi bi-calendar-check"></i>
                    </span>
                    <div>
                        <div class="text-secondary small text-uppercase">Citas pendientes</div>
                        <div class="h3 fw-bold mb-0"><%= citasPendientes %></div>
                    </div>
                </div>
            </div>
        </a>
    </div>
    <div class="col-sm-4">
        <a class="sr-stat" href="<%= ctx %>/panel/inmobiliaria/solicitudes">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body d-flex align-items-center gap-3">
                    <span class="sr-stat-icono<%= solicitudesPendientes > 0 ? " sr-stat-alerta" : "" %>">
                        <i class="bi bi-file-earmark-check"></i>
                    </span>
                    <div>
                        <div class="text-secondary small text-uppercase">Solicitudes por resolver</div>
                        <div class="h3 fw-bold mb-0"><%= solicitudesPendientes %></div>
                    </div>
                </div>
            </div>
        </a>
    </div>
</div>

<%-- ============ Modulos ============ --%>
<div class="row g-3">
    <div class="col-sm-6 col-lg-3">
        <a class="sr-modulo" href="<%= ctx %>/panel/inmobiliaria/propiedades">
            <div class="sr-modulo-tarjeta card border-0 shadow-sm h-100">
                <div class="card-body d-flex flex-column">
                    <span class="sr-modulo-icono mb-3"><i class="bi bi-houses"></i></span>
                    <div class="fw-semibold mb-1">Mis propiedades</div>
                    <p class="text-secondary small mb-0">
                        Fotos y caracteristicas de cada inmueble.
                    </p>
                </div>
            </div>
        </a>
    </div>
    <div class="col-sm-6 col-lg-3">
        <a class="sr-modulo" href="<%= ctx %>/panel/inmobiliaria/propiedades?accion=nueva">
            <div class="sr-modulo-tarjeta card border-0 shadow-sm h-100">
                <div class="card-body d-flex flex-column">
                    <span class="sr-modulo-icono mb-3"><i class="bi bi-plus-lg"></i></span>
                    <div class="fw-semibold mb-1">Publicar propiedad</div>
                    <p class="text-secondary small mb-0">
                        Dar de alta un nuevo inmueble a nombre de su agencia.
                    </p>
                </div>
            </div>
        </a>
    </div>
    <div class="col-sm-6 col-lg-3">
        <a class="sr-modulo" href="<%= ctx %>/panel/inmobiliaria/citas">
            <div class="sr-modulo-tarjeta card border-0 shadow-sm h-100">
                <div class="card-body d-flex flex-column">
                    <span class="sr-modulo-icono mb-3"><i class="bi bi-calendar-check"></i></span>
                    <div class="fw-semibold mb-1">Gestionar citas</div>
                    <p class="text-secondary small mb-0">
                        Confirmar, cancelar o marcar como realizadas las visitas agendadas.
                    </p>
                </div>
            </div>
        </a>
    </div>
    <div class="col-sm-6 col-lg-3">
        <a class="sr-modulo" href="<%= ctx %>/panel/inmobiliaria/solicitudes">
            <div class="sr-modulo-tarjeta card border-0 shadow-sm h-100">
                <div class="card-body d-flex flex-column">
                    <span class="sr-modulo-icono mb-3"><i class="bi bi-file-earmark-check"></i></span>
                    <div class="fw-semibold mb-1">Resolver solicitudes</div>
                    <p class="text-secondary small mb-0">
                        Evaluar documentos y aprobar o rechazar compras y arriendos.
                    </p>
                </div>
            </div>
        </a>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
