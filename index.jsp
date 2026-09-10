<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.dao.PropiedadDAO" %>
<%@ page import="com.inmobiliaria.modelo.Propiedad" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%--
    Pagina de aterrizaje (landing page).

    Es publica: la recorre el visitante sin cuenta. Presenta la inmobiliaria,
    ofrece el buscador rapido y muestra las publicaciones destacadas, que se
    leen de la base de datos y no estan escritas a mano en el HTML.
--%>
<%
    request.setAttribute("titulo", "Santander Raiz - Inmuebles en Santander");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    PropiedadDAO catalogo = new PropiedadDAO();
    List<Propiedad> destacadas = catalogo.destacadas(6);
    List<String> ciudades = catalogo.ciudadesConPropiedades();
    List<String> tipos = catalogo.tiposConPropiedades();

    NumberFormat pesos = NumberFormat.getCurrencyInstance(new Locale("es", "CO"));
    pesos.setMaximumFractionDigits(0);

    boolean sesionCerrada = "cerrada".equals(request.getParameter("sesion"));
%>

<%-- Los estilos de la marca viven en css/santander-raiz.css, que carga la
     cabecera. Asi el login, el registro y los paneles usan la misma paleta. --%>

<%  if (sesionCerrada) { %>
<div class="alert alert-success alert-dismissible fade show" role="alert">
    <i class="bi bi-check-circle-fill me-2"></i>Su sesion se cerro correctamente.
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<%  } %>

<%-- ===================== Portada ===================== --%>
<section class="sr-hero rounded-4 d-flex align-items-center text-white mb-0">
    <div class="p-4 p-md-5" style="max-width:38rem">
        <p class="text-uppercase fw-semibold small mb-3" style="letter-spacing:.2em">
            Inmuebles en Santander
        </p>
        <h1 class="display-5 fw-bold mb-3">Encuentre su hogar ideal</h1>
        <p class="lead text-white-50 mb-4">
            Espacios pensados para su estilo de vida, con el respaldo de Santander Raiz.
        </p>
        <a class="btn btn-sr btn-lg px-4" href="#destacadas">Ver propiedades</a>
    </div>
</section>

<%-- ===================== Buscador rapido ===================== --%>
<section class="mx-3 mx-md-5" style="margin-top:-2.5rem;position:relative;z-index:5">
    <form class="card border-0 shadow-lg" action="<%= ctx %>/catalogo" method="get">
        <div class="card-body p-3 p-md-4">
            <div class="row g-2 align-items-end">
                <div class="col-6 col-lg-3">
                    <label class="form-label small fw-semibold" for="ciudadInicio">Ciudad</label>
                    <select class="form-select" id="ciudadInicio" name="ciudad">
                        <option value="">Todas</option>
<%  for (String c : ciudades) { %>
                        <option value="<%= Html.esc(c) %>"><%= Html.esc(c) %></option>
<%  } %>
                    </select>
                </div>

                <div class="col-6 col-lg-3">
                    <label class="form-label small fw-semibold" for="tipoInicio">Tipo</label>
                    <select class="form-select" id="tipoInicio" name="tipo">
                        <option value="">Todos</option>
<%  for (String t : tipos) { %>
                        <option value="<%= Html.esc(t) %>"><%= Html.esc(t) %></option>
<%  } %>
                    </select>
                </div>

                <div class="col-6 col-lg-2">
                    <label class="form-label small fw-semibold" for="minInicio">Desde</label>
                    <input class="form-control" id="minInicio" name="minPrecio" type="number"
                           min="0" step="1000000" placeholder="$">
                </div>

                <div class="col-6 col-lg-2">
                    <label class="form-label small fw-semibold" for="maxInicio">Hasta</label>
                    <input class="form-control" id="maxInicio" name="maxPrecio" type="number"
                           min="0" step="1000000" placeholder="$">
                </div>

                <div class="col-12 col-lg-2 d-grid">
                    <button class="btn btn-sr" type="submit">
                        <i class="bi bi-search me-1"></i>Buscar
                    </button>
                </div>
            </div>
        </div>
    </form>
</section>

<%-- ===================== Destacadas ===================== --%>
<section id="destacadas" class="py-5">
    <div class="mb-4">
        <p class="texto-sr text-uppercase fw-semibold small mb-1" style="letter-spacing:.18em">
            Seleccion especial
        </p>
        <h2 class="fw-bold">Inmuebles destacados</h2>
        <p class="text-secondary mb-0">
            Publicaciones disponibles, tomadas directamente del catalogo.
        </p>
    </div>

