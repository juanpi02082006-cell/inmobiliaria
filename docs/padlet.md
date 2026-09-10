# Tablero de seguimiento — contenido para Padlet

El enunciado pide un tablero como evidencia de Scrum:

> *"Documentación Scrum: Evidencia del tablero padlet de seguimiento de su proyecto."*

**El tablero hay que crearlo con una cuenta propia.** Este archivo tiene el
contenido listo: cada tarjeta es un bloque con su título y su cuerpo, para
copiar el primero en el campo de arriba de Padlet y el segundo en el de abajo.

---

## Antes de empezar

1. Entrar a **padlet.com** y crear cuenta (el plan gratuito da 3 padlets).
2. **Make a padlet → Shelf** — es el formato de columnas, el que sirve de Kanban.
3. Título del padlet: `Santander Raíz — Tablero Scrum`
4. Crear estas **cinco columnas**, en este orden:

```
Product Backlog
En curso
En revisión
Hecho
Ceremonias
```

5. Ir pegando las tarjetas de abajo en su columna.
6. Al final: **Share → Change privacy → Secret**.

> ⚠️ Si queda en *Private* el docente no podrá abrirlo. Tiene que estar en
> **Secret** (visible con el enlace) o **Public**.

---

# COLUMNA: Product Backlog

*Ocho tarjetas. Son las historias del Sprint 3, que aún no se empiezan.*

---

**Título**
```
HU-08 · Marcar favoritos
```
**Cuerpo**
```
Como cliente quiero marcar propiedades como favoritas para consultarlas más adelante sin buscarlas de nuevo.
Prioridad: Media | Estimación: 3 pts | Sprint 3
Relación N:M usuario ↔ propiedad
```

---

**Título**
```
HU-09 · Agendar cita
```
**Cuerpo**
```
Como cliente quiero solicitar una cita en un horario disponible para visitar el inmueble sin que se crucen las agendas.
Prioridad: Media | Estimación: 8 pts | Sprint 3
Debe respetar UNIQUE (id_propiedad, fecha_hora)
```

---

**Título**
```
HU-10 · Radicar solicitud y documentos
```
**Cuerpo**
```
Como cliente quiero radicar los documentos de compra o arriendo y consultar el estado de mi solicitud.
Prioridad: Media | Estimación: 8 pts | Sprint 3
Relación 1:N solicitud → documento_solicitud
```

---

**Título**
```
HU-11 · Resolver solicitudes
```
**Cuerpo**
```
Como agente de la inmobiliaria quiero aprobar o rechazar las solicitudes y sus documentos para dar trámite a la negociación.
Prioridad: Media | Estimación: 5 pts | Sprint 3
```

---

**Título**
```
HU-12 · Reportes con agregación
```
**Cuerpo**
```
Como administrador quiero un reporte de propiedades por ciudad y estado, generado con consultas de agregación, para tomar decisiones.
Prioridad: Media | Estimación: 5 pts | Sprint 3
Consultas con GROUP BY y HAVING
```

---

**Título**
```
HU-13 · Consultar auditoría
```
**Cuerpo**
```
Como administrador quiero consultar la auditoría de accesos y cambios para hacer seguimiento a la operación del sistema.
Prioridad: Baja | Estimación: 3 pts | Sprint 3
La tabla auditoria ya se está llenando desde el Sprint 1
```

---

**Título**
```
HU-20 · Pruebas unitarias
```
**Cuerpo**
```
Como equipo queremos pruebas unitarias de la capa de datos y del cifrado de contraseñas para poder cambiar el código sin romper lo que ya funciona.
Prioridad: Alta | Estimación: 5 pts | Sprint 3
Entregable explícito del enunciado
```

---

**Título**
```
HU-21 · Despliegue en línea
```
**Cuerpo**
```
Como equipo queremos la base de datos y la aplicación funcionando en la nube.
Prioridad: Baja | Estimación: 8 pts | Sprint 3
Otorga puntos adicionales. db.properties ya tiene el perfil online preparado.
```

---

# COLUMNA: En curso

*Dejarla vacía. Aquí se arrastra la tarjeta que se esté trabajando.*

---

# COLUMNA: En revisión

*Dejarla vacía. Aquí van las historias terminadas pero sin probar del todo.*

---

# COLUMNA: Hecho

*Doce tarjetas.*

---

**Título**
```
HU-01 · Landing page
```
**Cuerpo**
```
Página pública y responsiva con buscador rápido, publicaciones destacadas leídas de la base de datos y accesos a registro e inicio de sesión.
Sprint 1 | 5 pts | ✅ Terminada
```

---

**Título**
```
HU-02 · Registro con correo único
```
**Cuerpo**
```
Registro validado en el servidor. Crea usuario, perfil y rol en una sola transacción. El correo repetido muestra un mensaje claro, no una excepción de Java.
Sprint 1 | 8 pts | ✅ Terminada
```

---

**Título**
```
HU-03 · Login y control de acceso por rol
```
**Cuerpo**
```
Contraseñas cifradas con PBKDF2 y salt por usuario. Un filtro de servlet protege las rutas privadas: el rol equivocado recibe 403 aunque escriba la URL a mano.
Sprint 1 | 8 pts | ✅ Terminada
```

---

