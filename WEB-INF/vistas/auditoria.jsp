<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.modelo.RegistroAuditoria" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%--
    Auditoria de accesos y cambios (HU-13).

    Vive bajo WEB-INF: solo se llega por forward desde AuditoriaServlet, que
    ya comprobo el rol ADMIN y resolvio el filtro.
--%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    List<RegistroAuditoria> registros = (List<RegistroAuditoria>) request.getAttribute("registros");
    List<String> acciones = (List<String>) request.getAttribute("acciones");
    String errorLista = (request.getAttribute("error") == null)
            ? "" : request.getAttribute("error").toString();

    String fAccion = String.valueOf(request.getAttribute("fAccion") == null ? "" : request.getAttribute("fAccion"));
    String fCorreo = String.valueOf(request.getAttribute("fCorreo") == null ? "" : request.getAttribute("fCorreo"));
    int limite = (Integer) request.getAttribute("limite");
    boolean hayFiltros = !fAccion.isEmpty() || !fCorreo.isEmpty();

    SimpleDateFormat fecha = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss a");
%>

<div class="d-flex flex-wrap align-items-center gap-3 mb-4">
    <span class="sr-marca-icono-sm"><i class="bi bi-clock-history"></i></span>
    <div class="flex-grow-1">
        <h1 class="h3 mb-1">Auditoria</h1>
        <p class="text-secondary mb-0">Registro de accesos y cambios del sistema.</p>
    </div>
    <a class="btn btn-outline-secondary" href="<%= ctx %>/panel/admin.jsp">
        <i class="bi bi-arrow-left me-1"></i>Volver al panel
    </a>
</div>

<%  if (!errorLista.isEmpty()) { %>
<div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorLista %></div>
<%  } %>

<form class="card border-0 shadow-sm mb-4" action="<%= ctx %>/panel/admin/auditoria" method="get">
    <div class="card-body">
        <div class="row g-2 align-items-end">
            <div class="col-6 col-lg-4">
                <label class="form-label small fw-semibold" for="accion">Accion</label>
                <select class="form-select" id="accion" name="accion">
                    <option value="">Todas</option>
<%  for (String a : acciones) { %>
                    <option value="<%= a %>" <%= a.equals(fAccion) ? "selected" : "" %>><%= a %></option>
<%  } %>
                </select>
            </div>
            <div class="col-6 col-lg-4">
                <label class="form-label small fw-semibold" for="correo">Correo</label>
                <input class="form-control" id="correo" name="correo" type="text"
                       placeholder="Buscar por correo" value="<%= Html.esc(fCorreo) %>">
            </div>
            <div class="col-12 col-lg-4 d-grid gap-1 d-lg-flex">
                <button class="btn btn-primary" type="submit">
                    <i class="bi bi-search me-1"></i>Filtrar
                </button>
<%  if (hayFiltros) { %>
                <a class="btn btn-link btn-sm" href="<%= ctx %>/panel/admin/auditoria">Limpiar filtros</a>
<%  } %>
            </div>
        </div>
    </div>
</form>

<%  if (registros.isEmpty()) { %>
<div class="alert alert-light border text-center py-5">
    <i class="bi bi-clock-history text-secondary" style="font-size:2rem"></i>
    <p class="mb-0 mt-2 text-secondary">No hay registros que coincidan con ese filtro.</p>
</div>
<%  } else { %>

<div class="card border-0 shadow-sm">
    <div class="table-responsive">
        <table class="table table-sm table-hover align-middle mb-0">
            <thead class="table-light">
                <tr>
                    <th>Fecha</th>
                    <th>Usuario</th>
                    <th>Accion</th>
                    <th>Detalle</th>
                    <th>IP</th>
                </tr>
            </thead>
            <tbody>
<%      for (RegistroAuditoria r : registros) { %>
                <tr>
                    <td class="text-nowrap"><%= fecha.format(r.getFecha()) %></td>
                    <td><%= (r.getCorreoUsuario() == null) ? "—" : Html.esc(r.getCorreoUsuario()) %></td>
                    <td><span class="badge text-bg-light border"><%= Html.esc(r.getAccion()) %></span></td>
                    <td class="text-secondary small"><%= (r.getDetalle() == null) ? "" : Html.esc(r.getDetalle()) %></td>
                    <td class="text-secondary small"><%= (r.getIp() == null) ? "" : Html.esc(r.getIp()) %></td>
                </tr>
<%      } %>
            </tbody>
        </table>
    </div>
</div>
<p class="text-secondary small mt-3 mb-0">
    Se muestran hasta <%= limite %> registros, los mas recientes primero. Use los
    filtros para acotar la busqueda.
</p>
<%  } %>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
