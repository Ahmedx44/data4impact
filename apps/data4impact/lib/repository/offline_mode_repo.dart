import 'dart:async';

import 'package:data4impact/core/model/offline_models/project_hive.dart';
import 'package:data4impact/core/service/api_service/Model/project.dart';
import 'package:data4impact/core/service/app_logger.dart';
import 'package:data4impact/core/utils.dart';
import 'package:hive/hive.dart';

class OfflineModeDataRepo {
  /// Factory constructor to return the same instance every time
  factory OfflineModeDataRepo() => _instance;

  /// Private constructor
  OfflineModeDataRepo._internal();

  /// The singleton instance
  static final OfflineModeDataRepo _instance = OfflineModeDataRepo._internal();
  Future<void> saveAllProjects(List<Project> value) async {
    Box<List<ProjectHive>> hiveBox =
        await Hive.openBox<List<ProjectHive>>(projectsBox);

    // Convert Project → ProjectHive
    final hiveProjects = value.map((p) => ProjectHive.fromProject(p)).toList();

    await hiveBox.put(projectsKey, hiveProjects);
  }

  Future<List<Project>> getSavedAllProjects() async {

    try {
      final box = await Hive.openBox<List<dynamic>>(projectsBox);

      final storedProjects = box.get(projectsKey);

      if (storedProjects == null) {
        return [];
      }

      final result = storedProjects
          .map((dynamic item) => (item as ProjectHive).toProject())
          .toList();
      return result;
    } catch (e) {
      return [];
    }
  }
}
