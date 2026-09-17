import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Official gradients for Cancun DashBooth.
abstract class AppGradients {
  /// Signature gradient for primary CTAs and header accents.
  static const LinearGradient flutterPrimary = LinearGradient(
    colors: [AppColors.flutterBlue, AppColors.flutterSkyBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Caribbean Dash gradient for glowing frames, camera visor & progress bars.
  static const LinearGradient carribeanDash = LinearGradient(
    colors: [AppColors.flutterSkyBlue, AppColors.dashCyan],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Golden sunshine gradient for "Flutter Pioneer" badge pills.
  static const LinearGradient sunshinePioneer = LinearGradient(
    colors: [AppColors.sunshineAmber, Color(0xFFFB8500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Ambient glow for screen background depth.
  static const RadialGradient ambientGlow = RadialGradient(
    center: Alignment(0.0, -0.5),
    radius: 1.2,
    colors: [
      Color(0x2E02569B),
      Colors.transparent,
    ],
  );
}
