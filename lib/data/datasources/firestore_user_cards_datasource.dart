import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_card_model.dart';

/// Data source that encapsulates Cloud Firestore interactions for the `UserCards` collection.
class FirestoreUserCardsDataSource {
  final FirebaseFirestore _firestore;

  FirestoreUserCardsDataSource([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('UserCards');

  /// Saves or overwrites a [UserCardModel] document in Firestore.
  Future<void> saveCard(UserCardModel model) async {
    await _collection.doc(model.id).set(model.toFirestore());
  }

  /// Streams real-time updates from `UserCards` collection, ordered by creation date descending.
  Stream<List<UserCardModel>> streamCards() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserCardModel.fromFirestore(doc))
          .toList();
    });
  }
}
