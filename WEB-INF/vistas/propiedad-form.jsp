<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.modelo.Caracteristica" %>
<%@ page import="com.inmobiliaria.modelo.Imagen" %>
<%@ page import="com.inmobiliaria.modelo.Propiedad" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%--
    Alta y edicion de un inmueble.

    La misma vista sirve para los dos casos: si "propiedad" viene en null es
    un alta; si trae un inmueble es una edicion. La galeria y las
    caracteristicas solo se administran cuando el inmueble ya existe, porque
    ambas necesitan su id.
--%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    Propiedad p = (Propiedad) request.getAttribute("propiedad");
    boolean esEdicion = (p != null && p.getId() > 0);

    Map<Integer, String> ciudades = (Map<Integer, String>) request.getAttribute("ciudades");
    Map<Integer, String> tipos = (Map<Integer, String>) request.getAttribute("tipos");
    List<Caracteristica> catalogo = (List<Caracteristica>) request.getAttribute("catalogoCaracteristicas");

    String errorForm = (request.getAttribute("error") == null)
            ? "" : request.getAttribute("error").toString();
    String ok = (request.getParameter("ok") == null) ? "" : request.getParameter("ok");

    // La subida de fotos falla con un redirect (no con un forward), asi que
    // su error viaja por la URL en vez de por un atributo de la peticion.
    String errorImagen = (request.getParameter("error") == null) ? "" : request.getParameter("error");

    String rutaGestion = ctx + "/panel/inmobiliaria/propiedades";
%>
<%!
    /** Escapa para poder meter el valor dentro de un atributo HTML. */
    private String att(Object v) {
        if (v == null) return "";
        return v.toString().replace("&", "&amp;").replace("\"", "&quot;")
                .replace("<", "&lt;").replace(">", "&gt;");
    }
    private String sel(boolean condicion) { return condicion ? " selected" : ""; }
    private String chk(boolean condicion) { return condicion ? " checked" : ""; }
%>

<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
    <div>
        <h1 class="h3 mb-1"><%= esEdicion ? "Editar propiedad" : "Publicar propiedad" %></h1>
        <p class="text-secondary mb-0">
<%  if (esEdicion) { %>
            <code><%= Html.esc(p.getMatricula()) %></code> &middot; <%= Html.esc(p.getTitulo()) %>
<%  } else { %>
            Los campos marcados con * son obligatorios.
<%  } %>
        </p>
    </div>
    <a class="btn btn-outline-secondary" href="<%= rutaGestion %>">
        <i class="bi bi-arrow-left me-1"></i>Volver al listado
    </a>
</div>

<%  if (!errorForm.isEmpty()) { %>
<div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorForm %></div>
<%  } %>

<%  if (!ok.isEmpty()) {
        String texto = "creada".equals(ok)        ? "Inmueble publicado. Ya puede agregarle fotos."
                     : "editada".equals(ok)       ? "Cambios guardados."
                     : "imagen".equals(ok)        ? "Foto agregada a la galeria."
                     : "imagen-fuera".equals(ok)  ? "Foto eliminada."
                     : "portada".equals(ok)       ? "Portada actualizada."
                     : "Operacion realizada.";
%>
<div class="alert alert-success alert-dismissible fade show">
    <i class="bi bi-check-circle-fill me-2"></i><%= texto %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<%  } %>

<form method="post" action="<%= rutaGestion %>" novalidate>
    <input type="hidden" name="accion" value="guardar">
<%  if (esEdicion) { %>
    <input type="hidden" name="id" value="<%= p.getId() %>">
<%  } %>

    <div class="row g-4">

        <%-- ============ Datos del inmueble ============ --%>
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white fw-semibold">Datos del inmueble</div>
                <div class="card-body">
                    <div class="row g-3">

                        <div class="col-sm-5">
                            <label class="form-label small fw-semibold" for="matricula">
                                Matricula inmobiliaria *
                            </label>
                            <input class="form-control" id="matricula" name="matricula" type="text"
                                   maxlength="30" required
                                   value="<%= att(p == null ? "" : p.getMatricula()) %>">
                            <div class="form-text">Identifica el inmueble. No puede repetirse.</div>
                        </div>

                        <div class="col-sm-7">
                            <label class="form-label small fw-semibold" for="titulo">Titulo *</label>
                            <input class="form-control" id="titulo" name="titulo" type="text"
                                   maxlength="150" required
                                   value="<%= att(p == null ? "" : p.getTitulo()) %>">
                        </div>

                        <div class="col-12">
                            <label class="form-label small fw-semibold" for="descripcion">Descripcion</label>
                            <textarea class="form-control" id="descripcion" name="descripcion"
                                      rows="3"><%= att(p == null ? "" : p.getDescripcion()) %></textarea>
                        </div>

                        <div class="col-sm-6">
                            <label class="form-label small fw-semibold" for="idTipo">Tipo *</label>
                            <select class="form-select" id="idTipo" name="idTipo" required>
                                <option value="">Seleccione…</option>
