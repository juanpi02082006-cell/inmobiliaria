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

<div class="d-flex flex-wrap align-items-center gap-3 mb-4">
    <span class="sr-marca-icono-sm"><i class="bi bi-person-check"></i></span>
    <div class="flex-grow-1">
        <h1 class="h3 mb-1">Mi cuenta</h1>
        <p class="text-secondary mb-0">Hola, <strong><%= Html.esc(usuarioSesion.nombreVisible()) %></strong>.</p>
    </div>
    <span class="sr-badge-rol rol-cliente">
        <span class="sr-punto"></span>CLIENTE
    </span>
</div>

<%-- ============ Cifras: tambien son el acceso rapido a cada seccion ============ --%>
<div class="row g-3 mb-4 sr-client-stats">
    <div class="col-sm-4">
        <a class="sr-stat" href="<%= ctx %>/panel/cliente/citas">
            <div class="card border-0 shadow-sm h-100 sr-client-stat-card">
                <div class="card-body">
                    <div class="sr-client-stat-content">
                        <div class="text-secondary small text-uppercase">Citas</div>
                        <div class="h3 fw-bold mb-0 mt-2"><%= misCitas %></div>
                    </div>
                    <span class="sr-stat-icono sr-icono-ambar"><i class="bi bi-calendar-check"></i></span>
                </div>
            </div>
        </a>
    </div>
    <div class="col-sm-4">
        <a class="sr-stat" href="<%= ctx %>/panel/cliente/favoritos">
            <div class="card border-0 shadow-sm h-100 sr-client-stat-card">
                <div class="card-body">
                    <div class="sr-client-stat-content">
                        <div class="text-secondary small text-uppercase">Favoritos</div>
                        <div class="h3 fw-bold mb-0 mt-2"><%= misFavoritos %></div>
                    </div>
                    <span class="sr-stat-icono sr-icono-rosa"><i class="bi bi-heart"></i></span>
                </div>
            </div>
        </a>
    </div>
    <div class="col-sm-4">
        <a class="sr-stat" href="<%= ctx %>/panel/cliente/solicitudes">
            <div class="card border-0 shadow-sm h-100 sr-client-stat-card">
                <div class="card-body">
                    <div class="sr-client-stat-content">
                        <div class="text-secondary small text-uppercase">Solicitudes</div>
                        <div class="h3 fw-bold mb-0 mt-2"><%= misSolicitudes %></div>
                    </div>
                    <span class="sr-stat-icono sr-icono-azul"><i class="bi bi-send-check"></i></span>
                </div>
            </div>
        </a>
    </div>
</div>

<div class="row g-3">
    <%-- ============ Mis datos ============ --%>
    <div class="col-lg-8">
        <div class="card border-0 shadow-sm h-100 sr-client-profile-card">
            <div class="card-body">
                <div class="d-flex align-items-center gap-2 mb-3">
                    <span class="sr-stat-icono sr-icono-azul"><i class="bi bi-person"></i></span>
                    <div class="fw-semibold">Mis datos</div>
                </div>
<%  if (miPerfil == null) { %>
                <p class="text-secondary mb-0">Aun no ha completado su perfil.</p>
<%  } else { %>
                <dl class="row mb-0">
                    <dt class="col-sm-3 text-secondary fw-normal">Nombre</dt>
                    <dd class="col-sm-9 fw-semibold"><%= Html.esc(miPerfil.nombreCompleto()) %></dd>

                    <dt class="col-sm-3 text-secondary fw-normal">Documento</dt>
                    <dd class="col-sm-9 fw-semibold"><%= Html.esc(miPerfil.getDocumento()) %></dd>

                    <dt class="col-sm-3 text-secondary fw-normal">Correo</dt>
                    <dd class="col-sm-9 fw-semibold"><%= Html.esc(usuarioSesion.getCorreo()) %></dd>

                    <dt class="col-sm-3 text-secondary fw-normal">Telefono</dt>
                    <dd class="col-sm-9 fw-semibold"><%= Html.esc((miPerfil.getTelefono() == null) ? "-" : miPerfil.getTelefono()) %></dd>

                    <dt class="col-sm-3 text-secondary fw-normal">Direccion</dt>
                    <dd class="col-sm-9 fw-semibold"><%= Html.esc((miPerfil.getDireccion() == null) ? "-" : miPerfil.getDireccion()) %></dd>
                </dl>
<%  } %>
                <hr>
                <a class="btn btn-primary" href="<%= ctx %>/panel/perfil">
                    <i class="bi bi-person-gear me-1"></i>Editar mi perfil
                </a>
            </div>
        </div>
    </div>

    <%-- ============ Buscar propiedades ============ --%>
    <div class="col-lg-4">
        <a class="sr-modulo" href="<%= ctx %>/catalogo">
            <div class="sr-modulo-tarjeta card border-0 shadow-sm h-100 sr-client-search-card">
                <div class="card-body d-flex flex-column">
                    <div class="d-flex justify-content-between align-items-start mb-3">
                        <span class="sr-modulo-icono sr-icono-verde"><i class="bi bi-search"></i></span>
                        <i class="bi bi-chevron-right sr-modulo-flecha"></i>
                    </div>
                    <div class="fw-semibold mb-1">Buscar propiedades</div>
                    <p class="text-secondary small mb-0">
                        Explore el catalogo y filtre por tipo, ciudad y precio.
                    </p>
                </div>
            </div>
        </a>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
