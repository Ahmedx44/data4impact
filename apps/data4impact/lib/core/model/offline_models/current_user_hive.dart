import 'dart:convert';

import 'package:data4impact/core/service/api_service/Model/current_user.dart';
import 'package:data4impact/core/utils.dart';
import 'package:hive/hive.dart';

part 'current_user_hive.g.dart';

@HiveType(typeId: currentUserId)
class CurrentUserHive {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String? middleName;

  @HiveField(3)
  final String lastName;

  @HiveField(4)
  final String role;

  @HiveField(5)
  final String rolesJson; // Store roles as JSON string

  @HiveField(6)
  final String? phone;

  @HiveField(7)
  final String email;

  @HiveField(8)
  final bool emailVerified;

  @HiveField(9)
  final String? imageUrl;

  @HiveField(10)
  final bool active;

  @HiveField(11)
  final bool systemOwner;

  @HiveField(12)
  final String createdAt;

  @HiveField(13)
  final String updatedAt;

  CurrentUserHive({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.role,
    required this.rolesJson,
    required this.phone,
    required this.email,
    required this.emailVerified,
    required this.imageUrl,
    required this.active,
    required this.systemOwner,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CurrentUserHive.fromCurrentUser(CurrentUser user) {
    return CurrentUserHive(
      id: user.id,
      firstName: user.firstName,
      middleName: user.middleName ?? '', // Convert null to empty string for Hive
      lastName: user.lastName,
      role: user.role,
      rolesJson: _encodeRoles(user.roles),
      phone: user.phone ?? '', // Convert null to empty string
      email: user.email,
      emailVerified: user.emailVerified,
      imageUrl: user.imageUrl ?? '', // Convert null to empty string
      active: user.active,
      systemOwner: user.systemOwner,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  CurrentUser toCurrentUser() {
    return CurrentUser(
      id: id,
      firstName: firstName,
      middleName: middleName!.isEmpty ? null : middleName, // Convert back to null
      lastName: lastName,
      role: role,
      roles: _decodeRoles(rolesJson),
      phone: phone!.isEmpty ? null : phone, // Convert back to null
      email: email,
      emailVerified: emailVerified,
      imageUrl: imageUrl!.isEmpty ? null : imageUrl, // Convert back to null
      active: active,
      systemOwner: systemOwner,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Helper to encode roles to JSON
  static String _encodeRoles(List<Map<String, dynamic>> roles) {
    try {
      return jsonEncode(roles);
    } catch (e) {
      return '[]';
    }
  }

  // Helper to decode roles from JSON
  static List<Map<String, dynamic>> _decodeRoles(String rolesJson) {
    try {
      final List<dynamic> decoded = jsonDecode(rolesJson) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  @override
  String toString() {
    return 'CurrentUserHive(id: $id, name: $firstName $middleName $lastName, email: $email, role: $role)';
  }
}