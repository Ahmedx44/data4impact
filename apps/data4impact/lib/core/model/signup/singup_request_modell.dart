class SignupRequestModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String? middleName;

  SignupRequestModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    this.middleName,
  });

  // Convert model to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      if (middleName != null) 'middleName': middleName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }

  // For debugging/printing
  @override
  String toString() {
    return 'SignupRequestModel{firstName: $firstName, middleName: $middleName, lastName: $lastName, email: $email, phone: $phone, password: *****}';
  }
}