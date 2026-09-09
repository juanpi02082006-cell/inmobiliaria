# Sprint 1 — Cimientos y acceso

**Proyecto:** Santander Raíz — Sistema web de inmobiliaria
**Asignatura:** Programación Java — UTS
**Product Owner:** Docente Julián Barney Jaimes Rincón
**Duración:** 7 días

---

## 1. Sprint Planning

### Objetivo del sprint

> Dejar en pie los cimientos del sistema: el modelo de datos cargado y
> consultable, la conexión JDBC centralizada, y un módulo de autenticación
> que separe de verdad los privilegios por rol.

Al cierre del sprint un usuario debe poder registrarse, iniciar sesión y
llegar al panel que le corresponde, y **no** debe poder entrar al panel de
otro rol aunque escriba la URL a mano.

### Historias de usuario comprometidas

| # | Historia | Prioridad | Estimación | Estado |
|---|----------|-----------|------------|--------|
| HU-01 | Como visitante, quiero una página de aterrizaje para conocer la inmobiliaria y buscar propiedades. | Alta | 5 pts | Hecha |
| HU-02 | Como usuario, quiero registrarme con un correo único y validado para crear mi cuenta sin duplicados. | Alta | 8 pts | Hecha |
| HU-03 | Como usuario registrado, quiero iniciar y cerrar sesión de forma segura para que el sistema me lleve al panel de mi rol. | Alta | 8 pts | Hecha |
| HU-15 | Como equipo, queremos el modelo de datos normalizado y cargado para construir sobre él. | Alta | 8 pts | Hecha |
| HU-16 | Como equipo, queremos la conexión JDBC centralizada y configurable para no repetirla en cada clase. | Alta | 3 pts | Hecha |

**Total comprometido:** 32 puntos.

### Criterios de aceptación (Definition of Done)

**HU-02 — Registro**
- [x] El formulario pide nombres, apellidos, documento, correo y contraseña.
- [x] La validación se hace en el servidor, no solo en el navegador.
- [x] Si el correo ya existe se muestra *"El correo ya se encuentra registrado"*, nunca una excepción de Java.
- [x] La contraseña se guarda cifrada; jamás en texto plano.
- [x] El usuario, su perfil y su rol se crean en una sola transacción.

**HU-03 — Autenticación y control de acceso**
- [x] Las credenciales se validan contra la base de datos.
- [x] La `HttpSession` guarda el id del usuario y sus roles.
- [x] Un `Filter` protege las rutas privadas.
- [x] Escribir la URL a mano sin el rol adecuado lleva a *acceso denegado*.
- [x] El menú se arma según el rol, pero la validación real está en el servidor.

---

## 2. Sprint Review — qué se entregó

### Modelo de datos
- 16 tablas normalizadas hasta 3FN, cargadas en MySQL con 10+ registros por tabla principal.
- Las tres relaciones exigidas quedan materializadas:
  - **1:1** — `usuario` ↔ `perfil`, garantizada por `UNIQUE (perfil.id_usuario)`.
  - **1:N** — `inmobiliaria` → `propiedad`, `propiedad` → `imagen_propiedad`, `usuario` → `cita`.
  - **N:M** — `usuario_rol` y `propiedad_caracteristica`, ambas con llave primaria compuesta y atributo propio (`fecha_asignacion`, `cantidad`).
- Siete restricciones `UNIQUE` (el enunciado pide tres).

### Conexión JDBC
- `ConexionBD` es la **única** clase que conoce la URL. Los DAO solo piden conexiones.
- La configuración vive en `db.properties`. Cambiar de la instancia local a la
  instancia en línea es cambiar `db.perfil=local` por `db.perfil=online`: no se
  recompila ni se toca una sola clase.

### Autenticación y seguridad
- Contraseñas cifradas con **PBKDF2-HMAC-SHA256**, 120 000 iteraciones y salt
  aleatorio de 16 bytes por usuario. Es una de las tres funciones que permite el
  enunciado y viene dentro del JDK, así que el proyecto no depende de ningún
  `.jar` externo.
