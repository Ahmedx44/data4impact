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

  // Project
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
      AppLogger.logError('Error loading saved projects: $e');
      return [];
    }
  }

  // Study
  Future<void> saveAllStudys(String value) async {
    final hiveBox = await Hive.openBox(studysBox);
    await hiveBox.put(studysKey, value);
  }

  Future<List<Map<String, dynamic>>> getSavedAllStudys() async {
    try {
      final hiveBox = await Hive.openBox(studysBox);
      final studys = hiveBox.get(studysKey);

      if (studys == null) {
        return [];
      }

      final storedStudies = (jsonDecode(studys.toString()) as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      return storedStudies;
    } catch (e) {
      AppLogger.logError('Error loading saved studies: $e');
      return [];
    }
  }

  // Current User - FIXED VERSION
  Future<void> saveCurrentUser(CurrentUser user) async {
    try {
      final hiveBox = await Hive.openBox<CurrentUserHive>(currentUserBox);
      final userHive = CurrentUserHive.fromCurrentUser(user);
      await hiveBox.put(currentUserKey, userHive);
      AppLogger.logInfo('Current user saved successfully');
    } catch (e) {
      AppLogger.logError('Error saving current user: $e');
    }
  }

  Future<CurrentUser?> getSavedCurrentUser() async {
    try {
      final hiveBox = await Hive.openBox<CurrentUserHive>(currentUserBox);
      final userHive = hiveBox.get(currentUserKey);

      if (userHive == null) {
        AppLogger.logInfo('No saved user found in local storage');
        return null;
      }

      AppLogger.logInfo('Loaded user from local storage: ${userHive.email}');
      return userHive.toCurrentUser();
    } catch (e) {
      AppLogger.logError('Error loading saved current user: $e');
      return null;
    }
  }

  Future<void> saveStudyQuestions(String studyId, String questionsJson) async {
    try {
      final hiveBox = await Hive.openBox(studyQuestionsBox);
      await hiveBox.put('${studyQuestionsKey}_$studyId', questionsJson);
    } catch (e) {
      AppLogger.logError('Error saving study questions: $e');
    }
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

  Future<void> saveOfflineAnswer(String studyId,
      Map<String, dynamic> answerData) async {
    try {
      final hiveBox = await Hive.openBox(offlineAnswersBox);
      final existingAnswers = await getOfflineAnswers(studyId);
      existingAnswers.add(answerData);
      await hiveBox.put(
          '${offlineAnswersKey}_$studyId', jsonEncode(existingAnswers));
    } catch (e) {
      AppLogger.logError('Error saving offline answer: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getOfflineAnswers(String studyId) async {
    try {
      final hiveBox = await Hive.openBox(offlineAnswersBox);
      final answersJson = hiveBox.get('${offlineAnswersKey}_$studyId');

      if (answersJson == null) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(answersJson.toString()) as List<
          dynamic>;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      AppLogger.logError('Error loading offline answers: $e');
      return [];
    }
  }

  Future<void> removeOfflineAnswer(String studyId, int index) async {
    try {
      final answers = await getOfflineAnswers(studyId);
      if (index >= 0 && index < answers.length) {
        answers.removeAt(index);
        final hiveBox = await Hive.openBox(offlineAnswersBox);
        await hiveBox.put('${offlineAnswersKey}_$studyId', jsonEncode(answers));
      }
    } catch (e) {
      AppLogger.logError('Error removing offline answer: $e');
    }
  }

  Future<void> saveStudyCohorts(String studyId,
      List<Map<String, dynamic>> cohorts) async {
    try {
      final hiveBox = await Hive.openBox(studyCohortsBox);
      await hiveBox.put('${studyCohortsKey}_$studyId', jsonEncode(cohorts));
      AppLogger.logInfo('Saved ${cohorts.length} cohorts for study $studyId');
    } catch (e) {
      AppLogger.logError('Error saving study cohorts: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getStudyCohorts(String studyId) async {
    try {
      final hiveBox = await Hive.openBox(studyCohortsBox);
      final cohortsJson = hiveBox.get('${studyCohortsKey}_$studyId');

      if (cohortsJson == null) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(cohortsJson.toString()) as List<
          dynamic>;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      AppLogger.logError('Error loading study cohorts: $e');
      return [];
    }
  }

// Study Waves
  Future<void> saveStudyWaves(String studyId,
      List<Map<String, dynamic>> waves) async {
    try {
      final hiveBox = await Hive.openBox(studyWavesBox);
      await hiveBox.put('${studyWavesKey}_$studyId', jsonEncode(waves));
      AppLogger.logInfo('Saved ${waves.length} waves for study $studyId');
    } catch (e) {
      AppLogger.logError('Error saving study waves: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getStudyWaves(String studyId) async {
    try {
      final hiveBox = await Hive.openBox(studyWavesBox);
      final wavesJson = hiveBox.get('${studyWavesKey}_$studyId');

      if (wavesJson == null) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(wavesJson.toString()) as List<
          dynamic>;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      AppLogger.logError('Error loading study waves: $e');
      return [];
    }
  }

// Study Respondents
  Future<void> saveStudyRespondents(String studyId,
      List<Map<String, dynamic>> respondents) async {
    try {
      final hiveBox = await Hive.openBox(studyRespondentsBox);
      await hiveBox.put(
          '${studyRespondentsKey}_$studyId', jsonEncode(respondents));
      AppLogger.logInfo(
          'Saved ${respondents.length} respondents for study $studyId');
    } catch (e) {
      AppLogger.logError('Error saving study respondents: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getStudyRespondents(String studyId) async {
    try {
      final hiveBox = await Hive.openBox(studyRespondentsBox);
      final respondentsJson = hiveBox.get('${studyRespondentsKey}_$studyId');

      if (respondentsJson == null) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(
          respondentsJson.toString()) as List<dynamic>;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      AppLogger.logError('Error loading study respondents: $e');
      return [];
    }
  }

// Study Groups
  Future<void> saveStudyGroups(String studyId,
      List<Map<String, dynamic>> groups) async {
    try {
      final hiveBox = await Hive.openBox(studyGroupsBox);
      await hiveBox.put('${studyGroupsKey}_$studyId', jsonEncode(groups));
      AppLogger.logInfo('Saved ${groups.length} groups for study $studyId');
    } catch (e) {
      AppLogger.logError('Error saving study groups: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getStudyGroups(String studyId) async {
    try {
      final hiveBox = await Hive.openBox(studyGroupsBox);
      final groupsJson = hiveBox.get('${studyGroupsKey}_$studyId');

      if (groupsJson == null) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(groupsJson.toString()) as List<
          dynamic>;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      AppLogger.logError('Error loading study groups: $e');
      return [];
    }
  }

// Study Subjects
  Future<void> saveStudySubjects(String studyId,
      List<Map<String, dynamic>> subjects) async {
    try {
      final hiveBox = await Hive.openBox(studySubjectsBox);
      await hiveBox.put('${studySubjectsKey}_$studyId', jsonEncode(subjects));
      AppLogger.logInfo('Saved ${subjects.length} subjects for study $studyId');
    } catch (e) {
      AppLogger.logError('Error saving study subjects: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getStudySubjects(String studyId) async {
    try {
      final hiveBox = await Hive.openBox(studySubjectsBox);
      final subjectsJson = hiveBox.get('${studySubjectsKey}_$studyId');

      if (subjectsJson == null) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(subjectsJson.toString()) as List<
          dynamic>;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      AppLogger.logError('Error loading study subjects: $e');
      return [];
    }
  }

  Future<void> clearStudyData(String studyId) async {
    try {
      final cohortsBox = await Hive.openBox(studyCohortsBox);
      final wavesBox = await Hive.openBox(studyWavesBox);
      final respondentsBox = await Hive.openBox(studyRespondentsBox);
      final groupsBox = await Hive.openBox(studyGroupsBox);
      final subjectsBox = await Hive.openBox(studySubjectsBox);
      final questionsBox = await Hive.openBox(studyQuestionsBox);
      final answersBox = await Hive.openBox(offlineAnswersBox);

      await cohortsBox.delete('${studyCohortsKey}_$studyId');
      await wavesBox.delete('${studyWavesKey}_$studyId');
      await respondentsBox.delete('${studyRespondentsKey}_$studyId');
      await groupsBox.delete('${studyGroupsKey}_$studyId');
      await subjectsBox.delete('${studySubjectsKey}_$studyId');
      await questionsBox.delete('${studyQuestionsKey}_$studyId');
      await answersBox.delete('${offlineAnswersKey}_$studyId');

      AppLogger.logInfo('Cleared all offline data for study $studyId');
    } catch (e) {
      AppLogger.logError('Error clearing study data: $e');
    }
  }
}