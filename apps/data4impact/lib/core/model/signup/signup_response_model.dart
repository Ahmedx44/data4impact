class SignupResponseModel {
  final bool error;
  final String message;
  final String? userId;
  final int? statusCode;

  SignupResponseModel({
    required this.error,
    required this.message,
    this.userId,
    this.statusCode,
  });

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
    return SignupResponseModel(
      error: json['error'] as bool? ?? false,
      message: json['message'] as String? ?? 'Unknown error',
      userId: json['user'] as String?,
      statusCode: json['statusCode'] as int?,
    );
  }

  @override
  String toString() {
    return 'SignupResponseModel{error: $error, message: $message, userId: $userId, statusCode: $statusCode}';
  }
}
