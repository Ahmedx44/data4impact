class SignInRequestModel {
  final String email;
  final String password;
  final Map<String, dynamic> headers;

  SignInRequestModel({
    required this.email,
    required this.password,
    this.headers = const {},
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };

  // Method to get headers
  Map<String, dynamic> getHeaders() => headers;
}