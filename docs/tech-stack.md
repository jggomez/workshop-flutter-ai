# Tech Stack & Architectural Blueprint — Cancun DashBooth

## 1. Visión General del Sistema
- **Plataforma Objetivo:** Flutter Web (CanvasKit / WebGL / Wasm ready).
- **Entorno de Ejecución:** Navegadores modernos móviles y de escritorio (Chrome, Safari, Firefox, Edge).
- **Patrón de Arquitectura:** Clean Architecture desacoplada + Reactive State Management con Riverpod.
- **Backend / Infraestructura:** Firebase (Firebase AI Logic, Cloud Firestore, Firebase Storage, Firebase Hosting).
- **Modelo de IA Generativa:** `gemini-3.1-flash-image` (Google AI Multimodal Image & Text Generation vía `package:firebase_ai`).
- **Sistema de Diseño UI/UX:** [Sistema de Diseño Flutter Caribeño](file:///Users/jggomez/Documents/jggomez/code/workshop-flutter-ia/docs/ui-ux-design.md) (Material 3 Dark, Glassmorphism, Paleta Flutter & Dash, `#flutterconflatam26`).

---

## 2. Dependencias y Paquetes Clave (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # --- State Management & DI ---
  flutter_riverpod: ^2.6.1

  # --- Firebase Core & Services ---
  firebase_core: ^3.10.0
  cloud_firestore: ^5.6.0
  firebase_storage: ^12.4.0

  # --- Firebase AI Logic & REST Fallback ---
  # SDK oficial de Firebase para generación multimodal de imagen y texto (gemini-3.1-flash-image)
  firebase_ai: ^2.3.0
  http: ^1.2.2 # Fallback directo a Google AI Developer API ante 401 App Check en web local

  # --- Captura Multimedia (Web Compatible) ---
  image_picker: ^1.1.2

  # --- Procesamiento de Imagen en Memoria (Web-Safe, sin dart:io) ---
  image: ^4.5.2

  # --- UI Components & Feedback ---
  shimmer: ^3.0.0

  # --- Utilidades Web & Exportación ---
  # Descarga en navegador de Blobs PNG/JPEG sin romper el soporte multiplataforma
  universal_html: ^2.2.4
  uuid: ^4.5.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  mocktail: ^1.0.4
```

---

## 3. Decisiones de Stack y Racional Técnico

### A. Firebase AI Logic (`firebase_ai`) con `gemini-3.1-flash-image` (Estrategia Dual-Channel y Gestión de API Key)

* **Modelo:** `gemini-3.1-flash-image` (Google AI Multimodal Image & Text Generation).
* **Por qué:** Soporta nativamente salida multimodal simultánea de texto e imagen mediante `GenerationConfig(responseModalities: [ResponseModalities.text, ResponseModalities.image])`. Transforma la fotografía del asistente directamente a través de IA, generando una ilustración caribeña completa con Dash en la playa sin requerir estampados manuales invasivos ni exponer API Keys adicionales.
* **Flujo Multimodal Directo:**
  1. **Entrada:** Se envía el buffer de la selfie (`InlineDataPart('image/jpeg', photoBytes)`) junto a un prompt en **inglés** formulado bajo las mejores prácticas para modelos de difusión/imagen de Google (*Subject, Character Anchoring, Scene, Style, Lighting, Mood*):
     > *"A vibrant, high-quality digital art portrait of the conference attendee ([name]) from the reference photo celebrating at FlutterConf LATAM Cancún 2026. Standing happily right next to the attendee is Dash, the official Flutter mascot. CRITICAL MASCOT DETAILS: Dash is a cute, round, chubby, fluffy blue plush bird toy (NOT a dolphin, NOT a fish, NOT an aquatic animal). Dash has a plump round body covered in soft cyan and royal-blue felt feathers with a cream-white belly patch, large friendly round cartoon eyes, a tiny short triangular orange beak, two small rounded blue bird wings, and two tiny orange bird feet standing on the sand. Setting: picturesque tropical Cancun beach in Quintana Roo, Mexico, with turquoise Caribbean ocean in the background, fine white sand of the Riviera Maya, swaying green palm trees under bright warm sunlight, with subtle colorful Mexican festival touches. Style: polished conference badge illustration, sharp focus, rich colors, joyful and festive atmosphere. CRITICAL REQUIREMENT FOR THE TEXT VIBE: You MUST provide a short, punchy 3 to 5 word conference vibe or title in Spanish that ALWAYS includes authentic Mexican phrases and regional expressions from Cancún, Quintana Roo, and Yucatán (such as '¡Qué Chido!', 'Bomba Yucateca', 'Vibra Maya', '¡Qué Padre!', 'A Toda Madre', 'Cenote', 'Kukulcán', 'Mayab', 'Marquesita', etc.). Examples of expected output: '¡Qué Chido Cancún! 100%', 'Bomba Yucateca de Código', 'Vibra Maya 100% Chida', '¡Qué Padre la Riviera!', 'Kukulcán del Hot Reload', 'Cenote Sagrado 99%'. Do not include quotes, markdown, or conversational filler."*
  2. **Inferencia y Desempaquetado:** Se extraen las partes de `response.candidates.firstOrNull?.content.parts`:
     - `InlineDataPart`: Bytes de la nueva imagen ilustrada generada por IA (`generatedImageBytes`).
     - `TextPart`: Título/vibe tropical del asistente (`aiVibeTitle`).
  3. **Resultado Unificado:** Retorna la entidad de dominio `AiBadgeResult(imageBytes: generatedImageBytes ?? photoBytes, aiVibeTitle: cleanVibe)`.

* **Origen y Ciclo de Vida de la API Key:**
  1. **Fuente de Verdad:** La API Key (`AIzaSy...`) reside en [`lib/firebase_options.dart`](file:///Users/jggomez/Documents/jggomez/code/workshop-flutter-ia/lib/firebase_options.dart#L19-L26) bajo `DefaultFirebaseOptions.web.apiKey`. Es la clave pública de cliente generada automáticamente por Firebase para el proyecto `dashbooth-cancun-2026`.
  2. **Inyección en `FirebaseAI`:** Al ejecutar `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` en [`lib/main.dart`](file:///Users/jggomez/Documents/jggomez/code/workshop-flutter-ia/lib/main.dart), Firebase almacena las opciones en `Firebase.app().options`. Cuando el SDK `FirebaseAI.googleAI()` instancia `HttpApiClient`, extrae internamente `Firebase.app().options.apiKey` y la adjunta en el encabezado HTTP `x-goog-api-key`.
  3. **Inyección en Fallback:** Si se requiere llamar a la API REST de respaldo, el datasource lee exactamente la misma clave desde `DefaultFirebaseOptions.web.apiKey`.

* **Diagnóstico del Error 401 (Unauthorized) en Web:**
  * El paquete oficial `firebase_ai` enruta sus peticiones a `https://firebasevertexai.googleapis.com/v1beta/projects/<projectId>/models/...`.
  * En clientes Web, esta pasarela de Firebase Vertex AI exige tokens de **Firebase App Check** (`X-Firebase-AppCheck`) cuando el enforcement está activo, o rechaza con 401 si los permisos IAM de la API `firebasevertexai.googleapis.com` en Google Cloud están en proceso de propagación (los cuales pueden tardar unos minutos tras habilitarse en la consola de Firebase).
  * En entornos de desarrollo local (`localhost:8080`), la ausencia de un proveedor de App Check (`ReCaptchaV3Provider`) genera el error 401.

* **Arquitectura de Resiliencia Dual-Channel (A prueba de fallos en conferencia):**
  ```mermaid
  flowchart TD
      A["Usuario captura foto"] --> B["Canal 1: FirebaseAI.googleAI()\nSDK Oficial de Firebase AI"]
      B -->|200 OK| D["Resultado Multimodal Oficial\n(Imagen Ilustrada + IA Vibe)"]
      B -->|401 App Check / Timeout| C["Canal 2: Google AI Gemini Developer API REST\n(Misma API Key + gemini-3.1-flash-image)"]
      C -->|200 OK| D
      C -->|Offline / Red Inestable| E["Canal 3: Fallback Determinista\n(Foto original + Frase Mexicana/Yucateca Breve)"]
  ```
  1. **Canal 1 (Principal):** Invocación oficial con `package:firebase_ai` usando `FirebaseAI.googleAI().generativeModel(model: 'gemini-3.1-flash-image')`.
  2. **Canal 2 (Respaldo Transparente):** Si Canal 1 arroja cualquier excepción (como el 401 de App Check o timeout de 20s), se ejecuta inmediatamente una petición HTTP POST a `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-image:generateContent?key=$apiKey`. Este endpoint comparte la misma cuota del proyecto de Google Cloud, no exige App Check y devuelve idéntica salida de imagen y texto.
  3. **Canal 3 (Catálogo Offline):** Si ambos canales fallan por pérdida total de conexión Wi-Fi, se preserva la foto original del asistente y se asigna una frase mexicana/yucateca corta calculada por hash determinista (ej: *"¡Qué Chido Cancún! 100%"*, *"Bomba Yucateca de Código"*, *"Vibra Maya Sagrada 99%"*).


### B. Cloud Firestore & Firebase Storage con Estrategia Zero-Auth

* **Por qué Firestore + Storage (y NO Auth):** En un workshop o conferencia en vivo, exigir autenticación (login con contraseña o OAuth) introduce alta fricción, fallos por bloqueadores de popups y demoras. La aplicación opera bajo una **estrategia Zero-Auth (sin login)** donde el asistente solo ingresa su nombre y correo en el formulario.
* **Separación de Responsabilidades (Cloud Best Practice):**
  * **Firebase Storage (`firebase_storage`):** Almacena los archivos binarios de imagen de las credenciales compuestas (`user_cards/{autoId}.png`). Aprovecha la CDN global de Google para entrega y caché ultrarrápido en los navegadores.
  * **Cloud Firestore (`cloud_firestore`):** Almacena únicamente los metadatos ligeros de la credencial en la colección **`UserCards`** con ID autogenerado por Firestore.
* **Estructura del Documento en `UserCards`:**
  ```json
  {
    "id": "auto-generated-by-firestore",
    "name": "Juan Pérez",
    "email": "juan@example.com",
    "imageUri": "https://firebasestorage.googleapis.com/v0/b/.../user_cards%2Fxxx.png?alt=media",
    "createdAt": "FieldValue.serverTimestamp()"
  }
  ```
* **Ventajas de Rendimiento:** Al almacenar únicamente `imageUri` en Firestore, las lecturas en tiempo real (`snapshots()`) del mural comunitario son extremadamente veloces, livianas en ancho de banda y eliminan cualquier preocupación sobre el límite de 1MB por documento de Firestore.
* **Reglas de Seguridad Públicas con Validación Estricta de Esquema:** El acceso a la colección `UserCards` no requiere `request.auth`, pero valida rigurosamente la integridad de los datos en `firestore.rules`:
  ```javascript
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /UserCards/{cardId} {
        // Lectura pública para proyectar y explorar el collage en vivo
        allow read: if true;

        // Creación pública sin login: valida tipos, longitud y formato
        allow create: if request.resource.data.name is string
                      && request.resource.data.name.size() >= 2
                      && request.resource.data.name.size() <= 50
                      && request.resource.data.email is string
                      && request.resource.data.email.size() >= 5
                      && request.resource.data.imageUri is string
                      && request.resource.data.imageUri.matches('https?://.*')
                      && request.resource.data.createdAt is timestamp;

        // Modificaciones y eliminaciones prohibidas para clientes
        allow update, delete: if false;
      }
    }
  }
  ```

### C. Riverpod (`flutter_riverpod`)

* **Por qué:** Inyección de dependencias segura en tiempo de compilación, desacoplamiento absoluto de la UI respecto a la lógica de negocio, y manejo reactivo de estados asíncronos mediante `AsyncValue` (`data`, `loading`, `error`) y `StreamProvider` para los streams de Firestore.

### E. Política de Privacidad y Cero Datos Ficticios (Zero-Fake-Data Policy)

* **Eliminación de Emails Sintéticos:** Anteriormente, el formulario de publicación asignaba por defecto `'pioneer@flutterconf.latam'` si el asistente dejaba el campo de correo vacío. Esta práctica violaba el principio de fidelidad de datos y confundía a los organizadores durante la ruleta de premios.
* **Persistencia Fiel:** Si el usuario no proporciona un correo electrónico, se almacena como cadena vacía `""`.
* **Filtrado en Componentes de Presentación (`_isRealUserEmail`):**
  Tanto en la ruleta de giro como en el podio oficial de Fórmula 1 ([`F1RouletteDialog`](file:///Users/jggomez/Documents/jggomez/code/workshop-flutter-ia/lib/presentation/widgets/f1_roulette_dialog.dart)), se evalúa la función de guardia:
  ```dart
  bool _isRealUserEmail(String? email) {
    if (email == null) return false;
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty) return false;
    if (trimmed.contains('pioneer@flutterconf.latam') ||
        trimmed.contains('asistente@flutterconf.latam') ||
        trimmed.contains('dash@flutterconf.latam')) {
      return false;
    }
    return true;
  }
  ```
  Si el asistente no suministró un correo auténtico, la línea de correo se omite limpiamente en la UI, resaltando su nombre, avatar, trofeo y pedestal oficial sin exponer datos sintéticos.

### F. Diseño Responsivo Universal & Eliminación de Colapsos en CanvasKit

* **Problema de CanvasKit con Shaders y Layouts no Acotados:** En Flutter Web, aplicar `BoxDecoration(gradient: ...)` a botones dentro de filas sin restricciones fijas provoca fallos de shader (`MakeLinearGradient: null` / `TypeError: reading 'toString'`). Adicionalmente, el anidamiento de `Expanded` dentro de contenedores flexibles con restricciones mínimas laxas colapsaba los textos letra por letra de forma vertical en ventanas estrechas.
* **Banner 100% Horizontal Permanente:** Se eliminaron las ramificaciones de diseño que forzaban una disposición vertical (`Column`) del banner en anchos `< 720px`. El banner superior del mural ahora es permanentemente horizontal mediante `Row(mainAxisAlignment: MainAxisAlignment.spaceBetween)`, con `Expanded` y `TextOverflow.ellipsis` en los textos y un botón compacto `_buildRouletteCtaButton` (`isCompact: isNarrow`).
* **Botón Flotante Persistente (FAB):** Se incorporó un `FloatingActionButton.extended` con `heroTag: 'f1_roulette_fab'` anclado en `bottom: 24, right: 24`, garantizando acceso instantáneo a la ruleta F1 sin importar la posición de scroll del usuario.

### G. Protección de Cuota IA y Bloqueo Post-Publicación

* **Prevención de Doble Gasto de IA:** Una vez que una credencial es compartida exitosamente en el mural en vivo (`isPublished == true`), el formulario, el visor de cámara y el botón de transformación se bloquean mediante `IgnorePointer` y atenuación visual (`Opacity(0.65)`).
* **Flujo Explícito de Nueva Credencial:** Se deshabilita el botón de publicación y se despliega la tarjeta de felicitación con el botón primario hero *"Crear Otra Credencial ✨"*. Esta acción limpia de manera controlada el borrador, los controladores y los estados de Riverpod, evitando consumos accidentales de cuota de Gemini en credenciales ya persistidas.
* **Copy Centrado en el Usuario:** Se prohíbe el uso de mensajes técnicos de infraestructura ("Subiendo a Firestore y Storage..."). Toda retroalimentación utiliza lenguaje humano y empático: *"Compartiendo en el Mural..."* y *"¡Tu credencial ha sido publicada en el Mural en Vivo! 🎉"*.

---

## 4. Matriz de Alineación con Skills Oficiales y User Stories

Cada tecnología y requerimiento del proyecto está respaldado por skills especializadas disponibles en el entorno:

| Área / Tecnología | User Stories Relacionadas | Skills Oficiales Asignadas | Propósito de la Skill |
| :--- | :--- | :--- | :--- |
| **Arquitectura & Capas** | Todas (US-01 a US-06) | `flutter-apply-architecture-best-practices` | Diseño estricto de capas (Domain, Data, Presentation) y flujo unidireccional. |
| **Captura & Layout Web** | US-01, US-03, US-04, US-05, US-06 | `flutter-build-responsive-layout`, `flutter-add-widget-preview` | Layouts adaptativos (Mobile, Tablet & Desktop Web), vistas previas desacopladas. |
| **Firebase AI Logic** | US-02 | `firebase-ai-logic-basics` | Inicialización de AI Logic, uso de `gemini-3.1-flash-image`, generación multimodal de imagen y texto con prompt optimizado en inglés. |
| **Cloud Firestore & Storage** | US-04, US-05 | `firebase-firestore`, `firebase-basics` | Modelado de datos, streams reactivos (`snapshots()`), colecciones y reglas. |
| **Testing & TDD** | Todas (US-01 a US-06) | `test-driven-development`, `dart-add-unit-test`, `flutter-add-widget-test`, `flutter-add-integration-test` | Ciclos Red-Green-Refactor, tests de dominio con `test`, tests de widgets con `WidgetTester`. |
| **Calidad de Código** | Todas | `dart-run-static-analysis`, `code-smells-expert`, `refactoring-code-expert` | Ejecución de `dart analyze`, detección de smells y refactorización continua. |
| **Despliegue & Hosting** | US-03, US-04, US-05 | `firebase-hosting-basics`, `flutter-release-engineering` | Despliegue en Firebase Hosting y optimización de compilación web. |

---

## 5. Invariantes Arquitecturales (Reglas No Negociables)

### Regla 1: Prohibición de `dart:io` (Web-Safe Memory Architecture)
* Está **estrictamente prohibido** importar `dart:io` (e.g., `File`, `Directory`).
* Toda imagen (capturada, generada o exportada) se manipula exclusivamente como buffer de memoria inmutable: **`Uint8List`**.

### Regla 2: Separación Estricta de Capas (Clean Architecture)
```text
lib/
├── domain/            # 100% Dart puro (Sin dependencias de Flutter ni Firebase)
│   ├── entities/      # Modelos inmutables (BadgeDraft, AiBadgeResult, UserCard)
│   ├── repositories/  # Interfaces y contratos abstractos (IAiBadgeService, IUserCardRepository)
│   └── usecases/      # Casos de uso de negocio puros
│
├── data/              # Implementaciones concretas de infraestructura
│   ├── datasources/   # Wrappers directos de image_picker, firebase_ai, storage y firestore
│   ├── models/        # DTOs y serializadores (fromFirestore, toFirestore, JSON)
│   └── repositories/  # Implementación de los contratos de domain
│
└── presentation/      # UI, Widgets y Manejo de Estado
    ├── providers/     # Notifiers, StateNotifiers y StreamProviders de Riverpod
    ├── screens/       # Pantallas principales (PhotoboothScreen, CommunityWallScreen, MainHomeScreen)
    ├── utils/         # Utilidades web (WebImageDownloader, SocialShareService)
    └── widgets/       # Widgets atómicos y visuales (OfficialBadgeCard, F1RouletteDialog, CommunityBadgeItem)
```

### Regla 3: Aislamiento del Árbol de Widgets (No Business Logic in UI)
* Ningún widget puede instanciar directamente `FirebaseFirestore`, `FirebaseAI` o `ImagePicker`.
* Los widgets interactúan **exclusivamente** con providers de Riverpod mediante `ConsumerWidget` o `ConsumerStatefulWidget`.
* Los estados asíncronos se consumen vía `AsyncValue` para renderizar spinners, skeleton shimmers o mensajes de error sin bloquear el hilo de la UI.

### Regla 4: Resiliencia ante Fallos de Red (Offline/Timeout Fallback)
* Las llamadas al modelo `gemini-3.1-flash-image` deben contar con un timeout estricto de **15 segundos**.
* Ante timeout o error de red, la capa `data/` activa el catálogo de títulos caribeños predefinidos y preserva limpiamente la fotografía original del asistente en memoria sin alteraciones invasivas ni artefactos, garantizando la continuidad del flujo en el evento en vivo.

### Regla 5: Separación de Almacenamiento (Firebase Storage para Imágenes)
* Los archivos binarios de imagen se almacenan exclusivamente en Firebase Storage (`user_cards/{cardId}.png`). En Cloud Firestore únicamente se persiste la URL pública (`imageUri`), manteniendo los documentos en `UserCards` ultra-livianos (< 2 KB).

### Regla 6: Estrategia Zero-Auth (Fricción Cero en Conferencia)
* Está **estrictamente prohibido** forzar formularios de login, pantallas de registro o dependencias de Firebase Auth.
* La interacción con Firestore y Storage se realiza de forma directa y abierta bajo la colección `UserCards` y el bucket de Storage, protegida por validación de esquema en `firestore.rules` y `storage.rules`.

### Regla 7: Cero Datos Ficticios o Correos Inventados
* El sistema **nunca** inventará correos ficticios (como `pioneer@flutterconf.latam`) si el asistente decide no ingresarlo.
* La UI de la ruleta y podio F1 filtra proactivamente cualquier correo que no haya sido suministrado explícitamente por el usuario.

### Regla 8: Protección de Cuota de IA y Bloqueo Post-Publicación
* Al publicar una credencial en el mural en vivo, los controles de entrada y transformación de IA quedan bloqueados para impedir sobrecostos o duplicaciones innecesarias, hasta que el asistente active explícitamente "Crear Otra Credencial ✨".

---

## 6. Sensory Verification & Gates (Condición de Parada)
Para que cualquier incremento se considere completado:
1. `dart analyze --fatal-infos` debe arrojar **0 issues**.
2. Todas las pruebas unitarias y de widgets (`flutter test`) deben ejecutarse y pasar al 100%.
3. No deben existir imports de `dart:io` ni advertencias de deprecación.