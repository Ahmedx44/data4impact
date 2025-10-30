// core/model/current_user/current_user_model.dart
class CurrentUser {
  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String role;
  final String? phone;
  final String email;
  final bool emailVerified;
  final String? imageUrl; // Make this nullable
  final bool active;
  final bool systemOwner; // Changed from String? to bool
  final String createdAt;
  final String updatedAt;

  CurrentUser({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.role,
    this.phone,
    required this.email,
    required this.emailVerified,
    this.imageUrl, // Now nullable
    required this.active,
    required this.systemOwner, // Changed to required bool
    required this.createdAt,
    required this.updatedAt,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      id: json['_id'] as String,
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String,
      role: (json['role'] ?? (json['roles'] != null && json['roles']!='' ? json['roles'][0] : 'user')) as String,
      phone: json['phone'] as String?,
      email: json['email'] as String,
      emailVerified: json['emailVerified'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      active: json['active'] as bool? ?? false,
      systemOwner: json['systemOwner'] as bool? ?? false, // safe fallback
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'role': role,
      'phone': phone,
      'email': email,
      'emailVerified': emailVerified,
      'imageUrl': imageUrl,
      'active': active,
      'systemOwner': systemOwner,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  String get fullName {
    return [firstName, middleName, lastName].where((name) => name != null && name.isNotEmpty).join(' ');
  }
}