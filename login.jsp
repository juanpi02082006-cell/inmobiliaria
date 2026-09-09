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

<div class="row justify-content-center py-lg-4">
    <div class="col-md-8 col-lg-5 col-xl-4">

        <div class="card border-0 shadow-sm sr-acceso">
            <div class="card-body p-4 p-sm-5">

                <div class="text-center mb-4">
                    <span class="sr-marca-icono mb-3">
                        <i class="bi bi-house-lock"></i>
                    </span>
                    <h1 class="h4 mb-1">Iniciar sesion</h1>
                    <p class="text-secondary small mb-0">Acceda a su espacio en Santander Raiz.</p>
                </div>

<%  if (!error.isEmpty()) { %>
                <div class="alert alert-danger d-flex align-items-start gap-2 py-2" role="alert">
                    <i class="bi bi-exclamation-triangle-fill mt-1"></i>
                    <div class="small"><%= error %></div>
                </div>
<%  } %>

<%  if (!aviso.isEmpty()) { %>
                <div class="alert alert-success d-flex align-items-start gap-2 py-2" role="alert">
                    <i class="bi bi-check-circle-fill mt-1"></i>
                    <div class="small"><%= aviso %></div>
                </div>
<%  } %>

                <form action="<%= ctx %>/login" method="post" novalidate>
                    <div class="mb-3">
                        <label class="form-label small fw-semibold" for="email">Correo electronico</label>
                        <div class="input-group">
                            <span class="input-group-text bg-body-tertiary">
                                <i class="bi bi-envelope text-secondary"></i>
                            </span>
                            <input class="form-control" id="email" name="email" type="email"
                                   autocomplete="email" placeholder="usuario@correo.com"
                                   value="<%= correoPrevio %>" required autofocus>
                        </div>
                    </div>

                    <div class="mb-4">
                        <label class="form-label small fw-semibold" for="password">Contrasena</label>
                        <div class="input-group">
                            <span class="input-group-text bg-body-tertiary">
                                <i class="bi bi-key text-secondary"></i>
                            </span>
                            <input class="form-control" id="password" name="password" type="password"
                                   autocomplete="current-password" placeholder="Su contrasena" required>
                        </div>
                    </div>

                    <button class="btn btn-primary w-100 py-2 fw-semibold" type="submit">
                        <i class="bi bi-box-arrow-in-right me-1"></i>Entrar
                    </button>
                </form>

                <div class="sr-separador my-4">o</div>

                <a class="btn btn-outline-primary w-100" href="<%= ctx %>/registro.jsp">
                    Crear una cuenta nueva
                </a>
            </div>
        </div>

        <div class="sr-demo rounded-3 mt-3 p-3 small">
            <div class="fw-semibold texto-sr mb-2">
                <i class="bi bi-info-circle me-1"></i>Usuarios de prueba
            </div>
            <div class="d-flex justify-content-between align-items-center py-1">
                <code>admin@inmobiliaria.com</code>
                <span class="badge text-bg-danger">ADMIN</span>
            </div>
            <div class="d-flex justify-content-between align-items-center py-1">
                <code>agente.norte@sraiz.com</code>
                <span class="badge text-bg-primary">INMOBILIARIA</span>
            </div>
            <div class="d-flex justify-content-between align-items-center py-1">
                <code>carlos.perez@gmail.com</code>
                <span class="badge text-bg-success">CLIENTE</span>
            </div>
            <div class="text-secondary mt-2 pt-2 border-top">
                Todos con la contrasena <code>password</code>
            </div>
        </div>

        <p class="text-center mt-3 mb-0">
            <a class="text-secondary small text-decoration-none" href="<%= ctx %>/index.jsp">
                <i class="bi bi-arrow-left me-1"></i>Volver a la pagina principal
            </a>
        </p>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
