import 'dart:typed_data';
import 'package:cancun_dashbooth/domain/entities/ai_badge_result.dart';
import 'package:cancun_dashbooth/domain/usecases/generate_ai_badge_usecase.dart';
import 'package:cancun_dashbooth/presentation/providers/ai_generation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGenerateAiBadgeUseCase extends Mock
    implements GenerateAiBadgeUseCase {}

void main() {
  late MockGenerateAiBadgeUseCase mockUseCase;
  late AiGenerationNotifier notifier;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockUseCase = MockGenerateAiBadgeUseCase();
    notifier = AiGenerationNotifier(mockUseCase);
  });

  tearDown(() {
    notifier.dispose();
  });

  group('AiGenerationNotifier', () {
    test(
        'generateBadge succeeds and updates state to AsyncData with bytes and aiVibeTitle',
        () async {
      final inputBytes = Uint8List.fromList([1, 2]);
      final outputBytes = Uint8List.fromList([3, 4]);
      const vibe = 'Capitán de Widgets Caribeños | Vibra Caribeña 100%';
      final aiResult =
          AiBadgeResult(imageBytes: outputBytes, aiVibeTitle: vibe);

      when(() => mockUseCase.execute(
            photoBytes: any(named: 'photoBytes'),
            attendeeName: any(named: 'attendeeName'),
          )).thenAnswer((_) async => aiResult);

      final result = await notifier.generateBadge(
        photoBytes: inputBytes,
        attendeeName: 'Valeria',
      );

      expect(result, equals(aiResult));
      expect(notifier.state.imageBytes.value, equals(outputBytes));
      expect(notifier.state.aiVibeTitle, equals(vibe));
      expect(notifier.state.statusMessage,
          contains('¡Tu credencial caribeña está lista!'));
    });

    test('generateBadge handles error and updates state to AsyncError',
        () async {
      final inputBytes = Uint8List.fromList([1, 2]);

      when(() => mockUseCase.execute(
            photoBytes: any(named: 'photoBytes'),
            attendeeName: any(named: 'attendeeName'),
          )).thenThrow(Exception('API error'));

      final result = await notifier.generateBadge(
        photoBytes: inputBytes,
        attendeeName: 'Valeria',
      );

      expect(result, isNull);
      expect(notifier.state.imageBytes, isA<AsyncError>());
      expect(notifier.state.statusMessage, contains('error'));
    });

    test('reset clears state including imageBytes and aiVibeTitle', () async {
      final inputBytes = Uint8List.fromList([1, 2]);
      final outputBytes = Uint8List.fromList([3, 4]);
      final aiResult = AiBadgeResult(
        imageBytes: outputBytes,
        aiVibeTitle: 'Explorador Maya',
      );

      when(() => mockUseCase.execute(
            photoBytes: any(named: 'photoBytes'),
            attendeeName: any(named: 'attendeeName'),
          )).thenAnswer((_) async => aiResult);

      await notifier.generateBadge(
          photoBytes: inputBytes, attendeeName: 'Valeria');
      expect(notifier.state.aiVibeTitle, 'Explorador Maya');

      notifier.reset();
      expect(notifier.state.imageBytes.value, isNull);
      expect(notifier.state.aiVibeTitle, isNull);
      expect(notifier.state.statusMessage, isEmpty);
    });
  });
}
