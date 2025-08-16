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
  final String priority;
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
    required this.priority,
    this.country,
    this.sector,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['_id'] as String,
      slug: map['slug'] as String,
      title: map['title'] as String,
      organization: map['organization'] as String,
      userId: map['userId'] as String,
      status: map['status'] as String,
      studiesCount: map['studiesCount'] as int,
      contributorsCount: map['contributorsCount'] as int,
      description: map['description'] as String,
      visibility: map['visibility'] as String,
      priority: map['priority'] as String,
      country: map['country'] as String?,
      sector: map['sector'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  factory Project.fromJson(String source) =>
      Project.fromMap(json.decode(source)as Map<String,dynamic>);

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
      'priority': priority,
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