import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cancun_dashbooth/domain/entities/user_card.dart';
import 'package:cancun_dashbooth/domain/repositories/i_user_card_repository.dart';
import 'package:cancun_dashbooth/domain/usecases/publish_user_card_usecase.dart';

class MockUserCardRepository extends Mock implements IUserCardRepository {}

void main() {
  late MockUserCardRepository mockRepository;
  late PublishUserCardUseCase useCase;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(UserCard(
      id: 'fallback',
      name: 'fallback',
      email: 'fallback@test.com',
      imageUri: 'https://test.com',
      createdAt: DateTime.now(),
    ));
  });

  setUp(() {
    mockRepository = MockUserCardRepository();
    useCase = PublishUserCardUseCase(mockRepository);
  });

  group('PublishUserCardUseCase', () {
    final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
    const downloadUrl = 'https://firebasestorage.googleapis.com/badge123.png';

    test('successfully uploads image and creates UserCard', () async {
      when(() => mockRepository.uploadBadgeImage(
            imageBytes: any(named: 'imageBytes'),
            cardId: any(named: 'cardId'),
          )).thenAnswer((_) async => downloadUrl);

      when(() => mockRepository.createUserCard(any()))
          .thenAnswer((_) async => Future.value());

      final result = await useCase.execute(
        name: 'Sofia G',
        email: 'sofia@flutter.dev',
        imageBytes: imageBytes,
      );

      expect(result.name, 'Sofia G');
      expect(result.email, 'sofia@flutter.dev');
      expect(result.imageUri, downloadUrl);
      expect(result.id.isNotEmpty, isTrue);

      verify(() => mockRepository.uploadBadgeImage(
            imageBytes: imageBytes,
            cardId: any(named: 'cardId'),
          )).called(1);

      verify(() => mockRepository.createUserCard(any())).called(1);
    });

    test('throws ArgumentError on invalid email', () async {
      expect(
        () => useCase.execute(
          name: 'Sofia',
          email: 'invalid-email',
          imageBytes: imageBytes,
        ),
        throwsA(isA<ArgumentError>()),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('throws ArgumentError on short name', () async {
      expect(
        () => useCase.execute(
          name: 'S',
          email: 'sofia@flutter.dev',
          imageBytes: imageBytes,
        ),
        throwsA(isA<ArgumentError>()),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('throws ArgumentError on empty image bytes', () async {
      expect(
        () => useCase.execute(
          name: 'Sofia G',
          email: 'sofia@flutter.dev',
          imageBytes: Uint8List(0),
        ),
        throwsA(isA<ArgumentError>()),
      );
      verifyZeroInteractions(mockRepository);
    });
  });
}
