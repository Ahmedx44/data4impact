// homogeneity_models.dart
// In your homogeneity_models.dart file

class Homogeneity {
  final List<HomogeneityField> fields;
  final List<HomogeneityGroup> groups;
  final int sampleGroupSize;
  final int maxGroupSize;
  final int minGroupSize;

  Homogeneity({
    required this.fields,
    required this.groups,
    this.sampleGroupSize = 0,
    this.maxGroupSize = 0,
    this.minGroupSize = 0,
  });

  factory Homogeneity.fromJson(Map<String, dynamic> json) {
    print('=== PARSING HOMOGENEITY JSON ===');
    print('Homogeneity JSON keys: ${json.keys}');
    print('Full homogeneity JSON: $json');

    // Parse fields
    List<HomogeneityField> fields = [];
    if (json['fields'] is List) {
      print('Fields is List, length: ${(json['fields'] as List).length}');
      for (var i = 0; i < (json['fields'] as List).length; i++) {
        final fieldJson = (json['fields'] as List)[i];
        print('Field $i: $fieldJson');
        if (fieldJson is Map<String, dynamic>) {
          try {
            final field = HomogeneityField.fromJson(fieldJson);
            fields.add(field);
            print('Successfully parsed field: ${field.name}');
          } catch (e) {
            print('Error parsing field $i: $e');
          }
        } else {
          print('Field $i is NOT a Map - type: ${fieldJson.runtimeType}');
        }
      }
    } else {
      print('Fields is NOT a List - type: ${json['fields']?.runtimeType}');
      print('Fields value: ${json['fields']}');
    }

    // Parse groups
    List<HomogeneityGroup> groups = [];
    if (json['groups'] is List) {
      print('Groups is List, length: ${(json['groups'] as List).length}');
      for (var i = 0; i < (json['groups'] as List).length; i++) {
        final groupJson = (json['groups'] as List)[i];
        print('Group $i: $groupJson');
        if (groupJson is Map<String, dynamic>) {
          try {
            final group = HomogeneityGroup.fromJson(groupJson);
            groups.add(group);
            print('Successfully parsed group: ${group.name}');
          } catch (e) {
            print('Error parsing group $i: $e');
          }
        } else {
          print('Group $i is NOT a Map - type: ${groupJson.runtimeType}');
        }
      }
    } else {
      print('Groups is NOT a List - type: ${json['groups']?.runtimeType}');
      print('Groups value: ${json['groups']}');
    }

    print('=== HOMOGENEITY PARSING RESULT ===');
    print('Parsed ${fields.length} fields and ${groups.length} groups');
    print('=== END HOMOGENEITY PARSING ===');

    return Homogeneity(
      fields: fields,
      groups: groups,
      sampleGroupSize: (json['sampleGroupSize'] as num?)?.toInt() ?? 0,
      maxGroupSize: (json['maxGroupSize'] as num?)?.toInt() ?? 0,
      minGroupSize: (json['minGroupSize'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fields': fields.map((field) => field.toJson()).toList(),
      'groups': groups.map((group) => group.toJson()).toList(),
      'sampleGroupSize': sampleGroupSize,
      'maxGroupSize': maxGroupSize,
      'minGroupSize': minGroupSize,
    };
  }
}

class HomogeneityField {
  final String id;
  final String name;
  final String type;
  final List<String> options;
  final String description;

  HomogeneityField({
    required this.id,
    required this.name,
    required this.type,
    required this.options,
    required this.description,
  });

  factory HomogeneityField.fromJson(Map<String, dynamic> json) {
    return HomogeneityField(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'options': options,
      'description': description,
    };
  }
}

class HomogeneityGroup {
  final String id;
  final String name;
  final String description;
  final List<GroupCriterion> criteria;

  HomogeneityGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.criteria,
  });

  factory HomogeneityGroup.fromJson(Map<String, dynamic> json) {
    return HomogeneityGroup(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      criteria: (json['criteria'] as List<dynamic>?)
          ?.map((criterion) => GroupCriterion.fromJson(criterion as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'criteria': criteria.map((criterion) => criterion.toJson()).toList(),
    };
  }
}

class GroupCriterion {
  final String id;
  final HomogeneityField field;
  final String operator;
  final String value;
  final String value2;
  final String description;

  GroupCriterion({
    required this.id,
    required this.field,
    required this.operator,
    required this.value,
    required this.value2,
    required this.description,
  });

  factory GroupCriterion.fromJson(Map<String, dynamic> json) {
    return GroupCriterion(
      id: json['id'] as String? ?? '',
      field: HomogeneityField.fromJson(json['field'] as Map<String, dynamic>),
      operator: json['operator'] as String? ?? '',
      value: json['value'] as String? ?? '',
      value2: json['value2'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field': field.toJson(),
      'operator': operator,
      'value': value,
      'value2': value2,
      'description': description,
    };
  }
}