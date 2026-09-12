<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.modelo.Cita" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%--
    Citas agendadas sobre las propiedades del agente (HU-09, lado agente).

    Vive bajo WEB-INF: solo se llega por forward desde CitaAgenteServlet,
    que ya comprobo el rol INMOBILIARIA.
--%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    List<Cita> citas = (List<Cita>) request.getAttribute("citas");
    String errorLista = (request.getAttribute("error") == null)
            ? "" : request.getAttribute("error").toString();
    String ok = (request.getParameter("ok") == null) ? "" : request.getParameter("ok");

    SimpleDateFormat fecha = new SimpleDateFormat("dd/MM/yyyy hh:mm a");

    int pendientes = 0;
    for (Cita c : citas) { if ("PENDIENTE".equals(c.getEstado())) pendientes++; }

    String rutaGestion = ctx + "/panel/inmobiliaria/citas";
%>

<div class="d-flex flex-wrap align-items-center gap-3 mb-4">
    <span class="sr-marca-icono-sm"><i class="bi bi-calendar-check"></i></span>
    <div class="flex-grow-1">
        <h1 class="h3 mb-1">Citas agendadas</h1>
        <p class="text-secondary mb-0">
            <%= pendientes %> por confirmar &middot; <%= citas.size() %> en total
        </p>
    </div>
    <a class="btn btn-outline-secondary" href="<%= ctx %>/panel/inmobiliaria.jsp">
        <i class="bi bi-arrow-left me-1"></i>Volver al panel
    </a>
</div>

<%  if (!errorLista.isEmpty()) { %>
<div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorLista %></div>
<%  } %>

<%  if (!ok.isEmpty()) {
        String texto = "confirmada".equals(ok) ? "La cita quedo confirmada."
                     : "cancelada".equals(ok)  ? "La cita se cancelo."
                     : "realizada".equals(ok)  ? "La visita se marco como realizada."
                     : "Operacion realizada.";
%>
<div class="alert alert-success alert-dismissible fade show">
    <i class="bi bi-check-circle-fill me-2"></i><%= texto %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<%  } %>

<%  if (citas.isEmpty()) { %>
<div class="card border-0 shadow-sm">
    <div class="card-body text-center py-5">
        <i class="bi bi-calendar-week text-secondary" style="font-size:2.5rem"></i>
        <h2 class="h5 mt-3">Todavia no hay citas agendadas</h2>
        <p class="text-secondary mb-0">
            Apareceran aqui cuando un cliente solicite visitar alguna de sus propiedades.
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
                    <th>Fecha y hora</th>
                    <th>Estado</th>
                    <th class="text-end">Acciones</th>
                </tr>
            </thead>
            <tbody>
<%      for (Cita c : citas) { %>
                <tr>
                    <td>
                        <div class="fw-semibold"><%= Html.esc(c.getPropiedadTitulo()) %></div>
                        <div class="text-secondary small">
                            <code><%= Html.esc(c.getPropiedadMatricula()) %></code> &middot;
                            <%= Html.esc(c.getPropiedadCiudad()) %>
                        </div>
<%          if (c.getObservaciones() != null && !c.getObservaciones().isEmpty()) { %>
                        <div class="text-secondary small fst-italic mt-1">
                            "<%= Html.esc(c.getObservaciones()) %>"
                        </div>
<%          } %>
                    </td>
                    <td>
                        <div><%= Html.esc(c.getClienteNombre()) %></div>
                        <div class="text-secondary small"><%= Html.esc(c.getClienteCorreo()) %></div>
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
<%          if ("PENDIENTE".equals(c.getEstado())) { %>
                        <form class="d-inline" method="post" action="<%= rutaGestion %>">
                            <input type="hidden" name="accion" value="confirmar">
                            <input type="hidden" name="idCita" value="<%= c.getId() %>">
                            <button class="btn btn-sm btn-outline-success" type="submit" title="Confirmar">
                                <i class="bi bi-check-lg"></i>
                            </button>
                        </form>
<%          } %>
<%          if ("CONFIRMADA".equals(c.getEstado())) { %>
                        <form class="d-inline" method="post" action="<%= rutaGestion %>">
                            <input type="hidden" name="accion" value="realizada">
                            <input type="hidden" name="idCita" value="<%= c.getId() %>">
                            <button class="btn btn-sm btn-outline-primary" type="submit" title="Marcar como realizada">
                                <i class="bi bi-flag"></i>
                            </button>
                        </form>
<%          } %>
<%          if (c.esGestionable()) { %>
                        <form class="d-inline" method="post" action="<%= rutaGestion %>"
                              onsubmit="return confirm('Cancelar esta cita?')">
                            <input type="hidden" name="accion" value="cancelar">
                            <input type="hidden" name="idCita" value="<%= c.getId() %>">
                            <button class="btn btn-sm btn-outline-danger" type="submit" title="Cancelar">
                                <i class="bi bi-x-lg"></i>
                            </button>
                        </form>
<%          } %>
<%          if (!c.esGestionable()) { %>
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
