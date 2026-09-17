import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_card.dart';

/// Data Transfer Object (DTO) for [UserCard] with Firestore serialization.
class UserCardModel extends UserCard {
  const UserCardModel({
    required super.id,
    required super.name,
    required super.email,
    required super.imageUri,
    required super.createdAt,
  });

  /// Factory constructor to parse a Cloud Firestore document snapshot.
  factory UserCardModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final timestamp = data['createdAt'] as Timestamp?;

    return UserCardModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      imageUri: data['imageUri'] as String? ?? '',
      createdAt: timestamp?.toDate() ?? DateTime.now(),
    );
  }

  /// Factory constructor to parse raw JSON map.
  factory UserCardModel.fromJson(Map<String, dynamic> json, {String? id}) {
    final rawDate = json['createdAt'];
    DateTime date;
    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is String) {
      date = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      date = DateTime.now();
    }

    return UserCardModel(
      id: id ?? (json['id'] as String? ?? ''),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      imageUri: json['imageUri'] as String? ?? '',
      createdAt: date,
    );
  }

  /// Converts this model into a map for Firestore persistence.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'imageUri': imageUri,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Converts this model into standard JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'imageUri': imageUri,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Converts to domain entity.
  UserCard toDomain() {
    return UserCard(
      id: id,
      name: name,
      email: email,
      imageUri: imageUri,
      createdAt: createdAt,
    );
  }

  /// Creates a model from a domain entity.
  factory UserCardModel.fromDomain(UserCard card) {
    return UserCardModel(
      id: card.id,
      name: card.name,
      email: card.email,
      imageUri: card.imageUri,
      createdAt: card.createdAt,
    );
  }
}
