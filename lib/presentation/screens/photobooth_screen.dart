import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/badge_draft.dart';
import '../providers/badge_draft_provider.dart';
import '../providers/ai_generation_provider.dart';
import '../providers/card_publish_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../utils/social_share_service.dart';
import '../utils/web_image_downloader.dart';
import '../widgets/ai_processing_indicator.dart';
import '../widgets/camera_viewfinder.dart';
import '../widgets/glass_container.dart';
import '../widgets/name_email_form.dart';
import '../widgets/official_badge_card.dart';

/// Interactive Photobooth Screen with instant live preview, responsive desktop/mobile layout,
/// Caribbean hero mascot (Dash en la playa), and seamless AI transformation.
class PhotoboothScreen extends ConsumerStatefulWidget {
  const PhotoboothScreen({super.key});

  @override
  ConsumerState<PhotoboothScreen> createState() => _PhotoboothScreenState();
}

class _PhotoboothScreenState extends ConsumerState<PhotoboothScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _badgeBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final draft = ref.read(badgeDraftProvider);
    _nameController.text = draft.attendeeName;
    _emailController.text = draft.attendeeEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleTransformWithAi() async {
    final draft = ref.read(badgeDraftProvider);
    if (!draft.hasPhoto) return;

    final aiNotifier = ref.read(aiGenerationProvider.notifier);
    final result = await aiNotifier.generateBadge(
      photoBytes: draft.rawPhotoBytes,
      attendeeName:
          draft.attendeeName.trim().isEmpty ? 'Pioneer' : draft.attendeeName,
    );
    if (result != null) {
      ref.read(badgeDraftProvider.notifier).setAiVibeTitle(result.aiVibeTitle);
    }
  }

  Future<void> _handleDownloadBadge() async {
    final draft = ref.read(badgeDraftProvider);
    final safeName = draft.attendeeName.trim().replaceAll(' ', '_');
    final fileName =
        'dash_badge_${safeName.isEmpty ? 'cancun_2026' : safeName}.png';

    final bytes = await WebImageDownloader.captureAndDownload(
      boundaryKey: _badgeBoundaryKey,
      fileName: fileName,
    );

    if (mounted) {
      if (bytes != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('¡Credencial HD descargada exitosamente en tu navegador!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Descarga iniciada. Revisa la carpeta de descargas.'),
            backgroundColor: AppColors.caribbeanTeal,
          ),
        );
      }
    }
  }

  Future<void> _handleShareToInstagram() async {
    final draft = ref.read(badgeDraftProvider);
    final safeName = draft.attendeeName.trim().isEmpty
        ? 'Flutter Pioneer'
        : draft.attendeeName;
    await SocialShareService.shareToInstagram(
      context,
      boundaryKey: _badgeBoundaryKey,
      attendeeName: safeName,
    );
  }

  Future<void> _handlePublishToWall() async {
    final draft = ref.read(badgeDraftProvider);
    final aiState = ref.read(aiGenerationProvider);
    final badgeBytes = aiState.imageBytes.value ??
        (draft.hasPhoto ? draft.rawPhotoBytes : null);

    if (badgeBytes == null || badgeBytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sube o toma una foto antes de publicar en el mural.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final publishNotifier = ref.read(cardPublishProvider.notifier);
    final card = await publishNotifier.publish(
      name: draft.attendeeName.trim().isEmpty
          ? 'Flutter Pioneer'
          : draft.attendeeName.trim(),
      email: draft.attendeeEmail.trim(),
      imageBytes: badgeBytes,
    );

    if (mounted) {
      if (card != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '¡Tu credencial ha sido publicada en el Mural en Vivo! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hubo un problema al publicar. Inténtalo de nuevo.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleReset() {
    _nameController.clear();
    _emailController.clear();
    ref.read(badgeDraftProvider.notifier).reset();
    ref.read(aiGenerationProvider.notifier).reset();
    ref.read(cardPublishProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(badgeDraftProvider);
    final aiState = ref.watch(aiGenerationProvider);
    final publishState = ref.watch(cardPublishProvider);
    final isPublishing = publishState.isLoading;
    final isPublished = publishState.hasValue && publishState.value != null;

    final isAiLoading = aiState.imageBytes.isLoading;
    final activePhotoBytes = aiState.imageBytes.value ??
        (draft.hasPhoto ? draft.rawPhotoBytes : null);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Caribbean Welcome Banner with Dash Mascot
                  _buildHeroBeachBanner(),

                  const SizedBox(height: 24),

                  // AI Loading Indicator (Overlay when generating)
                  if (isAiLoading) ...[
                    AiProcessingIndicator(
                      customStatusMessage: aiState.statusMessage,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Responsive Layout: 2-Column on Desktop / Stack on Mobile
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Form & Camera Viewfinder (Locked if published)
                        Expanded(
                          flex: 6,
                          child: _buildInputFormSection(
                            draft: draft,
                            isPublished: isPublished,
                            isAiLoading: isAiLoading,
                          ),
                        ),
                        const SizedBox(width: 28),
                        // Right: Live Interactive Badge Card & Actions
                        Expanded(
                          flex: 5,
                          child: _buildLiveBadgeSection(
                            draft: draft,
                            badgeBytes: activePhotoBytes,
                            isPublishing: isPublishing,
                            isPublished: isPublished,
                            aiVibeTitle:
                                aiState.aiVibeTitle ?? draft.aiVibeTitle,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInputFormSection(
                          draft: draft,
                          isPublished: isPublished,
                          isAiLoading: isAiLoading,
                        ),
                        const SizedBox(height: 24),
                        _buildLiveBadgeSection(
                          draft: draft,
                          badgeBytes: activePhotoBytes,
                          isPublishing: isPublishing,
                          isPublished: isPublished,
                          aiVibeTitle: aiState.aiVibeTitle ?? draft.aiVibeTitle,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroBeachBanner() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Mascot from images/dash_playa.png with glow animation
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.dashCyan.withValues(alpha: 0.35),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'images/dash_playa.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surfaceCard,
                  child: const Icon(Icons.beach_access,
                      color: AppColors.sunshineAmber, size: 36),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: AppGradients.sunshinePioneer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'CANCÚN 2026',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.bgDark,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'All-Access Photobooth',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.dashCyan,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  '¡Crea tu Credencial Interactiva Oficial!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Sube o tómate una foto y personalízala con inteligencia artificial multimodal.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFormSection({
    required BadgeDraft draft,
    required bool isPublished,
    required bool isAiLoading,
  }) {
    final draftNotifier = ref.read(badgeDraftProvider.notifier);

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isPublished) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F291E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.6),
                  width: 1.2,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_rounded, size: 20, color: AppColors.success),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Credencial publicada con éxito. Para crear una nueva credencial, pulsa "Crear Otra Credencial" en el panel derecho.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          const Row(
            children: [
              Icon(Icons.badge_outlined, color: AppColors.dashCyan, size: 20),
              SizedBox(width: 8),
              Text(
                '1. Datos del Asistente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name and Email Inputs (Locked if already published)
          Opacity(
            opacity: isPublished ? 0.65 : 1.0,
            child: IgnorePointer(
              ignoring: isPublished,
              child: NameEmailForm(
                nameController: _nameController,
                emailController: _emailController,
                onNameChanged: (val) => draftNotifier.setName(val),
                onEmailChanged: (val) => draftNotifier.setEmail(val),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Row(
            children: [
              Icon(Icons.camera_alt_outlined,
                  color: AppColors.caribbeanTeal, size: 20),
              SizedBox(width: 8),
              Text(
                '2. Tu Fotografía',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Camera & Upload Viewfinder (Locked if already published to save AI quota)
          Opacity(
            opacity: isPublished ? 0.65 : 1.0,
            child: IgnorePointer(
              ignoring: isPublished,
              child: CameraViewfinder(
                photoBytes: draft.hasPhoto ? draft.rawPhotoBytes : null,
                onCapturePressed: () async {
                  if (isPublished) return;
                  final ok = await draftNotifier.captureSelfie();
                  if (!ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('No se seleccionó o capturó ninguna imagen.'),
                      ),
                    );
                  }
                },
                onUploadPressed: () async {
                  if (isPublished) return;
                  final ok = await draftNotifier.uploadPhoto();
                  if (!ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('No se seleccionó o subió ningún archivo.'),
                      ),
                    );
                  }
                },
                onRetakePressed: () {
                  if (isPublished) return;
                  draftNotifier.setPhotoBytes(null);
                  ref.read(aiGenerationProvider.notifier).reset();
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action Button: Transform with AI (Disabled if published or loading)
          Container(
            decoration: BoxDecoration(
              gradient: (draft.hasPhoto && !isPublished && !isAiLoading)
                  ? AppGradients.carribeanDash
                  : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: (draft.hasPhoto && !isPublished && !isAiLoading)
                  ? [
                      BoxShadow(
                        color: AppColors.dashCyan.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: ElevatedButton.icon(
              onPressed: (draft.hasPhoto && !isPublished && !isAiLoading)
                  ? _handleTransformWithAi
                  : null,
              icon: Icon(
                isPublished ? Icons.check_circle : Icons.auto_awesome,
                color: isPublished ? AppColors.success : AppColors.bgDark,
              ),
              label: Text(
                isPublished
                    ? 'Credencial Publicada'
                    : 'Transformar con Dash IA',
                style: TextStyle(
                  color: isPublished ? Colors.white60 : AppColors.bgDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: (draft.hasPhoto && !isPublished && !isAiLoading)
                    ? Colors.transparent
                    : Colors.white12,
                shadowColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBadgeSection({
    required BadgeDraft draft,
    required dynamic badgeBytes,
    required bool isPublishing,
    required bool isPublished,
    String? aiVibeTitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.preview_rounded,
                color: AppColors.sunshineAmber, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Vista Previa Oficial (En Vivo)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (badgeBytes != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 12, color: AppColors.success),
                    SizedBox(width: 4),
                    Text(
                      'Listo',
                      style: TextStyle(
                          fontSize: 10.5,
                          color: AppColors.success,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),

        // The Official Badge Card rendered live with adaptive width
        Center(
          child: LayoutBuilder(
            builder: (context, cardConstraints) {
              final cardWidth =
                  (cardConstraints.maxWidth - 8).clamp(260.0, 350.0);
              return OfficialBadgeCard(
                repaintBoundaryKey: _badgeBoundaryKey,
                attendeeName: draft.attendeeName.trim().isEmpty
                    ? 'Tu Nombre Aquí'
                    : draft.attendeeName,
                attendeeEmail: draft.attendeeEmail.trim().isEmpty
                    ? 'tu-correo@flutterconf.latam'
                    : draft.attendeeEmail,
                badgeImageBytes: badgeBytes,
                aiVibeTitle: aiVibeTitle ?? draft.aiVibeTitle,
                width: cardWidth,
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Download Action Button
        Container(
          decoration: BoxDecoration(
            gradient: AppGradients.flutterPrimary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3302569B),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: _handleDownloadBadge,
            icon: const Icon(Icons.file_download_outlined, color: Colors.white),
            label: const Text(
              'Descargar Credencial HD (PNG)',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Share to Instagram Action Button
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF833AB4),
                Color(0xFFFD1D1D),
                Color(0xFFFCAF45),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFD1D1D).withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: _handleShareToInstagram,
            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            label: const Text(
              'Compartir en Instagram 📸',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
        const SizedBox(height: 12),

        if (isPublished) ...[
          // Celebratory Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Credencial en el Mural! 🎉',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tu credencial ya brilla en el mural en vivo del evento.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Primary Hero Action: Crear Otra Credencial
          Container(
            decoration: BoxDecoration(
              gradient: AppGradients.sunshinePioneer,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33FFB300),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _handleReset,
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: Colors.black87,
                size: 20,
              ),
              label: const Text(
                'Crear Otra Credencial ✨',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ] else ...[
          // Publish to Mural Action Button
          ElevatedButton.icon(
            onPressed: isPublishing ? null : _handlePublishToWall,
            icon: isPublishing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.public,
                    color: AppColors.dashCyan,
                    size: 18,
                  ),
            label: Text(
              isPublishing
                  ? 'Compartiendo en el Mural...'
                  : 'Publicar en Mural de Recuerdos',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceCard,
              foregroundColor: AppColors.textPrimary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.white12),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Clean Reset Button
          OutlinedButton.icon(
            onPressed: isPublishing ? null : _handleReset,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
            label: const Text(
              'Limpiar y reiniciar formulario',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: Colors.white12),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
