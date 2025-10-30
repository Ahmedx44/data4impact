// team_model.dart
class Team {
  final String id;
  final String name;
  final String description;
  final int memberCount;
  final String? project;

  Team({
    required this.id,
    required this.name,
    required this.description,
    required this.memberCount,
    this.project,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as String ?? '',
      name: json['name'] as String ?? '',
      description: json['description'] as String ?? '',
      memberCount: json['memberCount'] as int ?? 0,
      project: json['project'] as String,
    );
  }
}