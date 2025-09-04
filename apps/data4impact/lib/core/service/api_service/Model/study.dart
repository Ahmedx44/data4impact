import 'api_question.dart';

class Study {
  final String id;
  final String name;
  final String description;
  final String project;
  final String status;
  final List<ApiQuestion> questions;
  final Map<String, dynamic> welcomeCard;
  final Map<String, dynamic> ending;
  final ResponseValidation? responseValidation;
  final List<Map<String, dynamic>> languages;
  final int questionCount;
  final int responseCount;
  final String design;
  final String approach;
  final String methodology;
  final int sampleSize;
  final DateTime createdAt;
  final DateTime updatedAt;

  Study({
    required this.id,
    required this.name,
    required this.description,
    required this.project,
    required this.status,
    required this.questions,
    required this.welcomeCard,
    required this.ending,
    this.responseValidation,
    this.languages = const [],
    this.questionCount = 0,
    this.responseCount = 0,
    this.design = 'crossSectional',
    this.approach = 'quantitative',
    this.methodology = 'survey',
    this.sampleSize = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Study.fromJson(Map<String, dynamic> json) {
    // Check if this is an error response and throw exception
    if (json['error'] == true) {
      throw FormatException(json['message'] as String ?? 'Study is not available');
    }

    final questions = (json['questions'] as List<dynamic>?)
        ?.map((q) => ApiQuestion.fromJson(q as Map<String,dynamic>))
        .toList() ?? [];

    // Parse response validation
    ResponseValidation? responseValidation;
    if (json['responseValidation'] is Map<String, dynamic>) {
      responseValidation = ResponseValidation.fromJson(json['responseValidation']as Map<String,dynamic>);
    }

    // Parse languages
    List<Map<String, dynamic>> languages = [];
    if (json['languages'] is List<dynamic>) {
      languages = (json['languages'] as List).whereType<Map<String, dynamic>>().toList();
    }

    // Parse dates
    DateTime createdAt = DateTime.now();
    if (json['createdAt'] is String) {
      createdAt = DateTime.parse(json['createdAt'] as String);
    }

    DateTime updatedAt = DateTime.now();
    if (json['updatedAt'] is String) {
      updatedAt = DateTime.parse(json['updatedAt'] as String);
    }

    return Study(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      project: json['project'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      questions: questions,
      welcomeCard: json['welcomeCard'] as Map<String,dynamic>? ?? {},
      ending: json['ending'] as Map<String,dynamic>? ?? {},
      responseValidation: responseValidation,
      languages: languages,
      questionCount: (json['questionCount'] as num?)?.toInt() ?? 0,
      responseCount: (json['responseCount'] as num?)?.toInt() ?? 0,
      design: json['design']?['type'] as String? ?? 'crossSectional',
      approach: json['approach'] as String? ?? 'quantitative',
      methodology: json['methodology'] as String? ?? 'survey',
      sampleSize: (json['sampleSize'] as num?)?.toInt() ?? 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Helper method to get welcome headline in specified language
  String getWelcomeHeadline(String languageCode) {
    final headline = welcomeCard['headline'];
    if (headline is Map<String, dynamic>) {
      if (headline.containsKey(languageCode)) {
        return headline[languageCode] as String? ?? headline['default'] as String? ?? 'Welcome';
      }
      return headline['default'] as String? ?? 'Welcome';
    }
    return 'Welcome';
  }

  // Helper method to get welcome HTML content in specified language
  String getWelcomeHtml(String languageCode) {
    final html = welcomeCard['html'];
    if (html is Map<String, dynamic>) {
      if (html.containsKey(languageCode)) {
        return html[languageCode] as String? ?? html['default'] as String? ?? '';
      }
      return html['default'] as String? ?? '';
    }
    return '';
  }

  // Helper method to get ending headline in specified language
  String getEndingHeadline(String languageCode) {
    final headline = ending['headline'];
    if (headline is Map<String, dynamic>) {
      if (headline.containsKey(languageCode)) {
        return headline[languageCode] as String? ?? headline['default'] as String? ?? 'Thank you!';
      }
      return headline['default'] as String? ?? 'Thank you!';
    }
    return 'Thank you!';
  }

  // Helper method to get ending subheader in specified language
  String getEndingSubheader(String languageCode) {
    final subheader = ending['subheader'];
    if (subheader is Map<String, dynamic>) {
      if (subheader.containsKey(languageCode)) {
        return subheader[languageCode] as String? ?? subheader['default'] as String? ?? 'Your response has been recorded.';
      }
      return subheader['default'] as String? ?? 'Your response has been recorded.';
    }
    return 'Your response has been recorded.';
  }

  // Check if welcome card is enabled
  bool get isWelcomeCardEnabled {
    return welcomeCard['enabled'] as bool? ?? true;
  }

  // Check if ending button should be shown
  bool get showEndingButton {
    return ending['showButton'] as bool? ?? true;
  }
}

class ResponseValidation {
  final int voiceDuration;
  final bool requiredVoice;
  final bool requiredLocation;

  ResponseValidation({
    required this.voiceDuration,
    required this.requiredVoice,
    required this.requiredLocation,
  });

  factory ResponseValidation.fromJson(Map<String, dynamic> json) {
    return ResponseValidation(
      voiceDuration: (json['voiceDuration'] as num?)?.toInt() ?? 0,
      requiredVoice: json['requiredVoice'] as bool? ?? false,
      requiredLocation: json['requiredLocation'] as bool? ?? false,
    );
  }
}