import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cancun_dashbooth/data/models/user_card_model.dart';
import 'package:cancun_dashbooth/domain/entities/user_card.dart';

void main() {
  group('UserCardModel', () {
    final now = DateTime(2026, 9, 16, 12, 0, 0);

    final model = UserCardModel(
      id: 'id-456',
      name: 'Lucía Flutter',
      email: 'lucia@test.com',
      imageUri: 'https://storage/img.png',
      createdAt: now,
    );

    test('toFirestore serializes correctly with Timestamp', () {
      final map = model.toFirestore();
      expect(map['name'], 'Lucía Flutter');
      expect(map['email'], 'lucia@test.com');
      expect(map['imageUri'], 'https://storage/img.png');
      expect(map['createdAt'], isA<Timestamp>());
      expect((map['createdAt'] as Timestamp).toDate(), now);
    });

    test('toJson serializes correctly with ISO8601 string', () {
      final json = model.toJson();
      expect(json['id'], 'id-456');
      expect(json['name'], 'Lucía Flutter');
      expect(json['createdAt'], now.toIso8601String());
    });

    test('fromJson parses correctly', () {
      final json = {
        'id': 'id-789',
        'name': 'Pedro',
        'email': 'pedro@test.com',
        'imageUri': 'https://storage/pedro.png',
        'createdAt': now.toIso8601String(),
      };

      final parsed = UserCardModel.fromJson(json);
      expect(parsed.id, 'id-789');
      expect(parsed.name, 'Pedro');
      expect(parsed.email, 'pedro@test.com');
      expect(parsed.createdAt, now);
    });

    test('fromDomain and toDomain preserve identity', () {
      final domain = UserCard(
        id: 'dom-1',
        name: 'Andrea',
        email: 'andrea@test.com',
        imageUri: 'https://test.com/a.png',
        createdAt: now,
      );

      final fromDom = UserCardModel.fromDomain(domain);
      expect(fromDom.toDomain(), equals(domain));
    });
  });
}