- **Evidencia del salt:** los 12 usuarios de prueba comparten la contraseña
  `password` y aun así los 12 hashes guardados son distintos.
- `AutenticacionFilter` intercepta **todas** las peticiones y decide en tres
  pasos: ruta pública → pasa; sin sesión → al login; rol insuficiente → acceso
  denegado (HTTP 403).
- Extras implementados: bloqueo temporal de la cuenta a los 5 intentos fallidos,
  registro de actividad en la tabla `auditoria`, protección contra fijación de
  sesión (se invalida la sesión previa al autenticar) y cookie `HttpOnly`.

### Demostración funcional

| Prueba | Resultado |
|--------|-----------|
| Login `admin@inmobiliaria.com` | 302 → `/panel/admin.jsp` |
| Login `agente.norte@sraiz.com` | 302 → `/panel/inmobiliaria.jsp` |
| Login `carlos.perez@gmail.com` | 302 → `/panel/cliente.jsp` |
| Login `visitante@correo.com` | 302 → `/index.jsp` |
| Contraseña incorrecta | "Correo o contraseña incorrectos." |
| `/panel/admin.jsp` sin sesión | 302 → `login.jsp?motivo=sesion` |
| ADMIN entrando a `/panel/cliente.jsp` | **403 Acceso denegado** |
| Registro con correo repetido | "El correo ya se encuentra registrado." |
| Registro con documento repetido | "Ese número de documento ya está registrado." |
| Contraseñas que no coinciden | "Las dos contraseñas no coinciden." |

---

## 3. Sprint Retrospective

### Qué salió bien
- Diseñar la base de datos antes de programar evitó rehacer trabajo: los DAO
  salieron directo del esquema.
- Centralizar la conexión desde el primer día fue barato y ya se nota: agregar
  la instancia en línea no costará tocar código.
- Probar cada capa apenas se escribió (conexión y hash antes de los servlets)
  detectó los problemas de entorno temprano.

### Qué salió mal
- **Se editó `02_datos.sql` pero no se recargó la base de datos.** El login
  falló con "credenciales incorrectas" porque MySQL seguía con los hashes
  viejos. Se perdió tiempo buscando un error en el código que no existía.
- El entorno impuso restricciones que no se habían previsto: Tomcat 8.5 usa
  `javax.servlet` (no `jakarta`) y compila las JSP con un compilador que solo
  lee class files hasta Java 8.
- El proyecto arrastraba archivos duplicados (una carpeta `inmobiliaria/` con
  una copia vieja del sitio, dos hojas de estilo, cuatro imágenes que son el
  mismo archivo con distinto nombre).

### Acciones para el Sprint 2
1. **Después de cambiar un `.sql`, recargarlo antes de probar.** Se añade el
   paso al README.
2. Dejar documentada la restricción de `--release 8` en `compilar.bat` para que
   nadie la quite por descuido.
3. Eliminar los archivos duplicados en el primer commit del Sprint 2.
4. Migrar la landing page de Tailwind a Bootstrap, que es el framework que
   exige el enunciado.

---

## 4. Deuda técnica que queda abierta

| Asunto | Impacto | Cuándo |
|--------|---------|--------|
| Carpeta `inmobiliaria/` duplicada y archivos repetidos | Ensucia el repositorio | Sprint 2 |
| Repositorio sin remoto en GitHub | El enunciado pide repositorio público | Sprint 2 |
| Tablero Padlet de seguimiento | Entregable explícito de Scrum | Sprint 2 |
| Pruebas unitarias | Entregable del Sprint 3 | Sprint 3 |
| Despliegue en línea | Da puntos adicionales | Sprint 3 |

### Cerrado durante el sprint

- `index.jsp` se migró de Tailwind a Bootstrap, que es el framework que exige el enunciado.
- Se entregaron los dos diagramas en `bd/`: el MER en notación Chen (con las relaciones
  muchos a muchos **sin resolver**, como corresponde a un modelo conceptual) y el modelo
  relacional exportado desde MySQL Workbench (con las tres tablas puente ya materializadas).
