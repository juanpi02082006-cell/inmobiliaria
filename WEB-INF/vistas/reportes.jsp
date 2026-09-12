<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.modelo.ResumenCiudad" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.Map" %>
<%--
    Reporte de propiedades por ciudad y por estado (HU-12).

    Vive bajo WEB-INF: solo se llega por forward desde ReporteServlet, que ya
    comprobo el rol ADMIN y resolvio las tres consultas de agregacion.
--%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    List<ResumenCiudad> resumenCiudad = (List<ResumenCiudad>) request.getAttribute("resumenCiudad");
    Map<String, Integer> conteoEstado = (Map<String, Integer>) request.getAttribute("conteoEstado");
    Map<String, Map<String, Integer>> matriz = (Map<String, Map<String, Integer>>) request.getAttribute("matriz");
    String errorReporte = (request.getAttribute("error") == null)
            ? "" : request.getAttribute("error").toString();

    NumberFormat pesos = NumberFormat.getCurrencyInstance(new Locale("es", "CO"));
    pesos.setMaximumFractionDigits(0);

    int totalActivas = 0;
    for (ResumenCiudad r : resumenCiudad) { totalActivas += r.getTotal(); }
%>

<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
    <div>
        <h1 class="h3 mb-1">Reportes</h1>
        <p class="text-secondary mb-0">Propiedades activas por ciudad y por estado.</p>
    </div>
    <a class="btn btn-outline-secondary" href="<%= ctx %>/panel/admin.jsp">
        <i class="bi bi-arrow-left me-1"></i>Volver al panel
    </a>
</div>

<%  if (!errorReporte.isEmpty()) { %>
<div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorReporte %></div>
<%  } else { %>

<div class="row g-4">

    <%-- ============ Por ciudad (COUNT, AVG, MIN, MAX agrupados) ============ --%>
    <div class="col-lg-7">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white fw-semibold">
                Propiedades por ciudad
                <span class="text-secondary fw-normal small d-block">
                    <%= totalActivas %> inmueble(s) activo(s) &middot; COUNT, AVG, MIN, MAX agrupados por ciudad
                </span>
            </div>
<%      if (resumenCiudad.isEmpty()) { %>
            <div class="card-body">
                <p class="text-secondary mb-0">No hay propiedades activas para reportar.</p>
            </div>
<%      } else { %>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Ciudad</th>
                            <th class="text-end">Inmuebles</th>
                            <th class="text-end">Precio promedio</th>
                            <th class="text-end">Minimo</th>
                            <th class="text-end">Maximo</th>
                        </tr>
                    </thead>
                    <tbody>
<%          for (ResumenCiudad r : resumenCiudad) { %>
                        <tr>
                            <td class="fw-semibold"><%= Html.esc(r.getCiudad()) %></td>
                            <td class="text-end"><%= r.getTotal() %></td>
                            <td class="text-end"><%= pesos.format(r.getPrecioPromedio()) %></td>
                            <td class="text-end"><%= pesos.format(r.getPrecioMinimo()) %></td>
                            <td class="text-end"><%= pesos.format(r.getPrecioMaximo()) %></td>
                        </tr>
<%          } %>
                    </tbody>
                </table>
            </div>
<%      } %>
        </div>
    </div>

    <%-- ============ Por estado (COUNT agrupado) ============ --%>
    <div class="col-lg-5">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white fw-semibold">
                Propiedades por estado
                <span class="text-secondary fw-normal small d-block">COUNT agrupado por estado</span>
            </div>
            <ul class="list-group list-group-flush">
<%      for (Map.Entry<String, Integer> fila : conteoEstado.entrySet()) {
            int total = fila.getValue().intValue();
            int porcentaje = (totalActivas == 0) ? 0 : Math.round(100f * total / totalActivas);
%>
                <li class="list-group-item">
                    <div class="d-flex justify-content-between align-items-center mb-1">
                        <span><%= fila.getKey() %></span>
                        <span class="badge text-bg-secondary rounded-pill"><%= total %></span>
                    </div>
                    <div class="progress" style="height:6px">
                        <div class="progress-bar fondo-sr" style="width:<%= porcentaje %>%"></div>
                    </div>
                </li>
<%      } %>
            </ul>
        </div>
    </div>

    <%-- ============ Cruce ciudad x estado (COUNT agrupado por dos columnas) ============ --%>
    <div class="col-12">
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-white fw-semibold">
                Ciudad por estado
                <span class="text-secondary fw-normal small d-block">
                    COUNT agrupado por ciudad y estado a la vez
                </span>
            </div>
<%      if (matriz.isEmpty()) { %>
            <div class="card-body">
                <p class="text-secondary mb-0">No hay propiedades activas para reportar.</p>
            </div>
<%      } else { %>
            <div class="table-responsive">
                <table class="table table-sm align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Ciudad</th>
<%              for (String estado : conteoEstado.keySet()) { %>
                            <th class="text-end"><%= estado %></th>
<%              } %>
                        </tr>
                    </thead>
                    <tbody>
<%              for (Map.Entry<String, Map<String, Integer>> fila : matriz.entrySet()) { %>
                        <tr>
                            <td class="fw-semibold"><%= Html.esc(fila.getKey()) %></td>
<%                  for (String estado : conteoEstado.keySet()) { %>
                            <td class="text-end"><%= fila.getValue().get(estado) %></td>
<%                  } %>
                        </tr>
<%              } %>
                    </tbody>
                </table>
            </div>
<%      } %>
        </div>
    </div>
</div>
<%  } %>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
