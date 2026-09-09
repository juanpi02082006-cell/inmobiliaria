<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
    Pagina de acceso denegado.

    Aqui aterriza quien intenta abrir una ruta privada escribiendo la URL a
    mano sin tener el rol necesario. La decision la tomo AutenticacionFilter
    en el servidor; esta pagina solo la explica.
--%>
<%
    request.setAttribute("titulo", "Acceso denegado");
    Object rutaSolicitada = request.getAttribute("rutaSolicitada");
    Object rolExigido = request.getAttribute("rolExigido");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<div class="row justify-content-center">
    <div class="col-lg-7">
        <div class="card border-0 shadow-sm text-center">
            <div class="card-body p-5">
                <i class="bi bi-shield-exclamation text-danger" style="font-size:3.5rem"></i>
                <h1 class="h3 mt-3">Acceso denegado</h1>

                <p class="text-secondary">
                    No tiene permisos para entrar a esta seccion.
                </p>

<%  if (rutaSolicitada != null) { %>
                <div class="alert alert-light border text-start small">
                    <div><strong>Ruta solicitada:</strong> <code><%= rutaSolicitada %></code></div>
<%      if (rolExigido != null) { %>
                    <div><strong>Rol requerido:</strong> <%= rolExigido %></div>
<%      } %>
<%      if (usuarioSesion != null) { %>
                    <div><strong>Su rol:</strong> <%= usuarioSesion.rolPrincipal() %></div>
<%      } %>
                </div>
<%  } %>

                <p class="text-secondary small">
                    La validacion se hizo en el servidor. Escribir la direccion
                    en la barra del navegador no salta el control.
                </p>

                <div class="d-flex gap-2 justify-content-center mt-4">
                    <a class="btn btn-primary" href="<%= ctx %>/index.jsp">Volver al inicio</a>
<%  if (usuarioSesion == null) { %>
                    <a class="btn btn-outline-secondary" href="<%= ctx %>/login.jsp">Iniciar sesion</a>
<%  } %>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
