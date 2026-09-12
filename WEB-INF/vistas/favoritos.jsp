<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.modelo.Propiedad" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%--
    Mis favoritos (HU-08).

    Vive bajo WEB-INF: solo se llega por forward desde FavoritoServlet, que
    ya comprobo el rol CLIENTE.
--%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    List<Propiedad> favoritos = (List<Propiedad>) request.getAttribute("favoritos");
    String errorLista = (request.getAttribute("error") == null)
            ? "" : request.getAttribute("error").toString();

    NumberFormat pesos = NumberFormat.getCurrencyInstance(new Locale("es", "CO"));
    pesos.setMaximumFractionDigits(0);

    String rutaFavoritos = ctx + "/panel/cliente/favoritos";
%>

<div class="d-flex flex-wrap justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 mb-1">Mis favoritos</h1>
        <p class="text-secondary mb-0">Inmuebles guardados para consultarlos mas adelante.</p>
    </div>
    <a class="btn btn-outline-primary" href="<%= ctx %>/catalogo">
        <i class="bi bi-search me-1"></i>Buscar mas propiedades
    </a>
</div>

<%  if (!errorLista.isEmpty()) { %>
<div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorLista %></div>
<%  } %>

<%  if (favoritos == null || favoritos.isEmpty()) { %>
<div class="card border-0 shadow-sm">
    <div class="card-body text-center py-5">
        <i class="bi bi-heart text-secondary" style="font-size:2.5rem"></i>
        <h2 class="h5 mt-3">Todavia no ha guardado ningun favorito</h2>
        <p class="text-secondary">
            En la ficha de cada inmueble encontrara el boton "Guardar en favoritos".
        </p>
        <a class="btn btn-primary" href="<%= ctx %>/catalogo">Ver propiedades</a>
    </div>
</div>
<%  } else { %>
<div class="row g-4">
<%      for (Propiedad p : favoritos) { %>
    <div class="col-md-6 col-xl-4">
        <article class="card border-0 shadow-sm h-100 sr-tarjeta">
            <a class="text-decoration-none text-reset" href="<%= ctx %>/catalogo?id=<%= p.getId() %>">
                <div class="position-relative">
                    <img class="card-img-top sr-portada" src="<%= ctx %>/<%= p.getImagen() %>"
                         alt="<%= Html.esc(p.getTitulo()) %>">
                    <span class="badge fondo-sr position-absolute top-0 start-0 m-3">
                        EN <%= p.getOperacion() %>
                    </span>
                </div>
                <div class="card-body pb-0">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <span class="badge text-bg-light border"><%= Html.esc(p.getTipo()) %></span>
                        <span class="badge <%= "DISPONIBLE".equals(p.getEstado()) ? "text-bg-success" : "text-bg-secondary" %>">
                            <%= p.getEstado() %>
                        </span>
                    </div>
                    <h2 class="h6 fw-bold mb-1 text-reset"><%= Html.esc(p.getTitulo()) %></h2>
                    <p class="text-secondary small mb-2">
                        <i class="bi bi-geo-alt me-1"></i><%= Html.esc(p.getCiudad()) %> &middot; <%= Html.esc(p.getDireccion()) %>
                    </p>
                    <div class="fs-5 fw-bold"><%= pesos.format(p.getPrecio()) %></div>
                </div>
            </a>
            <div class="card-footer bg-white border-0 pt-2">
                <form method="post" action="<%= rutaFavoritos %>"
                      onsubmit="return confirm('Quitar este inmueble de sus favoritos?')">
                    <input type="hidden" name="accion" value="quitar">
                    <input type="hidden" name="idPropiedad" value="<%= p.getId() %>">
                    <input type="hidden" name="volver" value="<%= rutaFavoritos %>">
                    <button class="btn btn-outline-danger btn-sm w-100" type="submit">
                        <i class="bi bi-heart-fill me-1"></i>Quitar de favoritos
                    </button>
                </form>
            </div>
        </article>
    </div>
<%      } %>
</div>
<%  } %>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
