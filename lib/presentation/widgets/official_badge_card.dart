import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';

/// The official printable / downloadable conference badge for FlutterConf LATAM Cancún 2026.
/// Features a holographic Caribbean design, VIP NFC chip simulation,
/// conference logo, and high-definition rasterization via [RepaintBoundary].
class OfficialBadgeCard extends StatelessWidget {
  final GlobalKey repaintBoundaryKey;
  final String attendeeName;
  final String attendeeEmail;
  final Uint8List? badgeImageBytes;
  final String? badgeImageUrl;
  final String? aiVibeTitle;
  final double width;

  const OfficialBadgeCard({
    super.key,
    required this.repaintBoundaryKey,
    required this.attendeeName,
    required this.attendeeEmail,
    this.badgeImageBytes,
    this.badgeImageUrl,
    this.aiVibeTitle,
    this.width = 340,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          // Layered deep dark blue with iridescent gradient border
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF162035), Color(0xFF0D1527)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: AppColors.dashCyan.withValues(alpha: 0.7),
            width: 2.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.dashCyan.withValues(alpha: 0.3),
              blurRadius: 28,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.flutterBlue.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Lanyard Clip & Woven Strap Graphic
            _buildLanyardTop(),

            // Official Header with Custom Logo
            _buildHeaderBanner(),

            // Attendee Avatar Frame with Holographic Glow
            _buildAvatarSection(),

            const SizedBox(height: 8),

            // Attendee Name & Details Section
            _buildAttendeeDetails(),

            const SizedBox(height: 8),

            // Security NFC Chip & Conference Barcode simulation
            _buildSecurityChipAndBarcode(),

            // Tech Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanyardTop() {
    return Container(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      color: const Color(0xFF090D1A),
      child: Center(
        child: Container(
          width: 54,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white12, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.flutterBlue,
            Color(0xFF0284C7),
            AppColors.flutterSkyBlue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // Logo from images/logo.png
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              'images/logo.png',
              fit: BoxFit.contain,
              semanticLabel: 'Logo oficial de FlutterConf LATAM 2026',
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.flutter_dash,
                color: AppColors.flutterBlue,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Conference Title & Location
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'FLUTTERCONF LATAM 2026',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 11, color: AppColors.sunshineAmber),
                    SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        'Cancún, México • All-Access Pass',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // VIP tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.sunshineAmber,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'VIP',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.bgDark,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Photo Box (1:1 aspect)
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.dashCyan.withValues(alpha: 0.8),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dashCyan.withValues(alpha: 0.3),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildBadgeImage(),
            ),
          ),

          // "FLUTTER PIONEER" Pill with sunshine gradient
          Positioned(
            bottom: -13,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppGradients.sunshinePioneer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white70, width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 14, color: AppColors.bgDark),
                  SizedBox(width: 5),
                  Text(
                    'FLUTTER PIONEER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: AppColors.bgDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeeDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 6),
          Text(
            attendeeName.trim().isEmpty ? 'Asistente Oficial' : attendeeName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            attendeeEmail.trim().isEmpty
                ? 'asistente@flutterconf.latam'
                : attendeeEmail,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.dashCyan,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (aiVibeTitle != null && aiVibeTitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildAiVibePill(aiVibeTitle!.trim()),
          ],
        ],
      ),
    );
  }

  Widget _buildAiVibePill(String vibe) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 290),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D9488),
            Color(0xFF0284C7),
            Color(0xFF00E5FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.sunshineAmber.withValues(alpha: 0.85),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dashCyan.withValues(alpha: 0.35),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: AppColors.sunshineAmber.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 13,
            color: AppColors.sunshineAmber,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'IA Vibe: $vibe',
              maxLines: 2,
              softWrap: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.2,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityChipAndBarcode() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF090D1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Gold Chip Simulation
            Row(
              children: [
                Container(
                  width: 28,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(4),
                    border:
                        Border.all(color: const Color(0xFFFFD700), width: 1),
                  ),
                  child: Center(
                    child: Container(
                      width: 14,
                      height: 10,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFFB8860B), width: 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'NFC PASS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.sunshineAmber,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            // Barcode Lines simulation (excluded from semantics tree)
            ExcludeSemantics(
              child: Row(
                children: [
                  for (int i = 0; i < 18; i++)
                    Container(
                      margin: const EdgeInsets.only(left: 2),
                      width: (i % 3 == 0) ? 2.5 : 1.2,
                      height: 18,
                      color: Colors.white70,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF090D1A),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.dashCyan.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.dashCyan.withValues(alpha: 0.4),
            ),
          ),
          child: const Text(
            '#flutterconflatam26',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: AppColors.dashCyan,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeImage() {
    if (badgeImageBytes != null && badgeImageBytes!.isNotEmpty) {
      return Image.memory(
        badgeImageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackPlaceholder(),
      );
    } else if (badgeImageUrl != null && badgeImageUrl!.isNotEmpty) {
      return Image.network(
        badgeImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackPlaceholder(),
      );
    }
    return _fallbackPlaceholder();
  }

  Widget _fallbackPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.flutterBlue, AppColors.caribbeanTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.flutter_dash,
              size: 72,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              'Dash Cancun Vibe',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
