import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/camera_service_impl.dart';
import '../../data/repositories/ai_badge_service_impl.dart';
import '../../data/repositories/user_card_repository_impl.dart';
import '../../domain/repositories/i_camera_service.dart';
import '../../domain/repositories/i_ai_badge_service.dart';
import '../../domain/repositories/i_user_card_repository.dart';
import '../../domain/usecases/generate_ai_badge_usecase.dart';
import '../../domain/usecases/publish_user_card_usecase.dart';
import '../../domain/usecases/get_community_stream_usecase.dart';

// --- Repositories & Services ---

final cameraServiceProvider = Provider<ICameraService>((ref) {
  return CameraServiceImpl();
});

final aiBadgeServiceProvider = Provider<IAiBadgeService>((ref) {
  return AiBadgeServiceImpl();
});

final userCardRepositoryProvider = Provider<IUserCardRepository>((ref) {
  return UserCardRepositoryImpl();
});

// --- Use Cases ---

final generateAiBadgeUseCaseProvider = Provider<GenerateAiBadgeUseCase>((ref) {
  return GenerateAiBadgeUseCase(ref.watch(aiBadgeServiceProvider));
});

final publishUserCardUseCaseProvider = Provider<PublishUserCardUseCase>((ref) {
  return PublishUserCardUseCase(ref.watch(userCardRepositoryProvider));
});

final getCommunityStreamUseCaseProvider =
    Provider<GetCommunityStreamUseCase>((ref) {
  return GetCommunityStreamUseCase(ref.watch(userCardRepositoryProvider));
});
