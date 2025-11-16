import 'api_question.dart';
import 'homogeneity_models.dart'; // Add this import

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
  final Homogeneity? homogeneity; // CHANGED: Now using Homogeneity model
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
    this.homogeneity, // CHANGED
    this.subject,
  });

  factory Study.fromJson(Map<String, dynamic> json) {
    // Check if this is an error response and throw exception
    if (json['error'] == true) {
      throw FormatException(json['message'] as String ?? 'Study is not available');
    }

    // DEBUG: Check homogeneity data at the start
    print('=== STUDY PARSING DEBUG START ===');
    print('Study ID: ${json['_id']}');
    print('Study Name: ${json['name']}');
    print('Homogeneity key exists: ${json.containsKey('homogeneity')}');
    print('Homogeneity data type: ${json['homogeneity']?.runtimeType}');
    print('Homogeneity data: ${json['homogeneity']}');

    if (json['homogeneity'] != null) {
      print('Homogeneity is NOT null, proceeding with parsing...');
    } else {
      print('Homogeneity IS null - this is the problem!');
    }
    print('=== STUDY PARSING DEBUG END ===');

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

    // Parse homogeneity data for interview studies - CHANGED
    Homogeneity? homogeneity;
    if (json['homogeneity'] is Map<String, dynamic>) {
      print('=== PARSING HOMOGENEITY DATA ===');
      print('Homogeneity JSON keys: ${(json['homogeneity'] as Map<String, dynamic>).keys}');
      homogeneity = Homogeneity.fromJson(json['homogeneity'] as Map<String, dynamic>);
      print('=== HOMOGENEITY PARSING COMPLETE ===');
      print('Parsed homogeneity - fields: ${homogeneity?.fields.length}');
      print('Parsed homogeneity - groups: ${homogeneity?.groups.length}');
    } else {
      print('=== HOMOGENEITY PARSING FAILED ===');
      print('Homogeneity is NOT a Map - type: ${json['homogeneity']?.runtimeType}');
      print('Homogeneity value: ${json['homogeneity']}');
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

    // Final debug output
    print('=== STUDY CREATION SUMMARY ===');
    print('Study created with:');
    print('- ${questions.length} questions');
    print('- Homogeneity: ${homogeneity != null ? "EXISTS" : "NULL"}');
    if (homogeneity != null) {
      print('- Homogeneity fields: ${homogeneity!.fields.length}');
      print('- Homogeneity groups: ${homogeneity!.groups.length}');
    }
    print('=== STUDY CREATION COMPLETE ===');

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
      homogeneity: homogeneity, // CHANGED
      subject: subject,
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

  // Get homogeneity groups for interview studies - FIXED
  List<HomogeneityGroup> get homogeneityGroups {
    final groups = homogeneity?.groups ?? [];
    print('=== HOMOGENEITY GROUPS GETTER ===');
    print('Homogeneity object: ${homogeneity != null ? "EXISTS" : "NULL"}');
    print('Returning ${groups.length} groups');
    for (final group in groups) {
      print('- Group: ${group.name} (ID: ${group.id})');
    }
    print('=== END HOMOGENEITY GROUPS GETTER ===');
    return groups;
  }

  // Get homogeneity fields for interview studies - FIXED
  List<HomogeneityField> get homogeneityFields {
    final fields = homogeneity?.fields ?? [];
    print('=== HOMOGENEITY FIELDS GETTER ===');
    print('Homogeneity object: ${homogeneity != null ? "EXISTS" : "NULL"}');
    print('Returning ${fields.length} fields');
    for (final field in fields) {
      print('- Field: ${field.name} (ID: ${field.id})');
    }
    print('=== END HOMOGENEITY FIELDS GETTER ===');
    return fields;
  }

  // Get a specific homogeneity group by ID
  HomogeneityGroup? getHomogeneityGroupById(String groupId) {
    return homogeneityGroups.firstWhere(
          (group) => group.id == groupId,
      orElse: () => throw Exception('Group not found'),
    );
  }

  // Get a specific homogeneity field by ID
  HomogeneityField? getHomogeneityFieldById(String fieldId) {
    return homogeneityFields.firstWhere(
          (field) => field.id == fieldId,
      orElse: () => throw Exception('Field not found'),
    );
  }

  // Get criteria for a specific homogeneity group
  List<GroupCriterion> getCriteriaForGroup(String groupId) {
    final group = getHomogeneityGroupById(groupId);
    return group?.criteria ?? [];
  }

  // Check if a field is required by any group criteria
  bool isFieldRequired(String fieldId) {
    for (final group in homogeneityGroups) {
      for (final criterion in group.criteria) {
        if (criterion.field.id == fieldId) {
          return true;
        }
      }
    }
    return false;
  }

  // Get all criteria that apply to a specific field
  List<GroupCriterion> getCriteriaForField(String fieldId) {
    final List<GroupCriterion> fieldCriteria = [];
    for (final group in homogeneityGroups) {
      for (final criterion in group.criteria) {
        if (criterion.field.id == fieldId) {
          fieldCriteria.add(criterion);
        }
      }
    }
    return fieldCriteria;
  }

  // Get subject fields for longitudinal studies
  List<dynamic> get subjectFields {
    if (subject != null && subject!['fields'] is List) {
      return subject!['fields'] as List<dynamic>;
    }
    return [];
  }

  // Get sample group size for discussion studies
  int get sampleGroupSize {
    return homogeneity?.sampleGroupSize ?? 0;
  }

  // Get max group size for discussion studies
  int get maxGroupSize {
    return homogeneity?.maxGroupSize ?? 0;
  }

  // Get min group size for discussion studies
  int get minGroupSize {
    return homogeneity?.minGroupSize ?? 0;
  }

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

  // Convert to map for serialization
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'project': project,
      'status': status,
      'questions': questions.map((q) => q.toJson()).toList(),
      'welcomeCard': welcomeCard,
      'ending': ending,
      'responseValidation': responseValidation?.toJson(),
      'languages': languages,
      'questionCount': questionCount,
      'responseCount': responseCount,
      'methodology': methodology,
      'approach': approach,
      'design': design,
      'sampleSize': sampleSize,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'homogeneity': homogeneity?.toJson(),
      'subject': subject,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'voiceDuration': voiceDuration,
      'requiredVoice': requiredVoice,
      'requiredLocation': requiredLocation,
    };
  }
}