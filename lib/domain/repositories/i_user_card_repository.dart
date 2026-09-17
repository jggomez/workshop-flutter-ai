import 'dart:typed_data';
import '../entities/user_card.dart';

/// Abstract contract for managing UserCards in Cloud Firestore and Firebase Storage.
abstract class IUserCardRepository {
  /// Uploads badge image bytes to Firebase Storage and returns the public download URL.
  Future<String> uploadBadgeImage({
    required Uint8List imageBytes,
    required String cardId,
  });

  /// Saves the user card document into the Firestore `UserCards` collection.
  Future<void> createUserCard(UserCard userCard);

  /// Streams real-time updates of all published community cards from Firestore.
  Stream<List<UserCard>> streamCommunityCards();
}
