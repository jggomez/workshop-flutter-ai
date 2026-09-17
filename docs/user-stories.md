# User Stories & Acceptance Criteria — Cancun DashBooth (FlutterConf LATAM)

## Contexto de la Aplicación
Aplicación web en Flutter para la conferencia FlutterConf LATAM en Cancún, México. La app permite a los asistentes ingresar su nombre, capturar una selfie desde el navegador, transformar su retrato con temática caribeña y la mascota Dash usando Firebase AI Logic, componer una credencial/card oficial del evento lista para descargar y proyectar en tiempo real todas las fotos en un collage interactivo en vivo.

---

### US-01: Registro de Asistente y Captura de Selfie en Web
**Como** asistente de FlutterConf LATAM,  
**Quiero** ingresar mi nombre y mi correo electrónico, y activar la cámara web/móvil desde el navegador para tomarme una selfie,  
**Para** iniciar la personalización de mi badge oficial de la conferencia.

#### Criterios de Aceptación (Gherkin):
- **Escenario 1: Captura exitosa de la foto**
  - **Given** que el usuario está en la pantalla principal de la aplicación web,
  - **When** ingresa su nombre (mínimo 2 caracteres) y correo electrónico válido en los campos del formulario y presiona el botón "Tomar Selfie",
  - **Then** el navegador solicita permisos de cámara, muestra la vista previa o selector de cámara, captura la imagen y la retorna en memoria como `Uint8List` (bytes), sin escribir archivos en disco ni depender de `dart:io`.

- **Escenario 2: Validación de nombre y correo opcional sin datos ficticios**
  - **Given** que el usuario interactúa con los campos del formulario,
  - **When** ingresa su nombre (mínimo 2 caracteres),
  - **Then** el correo electrónico es opcional; si el usuario no lo ingresa, se preserva como cadena vacía (`""`) sin inyectar correos ficticios ni sintéticos (`pioneer@flutterconf.latam`),
  - **And** si decide ingresar un correo, se valida que cumpla con el formato de email estándar antes de permitir continuar.

- **Escenario 3: Retoma de foto (Retake)**
  - **Given** que la selfie ya fue capturada y se muestra la previsualización,
  - **When** el usuario hace clic en "Volver a tomar foto",
  - **Then** el buffer de imagen anterior se descarta y se reabre la cámara para una nueva captura.

- **Escenario 4: Bloqueo Post-Publicación y Protección de Cuota de IA**
  - **Given** que la credencial ha sido publicada exitosamente en el mural comunitario (`isPublished == true`),
  - **When** el usuario permanece en la pantalla de creación,
  - **Then** los campos de nombre/correo, el visor de cámara y el botón de transformación de IA se bloquean inmediatamente (`IgnorePointer` y `Opacity(0.65)`), mostrando el estado inactivo *"Credencial Publicada"*,
  - **And** se muestra una tarjeta celebratoria con el botón hero primario *"Crear Otra Credencial ✨"*,
  - **And** al presionar este botón, se limpian los controladores, se resetea el estado del borrador y se reactiva el formulario de forma limpia para un nuevo participante.

#### Invariantes Técnicas & Arquitectura:
- Definir en `domain/` la entidad inmutable `BadgeDraft` con los campos: `attendeeName`, `attendeeEmail`, `rawPhotoBytes`, `createdAt`.
- Definir en `domain/` el contrato abstracto `ICameraService`.
- Implementar en `data/` el servicio usando `image_picker` (soporte web) retornando bytes puros.
- El estado reactivo de la captura debe ser manejado mediante Riverpod (`StateNotifier` o `AsyncNotifier`), manteniendo la vista desacoplada de la lógica de cámara.
- Prohibición de emails inventados: la entidad `BadgeDraft` respeta estrictamente lo ingresado por el usuario sin inventar identidades falsas.

---

### US-02: Generación Temática Caribeña y Transformación de Retrato con Firebase AI (`gemini-3.1-flash-image`)
**Como** asistente registrado,  
**Quiero** que la inteligencia artificial multimodal transforme directamente mi selfie en un retrato festivo caribeño junto a Dash en la playa y me otorgue un título de vibra tropical,  
**Para** tener una versión festiva, única y conmemorativa de mi visita al evento creada 100% por IA.

