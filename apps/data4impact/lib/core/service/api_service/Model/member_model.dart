// member_model.dart
import 'package:equatable/equatable.dart';

class MemberModel extends Equatable {
  final String id;
  final String teamId;
  final List<String> roles;
  final String userId;
  final Map<String, dynamic> attributes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User user;

  const MemberModel({
    required this.id,
    required this.teamId,
    required this.roles,
    required this.userId,
    required this.attributes,
    this.createdAt,
    this.updatedAt,
    required this.user,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['_id'] as String ?? '',
      teamId: json['team']  as String?? '',
      roles: List<String>.from(json['roles'] as List ?? []),
      userId: json['userId'] as String ?? '',
      attributes: Map<String, dynamic>.from(json['attributes'] as Map<String,dynamic> ?? {}),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      user: User.fromJson(json['user'] as Map<String,dynamic> ?? {}),
    );
  }

  String get fullName {
    final names = [user.firstName, user.middleName, user.lastName].where((name) => name != null && name.isNotEmpty);
    return names.join(' ');
  }

  @override
  List<Object?> get props => [
    id,
    teamId,
    roles,
    userId,
    attributes,
    createdAt,
    updatedAt,
    user,
  ];
}

class User extends Equatable {
  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String phone;
  final String email;
  final bool emailVerified;
  final String? imageUrl;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.emailVerified,
    this.imageUrl,
    required this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String ?? '',
      firstName: json['firstName'] as String ?? '',
      middleName: json['middleName'] as String,
      lastName: json['lastName'] as String ?? '',
      phone: json['phone'] as String ?? '',
      email: json['email']  as String ?? '',
      emailVerified: json['emailVerified'] as bool ?? false,
      imageUrl: json['imageUrl'] as String,
      active: json['active'] as bool ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    firstName,
    middleName,
    lastName,
    phone,
    email,
    emailVerified,
    imageUrl,
    active,
    createdAt,
    updatedAt,
  ];
}