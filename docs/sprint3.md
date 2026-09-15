# Sprint 3 — Visitas, solicitudes y calidad

**Proyecto:** Santander Raíz — Sistema web de inmobiliaria
**Asignatura:** Programación Java — UTS
**Product Owner:** Docente Julián Barney Jaimes Rincón
**Fechas:** 9 al 14 de septiembre de 2026

---

## 1. Sprint Planning

### Objetivo del sprint

> Cerrar el ciclo del cliente: que pueda guardar lo que le interesa, agendar
> una visita y radicar su compra o arriendo, y que el agente tenga con qué
> resolverlo. Del lado del administrador, reportes y auditoría. Y, por primera
> vez, pruebas automáticas que respalden lo construido.

Al cierre del sprint, los dos módulos que el enunciado dejaba pendientes
—**gestión de visitas y solicitudes** y **reportes**— deben quedar completos.

### Historias de usuario comprometidas

| # | Historia | Prioridad | Estimación | Estado |
|---|----------|-----------|------------|--------|
| HU-08 | Como cliente, quiero marcar propiedades como favoritas para consultarlas después. | Media | 3 pts | Hecha |
| HU-09 | Como cliente, quiero solicitar una cita en un horario disponible sin que se crucen las agendas. | Media | 8 pts | Hecha |
| HU-10 | Como cliente, quiero radicar los documentos de compra o arriendo y consultar el estado de mi solicitud. | Media | 8 pts | Hecha |
| HU-11 | Como agente, quiero aprobar o rechazar las solicitudes y sus documentos. | Media | 5 pts | Hecha |
| HU-12 | Como administrador, quiero un reporte de propiedades por ciudad y estado generado con consultas de agregación. | Media | 5 pts | Hecha |
| HU-13 | Como administrador, quiero consultar la auditoría de accesos y cambios. | Baja | 3 pts | Hecha |
| HU-20 | Como equipo, queremos pruebas unitarias de la capa de datos y de seguridad. | Alta | 5 pts | Hecha |
| HU-21 | Como equipo, queremos la base de datos y la aplicación en la nube (puntos adicionales). | Baja | 8 pts | **Pendiente** |

**Comprometido:** 45 puntos. **Completado:** 37. **Pendiente:** 8 (HU-21).

Además se cerró **HU-19** (parametrizar ciudades y características, 5 pts),
arrastrada del Sprint 2, al arrancar el sprint.

### Criterios de aceptación (Definition of Done)

**HU-09 — Citas**
- [x] El cliente agenda desde la ficha del inmueble eligiendo fecha y hora.
- [x] Dos citas no pueden caer en el mismo inmueble a la misma hora.
- [x] El cruce muestra un mensaje claro, nunca el error de MySQL.
- [x] El agente solo ve y gestiona las citas de las propiedades de su agencia.

**HU-10 y HU-11 — Solicitudes**
- [x] El tipo de solicitud sale de la operación del inmueble, no del formulario.
- [x] El cliente agrega y quita documentos y consulta el estado.
- [x] El agente evalúa cada documento y resuelve la solicitud completa.
- [x] Una solicitud aprobada o rechazada no se puede reabrir, ni siquiera con una petición armada a mano.

**HU-20 — Pruebas unitarias**
- [x] Cubren la capa de datos y la seguridad (contraseñas y escape de HTML).
- [x] Se ejecutan con un solo comando, sin Maven ni Gradle.
- [x] Correrlas no deja la base de datos distinta de como estaba.

---

## 2. Sprint Review — qué se entregó

Desde el cierre del Sprint 2: **6 600 líneas** nuevas en 68 archivos. El
proyecto pasó de 22 a **41 clases Java**, de 7 a **15 controladores**, de 6 a
**18 vistas**, y estrenó **6 clases de prueba** con 33 casos.

Cada historia quedó en **un commit propio**, con su número en el mensaje, para
que el tablero y el historial de Git cuenten lo mismo.

### Favoritos y citas

`FavoritoServlet` guarda y quita favoritos desde la ficha o desde el propio
listado. Es una relación **N:M** entre usuario y propiedad, y la fecha en que se
agregó vive en la tabla puente como atributo propio. Marcar dos veces el mismo
inmueble no lanza error.

Las citas se reparten en **un controlador por rol**, como el resto del
proyecto: `CitaClienteServlet` agenda y `CitaAgenteServlet` confirma, cancela o
marca como realizada. La restricción `UNIQUE (id_propiedad, fecha_hora)` es la
que garantiza que las agendas no se crucen; el DAO la consulta antes de guardar
para dar un mensaje legible.

### Solicitudes de compra y arriendo

`SolicitudClienteServlet` radica y `SolicitudAgenteServlet` resuelve. Dos
decisiones de diseño:

- **El tipo no lo elige el cliente.** Un inmueble en `VENTA` genera una
  solicitud de `COMPRA`; uno en `ARRIENDO`, una de `ARRIENDO`. Así no se puede
  radicar una compra sobre algo que solo se arrienda.
- **Los estados finales son finales.** `SolicitudDAO.esGestionable()` consulta
  la base antes de cada cambio. La vista oculta los botones, pero la regla vive
  en el servidor.

### Reportes y auditoría

`ReporteServlet` arma tres vistas con **consultas de agregación**
(`COUNT`, `AVG`, `MIN`, `MAX` con `GROUP BY`) en vez de traer filas y sumar en
Java:

| Reporte | Contenido |
|---------|-----------|
| Por ciudad | Cantidad de propiedades activas y precio mínimo, máximo y promedio |
| Por estado | Cantidad de propiedades en cada estado |
| Ciudad × estado | El cruce de las dos dimensiones |

