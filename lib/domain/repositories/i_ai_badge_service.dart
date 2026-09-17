import 'dart:typed_data';
import '../entities/ai_badge_result.dart';

/// Abstract contract for AI image transformation using Firebase AI Logic.
abstract class IAiBadgeService {
  /// Transforms the given [photoBytes] incorporating a tropical Cancun theme
  /// and Dash the bird mascot using `gemini-1.5-flash` for multimodal analysis.
  Future<AiBadgeResult> generateDashBadge({
    required Uint8List photoBytes,
    required String attendeeName,
  });
}
