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
  final String methodology;
  final String approach;
  final String design;
  final int sampleSize;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? homogeneity; // Added for interview studies
  final Map<String, dynamic>? subject; // Added for longitudinal studies

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
    required this.methodology,
    this.approach = 'quantitative',
    this.design = 'crossSectional',
    this.sampleSize = 0,
    required this.createdAt,
    required this.updatedAt,
    this.homogeneity, // Added
    this.subject, // Added
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

    // Parse methodology - this is now the primary study type
    String methodology = json['methodology'] as String? ?? 'survey';

    // Parse design type for backward compatibility
    String designType = 'crossSectional';
    if (json['design'] is Map<String, dynamic>) {
      designType = (json['design']['type'] as String?) ?? 'crossSectional';
    }

    // Parse homogeneity data for interview studies
    Map<String, dynamic>? homogeneity;
    if (json['homogeneity'] is Map<String, dynamic>) {
      homogeneity = json['homogeneity'] as Map<String, dynamic>;
    }

    // Parse subject data for longitudinal studies
    Map<String, dynamic>? subject;
    if (json['subject'] is Map<String, dynamic>) {
      subject = json['subject'] as Map<String, dynamic>;
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
      methodology: methodology,
      approach: json['approach'] as String? ?? 'quantitative',
      design: designType,
      sampleSize: (json['sampleSize'] as num?)?.toInt() ?? 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
      homogeneity: homogeneity, // Added
      subject: subject, // Added
    );
  }

  // Get study type based on methodology
  String get studyType {
    return methodology;
  }

  // Check if this is an interview study
  bool get isInterviewStudy {
    return methodology == 'interview';
  }

  // Check if this is a group discussion study
  bool get isGroupDiscussionStudy {
    return methodology == 'discussion';
  }

  // Check if this is a longitudinal study
  bool get isLongitudinalStudy {
    return methodology == 'longitudinal';
  }

  // Get homogeneity groups for interview studies
  List<dynamic> get homogeneityGroups {
    if (homogeneity != null && homogeneity!['groups'] is List) {
      return homogeneity!['groups'] as List<dynamic>;
    }
    return [];
  }

  // Get homogeneity fields for interview studies
  List<dynamic> get homogeneityFields {
    if (homogeneity != null && homogeneity!['fields'] is List) {
      return homogeneity!['fields'] as List<dynamic>;
    }
    return [];
  }

  // Get subject fields for longitudinal studies
  List<dynamic> get subjectFields {
    if (subject != null && subject!['fields'] is List) {
      return subject!['fields'] as List<dynamic>;
    }
    return [];
  }

  // ... rest of your Study class methods remain the same
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

  bool get isWelcomeCardEnabled {
    return welcomeCard['enabled'] as bool? ?? true;
  }

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