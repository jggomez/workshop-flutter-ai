import 'package:flutter/material.dart';
import '../../domain/entities/user_card.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../utils/social_share_service.dart';
import 'official_badge_card.dart';

/// Modal dialog showing the high-resolution detail of an attendee's badge from the Community Wall,
/// enabling HD download and Instagram sharing.
class BadgeDetailModal extends StatelessWidget {
  final UserCard card;

  const BadgeDetailModal({
    super.key,
    required this.card,
  });

  static Future<void> show(BuildContext context, UserCard card) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => BadgeDetailModal(card: card),
    );
  }

  @override
  Widget build(BuildContext context) {
    final boundaryKey = GlobalKey();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top header with title and close icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.dashCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.dashCyan.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.badge_outlined,
                              color: AppColors.dashCyan, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Credencial Oficial',
                            style: TextStyle(
                              color: AppColors.dashCyan,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white70, size: 26),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Full official badge card rendered live
                Center(
                  child: OfficialBadgeCard(
                    repaintBoundaryKey: boundaryKey,
                    attendeeName: card.name,
                    attendeeEmail: card.email,
                    badgeImageUrl: card.imageUri,
                    width: 350,
                  ),
                ),

                const SizedBox(height: 18),

                // Download HD Action Button
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
                    onPressed: () => SocialShareService.downloadBadge(
                      context,
                      boundaryKey: boundaryKey,
                      attendeeName: card.name,
                    ),
                    icon: const Icon(Icons.file_download_outlined,
                        color: Colors.white),
                    label: const Text(
                      'Descargar Credencial HD (PNG)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
                    onPressed: () => SocialShareService.shareToInstagram(
                      context,
                      boundaryKey: boundaryKey,
                      attendeeName: card.name,
                    ),
                    icon: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 18),
                    label: const Text(
                      'Compartir en Instagram 📸',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Close Button
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: Colors.white12),
                    minimumSize: const Size(double.infinity, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