**Título**
```
HU-15 · Modelo de datos
```
**Cuerpo**
```
16 tablas normalizadas hasta 3FN, 18 llaves foráneas con acciones referenciales justificadas y 10 restricciones UNIQUE. MER y modelo relacional entregados.
Sprint 1 | 8 pts | ✅ Terminada
```

---

**Título**
```
HU-16 · Conexión JDBC centralizada
```
**Cuerpo**
```
Una sola clase conoce la URL de la base de datos. Pasar de la instancia local a la de la nube es editar un archivo .properties, sin recompilar.
Sprint 1 | 3 pts | ✅ Terminada
```

---

**Título**
```
HU-06 · CRUD de propiedades
```
**Cuerpo**
```
Alta, edición y baja lógica del inmueble, con galería de imágenes (1:N) y características con cantidad (N:M). Un agente no puede tocar los inmuebles de otra agencia ni cambiando el id en la URL.
Sprint 2 | 13 pts | ✅ Terminada
```

---

**Título**
```
HU-07 · Buscador con filtros
```
**Cuerpo**
```
Catálogo público filtrable por ciudad, tipo y rango de precio. Los desplegables se llenan desde la base de datos.
Sprint 2 | 5 pts | ✅ Terminada
```

---

**Título**
```
HU-17 · Ficha de detalle del inmueble
```
**Cuerpo**
```
Galería en carrusel, características con su cantidad e inmuebles similares. Un inmueble dado de baja responde 404 con mensaje claro.
Sprint 2 | 5 pts | ✅ Terminada
```

---

**Título**
```
HU-05 · Perfil del usuario
```
**Cuerpo**
```
Datos personales editables (relación 1:1 usuario ↔ perfil) y cambio de contraseña comprobando la actual.
Sprint 2 | 5 pts | ✅ Terminada
```

---

**Título**
```
HU-04 · Asignación de roles
```
**Cuerpo**
```
El administrador asigna y revoca roles sobre la tabla puente usuario_rol. Un usuario no puede quedarse sin ningún rol.
Sprint 2 | 8 pts | ✅ Terminada
```

---

**Título**
```
HU-18 · Activar e inactivar cuentas
```
**Cuerpo**
```
Una cuenta inactiva no puede iniciar sesión. Tres salvaguardas impiden dejar el sistema sin administrador: no puede inactivarse a sí mismo, ni quitarse el rol ADMIN, ni inactivar al único administrador activo.
Sprint 2 | 3 pts | ✅ Terminada
```

---

**Título**
```
HU-19 · Parametrizar catálogos
```
**Cuerpo**
```
Ciudades y características administrables. Los tipos de propiedad quedan fijos en los cinco del enunciado. Una ciudad con inmuebles no se puede borrar (ON DELETE RESTRICT).
Sprint 2 | 5 pts | ✅ Terminada
```

---

# COLUMNA: Ceremonias

*Seis tarjetas. Son las que evidencian el marco de trabajo, no solo el código.*

---

**Título**
```
Sprint 1 · Planning
```
**Cuerpo**
```
Objetivo: cimientos y acceso.
5 historias, 32 puntos comprometidos.
HU-01, HU-02, HU-03, HU-15, HU-16
```

---

**Título**
```
Sprint 1 · Review
```
**Cuerpo**
```
32 de 32 puntos completados.
Demostración: los cuatro roles entran a su panel y el filtro devuelve 403 al rol equivocado. Matriz de acceso verificada contra la aplicación en ejecución.
```

---

**Título**
```
Sprint 1 · Retrospective
```
**Cuerpo**
```
Qué salió mal: se editó 02_datos.sql pero no se recargó la base, y el login falló con "credenciales incorrectas" porque MySQL seguía con los hashes viejos. Se perdió tiempo buscando un error en el código que no existía.
Acción de mejora: después de cambiar un .sql, recargarlo antes de probar.
```

---

**Título**
```
Sprint 2 · Planning
```
**Cuerpo**
```
Objetivo: núcleo del negocio.
7 historias, 44 puntos comprometidos.
HU-04, HU-05, HU-06, HU-07, HU-17, HU-18, HU-19
```

---

**Título**
```
Sprint 2 · Review
```
**Cuerpo**
```
39 de 44 puntos completados. HU-19 no alcanzó y pasó al Sprint 3.
Demostración: alta y edición de inmuebles, galería con cambio de portada, baja lógica, y un agente recibiendo 403 al intentar editar el inmueble de otra agencia.
```

---

**Título**
```
Sprint 2 · Retrospective
```
**Cuerpo**
```
Qué salió mal: las cantidades de las características se leían por posición, y como una casilla sin marcar no se envía pero su campo numérico sí, una característica recibía la cantidad de otra. Se detectó revisando el código, no en las pruebas.
Acción de mejora: diseñar los casos de prueba pensando en el caso torcido, no solo en el camino feliz.
```

---

## Tres detalles que suman

- **Fechas.** Comentar cada tarjeta con la fecha en que se movió de columna. Un
  tablero sin movimiento parece llenado el último día.
- **Enlaces a los commits.** En cada tarjeta de Hecho, pegar el enlace al commit
  de GitHub. Ata el tablero al código y demuestra que las fechas son reales.
- **Capturas.** Adjuntar a las tarjetas de Review una captura de la pantalla
  correspondiente. Es la *demostración funcional* que pide el enunciado.

---

## Enlace del tablero

> Pegar aquí la URL cuando esté creado, y también en el README.

```
https://padlet.com/...
```
