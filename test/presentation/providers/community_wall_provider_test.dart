import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cancun_dashbooth/domain/entities/user_card.dart';
import 'package:cancun_dashbooth/domain/usecases/get_community_stream_usecase.dart';
import 'package:cancun_dashbooth/presentation/providers/community_wall_provider.dart';
import 'package:cancun_dashbooth/presentation/providers/di_providers.dart';

class MockGetCommunityStreamUseCase extends Mock
    implements GetCommunityStreamUseCase {}

void main() {
  late MockGetCommunityStreamUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetCommunityStreamUseCase();
  });

  test('communityWallProvider emits list of UserCards from use case', () async {
    final expectedCards = [
      UserCard(
        id: '1',
        name: 'Sofia',
        email: 'sofia@flutter.latam',
        imageUri: 'https://example.com/1.png',
        createdAt: DateTime(2026, 9, 16),
      ),
    ];

    when(() => mockUseCase.execute()).thenAnswer(
      (_) => Stream.value(expectedCards),
    );

    final container = ProviderContainer(
      overrides: [
        getCommunityStreamUseCaseProvider.overrideWithValue(mockUseCase),
      ],
    );
    addTearDown(container.dispose);

    final sub = container.listen(communityWallProvider, (_, __) {});

    // Wait for stream to emit
    await Future<void>.delayed(Duration.zero);

    expect(container.read(communityWallProvider).value, equals(expectedCards));
    expect(sub.read().value, equals(expectedCards));
  });
}
