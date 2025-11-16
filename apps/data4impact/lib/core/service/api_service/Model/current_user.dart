class CurrentUser {
  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String role;
  final List<Map<String, dynamic>> roles; // Simple list of maps
  final String? phone;
  final String email;
  final bool emailVerified;
  final String? imageUrl;
  final bool active;
  final bool systemOwner;
  final String createdAt;
  final String updatedAt;

  CurrentUser({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.role,
    required this.roles,
    this.phone,
    required this.email,
    required this.emailVerified,
    this.imageUrl,
    required this.active,
    required this.systemOwner,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    // Extract the primary role name from the roles array
    String extractPrimaryRole(Map<String, dynamic> json) {
      if (json['roles'] is List && (json['roles'] as List).isNotEmpty) {
        final firstRole = (json['roles'] as List).first;
        if (firstRole is Map<String, dynamic>) {
          return firstRole['name']?.toString() ?? 'user';
        }
      }

      // Fallback to direct role field
      if (json['role'] != null && json['role'].toString().isNotEmpty) {
        return json['role'].toString();
      }

      return 'user';
    }

    // Extract all roles as simple maps
    List<Map<String, dynamic>> extractRoles(Map<String, dynamic> json) {
      if (json['roles'] is List) {
        return (json['roles'] as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
      return [];
    }

    return CurrentUser(
      id: json['_id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String? ?? '',
      role: extractPrimaryRole(json),
      roles: extractRoles(json),
      phone: json['phone'] as String?,
      email: json['email'] as String? ?? '',
      emailVerified: json['emailVerified'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      active: json['active'] as bool? ?? false,
      systemOwner: json['systemOwner'] as bool? ?? false,
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
      'roles': roles,
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