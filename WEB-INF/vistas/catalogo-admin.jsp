<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%--
    Parametrizacion de catalogos (HU-19).

    Cada fila muestra en cuantos registros se usa el elemento, porque de eso
    depende si se puede borrar y que pasa si se borra:

      - ciudad          -> ON DELETE RESTRICT : el motor lo impide.
      - caracteristica  -> ON DELETE CASCADE  : el motor lo permite y la
                           retira de los inmuebles, asi que el aviso lo tiene
                           que dar la interfaz.
--%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    List<Object[]> ciudades = (List<Object[]>) request.getAttribute("ciudades");
    List<Object[]> caracteristicas = (List<Object[]>) request.getAttribute("caracteristicas");
    Map<Integer, String> tipos = (Map<Integer, String>) request.getAttribute("tipos");

    String errorCat = (request.getAttribute("error") == null)
            ? "" : String.valueOf(request.getAttribute("error"));
    String ok = (request.getParameter("ok") == null) ? "" : request.getParameter("ok");

    String base = ctx + "/panel/admin/catalogos";
%>
<%!
    private String att(Object v) {
        if (v == null) return "";
        return v.toString().replace("&", "&amp;").replace("\"", "&quot;")
                .replace("<", "&lt;").replace(">", "&gt;");
    }
%>

<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
    <div>
        <h1 class="h3 mb-1">Catalogos del sistema</h1>
        <p class="text-secondary mb-0">
            Ciudades y caracteristicas que alimentan los formularios de propiedades.
        </p>
    </div>
    <a class="btn btn-outline-secondary" href="<%= ctx %>/panel/admin.jsp">
        <i class="bi bi-arrow-left me-1"></i>Volver al panel
    </a>
</div>

<%  if (!errorCat.isEmpty() && !"null".equals(errorCat)) { %>
<div class="alert alert-danger">
    <i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorCat %>
</div>
<%  } %>

<%  if (!ok.isEmpty()) {
        String texto = ok.startsWith("ciudad") ? "Ciudad actualizada." : "Caracteristica actualizada.";
        if (ok.endsWith("creada"))    texto = ok.startsWith("ciudad") ? "Ciudad agregada." : "Caracteristica agregada.";
        if (ok.endsWith("eliminada")) texto = ok.startsWith("ciudad") ? "Ciudad eliminada." : "Caracteristica eliminada.";
%>
<div class="alert alert-success alert-dismissible fade show">
    <i class="bi bi-check-circle-fill me-2"></i><%= texto %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<%  } %>

<div class="row g-4">

    <%-- ============================ CIUDADES ============================ --%>
    <div class="col-lg-7">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white fw-semibold">
                Ciudades
                <span class="text-secondary fw-normal small d-block">
                    <%= ciudades.size() %> registradas &middot; UNIQUE (nombre, departamento)
                </span>
            </div>

            <div class="card-body border-bottom">
                <form class="row g-2 align-items-end" method="post" action="<%= base %>">
                    <input type="hidden" name="accion" value="ciudad-crear">
                    <div class="col-sm">
                        <label class="form-label small fw-semibold" for="nuevaCiudad">Ciudad</label>
                        <input class="form-control form-control-sm" id="nuevaCiudad"
                               name="nombre" type="text" maxlength="60" required>
                    </div>
                    <div class="col-sm">
                        <label class="form-label small fw-semibold" for="nuevoDepto">Departamento</label>
                        <input class="form-control form-control-sm" id="nuevoDepto"
                               name="departamento" type="text" maxlength="60" required>
                    </div>
                    <div class="col-sm-auto">
                        <button class="btn btn-sm btn-primary" type="submit">
                            <i class="bi bi-plus-lg me-1"></i>Agregar
                        </button>
                    </div>
                </form>
            </div>

            <div class="table-responsive">
                <table class="table table-sm align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Ciudad y departamento</th>
                            <th class="text-center">Inmuebles</th>
                            <th class="text-end">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
