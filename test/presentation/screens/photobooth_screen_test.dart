import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cancun_dashbooth/domain/repositories/i_camera_service.dart';
import 'package:cancun_dashbooth/presentation/providers/badge_draft_provider.dart';
import 'package:cancun_dashbooth/presentation/providers/di_providers.dart';
import 'package:cancun_dashbooth/presentation/screens/photobooth_screen.dart';
import 'package:cancun_dashbooth/presentation/widgets/official_badge_card.dart';

import 'package:cancun_dashbooth/domain/entities/ai_badge_result.dart';
import 'package:cancun_dashbooth/domain/entities/user_card.dart';
import 'package:cancun_dashbooth/domain/usecases/generate_ai_badge_usecase.dart';
import 'package:cancun_dashbooth/domain/usecases/publish_user_card_usecase.dart';
import 'package:cancun_dashbooth/presentation/providers/card_publish_provider.dart';

class MockCameraService extends Mock implements ICameraService {}

class MockGenerateAiBadgeUseCase extends Mock
    implements GenerateAiBadgeUseCase {}

class MockPublishUserCardUseCase extends Mock
    implements PublishUserCardUseCase {}

void main() {
  late MockCameraService mockCameraService;
  late MockGenerateAiBadgeUseCase mockGenerateAiUseCase;
  late MockPublishUserCardUseCase mockPublishUseCase;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockCameraService = MockCameraService();
    mockGenerateAiUseCase = MockGenerateAiBadgeUseCase();
    mockPublishUseCase = MockPublishUserCardUseCase();
  });

  Widget createTestWidget({List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: [
        cameraServiceProvider.overrideWithValue(mockCameraService),
        generateAiBadgeUseCaseProvider.overrideWithValue(mockGenerateAiUseCase),
        publishUserCardUseCaseProvider.overrideWithValue(mockPublishUseCase),
        ...overrides,
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: PhotoboothScreen(),
        ),
      ),
    );
  }

  testWidgets('renders photobooth initial state with form and disabled CTA',
      (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.textContaining('¡Crea tu Credencial'), findsOneWidget);
    expect(find.text('Nombre completo'), findsOneWidget);
    expect(find.text('Correo del asistente'), findsOneWidget);
    expect(find.text('Transformar con Dash IA'), findsOneWidget);

    final transformButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Transformar con Dash IA'),
    );
    expect(transformButton.onPressed, isNull);
  });

  testWidgets('enables CTA when name, email and photo are populated',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        cameraServiceProvider.overrideWithValue(mockCameraService),
        generateAiBadgeUseCaseProvider.overrideWithValue(mockGenerateAiUseCase),
        publishUserCardUseCaseProvider.overrideWithValue(mockPublishUseCase),
      ],
    );
    addTearDown(container.dispose);

    container.read(badgeDraftProvider.notifier).setName('Carlos');
    container
        .read(badgeDraftProvider.notifier)
        .setEmail('carlos@flutter.latam');
    container
        .read(badgeDraftProvider.notifier)
        .setPhotoBytes(Uint8List.fromList([1, 2, 3]));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: PhotoboothScreen(),
          ),
        ),
      ),
    );

    final transformButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Transformar con Dash IA'),
    );
    expect(transformButton.onPressed, isNotNull);
  });

  testWidgets(
      'triggers AI transformation and displays aiVibeTitle on badge preview',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        cameraServiceProvider.overrideWithValue(mockCameraService),
        generateAiBadgeUseCaseProvider.overrideWithValue(mockGenerateAiUseCase),
        publishUserCardUseCaseProvider.overrideWithValue(mockPublishUseCase),
      ],
    );
    addTearDown(container.dispose);

    const vibe = 'Capitán de Widgets Caribeños | Vibra Caribeña 100%';
    final photo = Uint8List.fromList([1, 2, 3]);
    final transformed = Uint8List.fromList([4, 5, 6]);

    when(() => mockGenerateAiUseCase.execute(
          photoBytes: any(named: 'photoBytes'),
          attendeeName: any(named: 'attendeeName'),
        )).thenAnswer((_) async => AiBadgeResult(
          imageBytes: transformed,
          aiVibeTitle: vibe,
        ));

    container.read(badgeDraftProvider.notifier).setName('Carlos');
    container
        .read(badgeDraftProvider.notifier)
        .setEmail('carlos@flutter.latam');
    container.read(badgeDraftProvider.notifier).setPhotoBytes(photo);

    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: PhotoboothScreen(),
          ),
        ),
      ),
    );

    // Tap "Transformar con Dash IA"
    final transformButton =
        find.widgetWithText(ElevatedButton, 'Transformar con Dash IA');
    await tester.ensureVisible(transformButton);
    await tester.tap(transformButton);
    await tester.pump(); // Start loading
    await tester.pump(const Duration(milliseconds: 100)); // Complete future
    await tester.pumpAndSettle();

    expect(find.textContaining('IA Vibe: Capitán de Widgets Caribeños'),
        findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(OfficialBadgeCard),
        matching: find.byIcon(Icons.auto_awesome),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
      'locks inputs and shows "Crear Otra Credencial" when card is published, and unlocks on reset',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        cameraServiceProvider.overrideWithValue(mockCameraService),
        generateAiBadgeUseCaseProvider.overrideWithValue(mockGenerateAiUseCase),
        publishUserCardUseCaseProvider.overrideWithValue(mockPublishUseCase),
      ],
    );
    addTearDown(container.dispose);

    final publishedCard = UserCard(
      id: 'card-999',
      name: 'Carlos',
      email: 'carlos@flutter.latam',
      imageUri: 'https://example.com/badge.png',
      createdAt: DateTime.now(),
    );

    when(() => mockPublishUseCase.execute(
          name: any(named: 'name'),
          email: any(named: 'email'),
          imageBytes: any(named: 'imageBytes'),
        )).thenAnswer((_) async => publishedCard);

    container.read(badgeDraftProvider.notifier).setName('Carlos');
    container
        .read(badgeDraftProvider.notifier)
        .setEmail('carlos@flutter.latam');
    container
        .read(badgeDraftProvider.notifier)
        .setPhotoBytes(Uint8List.fromList([1, 2, 3]));

    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: PhotoboothScreen(),
          ),
        ),
      ),
    );

    // Initial state: not published
    expect(find.text('Publicar en Mural de Recuerdos'), findsOneWidget);
    expect(find.text('Limpiar y reiniciar formulario'), findsOneWidget);
    expect(find.text('Transformar con Dash IA'), findsOneWidget);
    expect(find.text('Compartir en Instagram 📸'), findsOneWidget);
    expect(find.text('¡Credencial en el Mural! 🎉'), findsNothing);

    // Trigger publish
    await container.read(cardPublishProvider.notifier).publish(
          name: 'Carlos',
          email: 'carlos@flutter.latam',
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );
    await tester.pumpAndSettle();

    // Published state: locked and celebratory
    expect(find.text('¡Credencial en el Mural! 🎉'), findsOneWidget);
    expect(find.text('Crear Otra Credencial ✨'), findsOneWidget);
    expect(find.text('Credencial Publicada'), findsOneWidget);
    expect(find.text('Publicar en Mural de Recuerdos'), findsNothing);

    // Tap "Crear Otra Credencial ✨"
    final createAnotherBtn =
        find.widgetWithText(ElevatedButton, 'Crear Otra Credencial ✨');
    await tester.ensureVisible(createAnotherBtn);
    await tester.tap(createAnotherBtn);
    await tester.pumpAndSettle();

    // Screen should be completely reset and unlocked
    expect(find.text('Publicar en Mural de Recuerdos'), findsOneWidget);
    expect(find.text('Limpiar y reiniciar formulario'), findsOneWidget);
    expect(find.text('Transformar con Dash IA'), findsOneWidget);
    expect(find.text('¡Credencial en el Mural! 🎉'), findsNothing);
    expect(find.text('Crear Otra Credencial ✨'), findsNothing);
    expect(container.read(badgeDraftProvider).attendeeName, isEmpty);
    expect(container.read(badgeDraftProvider).hasPhoto, isFalse);
    expect(container.read(cardPublishProvider).value, isNull);
  });
}
