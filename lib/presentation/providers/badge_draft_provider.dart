import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/badge_draft.dart';
import '../../domain/repositories/i_camera_service.dart';
import 'di_providers.dart';

/// Notifier managing attendee input and camera capture for the badge draft.
class BadgeDraftNotifier extends StateNotifier<BadgeDraft> {
  final ICameraService _cameraService;

  BadgeDraftNotifier(this._cameraService)
      : super(BadgeDraft(
          attendeeName: '',
          attendeeEmail: '',
          rawPhotoBytes: Uint8List(0),
          createdAt: DateTime.now(),
        ));

  void updateName(String name) {
    state = state.copyWith(attendeeName: name);
  }

  void setName(String name) => updateName(name);

  void updateEmail(String email) {
    state = state.copyWith(attendeeEmail: email);
  }

  void setEmail(String email) => updateEmail(email);

  Future<bool> captureSelfie() async {
    final bytes = await _cameraService.captureSelfie();
    if (bytes != null && bytes.isNotEmpty) {
      state = state.copyWith(rawPhotoBytes: bytes);
      return true;
    }
    return false;
  }

  Future<bool> pickImageFromGallery() async {
    final bytes = await _cameraService.pickImageFromGallery();
    if (bytes != null && bytes.isNotEmpty) {
      state = state.copyWith(rawPhotoBytes: bytes);
      return true;
    }
    return false;
  }

  Future<bool> uploadPhoto() => pickImageFromGallery();

  void setPhotoBytes(Uint8List? bytes) {
    state = state.copyWith(rawPhotoBytes: bytes ?? Uint8List(0));
  }

  void clearPhoto() {
    state = state.copyWith(rawPhotoBytes: Uint8List(0));
  }

  void setAiVibeTitle(String? vibeTitle) {
    state = state.copyWith(aiVibeTitle: vibeTitle);
  }

  void reset() {
    state = BadgeDraft(
      attendeeName: '',
      attendeeEmail: '',
      rawPhotoBytes: Uint8List(0),
      createdAt: DateTime.now(),
      aiVibeTitle: null,
    );
  }
}

final badgeDraftProvider =
    StateNotifierProvider<BadgeDraftNotifier, BadgeDraft>((ref) {
  final cameraService = ref.watch(cameraServiceProvider);
  return BadgeDraftNotifier(cameraService);
});
