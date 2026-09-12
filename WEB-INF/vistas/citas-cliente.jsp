<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.modelo.Cita" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%--
    Mis citas (cliente).

    Vive bajo WEB-INF: solo se llega por forward desde CitaClienteServlet,
    que ya comprobo el rol CLIENTE.
--%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    List<Cita> misCitas = (List<Cita>) request.getAttribute("citas");
    String errorLista = (request.getAttribute("error") == null)
            ? "" : request.getAttribute("error").toString();
    String ok = (request.getParameter("ok") == null) ? "" : request.getParameter("ok");

    SimpleDateFormat fecha = new SimpleDateFormat("dd/MM/yyyy hh:mm a");
%>

<div class="d-flex flex-wrap align-items-center gap-3 mb-4">
    <span class="sr-marca-icono-sm"><i class="bi bi-calendar-check"></i></span>
    <div class="flex-grow-1">
        <h1 class="h3 mb-1">Mis citas</h1>
        <p class="text-secondary mb-0">Visitas agendadas a los inmuebles del catalogo.</p>
    </div>
    <a class="btn btn-primary" href="<%= ctx %>/catalogo">
        <i class="bi bi-search me-1"></i>Buscar un inmueble para visitar
    </a>
</div>

<%  if (!errorLista.isEmpty()) { %>
<div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorLista %></div>
<%  } %>

<%  if (!ok.isEmpty()) {
        String texto = "agendada".equals(ok)  ? "Visita agendada. La agencia debe confirmarla."
                     : "cancelada".equals(ok) ? "La cita se cancelo."
                     : "Operacion realizada.";
%>
<div class="alert alert-success alert-dismissible fade show">
    <i class="bi bi-check-circle-fill me-2"></i><%= texto %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<%  } %>

<%  if (misCitas == null || misCitas.isEmpty()) { %>
<div class="card border-0 shadow-sm">
    <div class="card-body text-center py-5">
        <i class="bi bi-calendar-x text-secondary" style="font-size:2.5rem"></i>
        <h2 class="h5 mt-3">Todavia no ha agendado ninguna visita</h2>
        <p class="text-secondary">Busque un inmueble en el catalogo y solicite una cita.</p>
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
                    <th>Fecha y hora</th>
                    <th>Estado</th>
                    <th class="text-end">Acciones</th>
                </tr>
            </thead>
            <tbody>
<%      for (Cita c : misCitas) { %>
                <tr>
                    <td>
                        <div class="fw-semibold"><%= Html.esc(c.getPropiedadTitulo()) %></div>
                        <div class="text-secondary small">
                            <code><%= Html.esc(c.getPropiedadMatricula()) %></code> &middot;
                            <%= Html.esc(c.getPropiedadCiudad()) %> &middot;
                            <%= Html.esc(c.getPropiedadDireccion()) %>
                        </div>
<%          if (c.getObservaciones() != null && !c.getObservaciones().isEmpty()) { %>
                        <div class="text-secondary small fst-italic mt-1">
                            "<%= Html.esc(c.getObservaciones()) %>"
                        </div>
<%          } %>
                    </td>
                    <td class="text-nowrap"><%= fecha.format(c.getFechaHora()) %></td>
                    <td>
                        <span class="badge <%= "PENDIENTE".equals(c.getEstado()) ? "text-bg-warning"
                                              : "CONFIRMADA".equals(c.getEstado()) ? "text-bg-success"
                                              : "REALIZADA".equals(c.getEstado()) ? "text-bg-primary"
                                              : "text-bg-secondary" %>">
                            <%= c.getEstado() %>
                        </span>
                    </td>
                    <td class="text-end text-nowrap">
<%          if (c.esGestionable()) { %>
                        <form class="d-inline" method="post" action="<%= ctx %>/panel/cliente/citas"
                              onsubmit="return confirm('Cancelar esta visita?')">
                            <input type="hidden" name="accion" value="cancelar">
                            <input type="hidden" name="idCita" value="<%= c.getId() %>">
                            <button class="btn btn-sm btn-outline-danger" type="submit">
                                <i class="bi bi-x-lg me-1"></i>Cancelar
                            </button>
                        </form>
<%          } else { %>
                        <span class="text-secondary small">&mdash;</span>
<%          } %>
                    </td>
                </tr>
<%      } %>
            </tbody>
        </table>
    </div>
</div>
<%  } %>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
