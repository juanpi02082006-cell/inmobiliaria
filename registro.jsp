<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
    Formulario de registro.

    Lo procesa RegistroServlet (/registro), que crea en una sola transaccion
    la fila de usuario, la de perfil (1:1) y la de usuario_rol (N:M).

    Los campos obligatorios coinciden con las columnas NOT NULL de la tabla
    perfil. El documento se pide porque es UNIQUE y NOT NULL en el modelo.
--%>
<%
    request.setAttribute("titulo", "Crear cuenta");

    String error = (request.getAttribute("error") == null) ? "" : request.getAttribute("error").toString();

    // Se devuelve lo que el usuario ya habia escrito para no obligarlo a
    // llenar todo de nuevo. La contrasena nunca se repite en el HTML.
    String vNombres   = valor(request.getParameter("nombres"));
    String vApellidos = valor(request.getParameter("apellidos"));
    String vDocumento = valor(request.getParameter("documento"));
    String vEmail     = valor(request.getParameter("email"));
    String vTelefono  = valor(request.getParameter("telefono"));
    String vDireccion = valor(request.getParameter("direccion"));
%>
<%!
    /** Evita nulls y escapa las comillas para que no rompan el atributo value. */
    private String valor(String v) {
        if (v == null) {
            return "";
        }
        return v.replace("&", "&amp;").replace("\"", "&quot;")
                .replace("<", "&lt;").replace(">", "&gt;");
    }
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<div class="row justify-content-center">
    <div class="col-md-9 col-lg-7">
        <div class="card border-0 shadow-sm">
            <div class="card-body p-4 p-sm-5">

                <div class="text-center mb-4">
                    <i class="bi bi-person-plus text-primary" style="font-size:2.5rem"></i>
                    <h1 class="h4 mt-2 mb-1">Crear cuenta</h1>
                    <p class="text-secondary small mb-0">Se registrara con el rol CLIENTE.</p>
                </div>

<%  if (!error.isEmpty()) { %>
                <div class="alert alert-danger d-flex align-items-center" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>
                    <div><%= error %></div>
                </div>
<%  } %>

                <form action="<%= ctx %>/registro" method="post" novalidate>
                    <div class="row g-3">
                        <div class="col-sm-6">
                            <label class="form-label" for="nombres">Nombres *</label>
                            <input class="form-control" id="nombres" name="nombres" type="text"
                                   maxlength="60" value="<%= vNombres %>" required>
                        </div>

                        <div class="col-sm-6">
                            <label class="form-label" for="apellidos">Apellidos *</label>
                            <input class="form-control" id="apellidos" name="apellidos" type="text"
                                   maxlength="60" value="<%= vApellidos %>" required>
                        </div>

                        <div class="col-sm-6">
                            <label class="form-label" for="documento">Documento *</label>
                            <input class="form-control" id="documento" name="documento" type="text"
                                   inputmode="numeric" pattern="\d{6,20}" maxlength="20"
                                   value="<%= vDocumento %>" required>
                            <div class="form-text">Entre 6 y 20 digitos, sin puntos.</div>
                        </div>

                        <div class="col-sm-6">
                            <label class="form-label" for="telefono">Telefono</label>
                            <input class="form-control" id="telefono" name="telefono" type="tel"
                                   maxlength="20" value="<%= vTelefono %>">
                        </div>

                        <div class="col-12">
                            <label class="form-label" for="email">Correo electronico *</label>
                            <input class="form-control" id="email" name="email" type="email"
                                   maxlength="120" value="<%= vEmail %>" required>
                            <div class="form-text">Sera su usuario de ingreso. No puede repetirse.</div>
                        </div>

                        <div class="col-12">
                            <label class="form-label" for="direccion">Direccion</label>
                            <input class="form-control" id="direccion" name="direccion" type="text"
                                   maxlength="150" value="<%= vDireccion %>">
                        </div>

                        <div class="col-sm-6">
                            <label class="form-label" for="password">Contrasena *</label>
                            <input class="form-control" id="password" name="password" type="password"
                                   minlength="8" autocomplete="new-password" required>
                            <div class="form-text">Minimo 8 caracteres.</div>
                        </div>

                        <div class="col-sm-6">
                            <label class="form-label" for="password2">Repetir contrasena *</label>
                            <input class="form-control" id="password2" name="password2" type="password"
                                   minlength="8" autocomplete="new-password" required>
                        </div>
                    </div>

                    <button class="btn btn-primary w-100 mt-4" type="submit">Crear cuenta</button>
                </form>

                <p class="text-center text-secondary small mt-4 mb-0">
                    ¿Ya tiene cuenta?
                    <a href="<%= ctx %>/login.jsp">Inicie sesion</a>
                </p>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
