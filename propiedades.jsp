<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
    Ruta antigua del catalogo.

    El catalogo pasó a CatalogoServlet (/catalogo) para cumplir el patron MVC:
    la vista ya no consulta la base de datos. Esta pagina se conserva para que
    los enlaces guardados sigan funcionando y redirige conservando los filtros.
--%>
<%
    String consulta = request.getQueryString();
    String destino = request.getContextPath() + "/catalogo"
                   + ((consulta == null || consulta.isEmpty()) ? "" : "?" + consulta);

    response.setStatus(HttpServletResponse.SC_MOVED_PERMANENTLY);
    response.setHeader("Location", destino);
%>
