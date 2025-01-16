// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModels {
  final String id;
  final String email;
  final String username;
  final String token;
  final DateTime createdAt;
  final DateTime updatedAt;
  UserModels({
    required this.id,
    required this.email,
    required this.username,
    required this.token,
    required this.createdAt,
    required this.updatedAt,
  });

  UserModels copyWith({
    String? id,
    String? email,
    String? username,
    String? token,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModels(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'username': username,
      'token': token,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory UserModels.fromMap(Map<String, dynamic> map) {
    return UserModels(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      token: map['token'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(), // Use current time if 'createdAt' is null
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : DateTime.now(), // Use current time if 'updatedAt' is null
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModels.fromJson(String source) =>
      UserModels.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModels(id: $id, email: $email, username: $username, token: $token, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant UserModels other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.email == email &&
        other.username == username &&
        other.token == token &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        username.hashCode ^
        token.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