<%  if (destacadas.isEmpty()) { %>
    <div class="alert alert-warning">
        Por ahora no hay propiedades disponibles publicadas.
    </div>
<%  } else { %>
    <div class="row g-4">
<%      for (Propiedad p : destacadas) { %>
        <div class="col-md-6 col-xl-4">
            <a class="text-decoration-none text-reset" href="<%= ctx %>/catalogo?id=<%= p.getId() %>">
            <article class="card border-0 shadow-sm h-100 sr-tarjeta">
                <div class="position-relative">
                    <img class="card-img-top sr-portada" src="<%= ctx %>/<%= p.getImagen() %>"
                         alt="<%= Html.esc(p.getTitulo()) %>">
                    <span class="badge fondo-sr position-absolute top-0 start-0 m-3">
                        EN <%= p.getOperacion() %>
                    </span>
                </div>

                <div class="card-body d-flex flex-column">
                    <p class="texto-sr text-uppercase small fw-semibold mb-1"><%= Html.esc(p.getTipo()) %></p>
                    <h3 class="h6 fw-bold mb-1"><%= Html.esc(p.getTitulo()) %></h3>
                    <p class="text-secondary small mb-3">
                        <i class="bi bi-geo-alt me-1"></i><%= Html.esc(p.getCiudad()) %> &middot; <%= Html.esc(p.getDireccion()) %>
                    </p>

                    <div class="fs-5 fw-bold mb-3"><%= pesos.format(p.getPrecio()) %></div>

                    <ul class="list-inline small text-secondary border-top pt-3 mb-0 mt-auto">
                        <li class="list-inline-item me-3"><i class="bi bi-door-closed me-1"></i><%= p.getHabitaciones() %> hab.</li>
                        <li class="list-inline-item me-3"><i class="bi bi-droplet me-1"></i><%= p.getBanos() %> banos</li>
                        <li class="list-inline-item"><i class="bi bi-rulers me-1"></i><%= p.getAreaM2() %> m&sup2;</li>
                    </ul>
                </div>
            </article>
            </a>
        </div>
<%      } %>
    </div>

    <div class="text-center mt-4">
        <a class="btn btn-outline-secondary" href="<%= ctx %>/catalogo">
            Ver todo el catalogo <i class="bi bi-arrow-right ms-1"></i>
        </a>
    </div>
<%  } %>
</section>

<%-- ===================== Nosotros ===================== --%>
<section id="nosotros" class="py-5 border-top">
    <div class="row g-4 align-items-center">
        <div class="col-lg-6">
            <img class="img-fluid rounded-4 shadow-sm" src="<%= ctx %>/img/bucaramanga.jpg"
                 alt="Bucaramanga y Santander" style="height:340px;width:100%;object-fit:cover">
        </div>

        <div class="col-lg-6">
            <p class="texto-sr text-uppercase fw-semibold small mb-1" style="letter-spacing:.18em">
                Sobre nosotros
            </p>
            <h2 class="fw-bold mb-3">Su confianza es nuestra mejor propiedad</h2>
            <p class="text-secondary mb-4">
                Somos una inmobiliaria especializada en conectar personas con espacios
                que mejoran su calidad de vida, con asesoria cercana y transparente.
            </p>

            <div class="row text-center g-3">
                <div class="col-4">
                    <div class="h3 fw-bold texto-sr mb-0"><%= destacadas.size() %>+</div>
                    <div class="small text-secondary">Publicaciones</div>
                </div>
                <div class="col-4">
                    <div class="h3 fw-bold texto-sr mb-0"><%= ciudades.size() %></div>
                    <div class="small text-secondary">Ciudades</div>
                </div>
                <div class="col-4">
                    <div class="h3 fw-bold texto-sr mb-0"><%= tipos.size() %></div>
                    <div class="small text-secondary">Tipos de inmueble</div>
                </div>
            </div>
        </div>
    </div>
</section>

<%-- ===================== Llamado a la accion ===================== --%>
<%  if (usuarioSesion == null) { %>
<section class="fondo-sr text-white text-center rounded-4 p-5 mb-4">
    <h2 class="fw-bold mb-3">Encuentre su proximo hogar</h2>
    <p class="text-white-50 mx-auto mb-4" style="max-width:38rem">
        Registrese para guardar favoritos, agendar visitas y seguir sus solicitudes.
    </p>
    <a class="btn btn-light btn-lg px-4 fw-semibold" href="<%= ctx %>/registro.jsp">
        Crear cuenta
    </a>
</section>
<%  } %>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