<%  for (Object[] c : ciudades) {
        int id = ((Integer) c[0]).intValue();
        String nombre = (String) c[1];
        String depto = (String) c[2];
        int usos = ((Integer) c[3]).intValue();
%>
                        <tr>
                            <td>
                                <form class="row g-1" method="post" action="<%= base %>">
                                    <input type="hidden" name="accion" value="ciudad-editar">
                                    <input type="hidden" name="id" value="<%= id %>">
                                    <div class="col">
                                        <input class="form-control form-control-sm" name="nombre"
                                               type="text" maxlength="60" required
                                               value="<%= att(nombre) %>"
                                               aria-label="Nombre de la ciudad">
                                    </div>
                                    <div class="col">
                                        <input class="form-control form-control-sm" name="departamento"
                                               type="text" maxlength="60" required
                                               value="<%= att(depto) %>"
                                               aria-label="Departamento">
                                    </div>
                                    <div class="col-auto">
                                        <button class="btn btn-sm btn-outline-primary" type="submit"
                                                title="Guardar cambios">
                                            <i class="bi bi-check-lg"></i>
                                        </button>
                                    </div>
                                </form>
                            </td>

                            <td class="text-center" style="font-variant-numeric:tabular-nums">
<%      if (usos > 0) { %>
                                <span class="badge text-bg-light border"><%= usos %></span>
<%      } else { %>
                                <span class="text-secondary">&mdash;</span>
<%      } %>
                            </td>

                            <td class="text-end">
<%      if (usos > 0) { %>
                                <button class="btn btn-sm btn-outline-secondary" disabled
                                        title="Tiene inmuebles publicados: la llave foranea lo impide">
                                    <i class="bi bi-lock"></i>
                                </button>
<%      } else { %>
                                <form class="d-inline" method="post" action="<%= base %>"
                                      onsubmit="return confirm('Eliminar <%= Html.js(nombre) %>?')">
                                    <input type="hidden" name="accion" value="ciudad-eliminar">
                                    <input type="hidden" name="id" value="<%= id %>">
                                    <button class="btn btn-sm btn-outline-danger" type="submit" title="Eliminar">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </form>
<%      } %>
                            </td>
                        </tr>
<%  } %>
                    </tbody>
                </table>
            </div>

            <div class="card-footer bg-white small text-secondary">
                <i class="bi bi-shield-check me-1"></i>
                Las ciudades con inmuebles no se pueden eliminar:
                <code>propiedad.id_ciudad</code> es <code>ON DELETE RESTRICT</code>
                y el motor rechaza el borrado.
            </div>
        </div>
    </div>

    <%-- ========================= CARACTERISTICAS ========================= --%>
    <div class="col-lg-5">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white fw-semibold">
                Caracteristicas
                <span class="text-secondary fw-normal small d-block">
                    <%= caracteristicas.size() %> registradas &middot; UNIQUE (nombre)
                </span>
            </div>

            <div class="card-body border-bottom">
                <form class="row g-2 align-items-end" method="post" action="<%= base %>">
                    <input type="hidden" name="accion" value="caracteristica-crear">
                    <div class="col">
                        <label class="form-label small fw-semibold" for="nuevaCar">Nombre</label>
                        <input class="form-control form-control-sm" id="nuevaCar"
                               name="nombre" type="text" maxlength="50" required
                               placeholder="Terraza, Chimenea…">
                    </div>
                    <div class="col-auto">
                        <button class="btn btn-sm btn-primary" type="submit">
                            <i class="bi bi-plus-lg me-1"></i>Agregar
                        </button>
                    </div>
                </form>
            </div>

            <div class="table-responsive">
                <table class="table table-sm align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Nombre</th>
                            <th class="text-center">Usos</th>
                            <th class="text-end">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
<%  for (Object[] c : caracteristicas) {
        int id = ((Integer) c[0]).intValue();
        String nombre = (String) c[1];
        int usos = ((Integer) c[2]).intValue();

        String aviso = (usos > 0)
            ? "Eliminar " + nombre + "? Se retirara de " + usos + " inmueble(s)."
            : "Eliminar " + nombre + "?";
%>
                        <tr>
                            <td>
                                <form class="row g-1" method="post" action="<%= base %>">
                                    <input type="hidden" name="accion" value="caracteristica-editar">
                                    <input type="hidden" name="id" value="<%= id %>">
                                    <div class="col">
                                        <input class="form-control form-control-sm" name="nombre"
                                               type="text" maxlength="50" required
                                               value="<%= att(nombre) %>"
                                               aria-label="Nombre de la caracteristica">
                                    </div>
                                    <div class="col-auto">
                                        <button class="btn btn-sm btn-outline-primary" type="submit"
                                                title="Guardar cambios">
                                            <i class="bi bi-check-lg"></i>
                                        </button>
                                    </div>
                                </form>
                            </td>

                            <td class="text-center" style="font-variant-numeric:tabular-nums">
<%      if (usos > 0) { %>
                                <span class="badge text-bg-warning"><%= usos %></span>
<%      } else { %>
                                <span class="text-secondary">&mdash;</span>
<%      } %>
                            </td>

                            <td class="text-end">
                                <form class="d-inline" method="post" action="<%= base %>"
                                      onsubmit="return confirm('<%= Html.js(aviso) %>')">
                                    <input type="hidden" name="accion" value="caracteristica-eliminar">
                                    <input type="hidden" name="id" value="<%= id %>">
                                    <button class="btn btn-sm btn-outline-danger" type="submit" title="Eliminar">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
<%  } %>
                    </tbody>
                </table>
            </div>

            <div class="card-footer bg-white small text-secondary">
                <i class="bi bi-exclamation-triangle me-1"></i>
                Aqui la llave foranea es <code>ON DELETE CASCADE</code>: el motor
                <strong>si</strong> permite el borrado y retira la caracteristica de
                los inmuebles que la tuvieran. Por eso el aviso lo da esta pantalla.
            </div>
        </div>
    </div>

    <%-- =========================== TIPOS (fijos) =========================== --%>
    <div class="col-12">
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-white fw-semibold">
                Tipos de propiedad
                <span class="text-secondary fw-normal small d-block">
                    Catalogo cerrado &middot; solo consulta
                </span>
            </div>
            <div class="card-body">
                <div class="d-flex flex-wrap gap-2 mb-3">
<%  for (Map.Entry<Integer, String> t : tipos.entrySet()) { %>
                    <span class="badge text-bg-light border py-2 px-3"><%= Html.esc(t.getValue()) %></span>
<%  } %>
                </div>
                <p class="text-secondary small mb-0">
                    Este catalogo no se parametriza a proposito. El enunciado define
                    el alcance del sistema en cinco tipos &mdash;casas, apartamentos,
                    locales, oficinas y terrenos&mdash; y agregar otros seria salirse
                    de lo que el proyecto declara gestionar.
                </p>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
