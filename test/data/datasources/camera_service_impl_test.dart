import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cancun_dashbooth/data/datasources/camera_service_impl.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockXFile extends Mock implements XFile {}

void main() {
  late MockImagePicker mockPicker;
  late CameraServiceImpl service;

  setUp(() {
    mockPicker = MockImagePicker();
    service = CameraServiceImpl(mockPicker);
  });

  group('CameraServiceImpl', () {
    test('captureSelfie returns bytes when photo is captured', () async {
      final mockFile = MockXFile();
      final expectedBytes = Uint8List.fromList([1, 2, 3]);

      when(() => mockPicker.pickImage(
            source: ImageSource.camera,
            preferredCameraDevice: CameraDevice.front,
            maxWidth: any(named: 'maxWidth'),
            maxHeight: any(named: 'maxHeight'),
            imageQuality: any(named: 'imageQuality'),
          )).thenAnswer((_) async => mockFile);

      when(() => mockFile.readAsBytes()).thenAnswer((_) async => expectedBytes);

      final result = await service.captureSelfie();

      expect(result, equals(expectedBytes));
      verify(() => mockPicker.pickImage(
            source: ImageSource.camera,
            preferredCameraDevice: CameraDevice.front,
            maxWidth: 1200,
            maxHeight: 1500,
            imageQuality: 85,
          )).called(1);
    });

    test('captureSelfie returns null when user cancels camera', () async {
      when(() => mockPicker.pickImage(
            source: ImageSource.camera,
            preferredCameraDevice: CameraDevice.front,
            maxWidth: any(named: 'maxWidth'),
            maxHeight: any(named: 'maxHeight'),
            imageQuality: any(named: 'imageQuality'),
          )).thenAnswer((_) async => null);

      final result = await service.captureSelfie();

      expect(result, isNull);
    });
  });
}
