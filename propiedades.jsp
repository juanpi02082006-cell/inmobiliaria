<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.dao.PropiedadDAO" %>
<%@ page import="com.inmobiliaria.modelo.Propiedad" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%--
    Catalogo publico de propiedades.

    Es una ruta publica: el visitante sin cuenta puede consultarla, tal como
    pide el enunciado. Los datos de contacto completos y las acciones sobre
    el inmueble quedan reservados a los usuarios autenticados.
--%>
<%
    request.setAttribute("titulo", "Propiedades");

    String fTipo   = valorParametro(request.getParameter("tipo"));
    String fCiudad = valorParametro(request.getParameter("ciudad"));
    String fMin    = valorParametro(request.getParameter("minPrecio"));
    String fMax    = valorParametro(request.getParameter("maxPrecio"));
%>
<%!
    private String valorParametro(String v) {
        return (v == null) ? "" : v.trim();
    }

    /** Convierte a BigDecimal sin reventar si el texto no es un numero. */
    private BigDecimal aPrecio(String texto) {
        if (texto == null || texto.trim().isEmpty()) {
            return null;
        }
        try {
            return new BigDecimal(texto.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    PropiedadDAO propiedadDAO = new PropiedadDAO();
    List<Propiedad> propiedades = propiedadDAO.filtrar(fTipo, fCiudad, aPrecio(fMin), aPrecio(fMax));
    List<String> ciudades = propiedadDAO.ciudadesConPropiedades();
    List<String> tipos = propiedadDAO.tiposConPropiedades();

    NumberFormat pesos = NumberFormat.getCurrencyInstance(new Locale("es", "CO"));
    pesos.setMaximumFractionDigits(0);
%>

<div class="d-flex flex-wrap justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 mb-1">Propiedades</h1>
        <p class="text-secondary mb-0"><%= propiedades.size() %> inmueble(s) encontrado(s)</p>
    </div>
</div>

<form class="card border-0 shadow-sm mb-4" action="<%= ctx %>/propiedades.jsp" method="get">
    <div class="card-body">
        <div class="row g-2 align-items-end">
            <div class="col-6 col-lg-3">
                <label class="form-label small" for="tipo">Tipo</label>
                <select class="form-select" id="tipo" name="tipo">
                    <option value="">Todos</option>
<%  for (String t : tipos) { %>
                    <option value="<%= t %>" <%= t.equals(fTipo) ? "selected" : "" %>><%= t %></option>
<%  } %>
                </select>
            </div>

            <div class="col-6 col-lg-3">
                <label class="form-label small" for="ciudad">Ciudad</label>
                <select class="form-select" id="ciudad" name="ciudad">
                    <option value="">Todas</option>
<%  for (String c : ciudades) { %>
                    <option value="<%= c %>" <%= c.equals(fCiudad) ? "selected" : "" %>><%= c %></option>
<%  } %>
                </select>
            </div>

            <div class="col-6 col-lg-2">
                <label class="form-label small" for="minPrecio">Precio desde</label>
                <input class="form-control" id="minPrecio" name="minPrecio" type="number"
                       min="0" step="1000000" value="<%= fMin %>">
            </div>

            <div class="col-6 col-lg-2">
                <label class="form-label small" for="maxPrecio">Precio hasta</label>
                <input class="form-control" id="maxPrecio" name="maxPrecio" type="number"
                       min="0" step="1000000" value="<%= fMax %>">
            </div>

            <div class="col-12 col-lg-2 d-grid gap-2">
                <button class="btn btn-primary" type="submit">
                    <i class="bi bi-search me-1"></i>Filtrar
                </button>
                <a class="btn btn-link btn-sm" href="<%= ctx %>/propiedades.jsp">Limpiar</a>
            </div>
        </div>
    </div>
</form>

<%  if (propiedades.isEmpty()) { %>
<div class="alert alert-light border text-center py-5">
    <i class="bi bi-search text-secondary" style="font-size:2rem"></i>
    <p class="mb-0 mt-2 text-secondary">No hay propiedades que coincidan con esos filtros.</p>
</div>
<%  } else { %>
<div class="row g-4">
<%      for (Propiedad p : propiedades) { %>
    <div class="col-md-6 col-xl-4">
        <article class="card border-0 shadow-sm h-100">
            <img class="card-img-top" src="<%= ctx %>/<%= p.getImagen() %>"
                 alt="<%= p.getTitulo() %>" style="height:220px;object-fit:cover">

            <div class="card-body d-flex flex-column">
                <div class="d-flex justify-content-between align-items-start mb-2">
                    <span class="badge text-bg-light border"><%= p.getTipo() %></span>
                    <span class="badge <%= "DISPONIBLE".equals(p.getEstado()) ? "text-bg-success" : "text-bg-secondary" %>">
                        <%= p.getEstado() %>
                    </span>
                </div>

                <h2 class="h6 fw-bold mb-1"><%= p.getTitulo() %></h2>

                <p class="text-secondary small mb-2">
                    <i class="bi bi-geo-alt me-1"></i><%= p.getCiudad() %> &middot; <%= p.getDireccion() %>
                </p>

                <ul class="list-inline small text-secondary mb-3">
                    <li class="list-inline-item"><i class="bi bi-door-closed me-1"></i><%= p.getHabitaciones() %></li>
                    <li class="list-inline-item"><i class="bi bi-droplet me-1"></i><%= p.getBanos() %></li>
                    <li class="list-inline-item"><i class="bi bi-car-front me-1"></i><%= p.getParqueaderos() %></li>
                    <li class="list-inline-item"><i class="bi bi-rulers me-1"></i><%= p.getAreaM2() %> m&sup2;</li>
                </ul>

                <div class="mt-auto">
                    <div class="fs-5 fw-bold"><%= pesos.format(p.getPrecio()) %></div>
                    <div class="text-secondary small">
                        <%= p.getOperacion() %> &middot; codigo <%= p.getCodigo() %>
                    </div>
                </div>
            </div>

            <div class="card-footer bg-white border-0 pt-0">
<%          if (usuarioSesion == null) { %>
                <a class="btn btn-outline-secondary btn-sm w-100" href="<%= ctx %>/login.jsp">
                    Inicie sesion para agendar una visita
                </a>
<%          } else { %>
                <button class="btn btn-outline-primary btn-sm w-100" disabled>
                    Agendar visita <span class="badge text-bg-light">Sprint 3</span>
                </button>
<%          } %>
            </div>
        </article>
    </div>
<%      } %>
</div>
<%  } %>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
