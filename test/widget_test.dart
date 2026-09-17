import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cancun_dashbooth/domain/entities/user_card.dart';
import 'package:cancun_dashbooth/domain/repositories/i_camera_service.dart';
import 'package:cancun_dashbooth/domain/usecases/generate_ai_badge_usecase.dart';
import 'package:cancun_dashbooth/domain/usecases/get_community_stream_usecase.dart';
import 'package:cancun_dashbooth/domain/usecases/publish_user_card_usecase.dart';
import 'package:cancun_dashbooth/presentation/providers/di_providers.dart';
import 'package:cancun_dashbooth/main.dart';

class MockCameraService extends Mock implements ICameraService {}

class MockGenerateAiBadgeUseCase extends Mock
    implements GenerateAiBadgeUseCase {}

class MockPublishUserCardUseCase extends Mock
    implements PublishUserCardUseCase {}

class MockGetCommunityStreamUseCase extends Mock
    implements GetCommunityStreamUseCase {}

void main() {
  testWidgets('CancunDashBoothApp smoke test renders title and navigation tabs',
      (WidgetTester tester) async {
    final mockCommunityUseCase = MockGetCommunityStreamUseCase();
    when(() => mockCommunityUseCase.execute())
        .thenAnswer((_) => Stream.value(<UserCard>[]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cameraServiceProvider.overrideWithValue(MockCameraService()),
          generateAiBadgeUseCaseProvider
              .overrideWithValue(MockGenerateAiBadgeUseCase()),
          publishUserCardUseCaseProvider
              .overrideWithValue(MockPublishUserCardUseCase()),
          getCommunityStreamUseCaseProvider
              .overrideWithValue(mockCommunityUseCase),
        ],
        child: const CancunDashBoothApp(),
      ),
    );

    expect(find.text('Cancún'), findsOneWidget);
    expect(find.text('DashBooth'), findsOneWidget);
    expect(find.text('Crear mi Badge'), findsOneWidget);
    expect(find.text('Mural en Vivo'), findsOneWidget);
  });
}
