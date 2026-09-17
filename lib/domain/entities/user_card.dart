/// Domain entity representing a completed and published conference badge.
class UserCard {
  final String id;
  final String name;
  final String email;
  final String imageUri;
  final DateTime createdAt;

  const UserCard({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUri,
    required this.createdAt,
  });

  UserCard copyWith({
    String? id,
    String? name,
    String? email,
    String? imageUri,
    DateTime? createdAt,
  }) {
    return UserCard(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUri: imageUri ?? this.imageUri,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserCard &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          imageUri == other.imageUri &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      imageUri.hashCode ^
      createdAt.hashCode;
}
