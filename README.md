# Santander Raíz — Sistema web de inmobiliaria

Aplicación web para la administración de una inmobiliaria: catálogo de
propiedades, usuarios con roles diferenciados, visitas, solicitudes de compra o
arriendo con sus documentos, favoritos, reportes y auditoría.

Proyecto académico de **Programación Java** — Unidades Tecnológicas de Santander.

---

## Estado por sprint

| Sprint | Alcance | Estado |
|--------|---------|--------|
| **1 — Cimientos y acceso** | Modelo de datos, conexión JDBC, landing, registro, login y control de acceso por rol | ✅ Completo |
| **2 — Núcleo del negocio** | CRUD de propiedades con imágenes (1:N) y características (N:M), ficha de detalle, buscador, perfil (1:1), usuarios y roles | ✅ Completo |
| **3 — Operación y cierre** | Citas, solicitudes con subida de documentos, favoritos, reportes con agregación, auditoría y pruebas unitarias | ✅ Completo |
| | Despliegue en línea (puntos adicionales) | ➖ Descartado: se entrega en local con XAMPP |

Planning, review y retrospectiva de cada sprint en [docs/](docs/); ver
[Documentación del proyecto](#documentación-del-proyecto).

## Qué puede hacer cada rol

| Rol | Funciones |
|-----|-----------|
| **Visitante** | Ver la portada, buscar en el catálogo con filtros y abrir la ficha de cada inmueble. Registrarse. |
| **Cliente** | Todo lo anterior, más: guardar favoritos, agendar visitas, radicar solicitudes de compra o arriendo, subir sus documentos y seguir el estado. Editar su perfil. |
| **Inmobiliaria** (agente) | Publicar, editar y dar de baja los inmuebles de su agencia, con fotos y características. Confirmar o cancelar visitas. Revisar documentos y aprobar o rechazar solicitudes. |
| **Administrador** | Asignar roles, activar e inactivar cuentas, administrar ciudades y características, consultar reportes y la auditoría. |

---

## Tecnologías

| Capa | Herramienta |
|------|-------------|
| Servidor | Apache Tomcat 8.5 (`javax.servlet`, Servlet 3.1) |
| Lenguaje | Java, compilado con `--release 8` |
| Vistas | JSP + JSPF |
| Datos | JDBC sobre MySQL 8 / MariaDB |
| Frontend | Bootstrap 5, HTML5, CSS3, JavaScript |
| Cifrado | PBKDF2-HMAC-SHA256 (incluido en el JDK) |
| Pruebas | JUnit 5 (*console standalone*, sin Maven ni Gradle) |

---

## Puesta en marcha

### 1. Cargar la base de datos

```bat
cd C:\xampp\tomcat\webapps\inmobiliaria
C:\xampp\mysql\bin\mysql.exe -u root < sql\01_esquema.sql
C:\xampp\mysql\bin\mysql.exe -u root < sql\02_datos.sql
```

> ⚠️ **Cada vez que edite un archivo `.sql`, vuelva a cargarlo antes de probar.**
> Un cambio en el script no llega solo a MySQL. Esto ya costó una sesión de
> depuración en el Sprint 1 (ver la retrospectiva).

### 2. Compilar

```bat
compilar.bat
```

El script compila con `--release 8` **a propósito**: Tomcat 8.5 traduce las JSP
con `ecj-4.6.3`, un compilador de 2016 que solo lee class files hasta Java 8. Si
se compila con la versión por defecto del JDK, las JSP que importan estas clases
fallan con *"Only a type can be imported… resolves to a package"*.

### 3. Abrir

<http://localhost:8080/inmobiliaria/>

### Si agregó una clase nueva y la ruta devuelve 404

Los servlets y el filtro se declaran con anotaciones (`@WebServlet`,
`@WebFilter`), y Tomcat solo las lee cuando arranca el contexto. Compilar no
basta: la clase existe en disco pero la aplicación en memoria no la conoce, así
que la ruta responde **404** aunque el código esté bien.

Fuerce la recarga tocando `web.xml` y espere unos segundos:

```bat
copy /b WEB-INF\web.xml +,, >nul
```

### Si cambió `db.properties` y la aplicación sigue conectándose a la base vieja

`ConexionBD` lee el archivo en un bloque `static`, que se ejecuta **una sola
vez** cuando Tomcat carga la clase. Como Tomcat no recarga la aplicación cuando
solo cambia un `.properties`, el valor viejo se queda en memoria y verá un error
del tipo *"Unknown database 'inmobiliaria_db'"* aunque el archivo en disco ya
diga otra cosa.

Para forzar la recarga del contexto basta con tocar `web.xml`:

```bat
copy /b WEB-INF\web.xml +,, >nul
```

Espere unos segundos y vuelva a abrir la aplicación.

---

## Pruebas unitarias

El proyecto no usa Maven ni Gradle, así que las pruebas corren con
[JUnit 5](https://junit.org/junit5/) en su presentación *console standalone*:
un solo `.jar` en [`lib/`](lib/) que trae el motor y el lanzador, sin que haga
falta descargar nada más ni cambiar cómo se compila o se despliega la
aplicación.

```bat
compilar.bat
compilar-pruebas.bat
ejecutar-pruebas.bat
```

- `compilar-pruebas.bat` compila lo que hay en [`test/`](test/) contra las
  clases ya compiladas en `WEB-INF/classes` (por eso hace falta correr
  `compilar.bat` primero). A diferencia de `compilar.bat`, no baja el
  bytecode a `--release 8`: las pruebas nunca las traduce el `ecj` de Tomcat
  porque nunca se despliegan.
- `ejecutar-pruebas.bat` corre toda la suite y muestra el árbol de resultados
  en la consola.

Las pruebas de `com.inmobiliaria.util` (escape de HTML, cifrado de
contraseñas) no tocan la base de datos. Las de `com.inmobiliaria.dao` sí:
necesitan MySQL de XAMPP levantado con la base `inmobiliaria` ya cargada
(sección [1](#1-cargar-la-base-de-datos) de esta misma guía), porque usan la
misma `ConexionBD` y el mismo `db.properties` que la aplicación. Las que
modifican datos (favoritos, intentos fallidos de login) restauran el estado
original en un `@AfterEach`, así que correr la suite varias veces seguidas no
deja el catálogo de prueba distinto de como estaba.

---

## Usuarios de prueba

Todos usan la contraseña **`password`**.

| Correo | Rol | Panel al que llega |
|--------|-----|--------------------|
| `admin@inmobiliaria.com` | ADMIN | `/panel/admin.jsp` |
| `agente.norte@sraiz.com` | INMOBILIARIA | `/panel/inmobiliaria.jsp` |
| `carlos.perez@gmail.com` | CLIENTE | `/panel/cliente.jsp` |
| `visitante@correo.com` | VISITANTE | `/index.jsp` |

Hay dos agencias más (`agente.sur@sraiz.com`, `agente.metro@sraiz.com`) y seis
clientes más (`diana.gomez`, `jorge.ruiz`, `laura.mora`, `andres.silva`,
`paola.leon`, `mateo.castro`, todos `@gmail.com`). Sirven para comprobar que un
agente no ve lo de otra agencia y que un cliente no ve lo de otro.

Tras cinco intentos fallidos seguidos, la cuenta se bloquea 15 minutos.

---

## Configuración de la base de datos

La cadena de conexión **no aparece en ninguna clase**. Vive en
[`src/db.properties`](src/db.properties) y la lee `ConexionBD`, que es el único
punto de acceso a la base de datos de todo el proyecto.

Para pasar de la instancia local a la instancia en línea basta con cambiar una
línea y reiniciar Tomcat:

```properties
db.perfil=online
```

No hay que recompilar ni tocar código.

---

## Estructura

Patrón **MVC**: los servlets reciben la petición y consultan los DAO; las
vistas solo pintan lo que el servlet les entrega y nunca abren una conexión.

```
inmobiliaria/
├── src/com/inmobiliaria/
│   ├── config/      ConexionBD ............ única clase que conoce la URL
│   ├── util/        PasswordUtil .......... cifrado PBKDF2 con salt
│   │                Html .................. escape anti-XSS para HTML y JavaScript
│   │                ArchivoUtil ........... validación y guardado de fotos y documentos
│   ├── modelo/      Usuario, Perfil, Propiedad, Imagen, Caracteristica, Cita,
│   │                Solicitud, DocumentoSolicitud, ResumenCiudad, RegistroAuditoria
│   ├── dao/         UsuarioDAO, PropiedadDAO, ImagenDAO, CatalogoDAO, CitaDAO,
│   │                FavoritoDAO, SolicitudDAO, ReporteDAO, ResumenDAO, AuditoriaDAO
│   ├── controlador/ 15 servlets ........... ver la tabla de rutas
│   └── filtro/      AutenticacionFilter ... control de acceso por rol
├── test/            pruebas JUnit 5 de util/ y dao/
├── WEB-INF/
│   ├── web.xml
│   ├── jspf/        cabecera.jspf, pie.jspf
│   ├── vistas/      18 vistas MVC, no accesibles por URL directa
│   └── documentos/  archivos de las solicitudes (se crea sola, no se versiona)
├── panel/           admin.jsp, inmobiliaria.jsp, cliente.jsp
├── img/propiedades/ fotos subidas por los agentes (no se versionan)
├── css/             santander-raiz.css ..... identidad de la marca
├── lib/             JUnit 5 console standalone
├── sql/             esquema, datos, consultas y diccionario de datos
├── bd/              MER, modelo relacional y casos de uso
└── docs/            documentación Scrum y tablero Padlet
```

## Rutas

| Ruta | Quién entra | Qué hace |
|------|-------------|----------|
| `/index.jsp` | Todos | Portada con buscador, destacadas y contacto |
| `/catalogo` | Todos | Listado con filtros por ciudad, tipo y precio |
| `/catalogo?id=N` | Todos | Ficha de detalle con galería, características y similares |
| `/login`, `/registro`, `/logout` | Todos | Autenticación |
| `/panel/perfil` | Autenticados | Datos personales (1:1) y contraseña |
| `/panel/cliente.jsp` | CLIENTE | Su panel |
| `/panel/cliente/favoritos` | CLIENTE | Favoritos guardados (N:M) |
| `/panel/cliente/citas` | CLIENTE | Agendar y consultar visitas |
| `/panel/cliente/solicitudes` | CLIENTE | Radicar solicitudes, subir documentos y seguir el estado |
| `/panel/inmobiliaria.jsp` | INMOBILIARIA | Su panel |
| `/panel/inmobiliaria/propiedades` | INMOBILIARIA | CRUD, galería (1:N) y características (N:M) |
| `/panel/inmobiliaria/citas` | INMOBILIARIA | Confirmar, cancelar o marcar como realizadas las visitas |
| `/panel/inmobiliaria/solicitudes` | INMOBILIARIA | Evaluar documentos y aprobar o rechazar solicitudes |
| `/panel/admin.jsp` | ADMIN | Su panel |
| `/panel/admin/usuarios` | ADMIN | Roles (N:M) y estado de las cuentas |
| `/panel/admin/catalogos` | ADMIN | Ciudades y características |
| `/panel/admin/reportes` | ADMIN | Propiedades por ciudad, por estado y cruce de ambos |
| `/panel/admin/auditoria` | ADMIN | Bitácora de accesos y cambios con filtros |

Cualquier otra combinación de rol y ruta responde **403** desde el servidor.

---

## Modelo de datos

16 tablas normalizadas hasta 3FN. Las tres relaciones exigidas:

| Tipo | Dónde se materializa | Cómo se garantiza |
|------|----------------------|-------------------|
| **1:1** | `usuario` ↔ `perfil` | `UNIQUE (perfil.id_usuario)` — sin ese UNIQUE sería 1:N |
| **1:N** | `inmobiliaria` → `propiedad`, `propiedad` → `imagen_propiedad`, `usuario` → `cita`, `solicitud` → `documento_solicitud` | La llave foránea vive en el lado "muchos", con `ON DELETE`/`ON UPDATE` justificados |
| **N:M** | `usuario_rol`, `propiedad_caracteristica`, `favorito` | Tabla intermedia con llave primaria compuesta y atributo propio |

Restricciones `UNIQUE` (el enunciado pide 3, el modelo tiene 10): `usuario.correo`,
`propiedad.matricula_inmobiliaria`, `perfil.id_usuario`, `perfil.documento`,
`cita(id_propiedad, fecha_hora)`, `inmobiliaria.nit`, `ciudad(nombre, departamento)`,
`tipo_propiedad.nombre`, `caracteristica.nombre` y `rol.nombre`. Las tablas
puente evitan duplicados con su llave primaria compuesta.

El detalle de cada tabla está en el
[diccionario de datos](sql/04_diccionario_datos.md), y hay consultas de
ejemplo con `JOIN` y agregación en [`sql/03_consultas.sql`](sql/03_consultas.sql).

---

## Seguridad

- **Contraseñas.** PBKDF2-HMAC-SHA256, 120 000 iteraciones, salt aleatorio de
  16 bytes por usuario. Los 12 usuarios de prueba comparten la misma contraseña
  y sus 12 hashes son distintos: eso es el salt funcionando.
- **Control de acceso.** `AutenticacionFilter` intercepta todas las peticiones.
  Escribir una URL privada a mano no sirve: la petición pasa por el filtro
  igual. Ocultar un botón en la vista no se considera control de acceso.
- **Control sobre cada registro.** El filtro protege secciones; los servlets
  protegen registros. Antes de leer o modificar un inmueble, una cita, una
  solicitud o un documento se comprueba que sea del usuario en sesión (o de su
  agencia). Cambiar el id en la URL devuelve **403**.
- **Reglas de negocio en el servidor.** Una solicitud aprobada o rechazada no
  se reabre, y un documento ya evaluado no se retira, aunque la petición se
  arme a mano sin pasar por la vista.
- **XSS.** Todo texto escrito por una persona se imprime con `Html.esc()` (o
  `Html.js()` dentro de JavaScript). `PreparedStatement` protege la base de
  datos, pero no la página.
- **Archivos subidos.** Se guardan con un nombre generado (UUID), nunca con el
  que envía el navegador, y con límite de 5 MB. Las fotos son públicas. Los
  documentos de las solicitudes van a `WEB-INF/documentos`, que Tomcat no sirve
  por URL. Solo los entrega el servlet al cliente dueño o al agente de la
  agencia, y antes de guardarlos se revisan los primeros bytes: un ejecutable
  renombrado a `.pdf` se rechaza.
- **Inyección SQL.** Toda la capa de datos usa `PreparedStatement` con
  parámetros; nunca se concatena lo que escribe el usuario dentro del SQL.
- **Auditoría.** Inicios de sesión (exitosos y fallidos) y cambios relevantes
  quedan en la tabla `auditoria`, que el administrador consulta desde la
  aplicación.
- **Sesiones.** Se invalida la sesión previa al autenticar (evita fijación de
  sesión), la cookie es `HttpOnly` y la sesión expira a los 30 minutos.
- **Errores.** Las violaciones de `UNIQUE` se traducen a mensajes en castellano;
  el usuario final nunca ve una traza de Java.

---

## Documentación del proyecto

### Scrum

El proyecto se desarrolló en tres sprints de siete días. El Product Owner es el
docente; cada sprint tiene su Sprint Planning (historias y estimación), su
Sprint Review (con demostración funcional) y su Sprint Retrospective.

| Documento | Contenido |
|-----------|-----------|
| [docs/sprint1.md](docs/sprint1.md) | Cimientos y acceso: 32/32 puntos |
| [docs/sprint2.md](docs/sprint2.md) | Núcleo del negocio: 39/44 puntos |
| [docs/sprint3.md](docs/sprint3.md) | Operación y cierre: 37 puntos completados; HU-21 (despliegue, 8 pts) descartada |
| [docs/padlet.md](docs/padlet.md) | Contenido y enlace del tablero de seguimiento en Padlet |

El historial de Git acompaña al tablero: cada historia de usuario tiene su
propio commit, con el número de la HU en el mensaje.

### Modelado

| Archivo | Contenido |
|---------|-----------|
| [bd/mer.png](bd/mer.png) | Modelo entidad-relación |
| [bd/modelo-relacional.png](bd/modelo-relacional.png) | Modelo relacional |
| [bd/casos-de-uso.png](bd/casos-de-uso.png) | Diagrama de casos de uso |
| [sql/01_esquema.sql](sql/01_esquema.sql) | Creación de las 16 tablas con sus restricciones |
| [sql/02_datos.sql](sql/02_datos.sql) | Datos de prueba |
| [sql/04_diccionario_datos.md](sql/04_diccionario_datos.md) | Diccionario de datos |

### Entorno de entrega

El proyecto se entrega y se ejecuta **en local con XAMPP** (Tomcat y MySQL);
no se despliega en ningún servicio en línea. Los pasos están en
[Puesta en marcha](#puesta-en-marcha).

La historia HU-21 (despliegue en línea), que solo daba puntos adicionales, se
descartó al cierre del Sprint 3. La conexión sigue siendo configurable desde
[`src/db.properties`](src/db.properties), como pide el enunciado.
