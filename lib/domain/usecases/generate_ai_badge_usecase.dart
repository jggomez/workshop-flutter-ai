import 'dart:typed_data';
import '../entities/ai_badge_result.dart';
import '../repositories/i_ai_badge_service.dart';

/// Business use case to transform an attendee's selfie with Caribbean theme & Dash.
class GenerateAiBadgeUseCase {
  final IAiBadgeService _aiService;

  const GenerateAiBadgeUseCase(this._aiService);

  Future<AiBadgeResult> execute({
    required Uint8List photoBytes,
    required String attendeeName,
  }) async {
    final trimmedName = attendeeName.trim();
    if (trimmedName.length < 2) {
      throw ArgumentError('El nombre debe tener al menos 2 caracteres.');
    }
    if (photoBytes.isEmpty) {
      throw ArgumentError('La fotografía no puede estar vacía.');
    }

    return await _aiService.generateDashBadge(
      photoBytes: photoBytes,
      attendeeName: trimmedName,
    );
  }
}
