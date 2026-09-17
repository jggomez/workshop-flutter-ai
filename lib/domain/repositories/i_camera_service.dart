import 'dart:typed_data';

/// Abstract contract for camera and multimedia capture in web browsers.
abstract class ICameraService {
  /// Captures a selfie using the device's camera.
  Future<Uint8List?> captureSelfie();

  /// Picks an existing photo from the device/browser file picker.
  Future<Uint8List?> pickImageFromGallery();
}
