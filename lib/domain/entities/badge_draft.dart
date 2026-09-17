import 'dart:typed_data';

/// In-memory representation of an attendee's badge draft prior to AI generation.
class BadgeDraft {
  final String attendeeName;
  final String attendeeEmail;
  final Uint8List rawPhotoBytes;
  final DateTime createdAt;
  final String? aiVibeTitle;

  const BadgeDraft({
    required this.attendeeName,
    required this.attendeeEmail,
    required this.rawPhotoBytes,
    required this.createdAt,
    this.aiVibeTitle,
  });

  bool get isValidName => attendeeName.trim().length >= 2;
  bool get isValidEmail =>
      RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')
          .hasMatch(attendeeEmail.trim());
  bool get hasPhoto => rawPhotoBytes.isNotEmpty;
  bool get isReadyForGeneration => isValidName && isValidEmail && hasPhoto;

  BadgeDraft copyWith({
    String? attendeeName,
    String? attendeeEmail,
    Uint8List? rawPhotoBytes,
    DateTime? createdAt,
    String? aiVibeTitle,
  }) {
    return BadgeDraft(
      attendeeName: attendeeName ?? this.attendeeName,
      attendeeEmail: attendeeEmail ?? this.attendeeEmail,
      rawPhotoBytes: rawPhotoBytes ?? this.rawPhotoBytes,
      createdAt: createdAt ?? this.createdAt,
      aiVibeTitle: aiVibeTitle ?? this.aiVibeTitle,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeDraft &&
          runtimeType == other.runtimeType &&
          attendeeName == other.attendeeName &&
          attendeeEmail == other.attendeeEmail &&
          createdAt == other.createdAt &&
          aiVibeTitle == other.aiVibeTitle;

  @override
  int get hashCode =>
      attendeeName.hashCode ^
      attendeeEmail.hashCode ^
      createdAt.hashCode ^
      aiVibeTitle.hashCode;
}
