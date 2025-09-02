import 'api_question.dart';

class Study {
  final String id;
  final String name;
  final String description;
  final List<ApiQuestion> questions;
  final Map<String, dynamic> welcomeCard;
  final Map<String, dynamic> ending;

  Study({
    required this.id,
    required this.name,
    required this.description,
    required this.questions,
    required this.welcomeCard,
    required this.ending,
  });

  factory Study.fromJson(Map<String, dynamic> json) {
    // Check if this is an error response and throw exception
    if (json['error'] == true) {
      throw FormatException(json['message'] as String ?? 'Study is not available');
    }

    final questions = (json['questions'] as List<dynamic>?)
        ?.map((q) => ApiQuestion.fromJson(q as Map<String,dynamic>))
        .toList() ?? [];

    return Study(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      questions: questions,
      welcomeCard: json['welcomeCard'] as Map<String,dynamic>? ?? {},
      ending: json['ending'] as Map<String,dynamic>? ?? {},
    );
  }
}