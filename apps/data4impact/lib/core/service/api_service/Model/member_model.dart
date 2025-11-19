class MemberModel {
  final String id;
  final String team;
  final List<String> roles;
  final String project;
  final String organization;
  final String userId;
  final Map<String, dynamic> attributes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;

  MemberModel({
    required this.id,
    required this.team,
    required this.roles,
    required this.project,
    required this.organization,
    required this.userId,
    required this.attributes,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  String get fullName => '${user.firstName} ${user.middleName} ${user.lastName}'.trim();

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['_id']?.toString() ?? '',
      team: json['team']?.toString() ?? '',
      roles: (json['roles'] as List<dynamic>?)?.map((role) => role.toString()).toList() ?? [],
      project: json['project']?.toString() ?? '',
      organization: json['organization']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      attributes: (json['attributes'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class User {
  final String id;
  final String firstName;
  final String middleName;
  final String lastName;
  final List<String> roles;
  final String phone;
  final String email;
  final bool emailVerified;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;

  User({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.roles,
    required this.phone,
    required this.email,
    required this.emailVerified,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      middleName: json['middleName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      roles: (json['roles'] as List<dynamic>?)?.map((role) => role.toString()).toList() ?? [],
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      emailVerified: json['emailVerified'] as bool? ?? false,
      active: json['active'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}