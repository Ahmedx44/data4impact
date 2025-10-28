import 'dart:convert';

class Project {
  final String id;
  final String slug;
  final String title;
  final String organization;
  final String userId;
  final String status;
  final int studiesCount;
  final int contributorsCount;
  final String description;
  final String visibility;
  final String? priority; // Make priority nullable
  final String? country;
  final String? sector;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.slug,
    required this.title,
    required this.organization,
    required this.userId,
    required this.status,
    required this.studiesCount,
    required this.contributorsCount,
    required this.description,
    required this.visibility,
    this.priority, // Now nullable
    this.country,
    this.sector,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    print('debug Project.fromMap: Creating project from $map');
    try {
      // Safe parsing with null checks and default values
      String safeString(String key) => map[key]?.toString() ?? '';
      int safeInt(String key) => (map[key] as num?)?.toInt() ?? 0;
      String? nullableString(String key) => map[key]?.toString();

      // Handle DateTime parsing safely
      DateTime safeDateTime(String key) {
        try {
          return DateTime.parse(map[key]?.toString() ?? '');
        } catch (e) {
          print('debug Project.fromMap: Error parsing $key, using current time');
          return DateTime.now();
        }
      }

      return Project(
        id: safeString('_id'),
        slug: safeString('slug'),
        title: safeString('title'),
        organization: safeString('organization'),
        userId: safeString('userId'),
        status: safeString('status'),
        studiesCount: safeInt('studiesCount'),
        contributorsCount: safeInt('contributorsCount'),
        description: safeString('description'),
        visibility: safeString('visibility'),
        priority: nullableString('priority'), // Can be null
        country: nullableString('country'),
        sector: nullableString('sector'),
        createdAt: safeDateTime('createdAt'),
        updatedAt: safeDateTime('updatedAt'),
      );
    } catch (e) {
      print('debug Project.fromMap: Error creating project - $e');
      rethrow;
    }
  }

  factory Project.fromJson(String source) {
    try {
      return Project.fromMap(json.decode(source) as Map<String, dynamic>);
    } catch (e) {
      print('debug Project.fromJson: Error parsing JSON - $e');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'slug': slug,
      'title': title,
      'organization': organization,
      'userId': userId,
      'status': status,
      'studiesCount': studiesCount,
      'contributorsCount': contributorsCount,
      'description': description,
      'visibility': visibility,
      'priority': priority, // Can be null
      'country': country,
      'sector': sector,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  Project copyWith({
    String? id,
    String? slug,
    String? title,
    String? organization,
    String? userId,
    String? status,
    int? studiesCount,
    int? contributorsCount,
    String? description,
    String? visibility,
    String? priority,
    String? country,
    String? sector,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      organization: organization ?? this.organization,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      studiesCount: studiesCount ?? this.studiesCount,
      contributorsCount: contributorsCount ?? this.contributorsCount,
      description: description ?? this.description,
      visibility: visibility ?? this.visibility,
      priority: priority ?? this.priority,
      country: country ?? this.country,
      sector: sector ?? this.sector,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, slug: $slug, title: $title, organization: $organization, userId: $userId, status: $status, studiesCount: $studiesCount, contributorsCount: $contributorsCount, description: $description, visibility: $visibility, priority: $priority, country: $country, sector: $sector, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}