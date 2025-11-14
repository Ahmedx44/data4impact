// models/team_model.dart
class TeamModel {
  final String id;
  final String name;
  final String description;
  final int memberCount;
  final String? project;

  TeamModel({
    required this.id,
    required this.name,
    required this.description,
    required this.memberCount,
    this.project,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      memberCount: json['memberCount'] as int? ?? json['members'] as int? ?? 0,
      project: json['project']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'memberCount': memberCount,
      'project': project,
    };
  }
}