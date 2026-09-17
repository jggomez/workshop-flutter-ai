import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import 'photobooth_screen.dart';
import 'community_wall_screen.dart';

/// Main navigation shell hosting the Photobooth and the Live Community Wall.
class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Ambient Caribbean Background Glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppGradients.ambientGlow,
              ),
            ),
          ),

          // Main Layout
          SafeArea(
            child: Column(
              children: [
                // Top App Header
                _buildTopHeader(),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      PhotoboothScreen(),
                      CommunityWallScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.85),
        border: const Border(
          bottom: BorderSide(color: AppColors.borderCard, width: 1),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 650;

              if (isNarrow) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mobile Header Row 1: Brand & Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBrand(compact: true),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.dashCyan.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    AppColors.dashCyan.withValues(alpha: 0.35),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '🌴 Cancún 2026',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.dashCyan,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Mobile Header Row 2: Full Width Segmented Tabs (50% / 50%)
                      _buildTabBar(isFullWidth: true),
                    ],
                  ),
                );
              }

              // Desktop / Tablet Header: Single Horizontal Row
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBrand(compact: false),
                    _buildTabBar(isFullWidth: false),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBrand({required bool compact}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 38 : 44,
          height: compact ? 38 : 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(compact ? 10 : 12),
            boxShadow: [
              BoxShadow(
                color: AppColors.dashCyan.withValues(alpha: 0.3),
                blurRadius: 10,
              ),
            ],
          ),
          padding: EdgeInsets.all(compact ? 3 : 4),
          child: Image.asset(
            'images/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.flutter_dash,
              color: AppColors.flutterBlue,
              size: compact ? 22 : 26,
            ),
          ),
        ),
        SizedBox(width: compact ? 10 : 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Cancún',
                  style: TextStyle(
                    fontSize: compact ? 14.5 : 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dashCyan,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'DashBooth',
                  style: TextStyle(
                    fontSize: compact ? 14.5 : 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              'FlutterConf LATAM 2026',
              style: TextStyle(
                fontSize: compact ? 10 : 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar({required bool isFullWidth}) {
    return Container(
      width: isFullWidth ? double.infinity : 340,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        indicator: BoxDecoration(
          gradient: AppGradients.flutterPrimary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(
          fontSize: isFullWidth ? 12 : 13,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.all(4),
        tabs: [
          Tab(
            height: isFullWidth ? 38 : 42,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.camera_alt_outlined, size: 17),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Crear mi Badge',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            height: isFullWidth ? 38 : 42,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.grid_view_rounded, size: 17),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Mural en Vivo',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