#### Criterios de Aceptación (Gherkin):
- **Escenario 1: Generación multimodal de imagen y texto con Firebase AI y Prompt en Inglés**
  - **Given** que se cuenta con el nombre del usuario y la selfie en `Uint8List`,
  - **When** el usuario confirma la foto y presiona "Transformar con Dash IA",
  - **Then** el servicio envía la imagen a Firebase AI (`firebase_ai`) utilizando el modelo multimodal `gemini-3.1-flash-image` configurado con `GenerationConfig(responseModalities: [ResponseModalities.text, ResponseModalities.image])`,
  - **And** el prompt multimodal en inglés aplica las mejores prácticas de difusión (*Subject, Character Anchoring, Setting, Style, Lighting, Mood*):
    > *"A vibrant, high-quality digital art portrait of the conference attendee ($attendeeName) from the reference photo celebrating at FlutterConf LATAM Cancún 2026. Standing happily right next to the attendee is Dash, the official Flutter mascot. CRITICAL MASCOT DETAILS: Dash is a cute, round, chubby, fluffy blue plush bird toy (NOT a dolphin, NOT a fish, NOT an aquatic animal). Dash has a plump round body covered in soft cyan and royal-blue felt feathers with a cream-white belly patch, large friendly round cartoon eyes, a tiny short triangular orange beak, two small rounded blue bird wings, and two tiny orange bird feet standing on the sand. Setting: picturesque tropical Cancun beach in Quintana Roo, Mexico, with turquoise Caribbean ocean in the background, fine white sand of the Riviera Maya, swaying green palm trees under bright warm sunlight, with subtle colorful Mexican festival touches. Style: polished conference badge illustration, sharp focus, rich colors, joyful and festive atmosphere. CRITICAL REQUIREMENT FOR THE TEXT VIBE: You MUST provide a short, punchy 3 to 5 word conference vibe or title in Spanish that ALWAYS includes authentic Mexican phrases and regional expressions from Cancún, Quintana Roo, and Yucatán (such as '¡Qué Chido!', 'Bomba Yucateca', 'Vibra Maya', '¡Qué Padre!', 'A Toda Madre', 'Cenote', 'Kukulcán', 'Mayab', 'Marquesita', etc.). Examples of expected output: '¡Qué Chido Cancún! 100%', 'Bomba Yucateca de Código', 'Vibra Maya 100% Chida', '¡Qué Padre la Riviera!', 'Kukulcán del Hot Reload', 'Cenote Sagrado 99%'. Do not include quotes, markdown, or conversational filler."*
  - **And** el modelo genera y retorna directamente los bytes de la nueva imagen en `InlineDataPart` y el título en `TextPart`,
  - **And** se retorna la entidad `AiBadgeResult` conteniendo la imagen generada por IA en bytes (`imageBytes`) y el título de vibra caribeña (`aiVibeTitle`).

- **Escenario 2: Experiencia de usuario empática y retroalimentación de carga (Loading Feedback)**
  - **Given** que la petición a la IA está en progreso,
  - **When** transcurre el tiempo de inferencia,
  - **Then** la UI muestra un indicador de carga animado con avatar de Dash, barra de progreso tropical y ticker dinámico con copy amigable y festivo (ej. *"Dash está preparando tu credencial bajo el sol de Cancún..."*, *"Capturando la magia caribeña..."*),
  - **And** se oculta cualquier log o mensaje técnico de backend (como endpoints, nombres de buckets o llamadas a APIs), manteniendo una experiencia 100% orientada al asistente.

- **Escenario 3: Resiliencia y catálogo de fallback ante fallos de red o timeout**
  - **Given** que la conexión a la API de Firebase AI falla o excede el timeout de 15 segundos,
  - **When** se captura la excepción en `AiBadgeRemoteDataSource`,
  - **Then** el sistema activa el canal dual-channel (fallback a Google AI Gemini Developer REST API) o catálogo determinista, preservando limpiamente la foto original del usuario (sin marcas opacas ni distorsiones) con frases mexicanas y regionales de Cancún/Yucatán de 3 a 5 palabras (ej. *"¡Qué Chido Cancún! 100%"*, *"Bomba Yucateca de Código"*, *"Vibra Maya Sagrada 99%"*).

