import 'dart:typed_data';
import 'package:cancun_dashbooth/domain/entities/ai_badge_result.dart';
import 'package:cancun_dashbooth/domain/repositories/i_ai_badge_service.dart';
import 'package:cancun_dashbooth/domain/usecases/generate_ai_badge_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAiBadgeService extends Mock implements IAiBadgeService {}

void main() {
  late MockAiBadgeService mockAiService;
  late GenerateAiBadgeUseCase useCase;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockAiService = MockAiBadgeService();
    useCase = GenerateAiBadgeUseCase(mockAiService);
  });

  group('GenerateAiBadgeUseCase', () {
    final testBytes = Uint8List.fromList([10, 20, 30, 40]);
    final expectedResult = AiBadgeResult(
      imageBytes: Uint8List.fromList([50, 60, 70, 80]),
      aiVibeTitle: 'Dash Surfista Legendario | Vibra Caribeña 100%',
    );

    test(
        'successfully calls ai service and returns transformed result with vibe',
        () async {
      when(() => mockAiService.generateDashBadge(
            photoBytes: any(named: 'photoBytes'),
            attendeeName: any(named: 'attendeeName'),
          )).thenAnswer((_) async => expectedResult);

      final result = await useCase.execute(
        photoBytes: testBytes,
        attendeeName: 'Alex Flutter',
      );

      expect(result, equals(expectedResult));
      expect(
          result.aiVibeTitle, 'Dash Surfista Legendario | Vibra Caribeña 100%');
      verify(() => mockAiService.generateDashBadge(
            photoBytes: testBytes,
            attendeeName: 'Alex Flutter',
          )).called(1);
    });

    test('throws ArgumentError when name has fewer than 2 characters',
        () async {
      expect(
        () => useCase.execute(photoBytes: testBytes, attendeeName: 'A'),
        throwsA(isA<ArgumentError>()),
      );
      verifyZeroInteractions(mockAiService);
    });

    test('throws ArgumentError when photo bytes are empty', () async {
      expect(
        () => useCase.execute(photoBytes: Uint8List(0), attendeeName: 'Alex'),
        throwsA(isA<ArgumentError>()),
      );
      verifyZeroInteractions(mockAiService);
    });
  });
}
