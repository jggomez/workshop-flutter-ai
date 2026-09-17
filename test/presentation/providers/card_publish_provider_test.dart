import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cancun_dashbooth/domain/entities/user_card.dart';
import 'package:cancun_dashbooth/domain/usecases/publish_user_card_usecase.dart';
import 'package:cancun_dashbooth/presentation/providers/card_publish_provider.dart';

class MockPublishUserCardUseCase extends Mock
    implements PublishUserCardUseCase {}

void main() {
  late MockPublishUserCardUseCase mockUseCase;
  late CardPublishNotifier notifier;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockUseCase = MockPublishUserCardUseCase();
    notifier = CardPublishNotifier(mockUseCase);
  });

  group('CardPublishNotifier', () {
    test('publish succeeds and updates state to AsyncData with card', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final expectedCard = UserCard(
        id: '123',
        name: 'Camila',
        email: 'camila@flutter.dev',
        imageUri: 'https://url.png',
        createdAt: DateTime(2026, 9, 16),
      );

      when(() => mockUseCase.execute(
            name: any(named: 'name'),
            email: any(named: 'email'),
            imageBytes: any(named: 'imageBytes'),
          )).thenAnswer((_) async => expectedCard);

      final result = await notifier.publish(
        name: 'Camila',
        email: 'camila@flutter.dev',
        imageBytes: bytes,
      );

      expect(result, equals(expectedCard));
      expect(notifier.state.value, equals(expectedCard));
    });

    test('publish handles error and updates state to AsyncError', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);

      when(() => mockUseCase.execute(
            name: any(named: 'name'),
            email: any(named: 'email'),
            imageBytes: any(named: 'imageBytes'),
          )).thenThrow(Exception('Firestore write error'));

      final result = await notifier.publish(
        name: 'Camila',
        email: 'camila@flutter.dev',
        imageBytes: bytes,
      );

      expect(result, isNull);
      expect(notifier.state, isA<AsyncError>());
    });
  });
}
