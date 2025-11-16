import 'package:data4impact/core/service/api_service/Model/current_user.dart';
import 'package:data4impact/core/utils.dart';
import 'package:hive/hive.dart';

part 'current_user_hive.g.dart';

@HiveType(typeId: currentUserId)
class CurrentUserHive extends HiveObject {
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
  final List<Map<String, dynamic>> roles; // Add this field

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
    this.middleName,
    required this.lastName,
    required this.role,
    required this.roles, // Add to constructor
    this.phone,
    required this.email,
    required this.emailVerified,
    this.imageUrl,
    required this.active,
    required this.systemOwner,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CurrentUserHive.fromCurrentUser(CurrentUser user) {
    return CurrentUserHive(
      id: user.id,
      firstName: user.firstName,
      middleName: user.middleName,
      lastName: user.lastName,
      role: user.role,
      roles: user.roles, // Add this
      phone: user.phone,
      email: user.email,
      emailVerified: user.emailVerified,
      imageUrl: user.imageUrl,
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
      middleName: middleName,
      lastName: lastName,
      role: role,
      roles: roles, // Add this
      phone: phone,
      email: email,
      emailVerified: emailVerified,
      imageUrl: imageUrl,
      active: active,
      systemOwner: systemOwner,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}