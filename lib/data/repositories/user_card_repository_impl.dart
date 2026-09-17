import 'dart:typed_data';
import '../../domain/entities/user_card.dart';
import '../../domain/repositories/i_user_card_repository.dart';
import '../datasources/firebase_storage_datasource.dart';
import '../datasources/firestore_user_cards_datasource.dart';
import '../models/user_card_model.dart';

/// Implementation of [IUserCardRepository] combining Firebase Storage and Cloud Firestore.
class UserCardRepositoryImpl implements IUserCardRepository {
  final FirebaseStorageDataSource _storageDataSource;
  final FirestoreUserCardsDataSource _firestoreDataSource;

  UserCardRepositoryImpl({
    FirebaseStorageDataSource? storageDataSource,
    FirestoreUserCardsDataSource? firestoreDataSource,
  })  : _storageDataSource = storageDataSource ?? FirebaseStorageDataSource(),
        _firestoreDataSource =
            firestoreDataSource ?? FirestoreUserCardsDataSource();

  @override
  Future<String> uploadBadgeImage({
    required Uint8List imageBytes,
    required String cardId,
  }) async {
    return await _storageDataSource.uploadBadgeImage(
      imageBytes: imageBytes,
      cardId: cardId,
    );
  }

  @override
  Future<void> createUserCard(UserCard userCard) async {
    final model = UserCardModel.fromDomain(userCard);
    await _firestoreDataSource.saveCard(model);
  }

  @override
  Stream<List<UserCard>> streamCommunityCards() {
    return _firestoreDataSource.streamCards().map(
          (models) => models.map((m) => m.toDomain()).toList(),
        );
  }
}
