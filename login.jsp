<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
    Formulario de inicio de sesion.

    El procesamiento lo hace LoginServlet (/login); esta pagina solo pinta el
    formulario y muestra los mensajes que el servlet deja en la peticion.
--%>
<%
    request.setAttribute("titulo", "Iniciar sesion");

    // El correo puede venir del servlet (reintento tras un error) o del query string.
    String correoPrevio = "";
    if (request.getAttribute("email") != null) {
        correoPrevio = request.getAttribute("email").toString();
    } else if (request.getParameter("email") != null) {
        correoPrevio = request.getParameter("email");
    }

    String error = (request.getAttribute("error") == null) ? "" : request.getAttribute("error").toString();

    String aviso = "";
    if ("1".equals(request.getParameter("success"))) {
        aviso = "Registro exitoso. Ya puede iniciar sesion.";
    } else if ("sesion".equals(request.getParameter("motivo"))) {
        aviso = "Debe iniciar sesion para entrar a esa seccion.";
    }
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<div class="row justify-content-center">
    <div class="col-md-7 col-lg-5">
        <div class="card border-0 shadow-sm">
            <div class="card-body p-4 p-sm-5">

                <div class="text-center mb-4">
                    <i class="bi bi-person-circle text-primary" style="font-size:2.5rem"></i>
                    <h1 class="h4 mt-2 mb-1">Iniciar sesion</h1>
                    <p class="text-secondary small mb-0">Acceda a su espacio en Santander Raiz.</p>
                </div>

<%  if (!error.isEmpty()) { %>
                <div class="alert alert-danger d-flex align-items-center" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>
                    <div><%= error %></div>
                </div>
<%  } %>

<%  if (!aviso.isEmpty()) { %>
                <div class="alert alert-success d-flex align-items-center" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i>
                    <div><%= aviso %></div>
                </div>
<%  } %>

                <form action="<%= ctx %>/login" method="post" novalidate>
                    <div class="mb-3">
                        <label class="form-label" for="email">Correo electronico</label>
                        <input class="form-control" id="email" name="email" type="email"
                               autocomplete="email" value="<%= correoPrevio %>" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="password">Contrasena</label>
                        <input class="form-control" id="password" name="password" type="password"
                               autocomplete="current-password" required>
                    </div>

                    <button class="btn btn-primary w-100" type="submit">Entrar</button>
                </form>

                <p class="text-center text-secondary small mt-4 mb-0">
                    ¿No tiene cuenta?
                    <a href="<%= ctx %>/registro.jsp">Registrese aqui</a>
                </p>
            </div>
        </div>

        <div class="alert alert-light border mt-3 small mb-0">
            <strong>Usuarios de prueba</strong> (todos con la contrasena <code>password</code>):
            <ul class="mb-0 mt-1">
                <li><code>admin@inmobiliaria.com</code> &rarr; ADMIN</li>
                <li><code>agente.norte@sraiz.com</code> &rarr; INMOBILIARIA</li>
                <li><code>carlos.perez@gmail.com</code> &rarr; CLIENTE</li>
            </ul>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
