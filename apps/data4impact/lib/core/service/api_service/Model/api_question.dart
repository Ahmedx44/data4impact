// Question Types from API
enum ApiQuestionType {
  openText,
  multipleChoiceSingle,
  multipleChoiceMulti,
  ranking,
  matrix,
  rating,
  date,
  cascade,
  unknown
}

// Convert API string to enum
ApiQuestionType parseQuestionType(String type) {
  switch (type) {
    case 'openText':
      return ApiQuestionType.openText;
    case 'multipleChoiceSingle':
      return ApiQuestionType.multipleChoiceSingle;
    case 'multipleChoiceMulti':
      return ApiQuestionType.multipleChoiceMulti;
    case 'ranking':
      return ApiQuestionType.ranking;
    case 'matrix':
      return ApiQuestionType.matrix;
    case 'rating':
      return ApiQuestionType.rating;
    case 'date':
      return ApiQuestionType.date;
    case 'cascade':
      return ApiQuestionType.cascade;
    default:
      return ApiQuestionType.unknown;
  }
}

class ApiQuestion {
  final String id;
  final int number;
  final String variable;
  final ApiQuestionType type;
  final bool required;
  final Map<String, dynamic> headline;
  final Map<String, dynamic>? placeholder;
  final List<dynamic>? choices;
  final List<dynamic>? rows;
  final List<dynamic>? columns;
  final List<dynamic>? cascades;
  final int? range;
  final String? scale;
  final Map<String, dynamic>? lowerLabel;
  final Map<String, dynamic>? upperLabel;
  final List<dynamic>? logic;
  final Map<String, dynamic>? charLimit;

  ApiQuestion({
    required this.id,
    required this.number,
    required this.variable,
    required this.type,
    required this.required,
    required this.headline,
    this.placeholder,
    this.choices,
    this.rows,
    this.columns,
    this.cascades,
    this.range,
    this.scale,
    this.lowerLabel,
    this.upperLabel,
    this.logic,
    this.charLimit,
  });

  factory ApiQuestion.fromJson(Map<String, dynamic> json) {
    return ApiQuestion(
      id: json['id'] as String? ?? '',
      number: (json['number'] as num?)?.toInt() ?? 0,
      variable: json['variable'] as String? ?? '',
      type: parseQuestionType(json['type'] as String? ?? 'unknown'),
      required: json['required'] as bool? ?? true,
      headline: json['headline'] is Map ?
      (json['headline'] as Map<String, dynamic>) :
      {'default': ''},
      placeholder: json['placeholder'] is Map ?
      (json['placeholder'] as Map<String, dynamic>) :
      null,
      choices: json['choices'] is List ?
      (json['choices'] as List<dynamic>) :
      null,
      rows: json['rows'] is List ?
      (json['rows'] as List<dynamic>) :
      null,
      columns: json['columns'] is List ?
      (json['columns'] as List<dynamic>) :
      null,
      cascades: json['cascades'] is List ?
      (json['cascades'] as List<dynamic>) :
      null,
      range: (json['range'] as num?)?.toInt(),
      scale: json['scale'] as String?,
      lowerLabel: json['lowerLabel'] is Map ?
      (json['lowerLabel'] as Map<String, dynamic>) :
      null,
      upperLabel: json['upperLabel'] is Map ?
      (json['upperLabel'] as Map<String, dynamic>) :
      null,
      logic: json['logic'] is List ?
      (json['logic'] as List<dynamic>) :
      null,
      charLimit: json['charLimit'] is Map ?
      (json['charLimit'] as Map<String, dynamic>) :
      null,
    );
  }

  String getTitle(String languageCode) {
    if (headline.containsKey(languageCode)) {
      return headline[languageCode] as String? ?? 'Question';
    }
    return headline['default'] as String? ?? 'Question';
  }
}