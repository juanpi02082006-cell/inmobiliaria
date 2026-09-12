<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.modelo.Propiedad" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%--
    Listado de las propiedades del agente.

    Vive bajo WEB-INF, asi que Tomcat no la sirve por URL directa: solo se
    llega por forward desde PropiedadServlet, que ya comprobo el rol.
--%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    List<Propiedad> mias = (List<Propiedad>) request.getAttribute("propiedades");
    String errorLista = (request.getAttribute("error") == null)
            ? "" : request.getAttribute("error").toString();
    String ok = (request.getParameter("ok") == null) ? "" : request.getParameter("ok");

    NumberFormat pesos = NumberFormat.getCurrencyInstance(new Locale("es", "CO"));
    pesos.setMaximumFractionDigits(0);

    int activas = 0;
    for (Propiedad pr : mias) { if (pr.isActivo()) activas++; }

    String rutaGestion = ctx + "/panel/inmobiliaria/propiedades";
%>

<div class="d-flex flex-wrap align-items-center gap-3 mb-4">
    <span class="sr-marca-icono-sm"><i class="bi bi-houses"></i></span>
    <div class="flex-grow-1">
        <h1 class="h3 mb-1">Mis propiedades</h1>
        <p class="text-secondary mb-0">
            <%= activas %> publicadas &middot; <%= mias.size() - activas %> dadas de baja
        </p>
    </div>
    <a class="btn btn-primary" href="<%= rutaGestion %>?accion=nueva">
        <i class="bi bi-plus-lg me-1"></i>Publicar propiedad
    </a>
</div>

<%  if (!errorLista.isEmpty()) { %>
<div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorLista %></div>
<%  } %>

<%  if (!ok.isEmpty()) {
        String texto = "creada".equals(ok)     ? "Inmueble publicado correctamente."
                     : "editada".equals(ok)    ? "Cambios guardados."
                     : "baja".equals(ok)       ? "El inmueble se retiro del catalogo."
                     : "reactivada".equals(ok) ? "El inmueble volvio al catalogo."
                     : "Operacion realizada.";
%>
<div class="alert alert-success alert-dismissible fade show">
    <i class="bi bi-check-circle-fill me-2"></i><%= texto %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<%  } %>

<%  if (mias.isEmpty()) { %>
<div class="card border-0 shadow-sm">
    <div class="card-body text-center py-5">
        <i class="bi bi-houses text-secondary" style="font-size:2.5rem"></i>
        <h2 class="h5 mt-3">Todavia no ha publicado ningun inmueble</h2>
        <p class="text-secondary">Empiece por dar de alta el primero.</p>
        <a class="btn btn-primary" href="<%= rutaGestion %>?accion=nueva">Publicar propiedad</a>
    </div>
</div>
<%  } else { %>

<div class="card border-0 shadow-sm">
    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light">
                <tr>
                    <th style="width:88px"></th>
                    <th>Inmueble</th>
                    <th class="d-none d-md-table-cell">Ciudad</th>
                    <th class="text-end">Precio</th>
                    <th>Estado</th>
                    <th class="text-end">Acciones</th>
                </tr>
            </thead>
            <tbody>
<%      for (Propiedad p : mias) { %>
                <tr<%= p.isActivo() ? "" : " class=\"table-secondary\"" %>>
                    <td>
                        <img src="<%= ctx %>/<%= p.getImagen() %>" alt=""
                             class="rounded" style="width:72px;height:52px;object-fit:cover<%= p.isActivo() ? "" : ";opacity:.5" %>">
                    </td>

                    <td>
                        <div class="fw-semibold"><%= Html.esc(p.getTitulo()) %></div>
                        <div class="text-secondary small">
                            <code><%= Html.esc(p.getMatricula()) %></code> &middot; <%= Html.esc(p.getTipo()) %>
                            &middot; <%= p.getOperacion() %>
                        </div>
                    </td>

                    <td class="d-none d-md-table-cell"><%= Html.esc(p.getCiudad()) %></td>

                    <td class="text-end fw-semibold" style="font-variant-numeric:tabular-nums">
                        <%= pesos.format(p.getPrecio()) %>
                    </td>

                    <td>
<%          if (!p.isActivo()) { %>
                        <span class="badge text-bg-secondary">DE BAJA</span>
<%          } else { %>
                        <span class="badge <%= "DISPONIBLE".equals(p.getEstado()) ? "text-bg-success" : "text-bg-warning" %>">
                            <%= p.getEstado() %>
                        </span>
<%          } %>
                    </td>

                    <td class="text-end text-nowrap">
                        <a class="btn btn-sm btn-outline-secondary"
                           href="<%= rutaGestion %>?accion=editar&amp;id=<%= p.getId() %>"
                           title="Editar">
                            <i class="bi bi-pencil"></i>
                        </a>

<%          if (p.isActivo()) { %>
                        <form class="d-inline" method="post" action="<%= rutaGestion %>"
                              onsubmit="return confirm('Retirar este inmueble del catalogo? Podra volver a publicarlo despues.')">
                            <input type="hidden" name="accion" value="baja">
                            <input type="hidden" name="id" value="<%= p.getId() %>">
                            <button class="btn btn-sm btn-outline-danger" type="submit" title="Dar de baja">
                                <i class="bi bi-eye-slash"></i>
                            </button>
                        </form>
<%          } else { %>
                        <form class="d-inline" method="post" action="<%= rutaGestion %>">
                            <input type="hidden" name="accion" value="reactivar">
                            <input type="hidden" name="id" value="<%= p.getId() %>">
                            <button class="btn btn-sm btn-outline-success" type="submit" title="Volver a publicar">
                                <i class="bi bi-eye"></i>
                            </button>
                        </form>
<%          } %>
                    </td>
                </tr>
<%      } %>
            </tbody>
        </table>
    </div>
</div>

<p class="text-secondary small mt-3 mb-0">
    Dar de baja es una <strong>baja logica</strong>: el inmueble sale del catalogo
    publico pero se conserva en la base de datos junto con sus citas y solicitudes.
</p>
<%  } %>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
