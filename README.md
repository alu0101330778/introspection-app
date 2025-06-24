# introspection-app

Aplicación Flutter multiplataforma para el registro emocional, introspección y bienestar personal.

---

## Descripción

**introspection-app** permite a los usuarios registrar sus emociones diarias, recibir frases motivacionales personalizadas, visualizar su evolución emocional mediante gráficos y acceder a una tienda de productos relacionados con el bienestar. Incluye autenticación segura, perfil de usuario y funcionalidades interactivas.

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