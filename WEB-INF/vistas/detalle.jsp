<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.modelo.Caracteristica" %>
<%@ page import="com.inmobiliaria.modelo.Imagen" %>
<%@ page import="com.inmobiliaria.modelo.Propiedad" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%--
    Ficha de detalle de un inmueble.

    Publica: la ve tambien el visitante sin cuenta. Lo que se reserva a los
    usuarios autenticados son las acciones (agendar visita, favorito) y los
    datos de contacto completos de la agencia, tal como pide el enunciado.
--%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    Propiedad p = (Propiedad) request.getAttribute("propiedad");
    List<Propiedad> similares = (List<Propiedad>) request.getAttribute("similares");
    boolean esFavorito = Boolean.TRUE.equals(request.getAttribute("esFavorito"));

    NumberFormat pesos = NumberFormat.getCurrencyInstance(new Locale("es", "CO"));
    pesos.setMaximumFractionDigits(0);
%>

<%  if (p == null) { %>

<div class="row justify-content-center py-5">
    <div class="col-md-7 text-center">
        <i class="bi bi-house-slash text-secondary" style="font-size:3rem"></i>
        <h1 class="h4 mt-3">Este inmueble ya no esta disponible</h1>
        <p class="text-secondary">
            Puede que se haya vendido, arrendado o retirado del catalogo.
        </p>
        <a class="btn btn-primary mt-2" href="<%= ctx %>/catalogo">Ver otras propiedades</a>
    </div>
</div>

<%  } else { %>

<nav aria-label="Ruta" class="mb-3">
    <ol class="breadcrumb small mb-0">
        <li class="breadcrumb-item"><a href="<%= ctx %>/index.jsp">Inicio</a></li>
        <li class="breadcrumb-item"><a href="<%= ctx %>/catalogo">Propiedades</a></li>
        <li class="breadcrumb-item active"><%= Html.esc(p.getCiudad()) %></li>
    </ol>
</nav>

<div class="row g-4">

    <%-- ============ Galeria (relacion 1:N) ============ --%>
    <div class="col-lg-8">
<%      if (p.getImagenes().isEmpty()) { %>
        <img class="w-100 rounded-3" src="<%= ctx %>/<%= p.getImagen() %>" alt="<%= Html.esc(p.getTitulo()) %>"
             style="height:420px;object-fit:cover">
<%      } else { %>
        <div id="galeria" class="carousel slide rounded-3 overflow-hidden" data-bs-ride="false">
<%          if (p.totalImagenes() > 1) { %>
            <div class="carousel-indicators">
<%              for (int i = 0; i < p.totalImagenes(); i++) { %>
                <button type="button" data-bs-target="#galeria" data-bs-slide-to="<%= i %>"
                        <%= i == 0 ? "class=\"active\" aria-current=\"true\"" : "" %>
                        aria-label="Foto <%= i + 1 %>"></button>
<%              } %>
            </div>
<%          } %>

            <div class="carousel-inner">
<%          int idx = 0;
            for (Imagen img : p.getImagenes()) { %>
                <div class="carousel-item<%= idx == 0 ? " active" : "" %>">
                    <img class="d-block w-100" src="<%= ctx %>/<%= Html.esc(img.getUrl()) %>"
                         alt="<%= Html.esc(p.getTitulo()) %>" style="height:420px;object-fit:cover">
                </div>
<%              idx++;
            } %>
            </div>

<%          if (p.totalImagenes() > 1) { %>
            <button class="carousel-control-prev" type="button" data-bs-target="#galeria" data-bs-slide="prev">
                <span class="carousel-control-prev-icon"></span>
                <span class="visually-hidden">Anterior</span>
            </button>
            <button class="carousel-control-next" type="button" data-bs-target="#galeria" data-bs-slide="next">
                <span class="carousel-control-next-icon"></span>
                <span class="visually-hidden">Siguiente</span>
            </button>
<%          } %>
        </div>
        <p class="text-secondary small mt-2 mb-0">
            <i class="bi bi-images me-1"></i><%= p.totalImagenes() %> foto(s) en la galeria
        </p>
<%      } %>

        <%-- ============ Descripcion ============ --%>
        <div class="card border-0 shadow-sm mt-4">
            <div class="card-body">
                <h2 class="h5 mb-3">Descripcion</h2>
                <p class="mb-0 text-secondary">
                    <%= Html.esc((p.getDescripcion() == null || p.getDescripcion().isEmpty())
                        ? "Este inmueble aun no tiene una descripcion detallada."
                        : p.getDescripcion()) %>
                </p>
            </div>
        </div>

        <%-- ============ Caracteristicas (relacion N:M) ============ --%>
        <div class="card border-0 shadow-sm mt-4">
            <div class="card-body">
                <h2 class="h5 mb-3">Caracteristicas</h2>
<%      if (p.getCaracteristicas().isEmpty()) { %>
                <p class="text-secondary mb-0">Sin caracteristicas registradas.</p>
<%      } else { %>
                <div class="d-flex flex-wrap gap-2">
<%          for (Caracteristica c : p.getCaracteristicas()) { %>
                    <span class="badge text-bg-light border py-2 px-3">
                        <i class="bi bi-check2 texto-sr me-1"></i><%= Html.esc(c.getNombre()) %>
<%              if (c.getCantidad() > 1) { %>
                        <span class="text-secondary">&times;<%= c.getCantidad() %></span>
<%              } %>
                    </span>
<%          } %>
                </div>
<%      } %>
            </div>
        </div>
    </div>

    <%-- ============ Columna lateral ============ --%>
    <div class="col-lg-4">
        <div class="card border-0 shadow-sm sr-acceso position-sticky" style="top:1rem">
            <div class="card-body">

                <div class="d-flex justify-content-between align-items-start mb-2">
                    <span class="badge text-bg-light border"><%= Html.esc(p.getTipo()) %></span>
                    <span class="badge <%= "DISPONIBLE".equals(p.getEstado()) ? "text-bg-success" : "text-bg-secondary" %>">
                        <%= p.getEstado() %>
                    </span>
                </div>

                <h1 class="h4 mb-1"><%= Html.esc(p.getTitulo()) %></h1>
                <p class="text-secondary small mb-3">
                    <i class="bi bi-geo-alt me-1"></i><%= Html.esc(p.getCiudad()) %> &middot; <%= Html.esc(p.getDireccion()) %>
                </p>

                <div class="h3 fw-bold texto-sr mb-1"><%= pesos.format(p.getPrecio()) %></div>
                <p class="text-secondary small mb-3">
                    En <%= Html.esc(p.getOperacion().toLowerCase()) %> &middot; codigo <code><%= Html.esc(p.getCodigo()) %></code>
                </p>

                <div class="row g-2 text-center border-top border-bottom py-3 mb-3">
                    <div class="col-3">
                        <div class="fw-semibold"><%= p.getHabitaciones() %></div>
                        <div class="text-secondary" style="font-size:.72rem">Alcobas</div>
                    </div>
                    <div class="col-3">
                        <div class="fw-semibold"><%= p.getBanos() %></div>
                        <div class="text-secondary" style="font-size:.72rem">Banos</div>
                    </div>
                    <div class="col-3">
                        <div class="fw-semibold"><%= p.getParqueaderos() %></div>
                        <div class="text-secondary" style="font-size:.72rem">Parqueo</div>
                    </div>
                    <div class="col-3">
                        <div class="fw-semibold"><%= p.getAreaM2() %></div>
                        <div class="text-secondary" style="font-size:.72rem">m&sup2;</div>
                    </div>
                </div>

                <%-- El visitante ve la agencia, pero no sus datos de contacto --%>
                <div class="mb-3">
                    <div class="text-secondary" style="font-size:.72rem">PUBLICADO POR</div>
                    <div class="fw-semibold"><%= Html.esc(p.getInmobiliaria()) %></div>
                </div>

<%      if (usuarioSesion == null) { %>
                <a class="btn btn-primary w-100 mb-2" href="<%= ctx %>/login.jsp?motivo=sesion">
                    <i class="bi bi-calendar-check me-1"></i>Inicie sesion para agendar
                </a>
                <p class="text-secondary small text-center mb-0">
                    Cree una cuenta para agendar visitas, guardar favoritos y
                    ver los datos de contacto.
                </p>
<%      } else if (usuarioSesion.tieneRol("CLIENTE")) { %>
<%          if ("DISPONIBLE".equals(p.getEstado()) || "RESERVADA".equals(p.getEstado())) { %>
                <a class="btn btn-primary w-100 mb-2"
                   href="<%= ctx %>/panel/cliente/citas?accion=nueva&idPropiedad=<%= p.getId() %>">
                    <i class="bi bi-calendar-check me-1"></i>Agendar visita
                </a>
<%          } else { %>
                <button class="btn btn-primary w-100 mb-2" disabled>
                    <i class="bi bi-calendar-check me-1"></i>Ya no se puede visitar
                </button>
<%          } %>
                <form method="post" action="<%= ctx %>/panel/cliente/favoritos">
                    <input type="hidden" name="accion" value="<%= esFavorito ? "quitar" : "agregar" %>">
                    <input type="hidden" name="idPropiedad" value="<%= p.getId() %>">
                    <input type="hidden" name="volver" value="<%= ctx %>/catalogo?id=<%= p.getId() %>">
<%          if (esFavorito) { %>
                    <button class="btn btn-outline-danger w-100" type="submit">
                        <i class="bi bi-heart-fill me-1"></i>Quitar de favoritos
                    </button>
<%          } else { %>
                    <button class="btn btn-outline-primary w-100" type="submit">
                        <i class="bi bi-heart me-1"></i>Guardar en favoritos
                    </button>
<%          } %>
                </form>
<%      } else { %>
                <p class="text-secondary small text-center mb-0">
                    Las acciones sobre el inmueble (agendar visita, favoritos) son
                    para cuentas con rol CLIENTE.
                </p>
<%      } %>
            </div>
        </div>
    </div>
</div>

<%-- ============ Similares ============ --%>
<%      if (similares != null && !similares.isEmpty()) { %>
<section class="mt-5">
    <h2 class="h5 mb-3">Otros inmuebles que le pueden interesar</h2>
    <div class="row g-4">
<%          for (Propiedad s : similares) { %>
        <div class="col-md-4">
            <a class="text-decoration-none text-reset" href="<%= ctx %>/catalogo?id=<%= s.getId() %>">
                <article class="card border-0 shadow-sm h-100 sr-tarjeta">
                    <img class="card-img-top sr-portada" src="<%= ctx %>/<%= s.getImagen() %>" alt="">
                    <div class="card-body">
                        <p class="texto-sr text-uppercase small fw-semibold mb-1"><%= Html.esc(s.getTipo()) %></p>
                        <h3 class="h6 fw-bold mb-1"><%= Html.esc(s.getTitulo()) %></h3>
                        <p class="text-secondary small mb-2">
                            <i class="bi bi-geo-alt me-1"></i><%= Html.esc(s.getCiudad()) %>
                        </p>
                        <div class="fw-bold"><%= pesos.format(s.getPrecio()) %></div>
                    </div>
                </article>
            </a>
        </div>
<%          } %>
    </div>
</section>
<%      } %>

<%  } %>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
