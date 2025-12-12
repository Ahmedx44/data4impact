class InvitationModel {
  final String id;
  final String email;
  final String invitedBy;
  final String type;
  final String targetId;
  final String status;
  final List<String> roles;
  final String? token; // Made nullable since it's not in response
  final DateTime expiredAt;
  final String message;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvitationModel({
    required this.id,
    required this.email,
    required this.invitedBy,
    required this.type,
    required this.targetId,
    required this.status,
    required this.roles,
    this.token, // Made optional
    required this.expiredAt,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['_id'] as String,
      email: json['email'] as String,
      invitedBy: json['invitedBy'] as String,
      type: json['type'] as String,
      targetId: json['targetId'] as String,
      status: json['status'] as String,
      // Fix: Extract role names from objects
      roles: List<String>.from(
        (json['roles'] as List? ?? [])
            .map((role) {
          // Check if role is already a string or an object
          if (role is String) {
            return role;
          } else if (role is Map<String, dynamic>) {
            return role['name'] as String? ?? '';
          } else {
            return '';
          }
        })
            .where((name) => name.isNotEmpty) // Remove empty names
            .toList(),
      ),
      token: json['token'] as String?,
      expiredAt: DateTime.parse(json['expiredAt'] as String),
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'invitedBy': invitedBy,
      'type': type,
      'targetId': targetId,
      'status': status,
      'roles': roles,
      'token': token,
      'expiredAt': expiredAt.toIso8601String(),
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'InvitationModel(id: $id, email: $email, status: $status, roles: $roles, type: $type)';
  }
}