import 'package:flutter_test/flutter_test.dart';
import 'package:cancun_dashbooth/domain/entities/user_card.dart';

void main() {
  group('UserCard Entity', () {
    final now = DateTime(2026, 9, 16);

    test('creates and verifies attributes correctly', () {
      final card = UserCard(
        id: 'card-123',
        name: 'Carlos Dev',
        email: 'carlos@dev.io',
        imageUri: 'https://firebasestorage.googleapis.com/badge.png',
        createdAt: now,
      );

      expect(card.id, 'card-123');
      expect(card.name, 'Carlos Dev');
      expect(card.email, 'carlos@dev.io');
      expect(card.imageUri, 'https://firebasestorage.googleapis.com/badge.png');
      expect(card.createdAt, now);
    });

    test('supports copyWith and value equality', () {
      final card1 = UserCard(
        id: 'card-123',
        name: 'Carlos Dev',
        email: 'carlos@dev.io',
        imageUri: 'https://firebasestorage.googleapis.com/badge.png',
        createdAt: now,
      );

      final card2 = card1.copyWith(name: 'Carlos Updated');
      expect(card2.name, 'Carlos Updated');
      expect(card2.id, card1.id);
      expect(card1 == card2, isFalse);

      final card3 = card2.copyWith(name: 'Carlos Dev');
      expect(card1, equals(card3));
    });
  });
}
