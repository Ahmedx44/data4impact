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

  Future<void> saveCurrentUser(CurrentUser user) async {
    try {
      final hiveBox = await Hive.openBox<CurrentUserHive>(currentUserBox);

      final userHive = CurrentUserHive.fromCurrentUser(user);

      await hiveBox.put(currentUserKey, userHive);

      await hiveBox.close();
    } catch (e, stackTrace) {
      AppLogger.logError('Error saving current user: $e');
      AppLogger.logError('Stack trace: $stackTrace');
    }
  }

  Future<void> saveTeamMembers(String teamId, List<dynamic> members) async {
    try {
      final hiveBox = await Hive.openBox(teamMembersBox);

      // Convert to JSON string for consistent storage
      final membersJson = jsonEncode(members);
      await hiveBox.put('team_members_$teamId', membersJson);

      AppLogger.logInfo(
          'Saved ${members.length} members for team $teamId to offline storage');
    } catch (e) {
      AppLogger.logError('Error saving team members: $e');
    }
  }

// Team Members - Get saved team members data
  Future<List<dynamic>> getSavedTeamMembers(String teamId) async {
    try {
      final hiveBox = await Hive.openBox(teamMembersBox);
      final membersData = hiveBox.get('team_members_$teamId');

      if (membersData == null) {
        return [];
      }

      // Handle both String (JSON) and List types
      if (membersData is String) {
        final decoded = jsonDecode(membersData);
        if (decoded is List) {
          return decoded;
        }
      } else if (membersData is List) {
        return membersData;
      }

      return [];
    } catch (e) {
      AppLogger.logError('Error loading saved team members: $e');
      return [];
    }
  }

  Future<CurrentUser?> getSavedCurrentUser() async {
    try {
      if (Hive.isBoxOpen(currentUserBox)) {
        await Hive.box<CurrentUserHive>(currentUserBox).close();
      }

      final hiveBox = await Hive.openBox<CurrentUserHive>(currentUserBox);
      final userHive = hiveBox.get(currentUserKey);

      final currentUser = userHive!.toCurrentUser();
      return currentUser;
    } catch (e, stackTrace) {
      AppLogger.logError('Error loading saved current user: $e');
      AppLogger.logError('Stack trace: $stackTrace');

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

  Future<void> saveOfflineAnswer(
      String studyId, Map<String, dynamic> answerData) async {
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

      final List<dynamic> decoded =
          jsonDecode(answersJson.toString()) as List<dynamic>;
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

  Future<void> saveStudyCohorts(
      String studyId, List<Map<String, dynamic>> cohorts) async {
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

      final List<dynamic> decoded =
          jsonDecode(cohortsJson.toString()) as List<dynamic>;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      AppLogger.logError('Error loading study cohorts: $e');
      return [];
    }
  }

// Study Waves
  Future<void> saveStudyWaves(
      String studyId, List<Map<String, dynamic>> waves) async {
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

      final List<dynamic> decoded =
          jsonDecode(wavesJson.toString()) as List<dynamic>;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      AppLogger.logError('Error loading study waves: $e');
      return [];
    }
  }

// Study Respondents
  Future<void> saveStudyRespondents(
      String studyId, List<Map<String, dynamic>> respondents) async {
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

      final List<dynamic> decoded =
          jsonDecode(respondentsJson.toString()) as List<dynamic>;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      AppLogger.logError('Error loading study respondents: $e');
      return [];
    }
  }

// Study Groups
  Future<void> saveStudyGroups(
      String studyId, List<Map<String, dynamic>> groups) async {
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

      final List<dynamic> decoded =
          jsonDecode(groupsJson.toString()) as List<dynamic>;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      AppLogger.logError('Error loading study groups: $e');
      return [];
    }
  }

