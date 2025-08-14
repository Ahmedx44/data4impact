class SignInResponseModel {
  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String role;
  final String phone;
  final String email;
  final bool emailVerified;
  final String? imageUrl;
  final bool active;
  final String systemOwner;
  final DateTime createdAt;
  final DateTime updatedAt;

  SignInResponseModel({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.role,
    required this.phone,
    required this.email,
    required this.emailVerified,
    this.imageUrl,
    required this.active,
    required this.systemOwner,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SignInResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      return SignInResponseModel(
        id: json['_id'] as String,
        firstName: json['firstName'] as String,
        middleName: json['middleName'] as String?,
        lastName: json['lastName'] as String,
        role: json['role'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String,
        emailVerified: json['emailVerified'] as bool,
        active: json['active'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        systemOwner: json['systemOwner'].toString(),
      );
    } catch (e, stack) {
      print('Error parsing user: $e\n$stack');
      rethrow;
    }
  }

  @override
  String toString() {
    return 'SignInResponseModel{id: $id, firstName: $firstName, middleName: $middleName, lastName: $lastName, email: $email}';
  }
}
