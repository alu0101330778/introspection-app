# Documentación de la aplicación introspection-app

## Descripción general

**introspection-app** es una aplicación Flutter multiplataforma diseñada para fomentar la introspección personal, el registro emocional y el bienestar a través de funcionalidades como frases motivacionales, seguimiento de emociones, perfil de usuario, tienda de productos y más.

---

## Características principales

### 1. Autenticación de usuarios
- Registro y login con validación de campos.
- Almacenamiento seguro del token y datos del usuario.
- Recuperación de sesión automática si el token es válido.

### 2. Página de inicio (`PaginaInicial`)
- Mensaje de bienvenida personalizado.
- Selección de emociones diarias (máximo 3).
- Confirmación y registro de emociones en el backend.
- Navegación automática a la generación de frase motivacional tras registrar emociones.

### 3. Generación de frases motivacionales (`PaginaFrase`)
- Muestra una frase personalizada basada en las emociones seleccionadas.
- Animaciones para mostrar título, cuerpo y cierre de la frase.
- Opción para marcar la frase como favorita.
- Botón para volver al inicio.

### 4. Home principal (`PaginaHome`)
- Visualización de la última frase generada.
- Sección de texto motivacional semanal.
- Sección interactiva con recursos multimedia.
- Navegación entre Home, Perfil, Frase y Tienda mediante barra inferior.

### 5. Perfil de usuario (`PaginaPerfil`)
- Visualización de datos del usuario.
- Gráficos de emociones (radar y temporal) usando `fl_chart`.
- Listado y gestión de frases favoritas (eliminar de favoritos).
- Paginación de gráficos de emociones por días.

### 6. Tienda de productos (`TiendaPage`)
- Catálogo de productos agrupados por categorías (Tea, Suplement, Book, Aromatherapy).
- Búsqueda y filtrado de productos.
- Visualización de detalles de producto, stock y precio.
- Productos relacionados por categoría.
- Botón para añadir al carrito (funcionalidad base).

---

## Estructura de carpetas relevante

- `lib/` — Código fuente principal de la app.
- `test/` — Pruebas unitarias y de widgets.
- `doc/` — Documentación del proyecto.
- `.env` — Variables de entorno (API, emociones, etc).
- `pubspec.yaml` — Dependencias y configuración de Flutter.

---

## Integración con backend

- Utiliza endpoints REST para autenticación, registro de emociones, obtención de frases, gestión de usuario y productos.
- El backend debe estar especificado en `.env` bajo `API_BASE_URL`.

---

## Seguridad

- Uso de `flutter_secure_storage` para almacenar tokens y datos sensibles.
- Validaciones estrictas en formularios de login y registro.

---

## Tecnologías y paquetes usados

- **Flutter** (multiplataforma)
- **fl_chart** (gráficos)
- **http** (peticiones REST)
- **flutter_secure_storage** (almacenamiento seguro)
- **flutter_dotenv** (variables de entorno)
- **Material Design** (UI)

---

## Navegación principal

- `/auth` — Autenticación
- `/inicial` — Selección de emociones y bienvenida
- `/paginaFrase` — Frase motivacional
- `/home` — Página principal
- `/perfil` — Perfil de usuario
- `/tienda` — Tienda de productos

---

## Pruebas

- Pruebas de widgets y servicios en la carpeta `test/`.
- Validaciones de formularios y lógica de negocio.

---

## Personalización

- Emociones y API configurables desde `.env`.
- Fácil extensión para nuevas categorías de productos o funcionalidades.

---

## Contacto y soporte

Para dudas o soporte, consulta el repositorio o contacta con el equipo de desarrollo.