<%  for (Map.Entry<Integer, String> e : tipos.entrySet()) { %>
                                <option value="<%= e.getKey() %>"<%= sel(p != null && p.getIdTipo() == e.getKey()) %>>
                                    <%= Html.esc(e.getValue()) %>
                                </option>
<%  } %>
                            </select>
                        </div>

                        <div class="col-sm-6">
                            <label class="form-label small fw-semibold" for="idCiudad">Ciudad *</label>
                            <select class="form-select" id="idCiudad" name="idCiudad" required>
                                <option value="">Seleccione…</option>
<%  for (Map.Entry<Integer, String> e : ciudades.entrySet()) { %>
                                <option value="<%= e.getKey() %>"<%= sel(p != null && p.getIdCiudad() == e.getKey()) %>>
                                    <%= Html.esc(e.getValue()) %>
                                </option>
<%  } %>
                            </select>
                        </div>

                        <div class="col-12">
                            <label class="form-label small fw-semibold" for="direccion">Direccion *</label>
                            <input class="form-control" id="direccion" name="direccion" type="text"
                                   maxlength="150" required
                                   value="<%= att(p == null ? "" : p.getDireccion()) %>">
                        </div>

                        <div class="col-sm-6">
                            <label class="form-label small fw-semibold" for="operacion">Operacion *</label>
                            <select class="form-select" id="operacion" name="operacion" required>
                                <option value="VENTA"<%= sel(p == null || "VENTA".equals(p.getOperacion())) %>>Venta</option>
                                <option value="ARRIENDO"<%= sel(p != null && "ARRIENDO".equals(p.getOperacion())) %>>Arriendo</option>
                            </select>
                        </div>

                        <div class="col-sm-6">
                            <label class="form-label small fw-semibold" for="estado">Estado *</label>
                            <select class="form-select" id="estado" name="estado" required>
                                <option value="DISPONIBLE"<%= sel(p == null || "DISPONIBLE".equals(p.getEstado())) %>>Disponible</option>
                                <option value="RESERVADA"<%= sel(p != null && "RESERVADA".equals(p.getEstado())) %>>Reservada</option>
                                <option value="VENDIDA"<%= sel(p != null && "VENDIDA".equals(p.getEstado())) %>>Vendida</option>
                                <option value="ARRENDADA"<%= sel(p != null && "ARRENDADA".equals(p.getEstado())) %>>Arrendada</option>
                            </select>
                        </div>

                        <div class="col-sm-6">
                            <label class="form-label small fw-semibold" for="precio">Precio (COP) *</label>
                            <div class="input-group">
                                <span class="input-group-text">$</span>
                                <input class="form-control" id="precio" name="precio" type="number"
                                       min="1" step="1000" required
                                       value="<%= p == null || p.getPrecio() == null ? "" : p.getPrecio().toPlainString() %>">
                            </div>
                        </div>

                        <div class="col-sm-6">
                            <label class="form-label small fw-semibold" for="areaM2">Area *</label>
                            <div class="input-group">
                                <input class="form-control" id="areaM2" name="areaM2" type="number"
                                       min="1" step="0.01" required
                                       value="<%= p == null || p.getAreaM2() == null ? "" : p.getAreaM2().toPlainString() %>">
                                <span class="input-group-text">m&sup2;</span>
                            </div>
                        </div>

                        <div class="col-4">
                            <label class="form-label small fw-semibold" for="habitaciones">Habitaciones</label>
                            <input class="form-control" id="habitaciones" name="habitaciones"
                                   type="number" min="0" value="<%= p == null ? 0 : p.getHabitaciones() %>">
                        </div>

                        <div class="col-4">
                            <label class="form-label small fw-semibold" for="banos">Banos</label>
                            <input class="form-control" id="banos" name="banos"
                                   type="number" min="0" value="<%= p == null ? 0 : p.getBanos() %>">
                        </div>

                        <div class="col-4">
                            <label class="form-label small fw-semibold" for="parqueaderos">Parqueaderos</label>
                            <input class="form-control" id="parqueaderos" name="parqueaderos"
                                   type="number" min="0" value="<%= p == null ? 0 : p.getParqueaderos() %>">
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- ============ Caracteristicas (N:M) ============ --%>
        <div class="col-lg-4">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-header bg-white fw-semibold">
                    Caracteristicas
                    <span class="text-secondary fw-normal small d-block">
                        Marque las que aplican y ajuste la cantidad
                    </span>
                </div>
                <div class="card-body">
