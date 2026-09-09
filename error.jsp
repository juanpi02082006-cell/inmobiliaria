<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%--
    Pagina de error generica.

    El enunciado pide mensajes comprensibles para el usuario final en lugar de
    excepciones de Java. Esta pagina muestra un texto claro; el detalle tecnico
    queda en el log de Tomcat, donde lo necesita el desarrollador.
--%>
<%
    Object codigo = request.getAttribute("javax.servlet.error.status_code");
    Object ruta = request.getAttribute("javax.servlet.error.request_uri");

    String mensaje;
    if (codigo != null && "404".equals(codigo.toString())) {
        mensaje = "La pagina que busca no existe o fue movida.";
    } else {
        mensaje = "Ocurrio un problema al procesar su solicitud. "
                + "Si persiste, avise al administrador del sistema.";
    }

    String ctxError = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Error - Santander Raiz</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
</head>
<body class="bg-body-tertiary">

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-8 col-lg-6">
            <div class="card border-0 shadow-sm text-center">
                <div class="card-body p-5">
                    <i class="bi bi-exclamation-octagon text-warning" style="font-size:3.5rem"></i>

                    <h1 class="h3 mt-3">
                        <%= (codigo == null) ? "Error" : "Error " + codigo %>
                    </h1>

                    <p class="text-secondary"><%= mensaje %></p>

<%  if (ruta != null) { %>
                    <p class="small text-secondary mb-0">
                        Direccion solicitada: <code><%= ruta %></code>
                    </p>
<%  } %>

                    <a class="btn btn-primary mt-4" href="<%= ctxError %>/index.jsp">
                        Volver al inicio
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>
