<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.modelo.DocumentoSolicitud" %>
<%@ page import="com.inmobiliaria.modelo.Solicitud" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%--
    Detalle de una solicitud y sus documentos radicados (HU-10).

    Vive bajo WEB-INF: solo se llega por forward desde SolicitudClienteServlet,
    que ya comprobo que la solicitud es del cliente en sesion.
--%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    Solicitud s = (Solicitud) request.getAttribute("solicitud");
    String ok = (request.getParameter("ok") == null) ? "" : request.getParameter("ok");
    String errorParam = (request.getParameter("error") == null) ? "" : request.getParameter("error");

    SimpleDateFormat fecha = new SimpleDateFormat("dd/MM/yyyy hh:mm a");
    NumberFormat pesos = NumberFormat.getCurrencyInstance(new Locale("es", "CO"));
    pesos.setMaximumFractionDigits(0);

    String rutaGestion = ctx + "/panel/cliente/solicitudes";
%>

<%  if (s == null) { %>
<div class="alert alert-warning">Esta solicitud ya no existe.</div>
<%  } else { %>

<div class="d-flex flex-wrap align-items-center gap-3 mb-4">
    <span class="sr-marca-icono-sm"><i class="bi bi-file-earmark-text"></i></span>
    <div class="flex-grow-1">
        <h1 class="h3 mb-1">Solicitud de <%= "COMPRA".equals(s.getTipo()) ? "compra" : "arriendo" %></h1>
        <p class="text-secondary mb-0">
            <%= Html.esc(s.getPropiedadTitulo()) %> &middot; <code><%= Html.esc(s.getPropiedadMatricula()) %></code>
        </p>
    </div>
    <a class="btn btn-outline-secondary" href="<%= rutaGestion %>">
        <i class="bi bi-arrow-left me-1"></i>Volver al listado
    </a>
</div>

<%  if (!ok.isEmpty()) {
        String texto = "radicada".equals(ok)      ? "Solicitud radicada. Ya puede agregar sus documentos."
                     : "documento".equals(ok)      ? "Documento subido."
                     : "documento-fuera".equals(ok) ? "Documento retirado."
                     : "Operacion realizada.";
%>
<div class="alert alert-success alert-dismissible fade show">
    <i class="bi bi-check-circle-fill me-2"></i><%= texto %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<%  } %>

<%  if (!errorParam.isEmpty()) {
        String texto = "documento".equals(errorParam)          ? "Indique que documento esta subiendo."
                     : "documento-largo".equals(errorParam)     ? "El nombre del documento es demasiado largo."
                     : "archivo-grande".equals(errorParam)      ? "El documento no puede superar los 5 MB."
                     : "documento-evaluado".equals(errorParam)  ? "Ese documento ya fue evaluado por la agencia y no se puede retirar."
                     : "resuelta".equals(errorParam)            ? "La solicitud ya fue resuelta; no admite mas cambios en sus documentos."
                     : "sin-archivo".equals(errorParam)         ? "Ese documento no tiene un archivo disponible."
                     : "No fue posible completar la operacion.";
%>
<div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i><%= texto %></div>
<%  } %>

<%-- El motivo por el que se rechazo el archivo lo redacta ArchivoUtil; viaja por la URL, asi que se escapa. --%>
<%  if (request.getParameter("errorArchivo") != null) { %>
<div class="alert alert-danger">
    <i class="bi bi-exclamation-triangle-fill me-2"></i><%= Html.esc(request.getParameter("errorArchivo")) %>
</div>
<%  } %>

<div class="row g-4">
    <div class="col-lg-7">
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-white fw-semibold">
                Documentos radicados
            </div>
            <div class="card-body">

<%          if (s.esGestionable()) { %>
                <%-- accion e idSolicitud van en la URL y no en campos ocultos: si el archivo
                     pasa del limite, Tomcat descarta el cuerpo y solo la URL sigue llegando. --%>
                <form class="row g-2 align-items-end mb-4" method="post" enctype="multipart/form-data"
                      action="<%= rutaGestion %>?accion=documento-agregar&amp;idSolicitud=<%= s.getId() %>">
                    <div class="col-sm-5">
                        <label class="form-label small fw-semibold" for="nombre">Documento</label>
                        <input class="form-control" id="nombre" name="nombre" type="text"
                               maxlength="120" placeholder="Cedula, carta laboral..." required>
                    </div>
                    <div class="col-sm">
                        <label class="form-label small fw-semibold" for="archivo">Archivo</label>
                        <input class="form-control" id="archivo" name="archivo" type="file"
                               accept="application/pdf,image/jpeg,image/png" required>
                        <div class="form-text">PDF, JPG o PNG, hasta 5 MB. Solo usted y la agencia pueden verlo.</div>
                    </div>
                    <div class="col-sm-auto">
                        <button class="btn btn-outline-primary" type="submit">
                            <i class="bi bi-upload me-1"></i>Subir
                        </button>
                    </div>
                </form>
<%          } %>

<%          if (s.getDocumentos().isEmpty()) { %>
                <p class="text-secondary mb-0">Todavia no ha radicado ningun documento.</p>
<%          } else { %>
                <div class="table-responsive">
                    <table class="table table-sm align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Documento</th>
                                <th>Estado</th>
                                <th class="text-end">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
<%              for (DocumentoSolicitud d : s.getDocumentos()) { %>
                            <tr>
                                <td>
                                    <div class="fw-semibold"><%= Html.esc(d.getNombre()) %></div>
<%                  if (d.tieneArchivo()) { %>
                                    <a class="small" target="_blank" rel="noopener"
                                       href="<%= rutaGestion %>?accion=documento&amp;id=<%= s.getId() %>&amp;idDocumento=<%= d.getId() %>">
                                        <i class="bi bi-box-arrow-up-right me-1"></i>Ver archivo
                                    </a>
<%                  } else { %>
                                    <div class="text-secondary small">Sin archivo adjunto</div>
<%                  } %>
                                </td>
                                <td>
                                    <span class="badge <%= "ACEPTADO".equals(d.getEstado()) ? "text-bg-success"
                                                          : "RECHAZADO".equals(d.getEstado()) ? "text-bg-danger"
                                                          : "text-bg-secondary" %>">
                                        <%= d.getEstado() %>
                                    </span>
                                </td>
                                <td class="text-end">
<%                  if (s.esGestionable() && "PENDIENTE".equals(d.getEstado())) { %>
                                    <form method="post" action="<%= rutaGestion %>"
                                          onsubmit="return confirm('Quitar este documento?')">
                                        <input type="hidden" name="accion" value="documento-eliminar">
                                        <input type="hidden" name="idSolicitud" value="<%= s.getId() %>">
                                        <input type="hidden" name="idDocumento" value="<%= d.getId() %>">
                                        <button class="btn btn-sm btn-outline-danger" type="submit">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </form>
<%                  } else { %>
                                    <span class="text-secondary small">&mdash;</span>
<%                  } %>
                                </td>
                            </tr>
<%              } %>
                        </tbody>
                    </table>
                </div>
<%          } %>
            </div>
        </div>
    </div>

    <div class="col-lg-5">
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-white fw-semibold">Estado de la solicitud</div>
            <div class="card-body">
                <span class="badge fs-6 <%= "RADICADA".equals(s.getEstado()) ? "text-bg-warning"
                                          : "EN_REVISION".equals(s.getEstado()) ? "text-bg-info"
                                          : "APROBADA".equals(s.getEstado()) ? "text-bg-success"
                                          : "text-bg-danger" %>">
                    <%= s.getEstado() %>
                </span>

                <dl class="row mt-3 mb-0 small">
                    <dt class="col-6">Radicada el</dt>
                    <dd class="col-6"><%= fecha.format(s.getFechaRadicacion()) %></dd>

<%          if (s.getFechaResolucion() != null) { %>
                    <dt class="col-6">Resuelta el</dt>
                    <dd class="col-6"><%= fecha.format(s.getFechaResolucion()) %></dd>
<%          } %>

<%          if (s.getOferta() != null) { %>
                    <dt class="col-6"><%= "COMPRA".equals(s.getTipo()) ? "Oferta" : "Canon ofrecido" %></dt>
                    <dd class="col-6"><%= pesos.format(s.getOferta()) %></dd>
<%          } %>
                </dl>

<%          if (s.getComentario() != null && !s.getComentario().isEmpty()) { %>
                <hr>
                <p class="text-secondary small mb-0 fst-italic">"<%= Html.esc(s.getComentario()) %>"</p>
<%          } %>

<%          if (!s.esGestionable()) { %>
                <hr>
                <p class="text-secondary small mb-0">
                    La agencia ya tomo una decision. Si quiere volver a intentarlo, radique
                    una nueva solicitud desde la ficha del inmueble.
                </p>
<%          } %>
            </div>
        </div>
    </div>
</div>

<%  } %>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
