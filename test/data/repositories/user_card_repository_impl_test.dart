import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cancun_dashbooth/data/datasources/firebase_storage_datasource.dart';
import 'package:cancun_dashbooth/data/datasources/firestore_user_cards_datasource.dart';
import 'package:cancun_dashbooth/data/models/user_card_model.dart';
import 'package:cancun_dashbooth/data/repositories/user_card_repository_impl.dart';
import 'package:cancun_dashbooth/domain/entities/user_card.dart';

class MockStorageDataSource extends Mock implements FirebaseStorageDataSource {}

class MockFirestoreDataSource extends Mock
    implements FirestoreUserCardsDataSource {}

void main() {
  late MockStorageDataSource mockStorage;
  late MockFirestoreDataSource mockFirestore;
  late UserCardRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(UserCardModel(
      id: 'fallback',
      name: 'fallback',
      email: 'fallback@test.com',
      imageUri: 'https://test.com',
      createdAt: DateTime.now(),
    ));
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockStorage = MockStorageDataSource();
    mockFirestore = MockFirestoreDataSource();
    repository = UserCardRepositoryImpl(
      storageDataSource: mockStorage,
      firestoreDataSource: mockFirestore,
    );
  });

  group('UserCardRepositoryImpl', () {
    test('uploadBadgeImage delegates to storage data source', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      when(() => mockStorage.uploadBadgeImage(
            imageBytes: any(named: 'imageBytes'),
            cardId: any(named: 'cardId'),
          )).thenAnswer((_) async => 'https://download/url.png');

      final result = await repository.uploadBadgeImage(
        imageBytes: bytes,
        cardId: 'card-1',
      );

      expect(result, 'https://download/url.png');
      verify(() => mockStorage.uploadBadgeImage(
            imageBytes: bytes,
            cardId: 'card-1',
          )).called(1);
    });

    test(
        'createUserCard converts domain to model and delegates to firestore data source',
        () async {
      final card = UserCard(
        id: 'c-1',
        name: 'Ana',
        email: 'ana@test.com',
        imageUri: 'https://img.png',
        createdAt: DateTime(2026, 9, 16),
      );

      when(() => mockFirestore.saveCard(any()))
          .thenAnswer((_) async => Future.value());

      await repository.createUserCard(card);

      verify(() => mockFirestore.saveCard(any(that: isA<UserCardModel>())))
          .called(1);
    });

    test('streamCommunityCards maps models to domain entities', () async {
      final model = UserCardModel(
        id: 'c-1',
        name: 'Ana',
        email: 'ana@test.com',
        imageUri: 'https://img.png',
        createdAt: DateTime(2026, 9, 16),
      );

      when(() => mockFirestore.streamCards())
          .thenAnswer((_) => Stream.value([model]));

      final stream = repository.streamCommunityCards();
      final list = await stream.first;

      expect(list.length, 1);
      expect(list.first.name, 'Ana');
      verify(() => mockFirestore.streamCards()).called(1);
    });
  });
}
