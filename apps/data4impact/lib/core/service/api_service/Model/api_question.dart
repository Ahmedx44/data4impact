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
  longText, // Added longText type for interviews
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
    case 'longText': // Handle longText type for interviews
      return ApiQuestionType.longText;
    default:
      return ApiQuestionType.unknown;
  }
}

// Convert enum to API string
String questionTypeToString(ApiQuestionType type) {
  switch (type) {
    case ApiQuestionType.openText:
      return 'openText';
    case ApiQuestionType.multipleChoiceSingle:
      return 'multipleChoiceSingle';
    case ApiQuestionType.multipleChoiceMulti:
      return 'multipleChoiceMulti';
    case ApiQuestionType.ranking:
      return 'ranking';
    case ApiQuestionType.matrix:
      return 'matrix';
    case ApiQuestionType.rating:
      return 'rating';
    case ApiQuestionType.date:
      return 'date';
    case ApiQuestionType.cascade:
      return 'cascade';
    case ApiQuestionType.longText:
      return 'longText';
    case ApiQuestionType.unknown:
      return 'unknown';
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
  final List<dynamic>? probings; // Added for interview questions
  final Map<String, dynamic>? buttonLabel; // Added for navigation
  final Map<String, dynamic>? backButtonLabel; // Added for navigation

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
    this.probings, // Added
    this.buttonLabel, // Added
    this.backButtonLabel, // Added
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
      probings: json['probings'] is List ? // Added
      (json['probings'] as List<dynamic>) :
      null,
      buttonLabel: json['buttonLabel'] is Map ? // Added
      (json['buttonLabel'] as Map<String, dynamic>) :
      null,
      backButtonLabel: json['backButtonLabel'] is Map ? // Added
      (json['backButtonLabel'] as Map<String, dynamic>) :
      null,
    );
  }

  // Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'variable': variable,
      'type': questionTypeToString(type),
      'required': required,
      'headline': headline,
      if (placeholder != null) 'placeholder': placeholder,
      if (choices != null) 'choices': choices,
      if (rows != null) 'rows': rows,
      if (columns != null) 'columns': columns,
      if (cascades != null) 'cascades': cascades,
      if (range != null) 'range': range,
      if (scale != null) 'scale': scale,
      if (lowerLabel != null) 'lowerLabel': lowerLabel,
      if (upperLabel != null) 'upperLabel': upperLabel,
      if (logic != null) 'logic': logic,
      if (charLimit != null) 'charLimit': charLimit,
      if (probings != null) 'probings': probings,
      if (buttonLabel != null) 'buttonLabel': buttonLabel,
      if (backButtonLabel != null) 'backButtonLabel': backButtonLabel,
    };
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

  // Get button label text
  String getButtonLabelText(String languageCode) {
    if (buttonLabel != null) {
      if (buttonLabel!.containsKey(languageCode)) {
        return buttonLabel![languageCode] as String? ?? buttonLabel!['default'] as String? ?? 'Next';
      }
      return buttonLabel!['default'] as String? ?? 'Next';
    }
    return 'Next';
  }

  // Get back button label text
  String getBackButtonLabelText(String languageCode) {
    if (backButtonLabel != null) {
      if (backButtonLabel!.containsKey(languageCode)) {
        return backButtonLabel![languageCode] as String? ?? backButtonLabel!['default'] as String? ?? 'Back';
      }
      return backButtonLabel!['default'] as String? ?? 'Back';
    }
    return 'Back';
  }

  // Get probing question text
  String getProbingLabel(Map<String, dynamic> probing, String languageCode) {
    final label = probing['label'];
    if (label is Map<String, dynamic>) {
      if (label.containsKey(languageCode)) {
        return label[languageCode] as String? ?? label['default'] as String? ?? '';
      }
      return label['default'] as String? ?? '';
    }
    return label?.toString() ?? '';
  }
}