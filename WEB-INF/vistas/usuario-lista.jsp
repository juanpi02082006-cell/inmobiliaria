<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.modelo.Usuario" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%--
    Administracion de usuarios y roles.

    Cada fila permite asignar los roles del usuario (relacion N:M con la tabla
    puente usuario_rol) y activar o inactivar su cuenta.
--%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
    Map<Integer, String> catalogoRoles = (Map<Integer, String>) request.getAttribute("catalogoRoles");

    String errorUsu = (request.getAttribute("error") == null)
            ? "" : String.valueOf(request.getAttribute("error"));
    String ok = (request.getParameter("ok") == null) ? "" : request.getParameter("ok");

    String base = ctx + "/panel/admin/usuarios";

    int activos = 0;
    for (Usuario u : usuarios) { if (u.isActivo()) activos++; }
%>

<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
    <div>
        <h1 class="h3 mb-1">Usuarios y roles</h1>
        <p class="text-secondary mb-0">
            <%= usuarios.size() %> cuentas &middot; <%= activos %> activas
        </p>
    </div>
    <a class="btn btn-outline-secondary" href="<%= ctx %>/panel/admin.jsp">
        <i class="bi bi-arrow-left me-1"></i>Volver al panel
    </a>
</div>

<%  if (!errorUsu.isEmpty() && !"null".equals(errorUsu)) { %>
<div class="alert alert-danger">
    <i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorUsu %>
</div>
<%  } %>

<%  if (!ok.isEmpty()) {
        String texto = "roles".equals(ok)       ? "Roles actualizados."
                     : "activada".equals(ok)    ? "Cuenta activada."
                     : "inactivada".equals(ok)  ? "Cuenta inactivada."
                     : "Operacion realizada.";
%>
<div class="alert alert-success alert-dismissible fade show">
    <i class="bi bi-check-circle-fill me-2"></i><%= texto %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<%  } %>

<div class="card border-0 shadow-sm">
    <div class="table-responsive">
        <table class="table align-middle mb-0">
            <thead class="table-light">
                <tr>
                    <th>Usuario</th>
                    <th>Roles</th>
                    <th class="text-end">Cuenta</th>
                </tr>
            </thead>
            <tbody>
<%  for (Usuario u : usuarios) {
        boolean esYo = (usuarioSesion != null && u.getId() == usuarioSesion.getId());
%>
                <tr<%= u.isActivo() ? "" : " class=\"table-secondary\"" %>>

                    <td style="min-width:210px">
                        <div class="fw-semibold">
                            <%= Html.esc((u.getPerfil() == null) ? u.getCorreo() : u.getPerfil().nombreCompleto()) %>
<%      if (esYo) { %>
                            <span class="badge text-bg-info ms-1">usted</span>
<%      } %>
                        </div>
                        <div class="text-secondary small"><%= Html.esc(u.getCorreo()) %></div>
                    </td>

                    <%-- ---- Roles: relacion N:M ---- --%>
                    <td>
                        <form class="d-flex flex-wrap align-items-center gap-3" method="post" action="<%= base %>">
                            <input type="hidden" name="accion" value="roles">
                            <input type="hidden" name="id" value="<%= u.getId() %>">

<%      for (Map.Entry<Integer, String> r : catalogoRoles.entrySet()) {
            boolean tiene = u.tieneRol(r.getValue());
%>
                            <div class="form-check mb-0">
                                <input class="form-check-input" type="checkbox"
                                       name="roles" value="<%= r.getKey() %>"
                                       id="r<%= u.getId() %>_<%= r.getKey() %>"
                                       <%= tiene ? "checked" : "" %>>
                                <label class="form-check-label small" for="r<%= u.getId() %>_<%= r.getKey() %>">
                                    <%= Html.esc(r.getValue()) %>
                                </label>
                            </div>
<%      } %>
                            <button class="btn btn-sm btn-outline-primary" type="submit">
                                Guardar roles
                            </button>
                        </form>
                    </td>

                    <%-- ---- Estado de la cuenta ---- --%>
                    <td class="text-end text-nowrap">
<%      if (u.isActivo()) { %>
                        <span class="badge text-bg-success me-1">ACTIVA</span>
                        <form class="d-inline" method="post" action="<%= base %>"
                              onsubmit="return confirm('Inactivar la cuenta de <%= Html.esc(u.getCorreo()) %>? No podra iniciar sesion.')">
                            <input type="hidden" name="accion" value="inactivar">
                            <input type="hidden" name="id" value="<%= u.getId() %>">
                            <button class="btn btn-sm btn-outline-danger" type="submit"
                                    <%= esYo ? "disabled title=\"No puede inactivar su propia cuenta\"" : "" %>>
                                <i class="bi bi-person-slash"></i>
                            </button>
                        </form>
<%      } else { %>
                        <span class="badge text-bg-secondary me-1">INACTIVA</span>
                        <form class="d-inline" method="post" action="<%= base %>">
                            <input type="hidden" name="accion" value="activar">
                            <input type="hidden" name="id" value="<%= u.getId() %>">
                            <button class="btn btn-sm btn-outline-success" type="submit">
                                <i class="bi bi-person-check"></i>
                            </button>
                        </form>
<%      } %>
                    </td>
                </tr>
<%  } %>
            </tbody>
        </table>
    </div>
</div>

<div class="alert alert-light border mt-3 small mb-0">
    <strong>Dos salvaguardas.</strong> El sistema no le permite inactivar su
    propia cuenta ni quitarse el rol de administrador, y tampoco dejar el
    sistema sin ningun administrador activo: en cualquiera de esos casos nadie
    podria volver a entrar a esta pantalla.
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
