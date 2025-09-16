import 'dart:async';
import 'dart:convert';

import 'package:data4impact/core/model/offline_models/current_user_hive.dart';
import 'package:data4impact/core/model/offline_models/project_hive.dart';
import 'package:data4impact/core/service/api_service/Model/current_user.dart';
import 'package:data4impact/core/service/api_service/Model/project.dart';
import 'package:data4impact/core/service/app_logger.dart';
import 'package:data4impact/core/utils.dart';
import 'package:hive/hive.dart';

class OfflineModeDataRepo {
  factory OfflineModeDataRepo() => _instance;

  OfflineModeDataRepo._internal();

  static final OfflineModeDataRepo _instance = OfflineModeDataRepo._internal();

  //Project
  Future<void> saveAllProjects(List<Project> value) async {
    Box<List<ProjectHive>> hiveBox =
        await Hive.openBox<List<ProjectHive>>(projectsBox);

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

  //Study
  Future<void> saveAllStudys(String value) async {
    final hiveBox = await Hive.openBox(studysBox);

    await hiveBox.put(studysKey, value);
  }

  Future<List<Map<String, dynamic>>> getSavedAllStudys() async {
    final hiveBox = await Hive.openBox(studysBox);

    final studys = hiveBox.get(studysKey);

    if (studys == null) {
      return [];
    }

    final storedStudies = (jsonDecode(studys.toString()) as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    return storedStudies;
  }

  // Current User
  Future<void> saveCurrentUser(CurrentUser user) async {
    final hiveBox = await Hive.openBox<CurrentUserHive>(currentUserBox);
    final userHive = CurrentUserHive.fromCurrentUser(user);

    await hiveBox.put(currentUserKey, userHive);

    print('current user saved');
  }

  Future<CurrentUser> getSavedCurrentUser() async {
    final hiveBox = await Hive.openBox<CurrentUserHive>(currentUserBox);

    return hiveBox.get(currentUserKey)!.toCurrentUser();
  }

  Future<void> saveStudyQuestions(String studyId, String questionsJson) async {
    final hiveBox = await Hive.openBox(studyQuestionsBox);
    await hiveBox.put('${studyQuestionsKey}_$studyId', questionsJson);
  }

  Future<Map<String, dynamic>?> getSavedStudyQuestions(String studyId) async {
    try {
      final hiveBox = await Hive.openBox(studyQuestionsBox);
      final questionsJson = hiveBox.get('${studyQuestionsKey}_$studyId');

      if (questionsJson == null) {
        return null;
      }

      return jsonDecode(questionsJson.toString()) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.logError('Error loading saved study questions: $e');
      return null;
    }
  }

  Future<void> saveOfflineAnswer(String studyId, Map<String, dynamic> answerData) async {
    final hiveBox = await Hive.openBox(offlineAnswersBox);

    // Get existing answers for this study
    final existingAnswers = await getOfflineAnswers(studyId);
    existingAnswers.add(answerData);

    await hiveBox.put('${offlineAnswersKey}_$studyId', jsonEncode(existingAnswers));
  }

  Future<List<Map<String, dynamic>>> getOfflineAnswers(String studyId) async {
    try {
      final hiveBox = await Hive.openBox(offlineAnswersBox);
      final answersJson = hiveBox.get('${offlineAnswersKey}_$studyId');

      if (answersJson == null) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(answersJson.toString()) as List<dynamic>;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      AppLogger.logError('Error loading offline answers: $e');
      return [];
    }
  }

  Future<void> removeOfflineAnswer(String studyId, int index) async {
    final answers = await getOfflineAnswers(studyId);
    if (index >= 0 && index < answers.length) {
      answers.removeAt(index);
      final hiveBox = await Hive.openBox(offlineAnswersBox);
      await hiveBox.put('${offlineAnswersKey}_$studyId', jsonEncode(answers));
    }
  }

}
