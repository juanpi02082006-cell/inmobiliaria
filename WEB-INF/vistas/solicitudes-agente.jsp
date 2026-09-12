<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.modelo.Solicitud" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%--
    Solicitudes recibidas sobre las propiedades del agente (HU-11).

    Vive bajo WEB-INF: solo se llega por forward desde SolicitudAgenteServlet,
    que ya comprobo el rol INMOBILIARIA.
--%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    List<Solicitud> solicitudes = (List<Solicitud>) request.getAttribute("solicitudes");
    String errorLista = (request.getAttribute("error") == null)
            ? "" : request.getAttribute("error").toString();

    SimpleDateFormat fecha = new SimpleDateFormat("dd/MM/yyyy hh:mm a");
    NumberFormat pesos = NumberFormat.getCurrencyInstance(new Locale("es", "CO"));
    pesos.setMaximumFractionDigits(0);

    int porResolver = 0;
    for (Solicitud s : solicitudes) { if (s.esGestionable()) porResolver++; }
%>

<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
    <div>
        <h1 class="h3 mb-1">Solicitudes recibidas</h1>
        <p class="text-secondary mb-0">
            <%= porResolver %> por resolver &middot; <%= solicitudes.size() %> en total
        </p>
    </div>
    <a class="btn btn-outline-secondary" href="<%= ctx %>/panel/inmobiliaria.jsp">
        <i class="bi bi-arrow-left me-1"></i>Volver al panel
    </a>
</div>

<%  if (!errorLista.isEmpty()) { %>
<div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorLista %></div>
<%  } %>

<%  if (solicitudes.isEmpty()) { %>
<div class="card border-0 shadow-sm">
    <div class="card-body text-center py-5">
        <i class="bi bi-file-earmark-text text-secondary" style="font-size:2.5rem"></i>
        <h2 class="h5 mt-3">Todavia no hay solicitudes radicadas</h2>
        <p class="text-secondary mb-0">
            Apareceran aqui cuando un cliente radique una compra o un arriendo
            sobre alguna de sus propiedades.
        </p>
    </div>
</div>
<%  } else { %>

<div class="card border-0 shadow-sm">
    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light">
                <tr>
                    <th>Inmueble</th>
                    <th>Cliente</th>
                    <th>Tipo</th>
                    <th>Oferta</th>
                    <th>Radicada</th>
                    <th>Estado</th>
                    <th class="text-end">Acciones</th>
                </tr>
            </thead>
            <tbody>
<%      for (Solicitud s : solicitudes) { %>
                <tr>
                    <td>
                        <div class="fw-semibold"><%= Html.esc(s.getPropiedadTitulo()) %></div>
                        <div class="text-secondary small">
                            <code><%= Html.esc(s.getPropiedadMatricula()) %></code>
                        </div>
                    </td>
                    <td>
                        <div><%= Html.esc(s.getClienteNombre()) %></div>
                        <div class="text-secondary small"><%= Html.esc(s.getClienteCorreo()) %></div>
                    </td>
                    <td><%= s.getTipo() %></td>
                    <td><%= (s.getOferta() == null) ? "—" : pesos.format(s.getOferta()) %></td>
                    <td class="text-nowrap"><%= fecha.format(s.getFechaRadicacion()) %></td>
                    <td>
                        <span class="badge <%= "RADICADA".equals(s.getEstado()) ? "text-bg-warning"
                                              : "EN_REVISION".equals(s.getEstado()) ? "text-bg-info"
                                              : "APROBADA".equals(s.getEstado()) ? "text-bg-success"
                                              : "text-bg-danger" %>">
                            <%= s.getEstado() %>
                        </span>
                    </td>
                    <td class="text-end">
                        <a class="btn btn-sm btn-outline-secondary"
                           href="<%= ctx %>/panel/inmobiliaria/solicitudes?accion=ver&id=<%= s.getId() %>">
                            <i class="bi bi-eye me-1"></i>Revisar
                        </a>
                    </td>
                </tr>
<%      } %>
            </tbody>
        </table>
    </div>
</div>
<%  } %>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
