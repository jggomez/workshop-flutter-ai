import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:cancun_dashbooth/domain/entities/badge_draft.dart';

void main() {
  group('BadgeDraft Entity', () {
    final now = DateTime(2026, 9, 16);
    final photo = Uint8List.fromList([1, 2, 3, 4]);

    test('validates attendee name correctly', () {
      final draftValid = BadgeDraft(
        attendeeName: 'Dash',
        attendeeEmail: 'dash@flutter.dev',
        rawPhotoBytes: photo,
        createdAt: now,
      );
      expect(draftValid.isValidName, isTrue);

      final draftShort = draftValid.copyWith(attendeeName: 'D');
      expect(draftShort.isValidName, isFalse);

      final draftEmpty = draftValid.copyWith(attendeeName: '   ');
      expect(draftEmpty.isValidName, isFalse);
    });

    test('validates attendee email correctly', () {
      final draftValid = BadgeDraft(
        attendeeName: 'Juan Gómez',
        attendeeEmail: 'juan@flutterconf.latam',
        rawPhotoBytes: photo,
        createdAt: now,
      );
      expect(draftValid.isValidEmail, isTrue);

      final draftInvalid = draftValid.copyWith(attendeeEmail: 'not-an-email');
      expect(draftInvalid.isValidEmail, isFalse);
    });

    test('validates photo existence and readiness', () {
      final readyDraft = BadgeDraft(
        attendeeName: 'María',
        attendeeEmail: 'maria@flutter.dev',
        rawPhotoBytes: photo,
        createdAt: now,
      );
      expect(readyDraft.hasPhoto, isTrue);
      expect(readyDraft.isReadyForGeneration, isTrue);

      final noPhotoDraft = readyDraft.copyWith(rawPhotoBytes: Uint8List(0));
      expect(noPhotoDraft.hasPhoto, isFalse);
      expect(noPhotoDraft.isReadyForGeneration, isFalse);
    });

    test('supports value equality', () {
      final draft1 = BadgeDraft(
        attendeeName: 'Dash',
        attendeeEmail: 'dash@flutter.dev',
        rawPhotoBytes: photo,
        createdAt: now,
      );
      final draft2 = BadgeDraft(
        attendeeName: 'Dash',
        attendeeEmail: 'dash@flutter.dev',
        rawPhotoBytes: photo,
        createdAt: now,
      );
      expect(draft1, equals(draft2));
    });

    test('supports aiVibeTitle in constructor and copyWith', () {
      final draft = BadgeDraft(
        attendeeName: 'Dash',
        attendeeEmail: 'dash@flutter.dev',
        rawPhotoBytes: photo,
        createdAt: now,
        aiVibeTitle: 'Dash Surfista Legendario',
      );
      expect(draft.aiVibeTitle, equals('Dash Surfista Legendario'));

      final updated = draft.copyWith(aiVibeTitle: 'Capitán Caribeño');
      expect(updated.aiVibeTitle, equals('Capitán Caribeño'));
    });
  });
}
