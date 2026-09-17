import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cancun_dashbooth/domain/entities/user_card.dart';
import 'package:cancun_dashbooth/domain/repositories/i_user_card_repository.dart';
import 'package:cancun_dashbooth/domain/usecases/get_community_stream_usecase.dart';

class MockUserCardRepository extends Mock implements IUserCardRepository {}

void main() {
  late MockUserCardRepository mockRepository;
  late GetCommunityStreamUseCase useCase;

  setUp(() {
    mockRepository = MockUserCardRepository();
    useCase = GetCommunityStreamUseCase(mockRepository);
  });

  test('emits stream of user cards from repository', () async {
    final expectedCards = [
      UserCard(
        id: '1',
        name: 'Diego',
        email: 'diego@test.com',
        imageUri: 'https://test.com/1.png',
        createdAt: DateTime(2026, 9, 16),
      ),
    ];

    when(() => mockRepository.streamCommunityCards())
        .thenAnswer((_) => Stream.value(expectedCards));

    final result = useCase.execute();

    expect(await result.first, equals(expectedCards));
    verify(() => mockRepository.streamCommunityCards()).called(1);
  });
}