#### Invariantes Técnicas & Arquitectura:
- Definir en `domain/` la entidad `AiBadgeResult` con `Uint8List imageBytes` y `String aiVibeTitle`.
- Definir en `domain/` el contrato abstracto `IAiBadgeService` con el método `Future<AiBadgeResult> generateDashBadge({required Uint8List photoBytes, required String attendeeName})`.
- La implementación en `data/` (`AiBadgeRemoteDataSource`) utiliza `package:firebase_ai` con el modelo `gemini-3.1-flash-image` y fallback REST a Google AI. Cero imports de `dart:io`.
- Prohibido exponer logs técnicos o fallos de red directamente en la interfaz del usuario.

---

### US-03: Composición de la Card Oficial, Píldora IA Vibe y Descarga Web
**Como** asistente,  
**Quiero** ver mi credencial terminada con el marco oficial de la conferencia, mi título de IA Vibe y el hashtag oficial, con la opción de descargarla a mi dispositivo,  
**Para** guardarla en mi galería y compartirla en mis redes sociales (LinkedIn, X, etc.).

#### Criterios de Aceptación (Gherkin):
- **Escenario 1: Visualización de la Card Oficial con IA Vibe y Branding**
  - **Given** que la imagen fue transformada con éxito o previsualizada,
  - **When** se renderiza la tarjeta credencial (`OfficialBadgeCard`),
  - **Then** la pantalla muestra una tarjeta de alta fidelidad (aspect ratio 4:5 vertical) que contiene:
    1. Logotipo oficial de FlutterConf LATAM Cancún (`images/logo.png`) y branding conmemorativo.
    2. El retrato del usuario compuesto con Dash en la playa y filtro caribeño.
    3. El nombre del asistente en tipografía destacada (`Poppins` SemiBold).
    4. El rol conmemorativo en dorado: *"Flutter Pioneer"*.
    5. La píldora brillante `IA Vibe: [título]` con icono `Icons.auto_awesome`, gradiente caribeño turquesa/azul, borde ámbar, texto compacto de 3 a 5 palabras con ajuste dinámico multilínea (`maxLines: 2`, sin truncamiento).
    6. Elementos tecnológicos de credencial: simulación de chip dorado NFC PASS y código de barras.
    7. Pie de tarjeta limpio con el hashtag oficial centrado: `#flutterconflatam26` (sin marcas de texto de versiones de modelo).

- **Escenario 2: Descarga directa en el navegador**
  - **Given** que la Card está renderizada en pantalla,
  - **When** el usuario hace clic en el botón "Descargar Credencial",
  - **Then** el sistema aplana el contenido visual a una imagen PNG de alta resolución mediante un `RepaintBoundary` (configurado con `pixelRatio: 2.0` para evitar pixelado en pantallas Retina),
  - **And** dispara la descarga nativa en el navegador web nombrando el archivo automáticamente como `flutterconf-cancun-[nombre].png`.

- **Escenario 3: Compartir en Instagram desde el creador de badges**
  - **Given** que la Card está generada,
  - **When** el usuario presiona "Compartir en Instagram 📸",
  - **Then** el servicio `SocialShareService` descarga la imagen en el dispositivo, copia al portapapeles el texto oficial con el hashtag `#flutterconflatam26` y abre un diálogo modal de confirmación con acceso directo a Instagram.

#### Invariantes Técnicas & Arquitectura:
- Para la descarga en Flutter Web, utilizar `web_image_downloader.dart` mediante Blobs seguros en navegador sin importar `dart:io`.
- En la rasterización con `RepaintBoundary.toImage()`, utilizar `pixelRatio >= 2.0` para máxima nitidez.
- El componente `OfficialBadgeCard` debe ser responsivo, adaptándose con fluidez a móviles (< 600px) y pantallas de escritorio.
- El pie de tarjeta contiene exclusivamente el hashtag oficial `#flutterconflatam26`.

---

### US-04: Mural Comunitario y Collage de Fotos Desordenadas en Tiempo Real
**Como** asistente y participante de la comunidad,  
**Quiero** que mi badge recién creado se publique automáticamente en un mural tipo álbum de fotos desordenadas dentro de la misma web,  
**Para** ver en tiempo real a todos los colegas y ponentes que estamos compartiendo en FlutterConf LATAM Cancún de manera dinámica y artística.

