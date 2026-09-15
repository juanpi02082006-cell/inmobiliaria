# Tablero de seguimiento — contenido para Padlet

El enunciado pide un tablero de seguimiento como evidencia de Scrum:

> *"Utilice un tablero de seguimiento (Trello, Jira o GitHub Projects)"*
> *"Documentación Scrum: Evidencia del tablero padlet de seguimiento de su proyecto."*

Este archivo tiene el contenido exacto para armarlo. **El tablero hay que crearlo
con una cuenta propia**; lo que sigue es para copiar y pegar.

---

## Cómo crearlo

1. Entrar a **padlet.com** y crear una cuenta (el plan gratuito permite 3 padlets).
2. **Make a padlet → Shelf** (formato de columnas, que es el que sirve para un tablero Kanban).
3. Título: `Santander Raíz — Tablero Scrum`
4. Crear las **cuatro columnas** de abajo y dentro de cada una las tarjetas.
5. Al terminar: **Share → Change privacy → Secret** (visible con el enlace) y copiar la URL.
6. Pegar esa URL en la sección final de este archivo y en el README.

> Ojo: si se deja en *Private*, el docente no podrá abrirlo. Debe quedar en
> **Secret** o **Public**.

---

## Columna 1 — Product Backlog

Historias que aún no se han empezado.

| Tarjeta | Cuerpo |
|---|---|
| **HU-21 · Despliegue en línea** | Como equipo queremos la base de datos y la aplicación en la nube (puntos adicionales). Prioridad Baja · 8 pts · Sprint 3 · ❌ Descartada: el proyecto se entrega en local con XAMPP |

---

## Columna 2 — En curso (Sprint 3)

Vacía: todas las historias del Sprint 3 quedaron hechas o descartadas.

---

## Columna 3 — En revisión

Empezar vacía. Aquí van las historias terminadas pero sin probar del todo.

---

## Columna 4 — Hecho

| Tarjeta | Cuerpo |
|---|---|
| **HU-01 · Landing page** | Página pública y responsiva con buscador rápido y destacadas leídas de la base de datos. Sprint 1 · 5 pts ✅ |
| **HU-02 · Registro con correo único** | Registro validado en servidor. El correo repetido muestra un mensaje claro, no una excepción. Sprint 1 · 8 pts ✅ |
| **HU-03 · Login y control por rol** | Contraseñas con PBKDF2 y salt. Un filtro protege las rutas: el rol equivocado recibe 403. Sprint 1 · 8 pts ✅ |
| **HU-15 · Modelo de datos** | 16 tablas en 3FN, 18 llaves foráneas, 10 restricciones UNIQUE, MER y modelo relacional. Sprint 1 · 8 pts ✅ |
| **HU-16 · Conexión JDBC centralizada** | Una sola clase conoce la URL. Cambiar de base local a la nube es editar un `.properties`. Sprint 1 · 3 pts ✅ |
| **HU-06 · CRUD de propiedades** | Alta, edición, baja lógica, galería (1:N) y características (N:M). Un agente no puede tocar los inmuebles de otra agencia. Sprint 2 · 13 pts ✅ |
| **HU-07 · Buscador con filtros** | Catálogo filtrable por ciudad, tipo y rango de precio. Sprint 2 · 5 pts ✅ |
| **HU-17 · Ficha de detalle** | Galería en carrusel, características con cantidad e inmuebles similares. Sprint 2 · 5 pts ✅ |
| **HU-05 · Perfil del usuario** | Datos personales editables (relación 1:1) y cambio de contraseña. Sprint 2 · 5 pts ✅ |
| **HU-04 · Roles de usuario** | El administrador asigna y revoca roles sobre la tabla puente `usuario_rol`. Sprint 2 · 8 pts ✅ |
| **HU-18 · Activar e inactivar cuentas** | Una cuenta inactiva no puede iniciar sesión. Tres salvaguardas impiden dejar el sistema sin administrador. Sprint 2 · 3 pts ✅ |
| **HU-19 · Parametrizar catálogos** | Ciudades y características administrables. Los tipos quedan fijos en los cinco del enunciado. Sprint 2 · 5 pts ✅ |
| **HU-09 · Agendar cita** | El cliente agenda la visita desde la ficha; la restricción UNIQUE (propiedad, fecha y hora) impide que se crucen las agendas. El agente confirma, cancela o marca como realizada. Sprint 3 · 8 pts ✅ |
| **HU-08 · Marcar favoritos** | Guardar y quitar favoritos desde la ficha (N:M usuario ↔ propiedad, con fecha como atributo de la tabla puente) y consultarlos en un listado propio. Sprint 3 · 3 pts ✅ |
| **HU-10 · Radicar solicitud** | El cliente radica una compra o arriendo con sus documentos y consulta el estado. El tipo se deriva de la operación del inmueble: no se puede comprar uno que solo está en arriendo. Sprint 3 · 8 pts ✅ |
| **HU-11 · Resolver solicitudes** | El agente evalúa cada documento y aprueba o rechaza la solicitud. Una solicitud resuelta queda cerrada: el servidor impide reabrirla con una petición armada a mano. Sprint 3 · 5 pts ✅ |
| **HU-12 · Reportes con agregación** | Propiedades por ciudad (con precio mínimo, máximo y promedio), por estado y el cruce de ambas, con COUNT, AVG, MIN y MAX y GROUP BY. Solo administrador. Sprint 3 · 5 pts ✅ |
| **HU-13 · Consultar auditoría** | Bitácora de accesos y cambios con filtro por acción y por correo, limitada a 200 filas. Solo administrador. Sprint 3 · 3 pts ✅ |
| **HU-20 · Pruebas unitarias** | 33 pruebas con JUnit 5: escape anti-XSS, cifrado PBKDF2 y la capa de datos contra la base real. La suite deja la base igual a como estaba. Sprint 3 · 5 pts ✅ |
| **Deuda técnica · Subida real de fotos** | La galería sube archivos de verdad (máx. 5 MB, solo imágenes) con nombre generado por UUID, nunca el que trae el navegador. Sprint 3 ✅ |
| **Deuda técnica · Subida real de documentos** | El cliente sube el PDF, JPG o PNG de cada documento. Quedan fuera del alcance de una URL directa: solo los abren el cliente dueño y el agente de la agencia. Sprint 3 ✅ |

