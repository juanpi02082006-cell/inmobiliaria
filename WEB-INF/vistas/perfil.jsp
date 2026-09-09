<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.modelo.Perfil" %>
<%--
    Perfil del usuario.

    Muestra la relacion 1:1 tal como esta en el modelo: arriba la cuenta
    (tabla usuario, no editable aqui) y abajo los datos personales
    (tabla perfil, editables).
--%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    Perfil mi = (usuarioSesion == null) ? null : usuarioSesion.getPerfil();

    String errorPerfil = (request.getAttribute("error") == null)
            ? "" : String.valueOf(request.getAttribute("error"));
    String avisoPerfil = (request.getAttribute("aviso") == null)
            ? "" : String.valueOf(request.getAttribute("aviso"));

    // Si el guardado fallo, se conserva lo que el usuario acababa de escribir.
    String vNombres   = campo(request, "nombres",   mi == null ? "" : mi.getNombres());
    String vApellidos = campo(request, "apellidos", mi == null ? "" : mi.getApellidos());
    String vDocumento = campo(request, "documento", mi == null ? "" : mi.getDocumento());
    String vTelefono  = campo(request, "telefono",  mi == null ? "" : mi.getTelefono());
    String vDireccion = campo(request, "direccion", mi == null ? "" : mi.getDireccion());
%>
<%!
    private String campo(javax.servlet.http.HttpServletRequest req, String nombre, String actual) {
        String enviado = req.getParameter(nombre);
        String v = (enviado != null) ? enviado : (actual == null ? "" : actual);
        return v.replace("&", "&amp;").replace("\"", "&quot;")
                .replace("<", "&lt;").replace(">", "&gt;");
    }
%>

<div class="row justify-content-center">
    <div class="col-lg-9 col-xl-8">

        <h1 class="h3 mb-1">Mi perfil</h1>
        <p class="text-secondary mb-4">
            Sus datos personales y su contrasena.
        </p>

<%  if (!errorPerfil.isEmpty() && !"null".equals(errorPerfil)) { %>
        <div class="alert alert-danger">
            <i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorPerfil %>
        </div>
<%  } %>

<%  if (!avisoPerfil.isEmpty() && !"null".equals(avisoPerfil)) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle-fill me-2"></i><%= avisoPerfil %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
<%  } %>

        <%-- ============ La cuenta (tabla usuario) ============ --%>
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header bg-white fw-semibold">
                Cuenta
                <span class="text-secondary fw-normal small d-block">
                    Tabla <code>usuario</code> &middot; credenciales y estado
                </span>
            </div>
            <div class="card-body">
                <dl class="row mb-0 small">
                    <dt class="col-sm-3 text-secondary">Correo</dt>
                    <dd class="col-sm-9"><%= usuarioSesion.getCorreo() %></dd>

                    <dt class="col-sm-3 text-secondary">Roles</dt>
                    <dd class="col-sm-9">
<%  for (String r : usuarioSesion.getRoles()) { %>
                        <span class="badge text-bg-secondary"><%= r %></span>
<%  } %>
                    </dd>

                    <dt class="col-sm-3 text-secondary">Estado</dt>
                    <dd class="col-sm-9 mb-0">
                        <span class="badge text-bg-success">ACTIVA</span>
                    </dd>
                </dl>
                <p class="text-secondary small mb-0 mt-3">
                    El correo es su credencial de ingreso y solo lo puede cambiar
                    el administrador.
                </p>
            </div>
        </div>

        <%-- ============ Datos personales (tabla perfil, 1:1) ============ --%>
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header bg-white fw-semibold">
                Datos personales
                <span class="text-secondary fw-normal small d-block">
                    Tabla <code>perfil</code> &middot; relacion 1:1 con la cuenta
                </span>
            </div>
            <div class="card-body">
                <form method="post" action="<%= ctx %>/panel/perfil" novalidate>
                    <input type="hidden" name="accion" value="datos">

                    <div class="row g-3">
                        <div class="col-sm-6">
                            <label class="form-label small fw-semibold" for="nombres">Nombres *</label>
                            <input class="form-control" id="nombres" name="nombres" type="text"
                                   maxlength="60" required value="<%= vNombres %>">
                        </div>

                        <div class="col-sm-6">
                            <label class="form-label small fw-semibold" for="apellidos">Apellidos *</label>
                            <input class="form-control" id="apellidos" name="apellidos" type="text"
                                   maxlength="60" required value="<%= vApellidos %>">
                        </div>

                        <div class="col-sm-6">
                            <label class="form-label small fw-semibold" for="documento">Documento *</label>
                            <input class="form-control" id="documento" name="documento" type="text"
                                   inputmode="numeric" pattern="\d{6,20}" maxlength="20"
                                   required value="<%= vDocumento %>">
                            <div class="form-text">Unico en el sistema.</div>
                        </div>

                        <div class="col-sm-6">
                            <label class="form-label small fw-semibold" for="telefono">Telefono</label>
                            <input class="form-control" id="telefono" name="telefono" type="tel"
                                   maxlength="20" value="<%= vTelefono %>">
                        </div>

                        <div class="col-12">
                            <label class="form-label small fw-semibold" for="direccion">Direccion</label>
                            <input class="form-control" id="direccion" name="direccion" type="text"
                                   maxlength="150" value="<%= vDireccion %>">
                        </div>
                    </div>

                    <button class="btn btn-primary mt-4" type="submit">
                        <i class="bi bi-check-lg me-1"></i>Guardar datos
                    </button>
                </form>
            </div>
        </div>

        <%-- ============ Contrasena ============ --%>
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-white fw-semibold">Cambiar contrasena</div>
            <div class="card-body">
                <form method="post" action="<%= ctx %>/panel/perfil" novalidate>
                    <input type="hidden" name="accion" value="password">

                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label small fw-semibold" for="passwordActual">
                                Contrasena actual *
                            </label>
                            <input class="form-control" id="passwordActual" name="passwordActual"
                                   type="password" autocomplete="current-password" required>
                        </div>

                        <div class="col-sm-6">
                            <label class="form-label small fw-semibold" for="passwordNueva">
                                Nueva contrasena *
                            </label>
                            <input class="form-control" id="passwordNueva" name="passwordNueva"
                                   type="password" minlength="8" autocomplete="new-password" required>
                            <div class="form-text">Minimo 8 caracteres.</div>
                        </div>

                        <div class="col-sm-6">
                            <label class="form-label small fw-semibold" for="passwordRepetida">
                                Repetir la nueva *
                            </label>
                            <input class="form-control" id="passwordRepetida" name="passwordRepetida"
                                   type="password" minlength="8" autocomplete="new-password" required>
                        </div>
                    </div>

                    <button class="btn btn-outline-primary mt-4" type="submit">
                        <i class="bi bi-key me-1"></i>Cambiar contrasena
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
