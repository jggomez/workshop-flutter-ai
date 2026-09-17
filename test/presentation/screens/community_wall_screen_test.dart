import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cancun_dashbooth/domain/entities/user_card.dart';
import 'package:cancun_dashbooth/domain/usecases/get_community_stream_usecase.dart';
import 'package:cancun_dashbooth/presentation/providers/di_providers.dart';
import 'package:cancun_dashbooth/presentation/screens/community_wall_screen.dart';

class MockGetCommunityStreamUseCase extends Mock
    implements GetCommunityStreamUseCase {}

void main() {
  late MockGetCommunityStreamUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetCommunityStreamUseCase();
  });

  testWidgets('renders empty state when no cards exist', (tester) async {
    when(() => mockUseCase.execute()).thenAnswer(
      (_) => Stream.value(<UserCard>[]),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getCommunityStreamUseCaseProvider.overrideWithValue(mockUseCase),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CommunityWallScreen(),
          ),
        ),
      ),
    );

    // Let the stream emit
    await tester.pump();

    expect(find.text('¡El Mural está esperando!'), findsOneWidget);
    expect(find.textContaining('Sé el primer asistente'), findsOneWidget);
  });

  testWidgets('renders cards grid when cards are emitted', (tester) async {
    final testCards = [
      UserCard(
        id: 'c1',
        name: 'Lucia Alvarez',
        email: 'lucia@flutter.latam',
        imageUri: 'https://example.com/badge1.png',
        createdAt: DateTime(2026, 9, 16),
      ),
    ];

    when(() => mockUseCase.execute()).thenAnswer(
      (_) => Stream.value(testCards),
    );

    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getCommunityStreamUseCaseProvider.overrideWithValue(mockUseCase),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CommunityWallScreen(),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.textContaining('Álbum de Recuerdos en Vivo'), findsOneWidget);
    expect(find.text('Lucia Alvarez'), findsOneWidget);
    expect(find.textContaining('1 Fotos de Flutter Pioneers'), findsOneWidget);
    expect(find.text('Ruleta F1 Premios'), findsWidgets);
  });

  testWidgets('tapping F1 Roulette button opens F1RouletteDialog',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final testCards = [
      UserCard(
        id: 'c1',
        name: 'Lucia Alvarez',
        email: 'lucia@flutter.latam',
        imageUri: 'https://example.com/badge1.png',
        createdAt: DateTime(2026, 9, 16),
      ),
    ];

    when(() => mockUseCase.execute()).thenAnswer(
      (_) => Stream.value(testCards),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getCommunityStreamUseCaseProvider.overrideWithValue(mockUseCase),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CommunityWallScreen(),
          ),
        ),
      ),
    );

    await tester.pump();

    final rouletteButton = find.text('Ruleta F1 Premios').first;
    expect(rouletteButton, findsOneWidget);

    await tester.tap(rouletteButton);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('GRAN PREMIO CANCÚN 2026'), findsOneWidget);
  });

  testWidgets(
      'tapping a card in the mural opens detail modal with download and Instagram share options',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final testCards = [
      UserCard(
        id: 'c1',
        name: 'Lucia Alvarez',
        email: 'lucia@flutter.latam',
        imageUri: 'https://example.com/badge1.png',
        createdAt: DateTime(2026, 9, 16),
      ),
    ];

    when(() => mockUseCase.execute()).thenAnswer(
      (_) => Stream.value(testCards),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getCommunityStreamUseCaseProvider.overrideWithValue(mockUseCase),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CommunityWallScreen(),
          ),
        ),
      ),
    );

    await tester.pump();

    // Tap on the polaroid badge item for Lucia Alvarez
    final badgeItem = find.text('Lucia Alvarez');
    expect(badgeItem, findsOneWidget);

    await tester.tap(badgeItem);
    await tester.pumpAndSettle();

    // Verify modal is open with download and Instagram share options
    expect(find.text('Descargar Credencial HD (PNG)'), findsOneWidget);
    expect(find.text('Compartir en Instagram 📸'), findsOneWidget);
    expect(find.text('Cerrar'), findsOneWidget);
  });
}
