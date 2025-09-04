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

  // Get title in the specified language, fallback to default
  String getTitle(String languageCode) {
    if (headline.containsKey(languageCode)) {
      return headline[languageCode] as String? ?? headline['default'] as String? ?? 'Question';
    }
    return headline['default'] as String? ?? 'Question';
  }

  // Get subtitle in the specified language, fallback to default
  String? getSubtitle(String languageCode) {
    final subtitle = headline['subtitle'];
    if (subtitle is Map<String, dynamic>) {
      if (subtitle.containsKey(languageCode)) {
        return subtitle[languageCode] as String?;
      }
      return subtitle['default'] as String?;
    }
    return null;
  }

  // Get placeholder text in the specified language, fallback to default
  String? getPlaceholder(String languageCode) {
    if (placeholder != null) {
      if (placeholder!.containsKey(languageCode)) {
        return placeholder![languageCode] as String?;
      }
      return placeholder!['default'] as String?;
    }
    return null;
  }

  // Get choice label in the specified language, fallback to default
  String getChoiceLabel(Map<String, dynamic> choice, String languageCode) {
    final label = choice['label'];
    if (label is Map<String, dynamic>) {
      if (label.containsKey(languageCode)) {
        return label[languageCode] as String? ?? label['default'] as String? ?? 'Option';
      }
      return label['default'] as String? ?? 'Option';
    }
    return 'Option';
  }

  // Get lower label text for rating questions
  String? getLowerLabel(String languageCode) {
    if (lowerLabel != null) {
      if (lowerLabel!.containsKey(languageCode)) {
        return lowerLabel![languageCode] as String?;
      }
      return lowerLabel!['default'] as String?;
    }
    return null;
  }

  // Get upper label text for rating questions
  String? getUpperLabel(String languageCode) {
    if (upperLabel != null) {
      if (upperLabel!.containsKey(languageCode)) {
        return upperLabel![languageCode] as String?;
      }
      return upperLabel!['default'] as String?;
    }
    return null;
  }

  // Get row label for matrix questions
  String getRowLabel(Map<String, dynamic> row, String languageCode) {
    final label = row['label'];
    if (label is Map<String, dynamic>) {
      if (label.containsKey(languageCode)) {
        return label[languageCode] as String? ?? label['default'] as String? ?? 'Row';
      }
      return label['default'] as String? ?? 'Row';
    }
    return 'Row';
  }

  // Get column label for matrix questions
  String getColumnLabel(Map<String, dynamic> column, String languageCode) {
    final label = column['label'];
    if (label is Map<String, dynamic>) {
      if (label.containsKey(languageCode)) {
        return label[languageCode] as String? ?? label['default'] as String? ?? 'Column';
      }
      return label['default'] as String? ?? 'Column';
    }
    return 'Column';
  }

  // Get cascade item name
  String getCascadeName(Map<String, dynamic> cascadeItem, String languageCode) {
    final name = cascadeItem['name'];
    if (name is Map<String, dynamic>) {
      if (name.containsKey(languageCode)) {
        return name[languageCode] as String? ?? name['default'] as String? ?? 'Item';
      }
      return name['default'] as String? ?? 'Item';
    }
    return 'Item';
  }
}