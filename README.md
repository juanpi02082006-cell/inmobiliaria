# Santander Raíz — Sistema web de inmobiliaria

Aplicación web para la administración de una inmobiliaria: catálogo de
propiedades, usuarios con roles diferenciados, citas y solicitudes.

Proyecto académico de **Programación Java** — Unidades Tecnológicas de Santander.

---

## Estado por sprint

| Sprint | Alcance | Estado |
|--------|---------|--------|
| **1 — Cimientos y acceso** | Modelo de datos, conexión JDBC, landing, registro, login y control de acceso por rol | ✅ Completo |
| **2 — Núcleo del negocio** | CRUD de propiedades con imágenes (1:N) y características (N:M), ficha de detalle, buscador, perfil (1:1), usuarios y roles | ✅ Completo |
| **3 — Operación y cierre** | Citas, solicitudes, documentos, favoritos, reportes, pruebas y despliegue | ⬜ Pendiente |

Documentación Scrum en [docs/](docs/).

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

```
inmobiliaria/
├── src/com/inmobiliaria/
│   ├── config/      ConexionBD .......... única clase que conoce la URL
│   ├── util/        PasswordUtil ........ cifrado PBKDF2 con salt
│   ├── modelo/      Usuario, Perfil, Propiedad, Imagen, Caracteristica
│   ├── dao/         UsuarioDAO, PropiedadDAO, ImagenDAO, CatalogoDAO,
│   │                ResumenDAO, AuditoriaDAO
│   ├── controlador/ Login, Registro, Logout, Catalogo, Propiedad,
│   │                Perfil, Usuario ..... un controlador por entidad
│   └── filtro/      AutenticacionFilter . control de acceso por rol
├── WEB-INF/
│   ├── web.xml
│   ├── jspf/        cabecera.jspf, pie.jspf
│   └── vistas/      vistas MVC, no accesibles por URL directa
├── panel/           admin.jsp, inmobiliaria.jsp, cliente.jsp
├── css/             santander-raiz.css ... identidad de la marca
├── sql/             esquema, datos, consultas y diccionario
├── bd/              MER y modelo relacional
└── docs/            documentación Scrum
```

## Rutas

| Ruta | Quién entra | Qué hace |
|------|-------------|----------|
| `/index.jsp` | Todos | Portada con buscador y destacadas |
| `/catalogo` | Todos | Listado con filtros |
| `/catalogo?id=N` | Todos | Ficha de detalle con galería y características |
| `/login`, `/registro`, `/logout` | Todos | Autenticación |
| `/panel/perfil` | Autenticados | Datos personales y contraseña (1:1) |
| `/panel/cliente.jsp` | CLIENTE | Su panel |
| `/panel/inmobiliaria/propiedades` | INMOBILIARIA | CRUD, galería (1:N) y características (N:M) |
| `/panel/admin/usuarios` | ADMIN | Roles (N:M) y estado de las cuentas |

Cualquier otra combinación de rol y ruta responde **403** desde el servidor.

---

## Modelo de datos

16 tablas normalizadas hasta 3FN. Las tres relaciones exigidas:

| Tipo | Dónde se materializa | Cómo se garantiza |
|------|----------------------|-------------------|
| **1:1** | `usuario` ↔ `perfil` | `UNIQUE (perfil.id_usuario)` — sin ese UNIQUE sería 1:N |
| **1:N** | `inmobiliaria` → `propiedad`, `propiedad` → `imagen_propiedad`, `usuario` → `cita` | La llave foránea vive en el lado "muchos", con `ON DELETE`/`ON UPDATE` justificados |
| **N:M** | `usuario_rol`, `propiedad_caracteristica` | Tabla intermedia con llave primaria compuesta y atributo propio |

Restricciones `UNIQUE` (el enunciado pide 3, el modelo tiene 7): `usuario.correo`,
`propiedad.matricula_inmobiliaria`, `perfil.id_usuario`, `perfil.documento`,
`usuario_rol(id_usuario, id_rol)`, `cita(id_propiedad, fecha_hora)`,
`inmobiliaria.nit`.

---

## Seguridad

- **Contraseñas.** PBKDF2-HMAC-SHA256, 120 000 iteraciones, salt aleatorio de
  16 bytes por usuario. Los 12 usuarios de prueba comparten la misma contraseña
  y sus 12 hashes son distintos: eso es el salt funcionando.
- **Control de acceso.** `AutenticacionFilter` intercepta todas las peticiones.
  Escribir una URL privada a mano no sirve: la petición pasa por el filtro
  igual. Ocultar un botón en la vista no se considera control de acceso.
- **Inyección SQL.** Toda la capa de datos usa `PreparedStatement` con
  parámetros; nunca se concatena lo que escribe el usuario dentro del SQL.
- **Sesiones.** Se invalida la sesión previa al autenticar (evita fijación de
  sesión), la cookie es `HttpOnly` y la sesión expira a los 30 minutos.
- **Errores.** Las violaciones de `UNIQUE` se traducen a mensajes en castellano;
  el usuario final nunca ve una traza de Java.
