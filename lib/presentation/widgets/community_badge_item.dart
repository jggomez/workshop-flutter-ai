import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/user_card.dart';
import '../theme/app_colors.dart';

/// Polaroid-style scrapbook photo card with organic tilt and hover straightening animation.
class CommunityBadgeItem extends StatefulWidget {
  final UserCard card;
  final int index;
  final VoidCallback onTap;

  const CommunityBadgeItem({
    super.key,
    required this.card,
    this.index = 0,
    required this.onTap,
  });

  @override
  State<CommunityBadgeItem> createState() => _CommunityBadgeItemState();
}

class _CommunityBadgeItemState extends State<CommunityBadgeItem> {
  bool _isHovered = false;

  // Organic scattering angles for a natural messy photo album feel
  static const List<double> _tiltAngles = [
    -0.045, // ~ -2.6 degrees
    0.035, // ~ +2.0 degrees
    -0.025, // ~ -1.4 degrees
    0.050, // ~ +2.9 degrees
    -0.038, // ~ -2.2 degrees
    0.042, // ~ +2.4 degrees
    -0.055, // ~ -3.1 degrees
    0.028, // ~ +1.6 degrees
  ];

  // Colorful translucent washi tape colors
  static const List<Color> _tapeColors = [
    Color(0xCC00E5FF), // Cyan
    Color(0xCCFFB703), // Amber
    Color(0xCCFF70A6), // Coral
    Color(0xCC04ACF6), // Sky Blue
    Color(0xCC10B981), // Emerald
  ];

  @override
  Widget build(BuildContext context) {
    final tiltAngle = _tiltAngles[widget.index % _tiltAngles.length];
    final tapeColor = _tapeColors[widget.index % _tapeColors.length];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.07 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: AnimatedRotation(
          turns: _isHovered ? 0.0 : (tiltAngle / (2 * math.pi)),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: Semantics(
            button: true,
            label: 'Ver credencial de ${widget.card.name}',
            child: GestureDetector(
              onTap: widget.onTap,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // Polaroid Card Body
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(
                          0xFFF8FAFC), // Classic polaroid paper white
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _isHovered
                              ? AppColors.dashCyan.withValues(alpha: 0.45)
                              : Colors.black.withValues(alpha: 0.35),
                          blurRadius: _isHovered ? 24 : 12,
                          spreadRadius: _isHovered ? 3 : 1,
                          offset: Offset(0, _isHovered ? 10 : 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Photo Frame
                        AspectRatio(
                          aspectRatio: 1.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              color: const Color(0xFF0F172A),
                              child: Image.network(
                                widget.card.imageUri,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.flutterBlue,
                                          AppColors.caribbeanTeal
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.flutter_dash,
                                        color: Colors.white,
                                        size: 44,
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          AppColors.dashCyan,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Polaroid Bottom Chin (Handwritten vibe)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.card.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB703),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '2026',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Row(
                          children: [
                            Icon(Icons.wb_sunny,
                                size: 10, color: Color(0xFFF59E0B)),
                            SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                'Cancún • FlutterConf',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Translucent Washi Tape on Top
                  Positioned(
                    top: -9,
                    child: Container(
                      width: 58,
                      height: 18,
                      decoration: BoxDecoration(
                        color: tapeColor,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
