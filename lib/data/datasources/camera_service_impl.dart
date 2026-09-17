import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/i_camera_service.dart';

/// Web-compatible camera service implementing [ICameraService] using [ImagePicker].
/// Reads files entirely in-memory as [Uint8List] with zero dependency on `dart:io`.
class CameraServiceImpl implements ICameraService {
  final ImagePicker _picker;

  CameraServiceImpl([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  @override
  Future<Uint8List?> captureSelfie() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 1200,
      maxHeight: 1500,
      imageQuality: 85,
    );
    if (photo == null) return null;
    return await photo.readAsBytes();
  }

  @override
  Future<Uint8List?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1500,
      imageQuality: 85,
    );
    if (image == null) return null;
    return await image.readAsBytes();
  }
}
