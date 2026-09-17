# 🏖️ Cancun DashBooth — FlutterConf LATAM 2026

[![Flutter Web](https://img.shields.io/badge/Platform-Flutter%20Web-02569B?logo=flutter)](https://flutter.dev)
[![Firebase AI Logic](https://img.shields.io/badge/AI-Firebase%20AI%20%7C%20Gemini-FFCA28?logo=firebase)](https://firebase.google.com)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture%20%2B%20Riverpod-00B4D8)](docs/tech-stack.md)
[![Quality Gates](https://img.shields.io/badge/Tests-57%2F57%20Passed%20(100%25)-green)](test/)
[![Harness Lab](https://img.shields.io/badge/Hands--on%20Lab-AI%20Harness%20Engineering-orange)](lab/README.md)
[![Live Production App](https://img.shields.io/badge/Live%20App-dashbooth--cancun--2026.web.app-success?logo=firebase)](https://dashbooth-cancun-2026.web.app)

> 🌐 **App en Producción (Firebase Hosting):** [https://dashbooth-cancun-2026.web.app](https://dashbooth-cancun-2026.web.app)

**Cancun DashBooth** es la aplicación web interactiva oficial de **FlutterConf LATAM 2026 en Cancún, México**.

Diseñada para una experiencia de usuario fluida y festiva, permite a los asistentes registrarse sin autenticación (**Zero-Auth**), capturar una selfie desde el navegador, transformarla con **Firebase AI Logic (`gemini-3.1-flash-image`)** en un retrato ilustrado en la playa de Cancún junto a **Dash** (la mascota oficial de Flutter), componer su credencial oficial VIP con el hashtag `#flutterconflatam26`, publicarla en tiempo real en un mural colaborativo, participar en un sorteo estilo **Fórmula 1** con podio tridimensional y compartir su credencial en **Instagram**.

---

## 🚀 Inicio Rápido (Quickstart)

### 1. Aprovisionar el Harness y las Agent Skills
Ejecuta el script automatizado para instalar las skills oficiales de Flutter, Dart y Firebase, junto con las del repositorio de ingeniería avanzada [jggomez/expert-ai-developer-skills](https://github.com/jggomez/expert-ai-developer-skills):

```bash
chmod +x skills.sh
./skills.sh
```

### 2. Instalar Dependencias y Ejecutar Pruebas
```bash
flutter pub get
dart analyze --fatal-infos
flutter test
```

### 3. Ejecutar Localmente en el Navegador
```bash
flutter run -d chrome
```
o probar el build de producción CanvasKit:
```bash
flutter build web --release
python3 -m http.server 8080 -d build/web
# Abrir en http://localhost:8080
```

---

## 📚 Laboratorio Paso a Paso (`lab/`)

¿Quieres aprender a construir esta aplicación desde cero utilizando **AI Harness Engineering**, **Agent Skills** y **Autonomous Looping (`/goal`)**?

Explora la guía completa en el directorio [`lab/`](lab/README.md):

* 📘 **[Módulo 1: Harness Engineering, Skills y Plugin senior-dev-flutter](lab/01-harness-and-skills.md):** Configuración del entorno con `skills.sh`, MCP de Dart y reglas del proyecto.
* 📗 **[Módulo 2: Spec-First & Documentación Viva](lab/02-spec-and-doc-driven-dev.md):** Cómo crear `docs/tech-stack.md`, `docs/user-stories.md` y `docs/plan.md` antes de codificar.
* 📙 **[Módulo 3: Demostración de Looping con /goal para Construir el MVP](lab/03-looping-con-goal-mvp.md):** Anatomía de los bucles autónomos, prompts maestros y autocorrección.
* 📕 **[Módulo 4: Paso a Paso de la Implementación Core](lab/04-core-implementation-paso-a-paso.md):** Clean Architecture en Domain, Data con Firebase AI y Presentation con Riverpod.
* 📒 **[Módulo 5: Refinamiento Iterativo y Lecciones del Pulido](lab/05-refinamiento-iterativo-y-maduracion.md):** Protección de cuota IA, prompt de Dash, ruleta F1, Zero-Fake-Data y CanvasKit responsive.
* 📓 **[Módulo 6: Quality Gates, Testing Sensorial y Despliegue](lab/06-verificacion-calidad-y-despliegue.md):** Auditoría estática, 57 tests verdes y despliegue en Firebase Hosting.
* 📖 **[Flutter Engineering Playbook](lab/flutter-playbook.md):** Guía completa de capacidades, The Three Trees, DevTools, vocabulario, patrones de diseño, librerías y buenas prácticas.

---

## 🏛️ Arquitectura del Sistema

El proyecto sigue una estricta **Clean Architecture desacoplada**:

```text
lib/
├── domain/            # 100% Dart puro (BadgeDraft, AiBadgeResult, UserCard, Casos de Uso)
├── data/              # Firebase AI (gemini-3.1-flash-image dual-channel), Storage y Firestore
└── presentation/      # Notifiers Riverpod, PhotoboothScreen, CommunityWallScreen, F1RouletteDialog
```

Para conocer todas las decisiones y justificaciones técnicas, consulta:
* [Documento de Stack Tecnológico e Invariantes](docs/tech-stack.md)
* [Historias de Usuario y Criterios Gherkin BDD](docs/user-stories.md)
* [Plan Maestro de Ejecución](docs/plan.md)
* [Tokens y Sistema de Diseño UI/UX Caribeño](docs/ui-ux-design.md)

---

## 🛠️ Tecnologías y Plugins

* **Framework:** Flutter Web (CanvasKit/Wasm).
* **Gestión de Estado:** `flutter_riverpod` (v2.6.1).
* **IA Generativa Multimodal:** `firebase_ai` (`gemini-3.1-flash-image`) + Fallback REST a Google AI Developer API.
* **Base de Datos & Almacenamiento:** Cloud Firestore (`UserCards`) y Firebase Storage (`user_cards/`) bajo estrategia **Zero-Auth**.
* **Plugin de Agentes:** [`senior-dev-flutter`](.agents/plugins/senior-dev-flutter) de [jggomez/expert-ai-developer-skills](https://github.com/jggomez/expert-ai-developer-skills).

---

## 📄 Licencia

Este proyecto está disponible bajo la licencia Apache 2.0. Desarrollado con pasión para la comunidad de Flutter en América Latina. 🌴💙🦜
