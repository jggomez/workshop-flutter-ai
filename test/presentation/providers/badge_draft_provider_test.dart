import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cancun_dashbooth/domain/repositories/i_camera_service.dart';
import 'package:cancun_dashbooth/presentation/providers/badge_draft_provider.dart';

class MockCameraService extends Mock implements ICameraService {}

void main() {
  late MockCameraService mockCamera;
  late BadgeDraftNotifier notifier;

  setUp(() {
    mockCamera = MockCameraService();
    notifier = BadgeDraftNotifier(mockCamera);
  });

  group('BadgeDraftNotifier', () {
    test('updates name and email correctly', () {
      notifier.updateName('Gael');
      notifier.updateEmail('gael@flutter.dev');

      expect(notifier.state.attendeeName, 'Gael');
      expect(notifier.state.attendeeEmail, 'gael@flutter.dev');
    });

    test('captureSelfie updates photo bytes on success', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      when(() => mockCamera.captureSelfie()).thenAnswer((_) async => bytes);

      final success = await notifier.captureSelfie();

      expect(success, isTrue);
      expect(notifier.state.rawPhotoBytes, equals(bytes));
      expect(notifier.state.hasPhoto, isTrue);
    });

    test('captureSelfie returns false on cancel without mutating photo',
        () async {
      when(() => mockCamera.captureSelfie()).thenAnswer((_) async => null);

      final success = await notifier.captureSelfie();

      expect(success, isFalse);
      expect(notifier.state.hasPhoto, isFalse);
    });

    test('reset clears fields and photos', () {
      notifier.updateName('Gael');
      notifier.clearPhoto();
      notifier.reset();

      expect(notifier.state.attendeeName, '');
      expect(notifier.state.attendeeEmail, '');
      expect(notifier.state.hasPhoto, isFalse);
      expect(notifier.state.aiVibeTitle, isNull);
    });

    test('setAiVibeTitle updates title and reset clears it', () {
      notifier.setAiVibeTitle('Capitán de Widgets');
      expect(notifier.state.aiVibeTitle, 'Capitán de Widgets');

      notifier.reset();
      expect(notifier.state.aiVibeTitle, isNull);
    });
  });
}
