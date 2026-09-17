import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_card.dart';
import '../../domain/usecases/publish_user_card_usecase.dart';
import 'di_providers.dart';

/// Notifier handling the publishing of a UserCard to Firebase Storage and Firestore.
class CardPublishNotifier extends StateNotifier<AsyncValue<UserCard?>> {
  final PublishUserCardUseCase _useCase;

  CardPublishNotifier(this._useCase) : super(const AsyncData(null));

  Future<UserCard?> publish({
    required String name,
    required String email,
    required Uint8List imageBytes,
  }) async {
    state = const AsyncLoading();
    try {
      final card = await _useCase.execute(
        name: name,
        email: email,
        imageBytes: imageBytes,
      );
      state = AsyncData(card);
      return card;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      return null;
    }
  }

  void reset() {
    state = const AsyncData(null);
  }
}

final cardPublishProvider =
    StateNotifierProvider<CardPublishNotifier, AsyncValue<UserCard?>>((ref) {
  final useCase = ref.watch(publishUserCardUseCaseProvider);
  return CardPublishNotifier(useCase);
});
