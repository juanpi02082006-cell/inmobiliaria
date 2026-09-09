# Sprint 2 — Núcleo del negocio

**Proyecto:** Santander Raíz — Sistema web de inmobiliaria
**Asignatura:** Programación Java — UTS
**Product Owner:** Docente Julián Barney Jaimes Rincón
**Duración:** 7 días

---

## 1. Sprint Planning

### Objetivo del sprint

> Poner en marcha el negocio: que el agente pueda administrar su catálogo de
> verdad —crear, editar y retirar inmuebles, con sus fotos y características—
> y que cada rol tenga por fin algo que hacer en su panel.

Al cierre del sprint, las tres relaciones que el modelo declara deben poder
*ejercitarse desde la interfaz*, no solo existir en el esquema.

### Historias de usuario comprometidas

| # | Historia | Prioridad | Estimación | Estado |
|---|----------|-----------|------------|--------|
| HU-06 | Como agente, quiero registrar y editar propiedades con fotos, características y precio para mantener el catálogo actualizado. | Alta | 13 pts | Hecha |
| HU-07 | Como cliente, quiero buscar y filtrar propiedades por ciudad, tipo, precio y características para encontrar las que se ajusten a mis necesidades. | Alta | 5 pts | Hecha |
| HU-04 | Como administrador, quiero asignar y revocar roles a los usuarios para controlar los permisos de la aplicación. | Alta | 8 pts | Hecha |
| HU-05 | Como cliente, quiero completar mi perfil con documento, teléfono y dirección para agilizar mis trámites. | Media | 5 pts | Hecha |
| HU-17 | Como visitante, quiero ver la ficha completa de un inmueble con su galería y características antes de decidir. | Alta | 5 pts | Hecha |
| HU-18 | Como administrador, quiero activar e inactivar cuentas para controlar quién entra al sistema. | Media | 3 pts | Hecha |
| HU-19 | Como administrador, quiero parametrizar ciudades y características desde la aplicación. | Baja | 5 pts | **No hecha** |

**Comprometido:** 44 puntos. **Completado:** 39. **Arrastrado al Sprint 3:** 5.

### Criterios de aceptación (Definition of Done)

**HU-06 — CRUD de propiedades**
- [x] Alta, edición y baja lógica desde la interfaz.
- [x] Validación en el servidor, no solo en el navegador.
- [x] La matrícula repetida muestra un mensaje claro, nunca una excepción.
- [x] La galería permite agregar, eliminar y elegir portada.
- [x] Las características se marcan con su cantidad.
- [x] Un agente no puede tocar los inmuebles de otra agencia.

**HU-04 y HU-18 — Roles y cuentas**
- [x] El administrador asigna y revoca roles sobre la tabla puente.
- [x] Puede activar e inactivar cuentas.
- [x] Una cuenta inactiva no puede iniciar sesión.
- [x] El sistema impide quedarse sin administrador.

---

## 2. Sprint Review — qué se entregó

Dos commits, **3 235 líneas** nuevas en 23 archivos. El proyecto pasó de 14 a
**22 clases Java**, de 3 a **7 controladores** y estrenó **6 vistas** bajo
`WEB-INF/vistas/`.

### Gestión de propiedades

`PropiedadServlet` cubre el ciclo completo del inmueble. La baja es **lógica**:
el inmueble sale del catálogo público pero se conserva en la base junto con sus
citas y solicitudes históricas, y el agente puede volver a publicarlo.

### Las tres relaciones, ahora en la interfaz

| Relación | Dónde se ejercita ahora |
|----------|------------------------|
| **1:1** | `PerfilServlet` edita `perfil`, que cuelga de `usuario` por un `UNIQUE` |
| **1:N** | La galería de imágenes: agregar, eliminar y cambiar portada |
| **N:M** | Características con cantidad, y roles de usuario, ambas sobre su tabla puente |

Esto era el punto del sprint: hasta ahora las relaciones existían en el
esquema; ahora se *usan*.

### Catálogo público reescrito en MVC

`CatalogoServlet` atiende el listado con filtros y la ficha de detalle. La vista
dejó de consultar la base de datos: el controlador le entrega los datos ya
preparados. La ruta anterior `propiedades.jsp` se conserva y redirige con un
301 conservando los filtros, para no romper enlaces guardados.

La ficha muestra la galería en un carrusel, las características con su cantidad
y sugerencias de inmuebles similares por ciudad o tipo.

### Seguridad añadida

El filtro del Sprint 1 protege *secciones*. Este sprint añadió la protección del
**registro concreto**, que es un agujero distinto: sin ella, un agente podía
editar los inmuebles de otra agencia cambiando el id en la URL.

