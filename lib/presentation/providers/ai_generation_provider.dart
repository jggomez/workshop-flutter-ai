import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai_badge_result.dart';
import '../../domain/usecases/generate_ai_badge_usecase.dart';
import 'di_providers.dart';

/// State of the AI Transformation stage.
class AiGenerationState {
  final AsyncValue<Uint8List?> imageBytes;
  final String statusMessage;
  final String? aiVibeTitle;

  const AiGenerationState({
    required this.imageBytes,
    required this.statusMessage,
    this.aiVibeTitle,
  });

  AiGenerationState copyWith({
    AsyncValue<Uint8List?>? imageBytes,
    String? statusMessage,
    String? aiVibeTitle,
    bool clearVibeTitle = false,
  }) {
    return AiGenerationState(
      imageBytes: imageBytes ?? this.imageBytes,
      statusMessage: statusMessage ?? this.statusMessage,
      aiVibeTitle: clearVibeTitle ? null : (aiVibeTitle ?? this.aiVibeTitle),
    );
  }
}

/// Notifier handling the AI Dash generation lifecycle with progress messages.
class AiGenerationNotifier extends StateNotifier<AiGenerationState> {
  final GenerateAiBadgeUseCase _useCase;
  Timer? _messageTimer;
  int _messageIndex = 0;

  static const List<String> _dashMessages = [
    'Dash está buscando la mejor palmera bajo el sol de Cancún...',
    'Agregando vibras tropicales y gafas de sol a tu retrato...',
    'Componiendo tu credencial oficial de FlutterConf LATAM...',
    'Casi listo, afinando los colores del Caribe...',
  ];

  AiGenerationNotifier(this._useCase)
      : super(const AiGenerationState(
          imageBytes: AsyncData(null),
          statusMessage: '',
          aiVibeTitle: null,
        ));

  Future<AiBadgeResult?> generateBadge({
    required Uint8List photoBytes,
    required String attendeeName,
  }) async {
    _startMessageTicker();
    state = state.copyWith(
      imageBytes: const AsyncLoading(),
      statusMessage: _dashMessages[0],
    );

    try {
      final result = await _useCase.execute(
        photoBytes: photoBytes,
        attendeeName: attendeeName,
      );
      _stopMessageTicker();
      state = state.copyWith(
        imageBytes: AsyncData(result.imageBytes),
        aiVibeTitle: result.aiVibeTitle,
        statusMessage: '¡Tu credencial caribeña está lista!',
      );
      return result;
    } catch (e, stack) {
      _stopMessageTicker();
      state = state.copyWith(
        imageBytes: AsyncError(e, stack),
        statusMessage: 'Ocurrió un error al procesar la imagen.',
      );
      return null;
    }
  }

  void reset() {
    _stopMessageTicker();
    state = const AiGenerationState(
      imageBytes: AsyncData(null),
      statusMessage: '',
      aiVibeTitle: null,
    );
  }

  void _startMessageTicker() {
    _stopMessageTicker();
    _messageIndex = 0;
    _messageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _messageIndex = (_messageIndex + 1) % _dashMessages.length;
      state = state.copyWith(statusMessage: _dashMessages[_messageIndex]);
    });
  }

  void _stopMessageTicker() {
    _messageTimer?.cancel();
    _messageTimer = null;
  }

  @override
  void dispose() {
    _stopMessageTicker();
    super.dispose();
  }
}

final aiGenerationProvider =
    StateNotifierProvider<AiGenerationNotifier, AiGenerationState>((ref) {
  final useCase = ref.watch(generateAiBadgeUseCaseProvider);
  return AiGenerationNotifier(useCase);
});
