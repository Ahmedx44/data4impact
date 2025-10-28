import 'package:data4impact/core/service/api_service/Model/project.dart';
import 'package:hive/hive.dart';

part 'project_hive.g.dart';

@HiveType(typeId: 0) // Changed typeId to 1 (use unique typeId for each model)
class ProjectHive {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String slug;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String organization;

  @HiveField(4)
  final String userId;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final int studiesCount;

  @HiveField(7)
  final int contributorsCount;

  @HiveField(8)
  final String description;

  @HiveField(9)
  final String visibility;

  @HiveField(10)
  final String? priority; // Made nullable

  @HiveField(11)
  final String? country;

  @HiveField(12)
  final String? sector;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;

  ProjectHive({
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

  factory ProjectHive.fromProject(Project project) {
    return ProjectHive(
      id: project.id,
      slug: project.slug,
      title: project.title,
      organization: project.organization,
      userId: project.userId,
      status: project.status,
      studiesCount: project.studiesCount,
      contributorsCount: project.contributorsCount,
      description: project.description,
      visibility: project.visibility,
      priority: project.priority, // Can be null
      country: project.country,
      sector: project.sector,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
    );
  }

  Project toProject() {
    return Project(
      id: id,
      slug: slug,
      title: title,
      organization: organization,
      userId: userId,
      status: status,
      studiesCount: studiesCount,
      contributorsCount: contributorsCount,
      description: description,
      visibility: visibility,
      priority: priority ?? 'medium', // Provide default value if null
      country: country,
      sector: sector,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() {
    return 'ProjectHive(id: $id, title: $title, organization: $organization, priority: $priority)';
  }
}