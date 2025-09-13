// study_hive.dart
import 'package:hive/hive.dart';
import 'package:data4impact/core/service/api_service/Model/study.dart';

part 'study_hive.g.dart';

@HiveType(typeId: 1)
class StudyHive {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String project;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final int responseCount;

  @HiveField(6)
  final int sampleSize;

  @HiveField(7)
  final String? closeOnDate;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  StudyHive({
    required this.id,
    required this.name,
    required this.description,
    required this.project,
    required this.status,
    required this.responseCount,
    required this.sampleSize,
    this.closeOnDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Study model to StudyHive
  factory StudyHive.fromStudy(Study study) {
    return StudyHive(
      id: study.id,
      name: study.name,
      description: study.description,
      project: study.project,
      status: study.status,
      responseCount: study.responseCount,
      sampleSize: study.sampleSize,
      closeOnDate: study.ending['closeOnDate'] as String?, // Extract from ending map if available
      createdAt: study.createdAt,
      updatedAt: study.updatedAt,
    );
  }

  // Convert from StudyHive to Study model
  Study toStudy() {
    return Study(
      id: id,
      name: name,
      description: description,
      project: project,
      status: status,
      questions: [], // Empty list since we're not storing questions in Hive
      welcomeCard: {}, // Empty map
      ending: {
        if (closeOnDate != null) 'closeOnDate': closeOnDate,
      },
      responseValidation: null,
      languages: [],
      questionCount: 0,
      responseCount: responseCount,
      design: 'crossSectional',
      approach: 'quantitative',
      methodology: 'survey',
      sampleSize: sampleSize,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}