#### Criterios de Aceptación (Gherkin):
- **Escenario 1: Subida a Firebase Storage y publicación en Firestore UserCards (Zero-Fake-Data)**
  - **Given** que el badge fue generado y previsualizado por el usuario,
  - **And** el usuario tiene activa la opción (habilitada por defecto) de compartir su badge en el mural comunitario,
  - **When** la credencial queda confirmada al presionar "Publicar en el Mural",
  - **Then** el botón muestra retroalimentación amigable para el usuario (*"Compartiendo en el Mural..."*) sin exponer logs técnicos de infraestructura,
  - **And** el sistema sube la imagen a Firebase Storage en la ruta `user_cards/{autoId}.png` y obtiene la URL de descarga pública (`imageUri`),
  - **And** guarda un documento en Cloud Firestore en la colección `UserCards` con ID autogenerado que contiene:
    - `id`: String único autogenerado por Firestore.
    - `name`: String (nombre auténtico del asistente).
    - `email`: String (correo del asistente o cadena vacía `""` si no fue provisto; prohibido inyectar correos falsos como `pioneer@flutterconf.latam`).
    - `imageUri`: String (URL pública de descarga en Firebase Storage).
    - `createdAt`: Timestamp del servidor.

- **Escenario 2: Banner de cabecera universalmente horizontal y collage dinámico en vivo**
  - **Given** que cualquier usuario de la conferencia abre la sección "Mural en Vivo", tanto en pantallas anchas de escritorio como en smartphones móviles o ventanas estrechas (< 600px),
  - **When** visualiza la cabecera y el mosaico de fotos,
  - **Then** el banner superior se mantiene permanentemente en una sola fila horizontal (`Row`), con truncamiento elíptico en textos largos y botón adaptativo (`isCompact: isNarrow`), erradicando colapsos de diseño vertical y fallos de shaders en CanvasKit,
  - **And** el collage visual se actualiza de forma automática en tiempo real mediante un `StreamProvider` de Riverpod conectado al snapshot de `UserCards`,
  - **And** las fotos se presentan con una estética orgánica de álbum de fotos desordenadas (inclinaciones sutiles aleatorias/escalonadas de -2° a +2°, marcos blancos tipo polaroid con sombras profundas, y animaciones suaves de entrada).

- **Escenario 3: Zoom e inspección de credencial en el mural**
  - **Given** que el usuario está explorando el collage de fotos de la comunidad,
  - **When** hace clic sobre cualquier foto del mosaico,
  - **Then** se abre el modal `BadgeDetailModal` con la credencial en tamaño completo, ofreciendo opciones de descarga en alta resolución y publicación en Instagram.

#### Invariantes Técnicas & Arquitectura:
- Definir en `domain/` la entidad `UserCard` y la interfaz `IUserCardRepository`.
- La implementación en `data/` debe subir los bytes a `firebase_storage` y persistir/escuchar la colección `UserCards` de Firestore usando streams (`snapshots()`).
- Los documentos de Firestore se mantienen livianos (< 2 KB) ya que solo almacenan metadatos y la URL `imageUri`.
- Regla Zero-Fake-Data: Si el email está en blanco, se almacena `""`, nunca emails inventados.
- El banner de la cabecera debe ser permanentemente horizontal para prevenir fallos de maquetación en CanvasKit.

---

### US-05: Sorteo de Premios con Ruleta y Podio de Fórmula 1 en el Mural
**Como** organizador o ponente de la conferencia,  
**Quiero** activar una ruleta de sorteo estilo Fórmula 1 desde la cabecera del Mural en Vivo,  
**Para** seleccionar al azar a 3 ganadores entre todos los participantes y premiarlos en un podio festivo de F1 con P1, P2 y P3.

#### Criterios de Aceptación (Gherkin):
- **Escenario 1: Lanzamiento de la Ruleta F1 desde la cabecera del Mural y Botón Flotante (FAB)**
  - **Given** que el usuario se encuentra en la pantalla "Mural en Vivo",
  - **When** visualiza el mural,
  - **Then** se renderiza el botón de acción en la cabecera horizontal (*"🏎️ Ruleta F1 Premios"* o *"🏎️ Ruleta F1"* en pantallas compactas) y adicionalmente un botón flotante persistente (`FloatingActionButton.extended`) en la esquina inferior derecha para acceso sin fricciones durante el scroll.

