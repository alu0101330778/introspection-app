# introspection-app

Aplicación móvil multiplataforma que traslada al entorno digital la práctica emocional y reflexiva presente en los libros de <nombre del autor>. Inspirada en la mecánica de abrir el libro al azar para encontrar una frase significativa, la app permite acceder a reflexiones de los libros tanto de forma aleatoria como mediante un sistema de recomendación personalizado basado en el estado emocional del usuario.

**Características principales:**
- Registro y seguimiento de emociones mediante interacción inicial.
- Generación de gráficas de evolución emocional.
- Sugerencia de reflexiones .
- Recomendación de productos personalizados según el perfil emocional del usuario.

La aplicación integra literatura, inteligencia artificial y diseño emocional, priorizando una interfaz amable, privacidad y una arquitectura escalable. Es una herramienta con potencial comercial, terapéutico y educativo.

---

## Instalación y puesta en marcha

### 1. Requisitos previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>=3.4.0)
- [Dart SDK](https://dart.dev/get-dart)
- Acceso a un backend compatible (ver `.env`)

### 2. Clonar el repositorio

```sh
git clone <URL-del-repositorio>
cd introspection-app
```

### 3. Instalar dependencias

```sh
flutter pub get
```

### 4. Configurar variables de entorno

Edita el archivo `.env` en la raíz con la URL de tu backend y las emociones:

```
API_BASE_URL=https://tu-backend.com
EMOTIONS=["Alegria", "Miedo", ...]
```

### 5. Ejecutar en local

#### Android/iOS

```sh
flutter run
```

#### Web

```sh
flutter run -d chrome
```

#### Windows/Linux/Mac

```sh
flutter run -d windows
# o
flutter run -d linux
# o
flutter run -d macos
```

### 6. Ejecutar pruebas

```sh
flutter test
```

---

## Estructura principal

- `lib/` — Código fuente de la app
- `test/` — Pruebas
- `doc/` — Documentación detallada ([doc/README.md](doc/README.md))

---

## Más información

Consulta la [documentación detallada](doc/README.md) para conocer todas las funcionalidades