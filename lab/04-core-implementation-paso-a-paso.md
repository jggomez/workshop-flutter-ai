# Módulo 4: Paso a Paso de la Implementación Core (Clean Architecture + TDD)

> **Ruta:** `lab/04-core-implementation-paso-a-paso.md`  
> **Objetivo del Módulo:** Recorrer paso a paso el código real implementado para construir el núcleo (Core MVP) de Cancun DashBooth, entendiendo cómo se articulan las capas desacopladas de **Clean Architecture**, la reactividad de **Riverpod** y la integración sin fricciones de **Firebase AI** y **Cloud Storage**.

---

## 1. Visión Estructural de Capas (Clean Architecture)

El código fuente de Cancun DashBooth en `lib/` está organizado bajo el principio de inversión de dependencias: las capas internas nunca conocen a las capas externas.

```text
lib/
├── domain/            # 1. Capa Central (Dart Puro, Cero dependencias de UI o Firebase)
│   ├── entities/      # BadgeDraft, AiBadgeResult, UserCard
│   ├── repositories/  # Contratos abstractos (ICameraService, IAiBadgeService, IUserCardRepository)
│   └── usecases/      # Reglas de negocio (GenerateAiBadgeUseCase, PublishUserCardUseCase)
│
├── data/              # 2. Infraestructura & Adaptadores
│   ├── datasources/   # Firebase AI Logic, Cloud Firestore, Firebase Storage, CameraService
│   ├── models/        # DTOs y serializadores (UserCardModel from/to Firestore)
│   └── repositories/  # Implementaciones concretas de los contratos de domain/
│
└── presentation/      # 3. Interfaz de Usuario & Estado
    ├── providers/     # Notifiers y StreamProviders de Riverpod
    ├── screens/       # PhotoboothScreen, CommunityWallScreen, MainHomeScreen
    ├── theme/         # AppColors, AppGradients, AppTheme (Material 3 Dark)
    ├── utils/         # WebImageDownloader, SocialShareService
    └── widgets/       # OfficialBadgeCard, F1RouletteDialog, CommunityBadgeItem, GlassContainer
```

---

## 2. Paso 1: Scaffolding Web y Configuración de Dependencias

### 2.1. Creación del Proyecto Web
El proyecto se inicializa habilitando exclusivamente la plataforma web:

```bash
flutter create . --platforms=web --project-name=cancun_dashbooth --org=latam.flutterconf
```

### 2.2. Dependencias en `pubspec.yaml`
Se declaran los paquetes esenciales garantizando compatibilidad total con Flutter Web (CanvasKit y Wasm):

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Manejo de Estado Reactivo & DI
  flutter_riverpod: ^2.6.1

  # Servicios Cloud de Firebase
  firebase_core: ^3.10.0
  cloud_firestore: ^5.6.0
  firebase_storage: ^12.4.0

  # IA Generativa Multimodal (Gemini)
  firebase_ai: ^2.3.0
  http: ^1.2.2 # Fallback ante 401 de App Check

  # Multimedia & Procesamiento en Memoria (Web-Safe)
  image_picker: ^1.1.2
  image: ^4.5.2

  # UI & Efectos Visuales
  google_fonts: ^6.2.1
  shimmer: ^3.0.0
  universal_html: ^2.2.4
  uuid: ^4.5.1
```

---

## 3. Paso 2: Capa de Dominio (100% Dart Puro & TDD)

La capa de dominio no importa `package:flutter` ni `package:firebase_*`. Esto permite que las pruebas unitarias se ejecuten en milisegundos sin arrancar emuladores ni entornos gráficos.

### 3.1. Entidades Inmutables
* [`BadgeDraft`](../lib/domain/entities/badge_draft.dart): Representa el borrador de trabajo del participante:
  ```dart
  class BadgeDraft {
    final String attendeeName;
    final String attendeeEmail;
    final Uint8List? rawPhotoBytes;
    final String? aiVibeTitle;
    final DateTime createdAt;
    // Constructor inmutable con validaciones y copyWith
  }
  ```
* [`AiBadgeResult`](../lib/domain/entities/ai_badge_result.dart): Encapsula la salida de la IA generativa:
  ```dart
  class AiBadgeResult {
    final Uint8List imageBytes;
    final String aiVibeTitle;
  }
  ```
* [`UserCard`](../lib/domain/entities/user_card.dart): Representa la tarjeta conmemorativa persistida en la comunidad:
  ```dart
  class UserCard {
    final String id;
    final String name;
    final String email;
    final String imageUri;
    final DateTime createdAt;
  }
  ```

### 3.2. Contratos Abstractos
* [`ICameraService`](../lib/domain/repositories/i_camera_service.dart): `captureSelfie()` y `pickImageFromGallery()`.
* [`IAiBadgeService`](../lib/domain/repositories/i_ai_badge_service.dart): `generateDashBadge({required Uint8List photoBytes, required String attendeeName})`.
* [`IUserCardRepository`](../lib/domain/repositories/i_user_card_repository.dart): `uploadBadgeImage(...)`, `createUserCard(...)` y `streamCommunityCards()`.

### 3.3. Casos de Uso con TDD
Implementamos los casos de uso con sus respectivas pruebas unitarias en `test/domain/usecases/`:
* `GenerateAiBadgeUseCase`: Valida que los bytes de entrada no estén vacíos y delega al servicio de IA.
* `PublishUserCardUseCase`: Valida los datos, sube el binario a Firebase Storage, obtiene el `imageUri` y registra el documento en Firestore.
* `GetCommunityStreamUseCase`: Retorna el stream reactivo ordenado para el mural comunitario.

---

## 4. Paso 3: Capa de Datos e Infraestructura Firebase

### 4.1. Servicio de Cámara Web-Safe (`CameraServiceImpl`)
Usa `image_picker` llamando a `pickImage(source: ImageSource.camera)` y extrayendo inmediatamente los bytes en memoria con `await pickedFile.readAsBytes()`. **Nunca** utiliza `File(pickedFile.path)` para garantizar que funcione en cualquier navegador.

### 4.2. DataSource de Firebase AI Logic con Resiliencia Dual-Channel
En [`AiBadgeRemoteDataSource`](../lib/data/datasources/ai_badge_remote_datasource.dart):
1. **Canal Principal (`package:firebase_ai`):** Se instancia el modelo `gemini-3.1-flash-image` configurando `responseModalities: [ResponseModalities.text, ResponseModalities.image]`.
2. **Canal Secundario (REST API Fallback):** Si ocurre una excepción en el SDK o timeout de 20s, se dispara un POST directo a `https://firebasevertexai.googleapis.com/v1beta/projects/$projectId/models/gemini-3.1-flash-image:generateContent?key=$apiKey`.
3. **Canal Terciario (Catálogo Offline):** Si no hay conexión, se preserva la foto original del usuario y se asigna un título caribeño determinista.

