import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_card.dart';
import 'di_providers.dart';

/// StreamProvider exposing the real-time community wall badges from Firestore.
final communityWallProvider = StreamProvider<List<UserCard>>((ref) {
  final useCase = ref.watch(getCommunityStreamUseCaseProvider);
  return useCase.execute();
});