<%  for (Caracteristica c : catalogo) {
        boolean marcada = (p != null && p.tieneCaracteristica(c.getId()));
        int cant = (p == null) ? 1 : p.cantidadDe(c.getId());
        if (cant < 1) cant = 1;
%>
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <div class="form-check flex-grow-1 mb-0">
                            <input class="form-check-input" type="checkbox"
                                   name="caracteristicas" value="<%= c.getId() %>"
                                   id="car<%= c.getId() %>"<%= chk(marcada) %>>
                            <label class="form-check-label small" for="car<%= c.getId() %>">
                                <%= Html.esc(c.getNombre()) %>
                            </label>
                        </div>
                        <%-- La cantidad se ata al id de la caracteristica y no a
                             la posicion: una casilla sin marcar no se envia, pero
                             su campo numerico si, y por posicion se desalinearian. --%>
                        <input class="form-control form-control-sm" style="width:72px"
                               type="number" name="cantidad_<%= c.getId() %>" min="1" max="99"
                               value="<%= cant %>" aria-label="Cantidad de <%= Html.esc(c.getNombre()) %>">
                    </div>
<%  } %>
                    <p class="text-secondary small mb-0 mt-3">
                        Indique cuantas unidades tiene de cada caracteristica marcada.
                    </p>
                </div>
            </div>
        </div>
    </div>

    <div class="d-flex gap-2 mt-4">
        <button class="btn btn-primary px-4" type="submit">
            <i class="bi bi-check-lg me-1"></i><%= esEdicion ? "Guardar cambios" : "Publicar inmueble" %>
        </button>
        <a class="btn btn-outline-secondary" href="<%= rutaGestion %>">Cancelar</a>
    </div>
</form>

<%-- ============ Galeria (1:N) - solo si el inmueble ya existe ============ --%>
<%  if (esEdicion) { %>
<div class="card border-0 shadow-sm mt-4">
    <div class="card-header bg-white fw-semibold">
        Galeria de imagenes
        <span class="text-secondary fw-normal small d-block">
            <%= p.totalImagenes() %> foto(s)
        </span>
    </div>
    <div class="card-body">

<%      if (!errorImagen.isEmpty()) { %>
        <div class="alert alert-danger py-2">
            <i class="bi bi-exclamation-triangle-fill me-2"></i><%= Html.esc(errorImagen) %>
        </div>
<%      } %>
        <form class="row g-2 align-items-end mb-4" method="post" action="<%= rutaGestion %>"
              enctype="multipart/form-data">
            <input type="hidden" name="accion" value="imagen-agregar">
            <input type="hidden" name="id" value="<%= p.getId() %>">
            <div class="col-sm">
                <label class="form-label small fw-semibold" for="archivo">Examinar imagen</label>
                <input class="form-control" id="archivo" name="archivo" type="file"
                       accept="image/png,image/jpeg,image/webp,image/gif" required>
                <div class="form-text">JPG, PNG, WEBP o GIF, hasta 5 MB.</div>
            </div>
            <div class="col-sm-auto">
                <button class="btn btn-outline-primary" type="submit">
                    <i class="bi bi-upload me-1"></i>Subir foto
                </button>
            </div>
        </form>

<%      if (p.getImagenes().isEmpty()) { %>
        <p class="text-secondary mb-0">
            Este inmueble no tiene fotos. La primera que agregue quedara como portada.
        </p>
<%      } else { %>
        <div class="row g-3">
<%          for (Imagen img : p.getImagenes()) { %>
            <div class="col-6 col-md-4 col-xl-3">
                <div class="card h-100 <%= img.isPortada() ? "border-primary border-2" : "" %>">
                    <img class="card-img-top" src="<%= ctx %>/<%= Html.esc(img.getUrl()) %>" alt=""
                         style="height:130px;object-fit:cover">
                    <div class="card-body p-2 d-flex flex-column gap-2">
<%              if (img.isPortada()) { %>
                        <span class="badge text-bg-primary w-100">
                            <i class="bi bi-star-fill me-1"></i>Portada
                        </span>
<%              } else { %>
                        <form method="post" action="<%= rutaGestion %>">
                            <input type="hidden" name="accion" value="imagen-portada">
                            <input type="hidden" name="id" value="<%= p.getId() %>">
                            <input type="hidden" name="idImagen" value="<%= img.getId() %>">
                            <button class="btn btn-sm btn-outline-secondary w-100" type="submit">
                                <i class="bi bi-star me-1"></i>Hacer portada
                            </button>
                        </form>
<%              } %>
                        <form method="post" action="<%= rutaGestion %>"
                              onsubmit="return confirm('Eliminar esta foto?')">
                            <input type="hidden" name="accion" value="imagen-eliminar">
                            <input type="hidden" name="id" value="<%= p.getId() %>">
                            <input type="hidden" name="idImagen" value="<%= img.getId() %>">
                            <button class="btn btn-sm btn-outline-danger w-100" type="submit">
                                <i class="bi bi-trash me-1"></i>Eliminar
                            </button>
                        </form>
                    </div>
                </div>
            </div>
<%          } %>
        </div>
<%      } %>
    </div>
</div>
<%  } else { %>
<p class="text-secondary small mt-3">
    Podra agregar fotos y administrar la galeria en cuanto publique el inmueble.
</p>
<%  } %>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
