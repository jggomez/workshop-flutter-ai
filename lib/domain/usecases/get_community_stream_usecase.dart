import '../entities/user_card.dart';
import '../repositories/i_user_card_repository.dart';

/// Use case that exposes the real-time stream of published community badges.
class GetCommunityStreamUseCase {
  final IUserCardRepository _repository;

  const GetCommunityStreamUseCase(this._repository);

  Stream<List<UserCard>> execute() {
    return _repository.streamCommunityCards();
  }
}
