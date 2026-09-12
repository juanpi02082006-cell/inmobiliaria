<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.modelo.Propiedad" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%--
    Agendar una visita a un inmueble (HU-09).

    Vive bajo WEB-INF: solo se llega por forward desde CitaClienteServlet,
    que ya comprobo el rol CLIENTE y que el inmueble existe y es visitable.
--%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    Propiedad p = (Propiedad) request.getAttribute("propiedad");
    String errorForm = (request.getAttribute("error") == null)
            ? "" : request.getAttribute("error").toString();

    // El navegador no deja elegir una fecha pasada si le fijamos el minimo.
    SimpleDateFormat minLocal = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
    String minimo = minLocal.format(new Date(System.currentTimeMillis() + 60000L));
%>

<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
    <div>
        <h1 class="h3 mb-1">Agendar visita</h1>
        <p class="text-secondary mb-0">
            <%= Html.esc(p.getTitulo()) %> &middot; <code><%= Html.esc(p.getMatricula()) %></code>
        </p>
    </div>
    <a class="btn btn-outline-secondary" href="<%= ctx %>/catalogo?id=<%= p.getId() %>">
        <i class="bi bi-arrow-left me-1"></i>Volver al inmueble
    </a>
</div>

<%  if (!errorForm.isEmpty()) { %>
<div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorForm %></div>
<%  } %>

<div class="row g-4">
    <div class="col-lg-7">
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-white fw-semibold">Datos de la visita</div>
            <div class="card-body">
                <form method="post" action="<%= ctx %>/panel/cliente/citas" novalidate>
                    <input type="hidden" name="accion" value="agendar">
                    <input type="hidden" name="idPropiedad" value="<%= p.getId() %>">

                    <div class="mb-3">
                        <label class="form-label small fw-semibold" for="fechaHora">
                            Fecha y hora de la visita *
                        </label>
                        <input class="form-control" id="fechaHora" name="fechaHora"
                               type="datetime-local" min="<%= minimo %>" required>
                        <div class="form-text">
                            No se puede agendar dos visitas al mismo inmueble en el mismo horario.
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-semibold" for="observaciones">
                            Observaciones (opcional)
                        </label>
                        <textarea class="form-control" id="observaciones" name="observaciones"
                                  maxlength="255" rows="3"
                                  placeholder="Por ejemplo, un horario alternativo o algo que quiera preguntar."></textarea>
                    </div>

                    <div class="d-flex gap-2">
                        <button class="btn btn-primary px-4" type="submit">
                            <i class="bi bi-calendar-check me-1"></i>Solicitar visita
                        </button>
                        <a class="btn btn-outline-secondary" href="<%= ctx %>/panel/cliente/citas">Cancelar</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="col-lg-5">
        <div class="card border-0 shadow-sm">
            <img class="card-img-top" src="<%= ctx %>/<%= p.getImagen() %>" alt=""
                 style="height:180px;object-fit:cover">
            <div class="card-body">
                <p class="texto-sr text-uppercase small fw-semibold mb-1"><%= Html.esc(p.getTipo()) %></p>
                <h2 class="h6 fw-bold mb-1"><%= Html.esc(p.getTitulo()) %></h2>
                <p class="text-secondary small mb-2">
                    <i class="bi bi-geo-alt me-1"></i><%= Html.esc(p.getCiudad()) %> &middot;
                    <%= Html.esc(p.getDireccion()) %>
                </p>
                <p class="text-secondary small mb-0">
                    Publicado por <%= Html.esc(p.getInmobiliaria()) %>. Recibira la confirmacion
                    de la agencia una vez revise la solicitud.
                </p>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