// Study Subjects
  Future<void> saveStudySubjects(
      String studyId, List<Map<String, dynamic>> subjects) async {
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

      final List<dynamic> decoded =
          jsonDecode(subjectsJson.toString()) as List<dynamic>;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      AppLogger.logError('Error loading study subjects: $e');
      return [];
    }
  }

  Future<void> saveCollectors(
      String projectId, List<Map<String, dynamic>> collectors) async {
    try {
      final hiveBox = await Hive.openBox(collectorsBox);

      final collectorsJson = jsonEncode(collectors);
      await hiveBox.put('${collectorsKey}_$projectId', collectorsJson);

      AppLogger.logInfo(
          'Saved ${collectors.length} collectors for project $projectId');
    } catch (e) {
      AppLogger.logError('Error saving collectors: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSavedCollectors(
      String projectId) async {
    try {
      final hiveBox = await Hive.openBox(collectorsBox);
      final collectorsData = hiveBox.get('${collectorsKey}_$projectId');

      if (collectorsData == null) {
        return [];
      }

      List<Map<String, dynamic>> result = [];

      if (collectorsData is String) {
        final decoded = jsonDecode(collectorsData);

        if (decoded is List) {
          result = _convertToListOfStringMap(decoded);
        }
      } else if (collectorsData is List) {
        result = _convertToListOfStringMap(collectorsData);
      }

      return result;
    } catch (e) {
      AppLogger.logError('Error loading saved collectors: $e');

      return [];
    }
  }

  List<Map<String, dynamic>> _convertToListOfStringMap(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) {
        final convertedMap = <String, dynamic>{};
        item.forEach((key, value) {
          convertedMap[key.toString()] = value;
        });
        return convertedMap;
      }
      return <String, dynamic>{};
    }).toList();
  }

  Future<void> saveTeams(List<dynamic> teams) async {
    try {
      final hiveBox = await Hive.openBox(teamsBox);

      // Convert to JSON string for consistent storage
      final teamsJson = jsonEncode(teams);
      await hiveBox.put(teamsKey, teamsJson);

      AppLogger.logInfo('Saved ${teams.length} teams to offline storage');
    } catch (e) {
      AppLogger.logError('Error saving teams: $e');
    }
  }