### 4.3. Almacenamiento Zero-Auth (Storage + Firestore)
* **Firebase Storage:** Sube a `user_cards/{cardId}.png` con `SettableMetadata(contentType: 'image/png')` y obtiene la URL de descarga pública.
* **Cloud Firestore:** Almacena únicamente el documento ligero en `UserCards`:
  ```dart
  await firestore.collection('UserCards').doc(card.id).set({
    'name': card.name,
    'email': card.email,
    'imageUri': card.imageUri,
    'createdAt': FieldValue.serverTimestamp(),
  });
  ```

---

## 5. Paso 4: Capa de Presentación Reactiva con Riverpod

La UI se mantiene 100% desacoplada de la lógica mediante los siguientes providers:

* **`badgeDraftProvider`:** Administra el nombre, email, selfie capturada y reseteo del formulario.
* **`aiGenerationProvider`:** Un `AsyncNotifier<AiBadgeResult?>` que gestiona el estado de carga (`loading`), los mensajes dinámicos de Dash y el resultado procesado.
* **`cardPublishProvider`:** Gestiona el estado asíncrono de publicación en el mural colaborativo.
* **`communityWallProvider`:** Un `StreamProvider<List<UserCard>>` que escucha en tiempo real las novedades de Firestore mediante `snapshots()`.

---

## 6. Paso 5: Composición Oficial de la Credencial & Descarga Web

### 6.1. Componente `OfficialBadgeCard`
En [`OfficialBadgeCard`](../lib/presentation/widgets/official_badge_card.dart):
* Proporción vertical clásica 4:5.
* Encabezado con logotipo de FlutterConf LATAM Cancún.
* Retrato estilizado del asistente con Dash.
* Píldora brillante `✨ IA Vibe: [título]` con gradiente caribeño turquesa y borde dorado.
* Chip dorado NFC PASS y código de barras conmemorativo.
* Pie de página limpio con el hashtag `#flutterconflatam26`.

### 6.2. Descarga Nativa Web en Alta Definición
Para evitar imágenes borrosas en pantallas Retina, [`WebImageDownloader`](../lib/presentation/utils/web_image_downloader.dart) envuelve la tarjeta en un `RepaintBoundary`, renderiza a `pixelRatio: 2.0` y descarga el Blob PNG nativamente en el navegador:

```dart
final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
final image = await boundary.toImage(pixelRatio: 2.0);
final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
final bytes = byteData!.buffer.asUint8List();
// Descarga nativa vía Blob de HTML (universal_html)
```

---

## 7. Paso 6: Mural Comunitario en Vivo

En [`CommunityWallScreen`](../lib/presentation/screens/community_wall_screen.dart):
* Conectado reactivamente al `communityWallProvider`.
* Cada credencial se despliega con marco polaroid blanco, sombras suaves e inclinaciones orgánicas alternadas entre -2° y +2°.
* Al hacer tap en cualquier credencial, se abre el modal [`BadgeDetailModal`](../lib/presentation/widgets/badge_detail_modal.dart) con opciones de descarga HD y publicación en Instagram.

---

### Siguiente Paso:
Con el núcleo de la aplicación comprendido, avanza al **[Módulo 5: Refinamiento Iterativo y Lecciones del Pulido](05-refinamiento-iterativo-y-maduracion.md)** para descubrir los desafíos del mundo real y cómo resolverlos mediante loops precisos.
