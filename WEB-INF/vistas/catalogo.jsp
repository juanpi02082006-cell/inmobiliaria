<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.modelo.Propiedad" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%--
    Catalogo publico de propiedades.

    La vista ya no consulta la base de datos: CatalogoServlet le deja todo
    listo en la peticion. Eso es lo que pide el enunciado con la separacion
    en capas del patron MVC.
--%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    List<Propiedad> propiedades = (List<Propiedad>) request.getAttribute("propiedades");
    List<String> ciudades = (List<String>) request.getAttribute("ciudades");
    List<String> tipos = (List<String>) request.getAttribute("tipos");

    String fTipo = String.valueOf(request.getAttribute("fTipo") == null ? "" : request.getAttribute("fTipo"));
    String fCiudad = String.valueOf(request.getAttribute("fCiudad") == null ? "" : request.getAttribute("fCiudad"));
    String fMin = String.valueOf(request.getAttribute("fMin") == null ? "" : request.getAttribute("fMin"));
    String fMax = String.valueOf(request.getAttribute("fMax") == null ? "" : request.getAttribute("fMax"));
    String errorCat = (request.getAttribute("error") == null) ? "" : request.getAttribute("error").toString();

    boolean hayFiltros = !fTipo.isEmpty() || !fCiudad.isEmpty() || !fMin.isEmpty() || !fMax.isEmpty();

    NumberFormat pesos = NumberFormat.getCurrencyInstance(new Locale("es", "CO"));
    pesos.setMaximumFractionDigits(0);
%>

<div class="d-flex flex-wrap justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 mb-1">Propiedades</h1>
        <p class="text-secondary mb-0"><%= propiedades.size() %> inmueble(s) encontrado(s)</p>
    </div>
</div>

<%  if (!errorCat.isEmpty()) { %>
<div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorCat %></div>
<%  } %>

<form class="card border-0 shadow-sm mb-4" action="<%= ctx %>/catalogo" method="get">
    <div class="card-body">
        <div class="row g-2 align-items-end">
            <div class="col-6 col-lg-3">
                <label class="form-label small fw-semibold" for="tipo">Tipo</label>
                <select class="form-select" id="tipo" name="tipo">
                    <option value="">Todos</option>
<%  for (String t : tipos) { %>
                    <option value="<%= Html.esc(t) %>" <%= t.equals(fTipo) ? "selected" : "" %>><%= Html.esc(t) %></option>
<%  } %>
                </select>
            </div>

            <div class="col-6 col-lg-3">
                <label class="form-label small fw-semibold" for="ciudad">Ciudad</label>
                <select class="form-select" id="ciudad" name="ciudad">
                    <option value="">Todas</option>
<%  for (String c : ciudades) { %>
                    <option value="<%= Html.esc(c) %>" <%= c.equals(fCiudad) ? "selected" : "" %>><%= Html.esc(c) %></option>
<%  } %>
                </select>
            </div>

            <div class="col-6 col-lg-2">
                <label class="form-label small fw-semibold" for="minPrecio">Precio desde</label>
                <input class="form-control" id="minPrecio" name="minPrecio" type="number"
                       min="0" step="1000000" value="<%= fMin %>">
            </div>

            <div class="col-6 col-lg-2">
                <label class="form-label small fw-semibold" for="maxPrecio">Precio hasta</label>
                <input class="form-control" id="maxPrecio" name="maxPrecio" type="number"
                       min="0" step="1000000" value="<%= fMax %>">
            </div>

            <div class="col-12 col-lg-2 d-grid gap-1">
                <button class="btn btn-primary" type="submit">
                    <i class="bi bi-search me-1"></i>Filtrar
                </button>
<%  if (hayFiltros) { %>
                <a class="btn btn-link btn-sm" href="<%= ctx %>/catalogo">Limpiar filtros</a>
<%  } %>
            </div>
        </div>
    </div>
</form>

<%  if (propiedades.isEmpty()) { %>
<div class="alert alert-light border text-center py-5">
    <i class="bi bi-search text-secondary" style="font-size:2rem"></i>
    <p class="mb-3 mt-2 text-secondary">No hay propiedades que coincidan con esos filtros.</p>
<%      if (hayFiltros) { %>
    <a class="btn btn-outline-primary btn-sm" href="<%= ctx %>/catalogo">Ver todo el catalogo</a>
<%      } %>
</div>
<%  } else { %>
<div class="row g-4">
<%      for (Propiedad p : propiedades) { %>
    <div class="col-md-6 col-xl-4">
        <a class="text-decoration-none text-reset" href="<%= ctx %>/catalogo?id=<%= p.getId() %>">
            <article class="card border-0 shadow-sm h-100 sr-tarjeta">
                <div class="position-relative">
                    <img class="card-img-top sr-portada" src="<%= ctx %>/<%= p.getImagen() %>"
                         alt="<%= Html.esc(p.getTitulo()) %>">
                    <span class="badge fondo-sr position-absolute top-0 start-0 m-3">
                        EN <%= p.getOperacion() %>
                    </span>
                </div>

                <div class="card-body d-flex flex-column">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <span class="badge text-bg-light border"><%= Html.esc(p.getTipo()) %></span>
                        <span class="badge <%= "DISPONIBLE".equals(p.getEstado()) ? "text-bg-success" : "text-bg-secondary" %>">
                            <%= p.getEstado() %>
                        </span>
                    </div>

                    <h2 class="h6 fw-bold mb-1"><%= Html.esc(p.getTitulo()) %></h2>

                    <p class="text-secondary small mb-2">
                        <i class="bi bi-geo-alt me-1"></i><%= Html.esc(p.getCiudad()) %> &middot; <%= Html.esc(p.getDireccion()) %>
                    </p>

                    <ul class="list-inline small text-secondary mb-3">
                        <li class="list-inline-item"><i class="bi bi-door-closed me-1"></i><%= p.getHabitaciones() %></li>
                        <li class="list-inline-item"><i class="bi bi-droplet me-1"></i><%= p.getBanos() %></li>
                        <li class="list-inline-item"><i class="bi bi-car-front me-1"></i><%= p.getParqueaderos() %></li>
                        <li class="list-inline-item"><i class="bi bi-rulers me-1"></i><%= p.getAreaM2() %> m&sup2;</li>
                    </ul>

                    <div class="mt-auto">
                        <div class="fs-5 fw-bold"><%= pesos.format(p.getPrecio()) %></div>
                        <div class="text-secondary small">codigo <%= Html.esc(p.getCodigo()) %></div>
                    </div>
                </div>

                <div class="card-footer bg-white border-0 pt-0">
                    <span class="btn btn-outline-primary btn-sm w-100">
                        Ver ficha completa <i class="bi bi-arrow-right ms-1"></i>
                    </span>
                </div>
            </article>
        </a>
    </div>
<%      } %>
</div>
<%  } %>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
