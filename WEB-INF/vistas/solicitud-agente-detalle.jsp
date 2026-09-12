<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.inmobiliaria.modelo.DocumentoSolicitud" %>
<%@ page import="com.inmobiliaria.modelo.Solicitud" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%--
    Detalle de una solicitud para que el agente la resuelva (HU-11).

    Vive bajo WEB-INF: solo se llega por forward desde SolicitudAgenteServlet,
    que ya comprobo que la solicitud cae sobre una propiedad de su agencia.
--%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    Solicitud s = (Solicitud) request.getAttribute("solicitud");
    String ok = (request.getParameter("ok") == null) ? "" : request.getParameter("ok");
    String errorParam = (request.getParameter("error") == null) ? "" : request.getParameter("error");
    String rutaGestion = ctx + "/panel/inmobiliaria/solicitudes";

    SimpleDateFormat fecha = new SimpleDateFormat("dd/MM/yyyy hh:mm a");
    NumberFormat pesos = NumberFormat.getCurrencyInstance(new Locale("es", "CO"));
    pesos.setMaximumFractionDigits(0);
%>

<%  if (s == null) { %>
<div class="alert alert-warning">Esta solicitud ya no existe.</div>
<%  } else { %>

<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
    <div>
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
        String texto = "revision".equals(ok)  ? "La solicitud quedo en revision."
                     : "aprobada".equals(ok)  ? "La solicitud fue aprobada."
                     : "rechazada".equals(ok) ? "La solicitud fue rechazada."
                     : "documento".equals(ok) ? "El documento quedo evaluado."
                     : "Operacion realizada.";
%>
<div class="alert alert-success alert-dismissible fade show">
    <i class="bi bi-check-circle-fill me-2"></i><%= texto %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<%  } %>

<%  if ("resuelta".equals(errorParam)) { %>
<div class="alert alert-warning">
    <i class="bi bi-exclamation-triangle-fill me-2"></i>Esta solicitud ya fue resuelta; no admite mas cambios.
</div>
<%  } %>

<div class="row g-4">
    <div class="col-lg-7">
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-white fw-semibold">
                Documentos radicados
                <span class="text-secondary fw-normal small d-block">
                    Evalue cada uno antes de resolver la solicitud
                </span>
            </div>
            <div class="card-body">
<%          if (s.getDocumentos().isEmpty()) { %>
                <p class="text-secondary mb-0">El cliente todavia no ha radicado documentos.</p>
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
                                    <div class="text-secondary small"><%= Html.esc(d.getUrl()) %></div>
                                </td>
                                <td>
                                    <span class="badge <%= "ACEPTADO".equals(d.getEstado()) ? "text-bg-success"
                                                          : "RECHAZADO".equals(d.getEstado()) ? "text-bg-danger"
                                                          : "text-bg-secondary" %>">
                                        <%= d.getEstado() %>
                                    </span>
                                </td>
                                <td class="text-end text-nowrap">
<%                  if (s.esGestionable()) { %>
                                    <form class="d-inline" method="post" action="<%= rutaGestion %>">
                                        <input type="hidden" name="accion" value="documento-aceptar">
                                        <input type="hidden" name="idSolicitud" value="<%= s.getId() %>">
                                        <input type="hidden" name="idDocumento" value="<%= d.getId() %>">
                                        <button class="btn btn-sm btn-outline-success" type="submit" title="Aceptar">
                                            <i class="bi bi-check-lg"></i>
                                        </button>
                                    </form>
                                    <form class="d-inline" method="post" action="<%= rutaGestion %>">
                                        <input type="hidden" name="accion" value="documento-rechazar">
                                        <input type="hidden" name="idSolicitud" value="<%= s.getId() %>">
                                        <input type="hidden" name="idDocumento" value="<%= d.getId() %>">
                                        <button class="btn btn-sm btn-outline-danger" type="submit" title="Rechazar">
                                            <i class="bi bi-x-lg"></i>
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
            <div class="card-header bg-white fw-semibold">Cliente y estado</div>
            <div class="card-body">
                <div class="mb-3">
                    <div class="text-secondary small text-uppercase">Cliente</div>
                    <div class="fw-semibold"><%= Html.esc(s.getClienteNombre()) %></div>
                    <div class="text-secondary small"><%= Html.esc(s.getClienteCorreo()) %></div>
                </div>

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

<%          if (s.esGestionable()) { %>
                <hr>
                <div class="d-grid gap-2">
<%              if ("RADICADA".equals(s.getEstado())) { %>
                    <form method="post" action="<%= rutaGestion %>">
                        <input type="hidden" name="accion" value="revisar">
                        <input type="hidden" name="idSolicitud" value="<%= s.getId() %>">
                        <button class="btn btn-outline-secondary w-100" type="submit">
                            <i class="bi bi-hourglass-split me-1"></i>Poner en revision
                        </button>
                    </form>
<%              } %>
                    <form method="post" action="<%= rutaGestion %>"
                          onsubmit="return confirm('Aprobar esta solicitud? La decision no se puede deshacer.')">
                        <input type="hidden" name="accion" value="aprobar">
                        <input type="hidden" name="idSolicitud" value="<%= s.getId() %>">
                        <button class="btn btn-success w-100" type="submit">
                            <i class="bi bi-check-lg me-1"></i>Aprobar
                        </button>
                    </form>
                    <form method="post" action="<%= rutaGestion %>"
                          onsubmit="return confirm('Rechazar esta solicitud? La decision no se puede deshacer.')">
                        <input type="hidden" name="accion" value="rechazar">
                        <input type="hidden" name="idSolicitud" value="<%= s.getId() %>">
                        <button class="btn btn-outline-danger w-100" type="submit">
                            <i class="bi bi-x-lg me-1"></i>Rechazar
                        </button>
                    </form>
                </div>
<%          } else { %>
                <hr>
                <p class="text-secondary small mb-0">Esta solicitud ya fue resuelta.</p>
<%          } %>
            </div>
        </div>
    </div>
</div>

<%  } %>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