---

## Tarjetas de ceremonias

Estas van en una columna aparte llamada **Ceremonias**, o como comentarios.
Son las que evidencian que se siguió el marco de trabajo, no solo que se programó.

| Tarjeta | Cuerpo |
|---|---|
| **Sprint 1 — Planning** | 32 puntos comprometidos en 5 historias. Objetivo: cimientos y acceso. |
| **Sprint 1 — Review** | 32/32 completados. Demostración: login por rol con matriz 200/403 verificada. |
| **Sprint 1 — Retrospective** | Se editó `02_datos.sql` sin recargarlo y el login falló por hashes viejos. Acción: recargar el script antes de probar. |
| **Sprint 2 — Planning** | 44 puntos comprometidos en 7 historias. Objetivo: núcleo del negocio. |
| **Sprint 2 — Review** | 39/44 completados. HU-19 no alcanzó y pasó al Sprint 3. |
| **Sprint 2 — Retrospective** | Las cantidades de características se leían por posición y una casilla sin marcar desalineaba las listas. Acción: diseñar pruebas para el caso torcido, no solo el feliz. |
| **Sprint 3 — Planning** | 45 puntos comprometidos en 8 historias. Objetivo: visitas, solicitudes, reportes y pruebas unitarias. HU-21 (despliegue) da puntos adicionales. |
| **Sprint 3 — Ajuste de alcance** | HU-21 (despliegue en línea, 8 pts) se descarta: el proyecto se entrega en local con XAMPP. Resultado: 37 puntos completados, 8 descartados. |

---

## Consejos para que sume puntos

- **Fechas en las tarjetas.** Padlet permite comentar cada tarjeta: poner la fecha
  en que se movió de columna. Un tablero sin movimiento parece llenado el último día.
- **Capturas.** Adjuntar a las tarjetas de Review una captura de la pantalla
  correspondiente. Es la *demostración funcional* que pide el enunciado.
- **Enlazar los commits.** En cada tarjeta de Hecho, pegar el enlace al commit de
  GitHub. Ata el tablero al código y demuestra que las fechas son reales.
- **No dejarlo todo en Hecho.** Un tablero con las cuatro columnas usadas cuenta
  una historia; uno donde todo está en Hecho parece rellenado a posteriori.

---

## Enlace del tablero

```
https://padlet.com/juanpi02082006/santander-raiz-s023fkrg0abichm3n84w
```