- `perteneceAlUsuario` comprueba la propiedad del inmueble antes de leer o escribir.
- La agencia se toma de la sesión, nunca del formulario: nadie publica a nombre de otro.
- Las vistas viven en `WEB-INF/vistas/`, donde Tomcat no las sirve por URL directa.
- Tres salvaguardas impiden que el administrador deje el sistema sin salida.

### Demostración funcional

| Prueba | Resultado |
|--------|-----------|
| Crear inmueble | 302 → edición, `ok=creada` |
| Matrícula repetida | "Ya existe un inmueble publicado con esa matrícula" |
| Precio negativo | "El precio debe ser un número mayor que cero" |
| `idTipo=99` (fuera del catálogo) | "Seleccione un tipo de propiedad válido" |
| Galería: 3 fotos | Portada automática en la primera |
| Cambiar portada | Siempre exactamente una portada |
| Baja lógica | Fuera del catálogo, presente en el panel del agente |
| Otro agente edita el inmueble | **403**, y la fila no cambia en la base |
| Inmueble de baja consultado por id | **404** con mensaje claro |
| Documento de otro usuario | "Ese número de documento ya está registrado" |
| Contraseña actual incorrecta | "Su contraseña actual no es correcta" |
| Cuenta inactivada intenta entrar | "Su cuenta está inactiva" |
| `/panel/admin/usuarios` como cliente o agente | **403 / 403** |
| Administrador se inactiva a sí mismo | Bloqueado, y sigue siendo ADMIN |

---

## 3. Sprint Retrospective

### Qué salió bien

- **Probar el DAO antes de escribir el servlet.** Se escribió una prueba de
  línea de comandos que ejercitaba alta, duplicados, propiedad del inmueble,
  N:M, galería y baja lógica. Todo el CRUD quedó validado antes de que
  existiera una sola pantalla, así que cuando aparecieron fallos en la interfaz
  se sabía con certeza que no venían de la capa de datos.
- **Sacar el DAO de las JSP.** El catálogo funcionaba llamando al DAO desde la
  vista. Reescribirlo con controlador costó poco y dejó el proyecto alineado
  con el patrón MVC que exige el enunciado.
- **Pensar la seguridad en dos niveles.** Distinguir "proteger la sección" de
  "proteger el registro" evitó un agujero que el filtro por sí solo no cubre.

### Qué salió mal

- **Un error de diseño detectado por poco.** Las cantidades de las
  características se enviaban con el mismo nombre para todas las filas y se
  leían por posición. Como una casilla sin marcar **no se envía** pero su campo
  numérico **sí**, las dos listas se desalineaban y una característica recibía
  la cantidad de otra. Se corrigió nombrando cada campo `cantidad_<id>`. Se
  detectó al revisar el código, no en las pruebas: una prueba que marcara todas
  las casillas nunca lo habría encontrado.
- **Tomcat no ve las clases nuevas.** Al agregar un servlet con `@WebServlet`,
  la ruta devolvía 404 hasta forzar la recarga del contexto tocando `web.xml`.
  Pasó tres veces antes de incorporarlo al procedimiento.
- **Los datos de prueba se dañaron durante las pruebas.** Al limpiar por
  contenido (`DELETE ... WHERE accion IN (...)`) se borraron filas que venían de
  la semilla, no de las pruebas.

### Acciones para el Sprint 3

1. **Diseñar los casos de prueba pensando en el caso torcido**, no solo en el
   camino feliz: marcar *algunas* casillas, no todas.
2. Añadir al README el paso de tocar `web.xml` tras agregar clases nuevas.
   *(Hecho durante el sprint.)*
3. **Limpiar los datos de prueba por id, nunca por contenido**, o recargar
   `02_datos.sql` completo.
4. Cerrar HU-19 (parametrizar catálogos), que quedó fuera.

---

## 4. Deuda técnica que queda abierta

| Asunto | Impacto | Cuándo |
|--------|---------|--------|
| HU-19: parametrizar ciudades y características | El administrador aún no puede crear ciudades desde la aplicación | Sprint 3 |
| Subida real de archivos de imagen | Hoy se elige entre las imágenes del proyecto, no se suben | Sprint 3 |
| Carpeta `inmobiliaria/` duplicada | Ensucia el repositorio; sigue excluida del control de versiones | Sprint 3 |
| Diagrama de casos de uso | Entregable explícito del enunciado | Sprint 3 |
| Tablero Padlet | Entregable de Scrum | Sprint 3 |
| Pruebas unitarias | Entregable del Sprint 3 | Sprint 3 |
| Despliegue en línea | Puntos adicionales | Sprint 3 |

---

## 5. Estado del producto al cierre

| Módulo del enunciado | Estado |
|----------------------|--------|
| Página de aterrizaje | Completo |
| Módulo de autenticación | Completo |
| Paneles diferenciados | Completo |
| Gestión de propiedades | Completo |
| Gestión de visitas y solicitudes | Sprint 3 |
| Reportes | Sprint 3 |
