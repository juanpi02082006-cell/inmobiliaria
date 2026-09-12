<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.modelo.Solicitud" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%--
    Mis solicitudes (HU-10).

    Vive bajo WEB-INF: solo se llega por forward desde SolicitudClienteServlet,
    que ya comprobo el rol CLIENTE.
--%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    List<Solicitud> misSolicitudes = (List<Solicitud>) request.getAttribute("solicitudes");
    String errorLista = (request.getAttribute("error") == null)
            ? "" : request.getAttribute("error").toString();

    SimpleDateFormat fecha = new SimpleDateFormat("dd/MM/yyyy hh:mm a");
    NumberFormat pesos = NumberFormat.getCurrencyInstance(new Locale("es", "CO"));
    pesos.setMaximumFractionDigits(0);
%>

<div class="d-flex flex-wrap align-items-center gap-3 mb-4">
    <span class="sr-marca-icono-sm"><i class="bi bi-send-check"></i></span>
    <div class="flex-grow-1">
        <h1 class="h3 mb-1">Mis solicitudes</h1>
        <p class="text-secondary mb-0">Solicitudes de compra o arriendo radicadas sobre el catalogo.</p>
    </div>
    <a class="btn btn-primary" href="<%= ctx %>/catalogo">
        <i class="bi bi-search me-1"></i>Buscar un inmueble
    </a>
</div>

<%  if (!errorLista.isEmpty()) { %>
<div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorLista %></div>
<%  } %>

<%  if (misSolicitudes == null || misSolicitudes.isEmpty()) { %>
<div class="card border-0 shadow-sm">
    <div class="card-body text-center py-5">
        <i class="bi bi-file-earmark-text text-secondary" style="font-size:2.5rem"></i>
        <h2 class="h5 mt-3">Todavia no ha radicado ninguna solicitud</h2>
        <p class="text-secondary">
            Desde la ficha de un inmueble encontrara el boton para radicar la compra o el arriendo.
        </p>
        <a class="btn btn-primary" href="<%= ctx %>/catalogo">Ver propiedades</a>
    </div>
</div>
<%  } else { %>

<div class="card border-0 shadow-sm">
    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light">
                <tr>
                    <th>Inmueble</th>
                    <th>Tipo</th>
                    <th>Oferta</th>
                    <th>Radicada</th>
                    <th>Estado</th>
                    <th class="text-end">Documentos</th>
                </tr>
            </thead>
            <tbody>
<%      for (Solicitud s : misSolicitudes) { %>
                <tr>
                    <td>
                        <div class="fw-semibold"><%= Html.esc(s.getPropiedadTitulo()) %></div>
                        <div class="text-secondary small">
                            <code><%= Html.esc(s.getPropiedadMatricula()) %></code> &middot;
                            <%= Html.esc(s.getPropiedadCiudad()) %>
                        </div>
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
                           href="<%= ctx %>/panel/cliente/solicitudes?accion=ver&id=<%= s.getId() %>">
                            <i class="bi bi-eye me-1"></i>Ver
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
