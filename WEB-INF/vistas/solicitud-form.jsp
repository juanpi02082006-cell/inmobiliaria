<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.modelo.Propiedad" %>
<%--
    Radicar una solicitud de compra o arriendo (HU-10).

    Vive bajo WEB-INF: solo se llega por forward desde SolicitudClienteServlet,
    que ya comprobo el rol CLIENTE y que el inmueble existe y sigue en
    negociacion.
--%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    Propiedad p = (Propiedad) request.getAttribute("propiedad");
    String tipoSolicitud = String.valueOf(request.getAttribute("tipoSolicitud"));
    String errorForm = (request.getAttribute("error") == null)
            ? "" : request.getAttribute("error").toString();
%>

<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
    <div>
        <h1 class="h3 mb-1">Radicar solicitud de <%= "COMPRA".equals(tipoSolicitud) ? "compra" : "arriendo" %></h1>
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
            <div class="card-header bg-white fw-semibold">Datos de la solicitud</div>
            <div class="card-body">
                <form method="post" action="<%= ctx %>/panel/cliente/solicitudes" novalidate>
                    <input type="hidden" name="accion" value="radicar">
                    <input type="hidden" name="idPropiedad" value="<%= p.getId() %>">

                    <div class="mb-3">
                        <label class="form-label small fw-semibold">Tipo de solicitud</label>
                        <input class="form-control" type="text" value="<%= tipoSolicitud %>" disabled>
                        <div class="form-text">
                            Lo determina la operacion del inmueble: no se puede cambiar.
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-semibold" for="oferta">
                            <%= "COMPRA".equals(tipoSolicitud) ? "Oferta (COP)" : "Canon ofrecido (COP)" %>
                            <span class="text-secondary fw-normal">(opcional)</span>
                        </label>
                        <div class="input-group">
                            <span class="input-group-text">$</span>
                            <input class="form-control" id="oferta" name="oferta" type="number"
                                   min="1" step="1000" placeholder="<%= p.getPrecio().toPlainString() %>">
                        </div>
                        <div class="form-text">Dejelo vacio para negociar directamente con la agencia.</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-semibold" for="comentario">
                            Comentario (opcional)
                        </label>
                        <textarea class="form-control" id="comentario" name="comentario"
                                  maxlength="255" rows="3"
                                  placeholder="Condiciones, plazos u otra informacion para la agencia."></textarea>
                    </div>

                    <div class="d-flex gap-2">
                        <button class="btn btn-primary px-4" type="submit">
                            <i class="bi bi-send-check me-1"></i>Radicar solicitud
                        </button>
                        <a class="btn btn-outline-secondary" href="<%= ctx %>/panel/cliente/solicitudes">Cancelar</a>
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
                    Podra radicar los documentos (cedula, certificados, etc.) apenas
                    quede creada la solicitud. Publicado por <%= Html.esc(p.getInmobiliaria()) %>.
                </p>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