// Teams - Get saved teams data
  Future<List<dynamic>> getSavedTeams() async {
    try {
      final hiveBox = await Hive.openBox(teamsBox);
      final teamsData = hiveBox.get(teamsKey);

      if (teamsData == null) {
        return [];
      }

      // Handle both String (JSON) and List types
      if (teamsData is String) {
        final decoded = jsonDecode(teamsData);
        if (decoded is List) {
          return decoded;
        }
      } else if (teamsData is List) {
        return teamsData;
      }

      return [];
    } catch (e) {
      AppLogger.logError('Error loading saved teams: $e');
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

  Future<void> incrementStudyResponseCount(String studyId) async {
    try {
      // 1. Update Study List
      final sBox = await Hive.openBox(studysBox);
      final studysJson = sBox.get(studysKey);
      if (studysJson != null) {
        final List<dynamic> studys =
            jsonDecode(studysJson.toString()) as List<dynamic>;
        bool changed = false;
        for (var i = 0; i < studys.length; i++) {
          if (studys[i]['_id'] == studyId) {
            studys[i]['responseCount'] = (studys[i]['responseCount'] ?? 0) + 1;
            changed = true;
            break;
          }
        }
        if (changed) {
          await sBox.put(studysKey, jsonEncode(studys));
        }
      }

      // 2. Update Study Questions (Single Study)
      final qBox = await Hive.openBox(studyQuestionsBox);
      final questionsJson = qBox.get('${studyQuestionsKey}_$studyId');
      if (questionsJson != null) {
        final Map<String, dynamic> study =
            jsonDecode(questionsJson.toString()) as Map<String, dynamic>;
        study['responseCount'] = (study['responseCount'] ?? 0) + 1;
        await qBox.put('${studyQuestionsKey}_$studyId', jsonEncode(study));
      }

      // 3. Update Collectors
      final cBox = await Hive.openBox(collectorsBox);
      for (final key in cBox.keys) {
        if (key.toString().startsWith(collectorsKey)) {
          final collectorsJson = cBox.get(key);
          if (collectorsJson != null) {
            final List<dynamic> collectors =
                jsonDecode(collectorsJson.toString()) as List<dynamic>;
            bool changed = false;
            for (var i = 0; i < collectors.length; i++) {
              final collectorStudy = collectors[i]['study'];
              String? cStudyId;
              if (collectorStudy is Map) {
                cStudyId = collectorStudy['_id'] as String?;
              } else if (collectorStudy is String) {
                cStudyId = collectorStudy;
              }

              if (cStudyId == studyId) {
                collectors[i]['responseCount'] =
                    (collectors[i]['responseCount'] ?? 0) + 1;
                // Also update the nested study object if it exists
                if (collectors[i]['study'] is Map) {
                  collectors[i]['study']['responseCount'] =
                      (collectors[i]['study']['responseCount'] ?? 0) + 1;
                }
                changed = true;
              }
            }
            if (changed) {
              await cBox.put(key, jsonEncode(collectors));
            }
          }
        }
      }
      AppLogger.logInfo(
          'Incremented offline response count for study $studyId');
    } catch (e) {
      AppLogger.logError('Error incrementing response count: $e');
    }
  }

  Future<void> clearAllOfflineAnswers() async {
    try {
      final hiveBox = await Hive.openBox(offlineAnswersBox);
      await hiveBox.clear();
      AppLogger.logInfo('Cleared all offline answers');
    } catch (e) {
      AppLogger.logError('Error clearing all offline answers: $e');
    }
  }

  // Auto Sync Preference
  static const String _prefsBox = 'app_preferences_box';
  static const String _autoSyncKey = 'auto_sync_enabled';

  Future<void> saveAutoSyncPreference(bool isEnabled) async {
    try {
      final hiveBox = await Hive.openBox(_prefsBox);
      await hiveBox.put(_autoSyncKey, isEnabled);
    } catch (e) {
      AppLogger.logError('Error saving auto sync preference: $e');
    }
  }

  Future<bool> getAutoSyncPreference() async {
    try {
      final hiveBox = await Hive.openBox(_prefsBox);
      return hiveBox.get(_autoSyncKey, defaultValue: true) as bool;
    } catch (e) {
      AppLogger.logError('Error loading auto sync preference: $e');
      return true; // Default to true on error
    }
  }

  // Longitudinal Completion Tracking
  Future<void> updateSubjectCompletionStatus({
    required String studyId,
    required String subjectId,
    required String waveId,
    bool isCompleted = true,
  }) async {
    try {
      final hiveBox = await Hive.openBox<dynamic>(studySubjectsBox);
      final subjectsJson = hiveBox.get('${studySubjectsKey}_$studyId');

      if (subjectsJson == null) {
        AppLogger.logWarning('No subjects found for study $studyId');
        return;
      }

      final List<dynamic> decoded =
          jsonDecode(subjectsJson.toString()) as List<dynamic>;
      final subjects =
          decoded.map((item) => item as Map<String, dynamic>).toList();

      // Find and update the subject
      bool updated = false;
      for (var subject in subjects) {
        if (subject['_id'] == subjectId) {
          // Initialize completedWaves if it doesn't exist
          if (subject['completedWaves'] == null) {
            subject['completedWaves'] = <String>[];
          }

          final completedWaves =
              List<String>.from(subject['completedWaves'] as List);

          if (isCompleted && !completedWaves.contains(waveId)) {
            completedWaves.add(waveId);
            subject['completedWaves'] = completedWaves;
            updated = true;
          } else if (!isCompleted && completedWaves.contains(waveId)) {
            completedWaves.remove(waveId);
            subject['completedWaves'] = completedWaves;
            updated = true;
          }
          break;
        }
      }

      if (updated) {
        await hiveBox.put('${studySubjectsKey}_$studyId', jsonEncode(subjects));
        AppLogger.logInfo(
            'Updated completion status for subject $subjectId, wave $waveId');
      }
    } catch (e) {
      AppLogger.logError('Error updating subject completion status: $e');
    }
  }

  Future<void> updateWaveProgress({
    required String studyId,
    required String waveId,
  }) async {
    try {
      // Get subjects to count completions
      final subjectsBox = await Hive.openBox<dynamic>(studySubjectsBox);
      final subjectsJson = subjectsBox.get('${studySubjectsKey}_$studyId');

      if (subjectsJson == null) {
        return;
      }

      final List<dynamic> decodedSubjects =
          jsonDecode(subjectsJson.toString()) as List<dynamic>;
      final subjects =
          decodedSubjects.map((item) => item as Map<String, dynamic>).toList();

      // Count completed subjects for this wave
      int completedCount = 0;
      for (var subject in subjects) {
        final completedWaves = subject['completedWaves'] as List?;
        if (completedWaves != null && completedWaves.contains(waveId)) {
          completedCount++;
        }
      }

      // Update wave data
      final wavesBox = await Hive.openBox<dynamic>(studyWavesBox);
      final wavesJson = wavesBox.get('${studyWavesKey}_$studyId');

      if (wavesJson == null) {
        return;
      }

      final List<dynamic> decodedWaves =
          jsonDecode(wavesJson.toString()) as List<dynamic>;
      final waves =
          decodedWaves.map((item) => item as Map<String, dynamic>).toList();

      // Find and update the wave
      bool updated = false;
      for (var wave in waves) {
        if (wave['_id'] == waveId) {
          final totalSubjects = subjects.length;
          final completionPercentage =
              totalSubjects > 0 ? (completedCount / totalSubjects) * 100 : 0.0;

          wave['completedSubjects'] = completedCount;
          wave['totalSubjects'] = totalSubjects;
          wave['completionPercentage'] = completionPercentage.toInt();
          wave['responsesCount'] = completedCount;
          
          // Update subjects list in wave (list of completed subject IDs)
          final completedSubjectIds = subjects
              .where((s) {
                final cw = s['completedWaves'] as List?;
                return cw != null && cw.contains(waveId);
              })
              .map((s) => s['_id'])
              .toList();
          wave['subjects'] = completedSubjectIds;

          updated = true;
          break;
        }
      }

      if (updated) {
        await wavesBox.put('${studyWavesKey}_$studyId', jsonEncode(waves));
        AppLogger.logInfo(
            'Updated wave $waveId progress: $completedCount/${subjects.length}');
      }
    } catch (e) {
      AppLogger.logError('Error updating wave progress: $e');
    }
  }
}
