class InvitationModel {
  final String id;
  final String email;
  final String invitedBy;
  final String type;
  final String targetId;
  final String status;
  final List<String> roles;
  final String token;
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
    required this.token,
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
      roles: List<String>.from(json['roles'] as List ?? []),
      token: json['token'] as String,
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
