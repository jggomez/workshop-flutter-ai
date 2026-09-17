import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../domain/entities/user_card.dart';
import '../providers/community_wall_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/badge_detail_modal.dart';
import '../widgets/community_badge_item.dart';
import '../widgets/f1_roulette_dialog.dart';
import '../widgets/glass_container.dart';

/// Screen displaying the real-time community wall collage of all attendees' badges (US-04).
class CommunityWallScreen extends ConsumerWidget {
  const CommunityWallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallAsync = ref.watch(communityWallProvider);

    return wallAsync.when(
      data: (cards) => _buildWallContent(context, cards),
      loading: () => _buildLoadingShimmer(),
      error: (error, stack) => _buildErrorState(context, error, ref),
    );
  }

  void _openF1Roulette(BuildContext context, List<UserCard> cards) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => F1RouletteDialog(cards: cards),
    );
  }

  Widget _buildWallContent(BuildContext context, List<UserCard> cards) {
    if (cards.isEmpty) {
      return _buildEmptyState(context);
    }

    return Stack(
      children: [
        // Scrollable Wall Content
        Positioned.fill(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Summary Banner (Always Horizontal & Sleek)
                      _buildHeaderBanner(context, cards),
                      const SizedBox(height: 28),

                      // Disorganized / Scattered Polaroid Album Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 230,
                          childAspectRatio: 0.74,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 28,
                        ),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          return CommunityBadgeItem(
                            card: card,
                            index: index,
                            onTap: () =>
                                BadgeDetailModal.show(context, card),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Persistent Floating Action Button for F1 Roulette (Always Visible)
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            heroTag: 'f1_roulette_fab',
            onPressed: () => _openF1Roulette(context, cards),
            backgroundColor: const Color(0xFFE10600),
            elevation: 8,
            icon: const Text('🏎️', style: TextStyle(fontSize: 20)),
            label: const Text(
              'Ruleta F1 Premios',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFFF5252), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderBanner(BuildContext context, List<UserCard> cards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 520;

        return GlassContainer(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 14 : 20,
            vertical: isNarrow ? 12 : 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: isNarrow ? 40 : 48,
                      height: isNarrow ? 40 : 48,
                      decoration: BoxDecoration(
                        color: AppColors.dashCyan.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.dashCyan.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.collections_bookmark_rounded,
                          color: AppColors.dashCyan,
                          size: isNarrow ? 20 : 24,
                        ),
                      ),
                    ),
                    SizedBox(width: isNarrow ? 10 : 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isNarrow
                                ? 'Álbum en Vivo 📸'
                                : 'Álbum de Recuerdos en Vivo 📸',
                            style: TextStyle(
                              fontSize: isNarrow ? 15 : 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isNarrow
                                ? '${cards.length} Fotos de Pioneers'
                                : '${cards.length} Fotos de Flutter Pioneers en Cancún 2026',
                            style: TextStyle(
                              fontSize: isNarrow ? 11.5 : 12.5,
                              color: AppColors.dashCyan,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _buildRouletteCtaButton(context, cards, isCompact: isNarrow),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRouletteCtaButton(
    BuildContext context,
    List<UserCard> cards, {
    bool fullWidth = false,
    bool isCompact = false,
  }) {
    final buttonChild = ElevatedButton.icon(
      onPressed: () => _openF1Roulette(context, cards),
      icon: const Text('🏎️', style: TextStyle(fontSize: 16)),
      label: Text(
        isCompact ? 'Ruleta F1' : 'Ruleta F1 Premios',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 13.5,
          letterSpacing: 0.3,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE10600), // F1 Official Red
        foregroundColor: Colors.white,
        minimumSize: fullWidth
            ? const Size(double.infinity, 50)
            : (isCompact ? const Size(120, 42) : const Size(160, 44)),
        elevation: 6,
        shadowColor: const Color(0xFFE10600).withValues(alpha: 0.5),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 18,
          vertical: isCompact ? 10 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFFF4136), width: 1.5),
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: buttonChild,
      );
    }
    return buttonChild;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: GlassContainer(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.dashCyan.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.dashCyan.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.photo_library_outlined,
                      size: 40,
                      color: AppColors.dashCyan,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '¡El Mural está esperando!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sé el primer asistente en tomarte una foto con Dash y publicar tu credencial oficial.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                _buildRouletteCtaButton(context, const [], fullWidth: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Shimmer.fromColors(
            baseColor: AppColors.surfaceDark,
            highlightColor: AppColors.surfaceCard,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: 0.72,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: GlassContainer(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                const Text(
                  'No pudimos conectar con el mural en vivo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(communityWallProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar conexión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