`AuditoriaServlet` muestra por fin la bitácora que se viene llenando desde el
Sprint 1, con filtro por acción y por correo, limitada a 200 filas.

### Pruebas unitarias

JUnit 5 en su versión *console standalone*: un único `.jar` en `lib/`, sin
cambiar cómo se compila ni se despliega la aplicación.

| Clase | Casos | Qué cubre |
|-------|-------|-----------|
| `HtmlTest` | 9 | Escape anti-XSS para HTML y para cadenas JavaScript |
| `PasswordUtilTest` | 6 | Cifrado PBKDF2 con salt y verificación |
| `CatalogoDAOTest` | 5 | Ciudades, tipos y características del catálogo |
| `FavoritoDAOTest` | 5 | Agregar, quitar, consultar e idempotencia |
| `PropiedadDAOTest` | 4 | Consultas del catálogo de propiedades |
| `UsuarioDAOTest` | 4 | Autenticación correcta, incorrecta y correo inexistente |

Las pruebas de datos corren contra la base local real, sin *mocks*. Las que
modifican filas las restauran al terminar.

### Deuda técnica cerrada

- **Subida real de fotos.** La galería deja de escoger entre cuatro imágenes
  fijas y sube archivos de verdad. El archivo se guarda con un nombre generado
  (UUID), nunca con el que envía el navegador.
- **Diagrama de casos de uso** (`bd/casos-de-uso.png`) y **tablero Padlet**
  (`docs/padlet.md`), los dos entregables pendientes del enunciado.
- **Interfaz.** Sistema de diseño común para los tres paneles, navbar con el
  logo real, sección de contacto y "Por qué elegirnos" en el inicio, y nuevas
  pantallas de acceso.

### Demostración funcional

| Prueba | Resultado |
|--------|-----------|
| Cita en un horario ya ocupado | Mensaje claro, sin excepción de MySQL |
| Marcar el mismo favorito dos veces | Sin error; queda una sola marca |
| Radicar sobre un inmueble en arriendo | La solicitud nace como `ARRIENDO` |
| Rechazar una solicitud ya aprobada cambiando `accion` a mano | Bloqueado; el estado no cambia |
| Subir un `.txt` renombrado como imagen | Rechazado |
| Subir un `.exe` con `Content-Type` de imagen falso | Rechazado |
| Agente de otra agencia sube una foto a un inmueble ajeno | **403** |
| Reportes y auditoría como cliente o agente | **403** |
| Suite de pruebas, tres veces seguidas | 33/33 cada vez, y la base queda igual |

---

## 3. Sprint Retrospective

### Qué salió bien

- **Las acciones del Sprint 2 se cumplieron.** Se probó el *caso torcido*: un
  ejecutable disfrazado de imagen, una petición armada a mano para reabrir una
  solicitud. Y las pruebas limpian por id lo que crean, en lugar de borrar por
  contenido como pasó en el sprint anterior.
- **Una revisión de seguridad antes de construir encima.** Al arrancar el
  sprint se revisó el proyecto completo y apareció un **XSS almacenado**: un
  cliente podía ejecutar código en la sesión del administrador escribiendo
  etiquetas en su nombre. Se corrigió con `Html.esc()` en 64 puntos antes de
  sumar pantallas nuevas que habrían heredado el mismo defecto.
- **Un commit por historia.** Hace trivial rastrear qué entró en cada HU y
  enlazarlo desde el tablero.

### Qué salió mal

- **La regla de negocio vivía solo en la vista.** La primera versión de HU-11
  ocultaba los botones de una solicitud resuelta, pero el servlet no lo
  comprobaba: cambiando un parámetro, una solicitud aprobada se podía rechazar.
  Se detectó y corrigió antes del commit, pero es el mismo tipo de error que el
  filtro por rol ya había enseñado en el Sprint 2.
- **Un defecto de datos que venía del Sprint 2.** El parseo de números trataba
  el punto siempre como separador de miles, y un `input type="number"` lo envía
  como decimal: un área de 120,5 m² se guardaba como 1 205.
- **El pulido visual se comió el final del sprint.** Tras cerrar las historias
  hubo diez commits seguidos de ajustes de interfaz, y HU-21 no llegó a
  empezarse.

### Acciones para lo que sigue

1. **Toda regla de negocio se valida en el servidor**, aunque la vista ya la
   imponga. Revisarlo en cada servlet nuevo antes del commit.
2. **Poner un límite de tiempo al pulido visual** y no abrirlo mientras quede
   una historia comprometida sin empezar.
3. **Extender las pruebas a `CitaDAO` y `SolicitudDAO`**, que concentran las
   reglas más delicadas y hoy no tienen cobertura.
4. Hacer el despliegue en línea (HU-21).

---

## 4. Deuda técnica que queda abierta

| Asunto | Impacto | Prioridad |
|--------|---------|-----------|
| HU-21: despliegue en línea | Puntos adicionales del enunciado | Alta |
| Subida real de documentos en las solicitudes | Hoy se indica el nombre y la ubicación del documento, no se sube el archivo | Media |
| Pruebas de `CitaDAO` y `SolicitudDAO` | Las reglas de agenda y de estados finales solo están probadas a mano | Media |
| Carpeta `inmobiliaria/` duplicada | Sigue en el disco, excluida del control de versiones | Baja |

---

## 5. Estado del producto al cierre

| Módulo del enunciado | Estado |
|----------------------|--------|
| Página de aterrizaje | Completo |
| Módulo de autenticación | Completo |
| Paneles diferenciados | Completo |
| Gestión de propiedades | Completo |
| Gestión de visitas y solicitudes | Completo |
| Reportes | Completo |
| Pruebas unitarias | Completo |
| Despliegue en línea | Pendiente |