- **Escenario 2: Semáforo de salida y giro de ruleta de 10 segundos**
  - **Given** que el usuario pulsa el botón de la Ruleta F1,
  - **When** el modal `F1RouletteDialog` se abre,
  - **Then** la ruleta inicia automáticamente su secuencia de salida con las 5 luces rojas de la F1 (`🔴🔴🔴🔴🔴`),
  - **And** al apagarse las luces (*"¡LIGHTS OUT AND AWAY WE GO! 🏁"*), gira a más de 330 km/h alternando los asistentes registrados,
  - **And** muestra telemetría en vivo y un cronómetro digital decreciente (*10.0s ➔ 0.0s*),
  - **And** desacelera dramáticamente durante los últimos 2.5 segundos para completar exactamente 10 segundos de alta emoción.

- **Escenario 3: Revelación del Podio Oficial F1 (P1, P2, P3) con Filtrado de Privacidad de Emails**
  - **Given** que transcurren los 10 segundos de giro y desaceleración,
  - **When** se alcanza la bandera a cuadros (*0.0s*),
  - **Then** se despliega una animación elástica que revela el podio clásico de Fórmula 1 en 3 niveles con los 3 ganadores seleccionados aleatoriamente:
    - **P1 (Centro, Más Alto - 170px):** Pedestal de Oro brillante, trofeo dorado 🏆, corona de laureles, foto y título *"¡CAMPEÓN!"*.
    - **P2 (Izquierda, Nivel Medio - 120px):** Pedestal Plateado cromado con trofeo 🥈, foto y título *"2º LUGAR"*.
    - **P3 (Derecha, Nivel Bronce - 90px):** Pedestal de Bronce con trofeo 🥉, foto y título *"3ER LUGAR"*.
  - **And** los pedestales aplican la función de guardia `_isRealUserEmail`: si el participante no ingresó un email auténtico, la línea de correo se oculta de forma limpia y elegante en el podio sin mostrar datos ficticios,
  - **And** se habilitan los botones *"Girar de Nuevo 🔄"* (reinicia el giro de 10 segundos) y *"¡Celebrar! 🍾"*.

---

### US-06: Descarga HD y Compartir en Instagram en el Mural y el Creador de Badge
**Como** asistente o visitante de la conferencia,  
**Quiero** poder descargar la credencial en HD y compartirla en Instagram directamente al hacer clic sobre cualquier credencial en el mural colectivo o al crear mi badge,  
**Para** difundir el evento en mis Stories/Feed con el hashtag oficial `#flutterconflatam26` de manera instantánea y sin fricciones.

#### Criterios de Aceptación (Gherkin):
- **Escenario 1: Apertura de credencial desde el Mural Comunitario**
  - **Given** que el usuario está en la pestaña "Mural en Vivo",
  - **When** hace clic en cualquier tarjeta del collage de fotos polaroid,
  - **Then** se abre el modal `BadgeDetailModal` renderizando la credencial oficial en alta resolución,
  - **And** presenta botones destacados para *"Descargar Credencial HD (PNG)"*, *"Compartir en Instagram 📸"* y *"Cerrar"*.

- **Escenario 2: Compartir en Instagram con descarga automática y hashtag copiado**
  - **Given** que el usuario está en el modal de detalle del mural o en la pantalla de creación de credencial,
  - **When** pulsa el botón con gradiente de Instagram *"Compartir en Instagram 📸"*,
  - **Then** el sistema descarga automáticamente la imagen PNG en el dispositivo,
  - **And** copia al portapapeles el texto oficial con el hashtag: `¡Mi credencial oficial de FlutterConf LATAM Cancún 2026 con Dash! 🦜✨🌴 #flutterconflatam26`,
  - **And** invoca la API nativa de Web Share si el navegador la soporta,
  - **And** despliega un diálogo explicativo con botón directo *"Abrir Instagram 📸"* para publicar en Stories o Feed.