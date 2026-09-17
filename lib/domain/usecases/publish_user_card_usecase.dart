import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import '../entities/user_card.dart';
import '../repositories/i_user_card_repository.dart';

/// Use case that orchestrates uploading a badge image to Storage
/// and persisting the UserCard document into Firestore.
class PublishUserCardUseCase {
  final IUserCardRepository _repository;
  final Uuid _uuid;

  PublishUserCardUseCase(this._repository, [Uuid? uuid])
      : _uuid = uuid ?? const Uuid();

  Future<UserCard> execute({
    required String name,
    required String email,
    required Uint8List imageBytes,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();

    if (trimmedName.length < 2) {
      throw ArgumentError('El nombre debe tener al menos 2 caracteres.');
    }
    if (!RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')
        .hasMatch(trimmedEmail)) {
      throw ArgumentError('Ingresa un correo electrónico válido.');
    }
    if (imageBytes.isEmpty) {
      throw ArgumentError('La imagen del badge no puede estar vacía.');
    }

    final cardId = _uuid.v4();
    final imageUri = await _repository.uploadBadgeImage(
      imageBytes: imageBytes,
      cardId: cardId,
    );

    final userCard = UserCard(
      id: cardId,
      name: trimmedName,
      email: trimmedEmail,
      imageUri: imageUri,
      createdAt: DateTime.now(),
    );

    await _repository.createUserCard(userCard);
    return userCard;
  }
}
