// team_model.dart
import 'package:equatable/equatable.dart';

class TeamModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? project;
  final String? organization;
  final int memberCount;
  final List<dynamic> fields;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TeamModel({
    required this.id,
    required this.name,
    this.description,
    this.project,
    this.organization,
    this.memberCount = 0,
    this.fields = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['_id'] as String ?? '',
      name: json['name'] as String ?? 'Unknown Team',
      description: json['description'] as String ?? '',
      project: json['project'] as String,
      organization: json['organization'] as String,
      memberCount: json['memberCount'] as int ?? 0,
      fields: json['fields'] as List ?? [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'project': project,
      'organization': organization,
      'memberCount': memberCount,
      'fields': fields,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    project,
    organization,
    memberCount,
    fields,
    createdAt,
    updatedAt,
  ];
}