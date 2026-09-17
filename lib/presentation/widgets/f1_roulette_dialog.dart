import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/user_card.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';

enum RouletteStatus { spinning, podium }

/// High-energy Formula 1 style raffle/roulette modal that spins for ~10 seconds
/// and reveals the 3 winners on an authentic F1 3-tiered podium (P1, P2, P3).
class F1RouletteDialog extends StatefulWidget {
  final List<UserCard> cards;

  const F1RouletteDialog({
    super.key,
    required this.cards,
  });

  @override
  State<F1RouletteDialog> createState() => _F1RouletteDialogState();
}

class _F1RouletteDialogState extends State<F1RouletteDialog>
    with SingleTickerProviderStateMixin {
  RouletteStatus _status = RouletteStatus.spinning;
  int _activeRedLights = 0;
  Timer? _spinTimer;
  int _spinTick = 0;
  double _secondsRemaining = 10.0;
  int _speedKmh = 0;
  String _f1StatusText = 'PARRILLA DE SALIDA: ENCENDIENDO SEMÁFORO...';
  UserCard? _currentCyclingCard;

  List<UserCard> _winners = [];
  late AnimationController _podiumAnimController;
  late Animation<double> _podiumScaleAnimation;

  List<UserCard> get _effectiveCards {
    if (widget.cards.isNotEmpty) return widget.cards;
    return [
      UserCard(
        id: 'demo-1',
        name: 'Dash Explorador',
        email: '',
        imageUri: '',
        createdAt: DateTime.now(),
      ),
      UserCard(
        id: 'demo-2',
        name: 'Ana García',
        email: '',
        imageUri: '',
        createdAt: DateTime.now(),
      ),
      UserCard(
        id: 'demo-3',
        name: 'Carlos Mendoza',
        email: '',
        imageUri: '',
        createdAt: DateTime.now(),
      ),
      UserCard(
        id: 'demo-4',
        name: 'Sofía Valdés',
        email: '',
        imageUri: '',
        createdAt: DateTime.now(),
      ),
      UserCard(
        id: 'demo-5',
        name: 'Mateo Morales',
        email: '',
        imageUri: '',
        createdAt: DateTime.now(),
      ),
    ];
  }

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

  @override
  void initState() {
    super.initState();
    _podiumAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _podiumScaleAnimation = CurvedAnimation(
      parent: _podiumAnimController,
      curve: Curves.elasticOut,
    );

    // Auto-start the 10-second roulette immediately upon opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRoulette();
    });
  }

  @override
  void dispose() {
    _spinTimer?.cancel();
    _podiumAnimController.dispose();
    super.dispose();
  }

  void _startRoulette() {
    _spinTimer?.cancel();
    _podiumAnimController.reset();

    final candidates = _effectiveCards;
    final shuffled = List<UserCard>.from(candidates)..shuffle(Random());
    if (shuffled.length >= 3) {
      _winners = shuffled.sublist(0, 3);
    } else {
      _winners = List.generate(3, (index) => shuffled[index % shuffled.length]);
    }

    setState(() {
      _status = RouletteStatus.spinning;
      _spinTick = 0;
      _secondsRemaining = 10.0;
      _speedKmh = 0;
      _activeRedLights = 0;
      _f1StatusText = 'PARRILLA DE SALIDA: ENCENDIENDO SEMÁFORO...';
    });

    _tickSpin(elapsedMs: 0, delayMs: 250);
  }

  void _tickSpin({required int elapsedMs, required int delayMs}) {
    _spinTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      final currentElapsed = elapsedMs + delayMs;

      // Total 10.0 seconds (10,000 ms)
      if (currentElapsed >= 10000) {
        setState(() {
          _status = RouletteStatus.podium;
          _secondsRemaining = 0.0;
          _speedKmh = 0;
          _activeRedLights = 0;
        });
        _podiumAnimController.forward(from: 0.0);
        return;
      }

      int nextDelayMs;
      int lights;
      int speed;
      String status;

      if (currentElapsed < 300) {
        lights = 1;
        speed = 0;
        status = '🔴 EN SUS MARCAS...';
        nextDelayMs = 250;
      } else if (currentElapsed < 600) {
        lights = 2;
        speed = 0;
        status = '🔴🔴 REVOLUCIONES SUBIENDO...';
        nextDelayMs = 250;
      } else if (currentElapsed < 900) {
        lights = 3;
        speed = 0;
        status = '🔴🔴🔴 ACELERANDO MOTORES...';
        nextDelayMs = 250;
      } else if (currentElapsed < 1200) {
        lights = 4;
        speed = 0;
        status = '🔴🔴🔴🔴 PREPARANDO SALIDA...';
        nextDelayMs = 250;
      } else if (currentElapsed < 1500) {
        lights = 5;
        speed = 0;
        status = '🔴🔴🔴🔴🔴 ¡A FONDO!';
        nextDelayMs = 250;
      } else if (currentElapsed < 7500) {
        lights = 0;
        speed = 310 + Random().nextInt(35);
        status = '¡LIGHTS OUT AND AWAY WE GO! 🏎️💨';
        nextDelayMs = 60;
      } else {
        lights = 0;
        // Smooth deceleration during final 2.5 seconds
        final progress = (currentElapsed - 7500) / 2500.0; // 0.0 to 1.0
        speed = ((1.0 - progress) * 310).round().clamp(0, 310);
        status = progress < 0.6
            ? '🏁 ENTRANDO A LA RECTA PRINCIPAL...'
            : '🏁 FRENANDO PARA LA META...';
        nextDelayMs = (65 + pow(progress, 2.4) * 550).round();
      }

      final candidates = _effectiveCards;
      final nextCard = candidates[Random().nextInt(candidates.length)];
      final remainingSec = ((10000 - currentElapsed) / 1000.0).clamp(0.0, 10.0);

      setState(() {
        _activeRedLights = lights;
        _speedKmh = speed;
        _f1StatusText = status;
        _currentCyclingCard = nextCard;
        _secondsRemaining = remainingSec;
        _spinTick++;
      });

      _tickSpin(elapsedMs: currentElapsed, delayMs: nextDelayMs);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 28,
        vertical: isMobile ? 16 : 28,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 820,
          maxHeight: size.height * 0.90,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0D111A), // Carbon cockpit dark
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFE10600).withValues(alpha: 0.6), // F1 Red
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE10600).withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: 2,
            ),
            const BoxShadow(
              color: Colors.black87,
              blurRadius: 40,
              offset: Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Cockpit Header
            _buildHeader(isMobile),

            // Main Content Area
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: 24,
                ),
                child: _status == RouletteStatus.spinning
                    ? _buildSpinningState()
                    : _buildPodiumState(isMobile),
              ),
            ),

            // Bottom Actions Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF141A26),
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE10600),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('🏎️', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GRAN PREMIO CANCÚN 2026',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Ruleta Oficial de Premios • 3 Ganadores',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpinningState() {
    final progress = (1.0 - (_secondsRemaining / 10.0)).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // F1 5-Red Starting Lights
        _buildStartLights(),
        const SizedBox(height: 16),

        // Live Status Commentary
        Text(
          _f1StatusText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF00E5FF),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 14),

        // Live 10-Second Countdown & Telemetry Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF080C14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Timer
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      color: AppColors.sunshineAmber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${_secondsRemaining.toStringAsFixed(1)}s',
                    style: const TextStyle(
                      color: AppColors.sunshineAmber,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              Container(width: 1, height: 24, color: Colors.white12),
              // Speed
              Row(
                children: [
                  const Icon(Icons.speed, color: AppColors.dashCyan, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$_speedKmh KM/H',
                    style: const TextStyle(
                      color: AppColors.dashCyan,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              Container(width: 1, height: 24, color: Colors.white12),
              // Lap Tick
              Text(
                'GIRO #$_spinTick',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Progress Line
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE10600)),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 24),

        // Candidate Reel / Pilot Spotlight
        Container(
          height: 155,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF131A26),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.dashCyan.withValues(alpha: 0.8),
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.dashCyan.withValues(alpha: 0.3),
                blurRadius: 24,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Candidate Photo
              Container(
                width: 95,
                height: 95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.sunshineAmber, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 10),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: _currentCyclingCard != null &&
                        _currentCyclingCard!.imageUri.isNotEmpty
                    ? Image.network(
                        _currentCyclingCard!.imageUri,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.white70,
                        ),
                      )
                    : const Icon(Icons.person, size: 48, color: Colors.white70),
              ),
              const SizedBox(width: 20),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE10600),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PILOTO EN RUEDA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currentCyclingCard?.name ?? 'Piloto...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    if (_isRealUserEmail(_currentCyclingCard?.email)) ...[
                      const SizedBox(height: 2),
                      Text(
                        _currentCyclingCard!.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.dashCyan,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumState(bool isMobile) {
    if (_winners.length < 3) return const SizedBox.shrink();

    final p1 = _winners[0];
    final p2 = _winners[1];
    final p3 = _winners[2];

    return ScaleTransition(
      scale: _podiumScaleAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Celebration banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppGradients.sunshinePioneer,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66FFC107),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🍾', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text(
                  '¡PODIO DEL GRAN PREMIO FLUTTERCONF! 🏆',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.bgDark,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(width: 8),
                Text('🍾', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // The 3-Tiered F1 Podium: P2 (Silver, Left) | P1 (Gold, Center, Tallest) | P3 (Bronze, Right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // P2 (Silver)
              Expanded(
                child: _buildPodiumColumn(
                  position: 2,
                  label: 'P2',
                  title: '2º LUGAR',
                  card: p2,
                  pedestalHeight: isMobile ? 85 : 120,
                  accentColor: const Color(0xFFE0E0E0),
                  pedestalGradient: const LinearGradient(
                    colors: [Color(0xFF757575), Color(0xFFBDBDBD)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  trophyEmoji: '🥈',
                  avatarSize: isMobile ? 54 : 70,
                ),
              ),
              const SizedBox(width: 8),

              // P1 (Gold - Center & Highest)
              Expanded(
                child: _buildPodiumColumn(
                  position: 1,
                  label: 'P1',
                  title: '¡CAMPEÓN!',
                  card: p1,
                  pedestalHeight: isMobile ? 125 : 170,
                  accentColor: const Color(0xFFFFD700),
                  pedestalGradient: const LinearGradient(
                    colors: [
                      Color(0xFFB78103),
                      Color(0xFFFFD700),
                      Color(0xFFFFF176)
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  trophyEmoji: '🏆',
                  avatarSize: isMobile ? 70 : 92,
                  isP1: true,
                ),
              ),
              const SizedBox(width: 8),

              // P3 (Bronze)
              Expanded(
                child: _buildPodiumColumn(
                  position: 3,
                  label: 'P3',
                  title: '3ER LUGAR',
                  card: p3,
                  pedestalHeight: isMobile ? 65 : 90,
                  accentColor: const Color(0xFFCD7F32),
                  pedestalGradient: const LinearGradient(
                    colors: [Color(0xFF6E3C1B), Color(0xFFCD7F32)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  trophyEmoji: '🥉',
                  avatarSize: isMobile ? 48 : 64,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required int position,
    required String label,
    required String title,
    required UserCard card,
    required double pedestalHeight,
    required Color accentColor,
    required Gradient pedestalGradient,
    required String trophyEmoji,
    required double avatarSize,
    bool isP1 = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Trophy & Crown
        Text(trophyEmoji, style: TextStyle(fontSize: isP1 ? 32 : 24)),
        const SizedBox(height: 4),

        // Pilot Avatar
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: accentColor,
              width: isP1 ? 3.5 : 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.5),
                blurRadius: isP1 ? 20 : 10,
                spreadRadius: isP1 ? 2 : 0,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: card.imageUri.isNotEmpty
              ? Image.network(
                  card.imageUri,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 32,
                  ),
                )
              : const Icon(Icons.person, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 8),

        // Name
        Text(
          card.name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isP1 ? 14 : 12,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        if (_isRealUserEmail(card.email)) ...[
          const SizedBox(height: 2),
          Text(
            card.email,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white54,
            ),
          ),
        ],
        const SizedBox(height: 10),

        // The Podium Pedestal Block
        Container(
          height: pedestalHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: pedestalGradient,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(
              color: Colors.white38,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isP1 ? 38 : 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF090D1A),
                  letterSpacing: -1.0,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF090D1A),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartLights() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF06090F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final isLit = index < _activeRedLights;
          final color =
              isLit ? const Color(0xFFFF1801) : const Color(0xFF222836);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: isLit
                    ? [
                        const BoxShadow(
                          color: Color(0xFFFF1801),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF121722),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_status == RouletteStatus.podium)
            TextButton.icon(
              onPressed: _startRoulette,
              icon: const Icon(Icons.refresh,
                  color: AppColors.dashCyan, size: 18),
              label: const Text(
                'Girar de Nuevo 🔄',
                style: TextStyle(
                  color: AppColors.dashCyan,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceCard,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white24),
              ),
            ),
            child: Text(
                _status == RouletteStatus.podium ? '¡Celebrar! 🍾' : 'Cerrar'),
          ),
        ],
      ),
    );
  }
}
