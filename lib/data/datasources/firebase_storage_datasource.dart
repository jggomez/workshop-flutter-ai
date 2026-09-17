import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

/// Data source for uploading badge images to Firebase Storage.
class FirebaseStorageDataSource {
  final FirebaseStorage _storage;

  FirebaseStorageDataSource([FirebaseStorage? storage])
      : _storage = storage ??
            FirebaseStorage.instanceFor(
              bucket: 'dashbooth-cancun-2026-user-cards',
            );

  /// Uploads [imageBytes] as PNG to `user_cards/{cardId}.png`
  /// and returns the public download URL.
  Future<String> uploadBadgeImage({
    required Uint8List imageBytes,
    required String cardId,
  }) async {
    final ref = _storage.ref().child('user_cards/$cardId.png');
    final metadata = SettableMetadata(
      contentType: 'image/png',
      customMetadata: {
        'uploadedAt': DateTime.now().toIso8601String(),
        'app': 'CancunDashBooth',
      },
    );

    final uploadTask = await ref.putData(imageBytes, metadata);
    return await uploadTask.ref.getDownloadURL();
  }
}
