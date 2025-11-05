import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:data4impact/core/service/api_service/Model/api_question.dart';
import 'package:data4impact/core/service/api_service/Model/study.dart';
import 'package:data4impact/core/service/api_service/file_upload_service.dart';
import 'package:data4impact/core/service/api_service/study_service.dart';
import 'package:data4impact/core/service/audio_service.dart';
import 'package:data4impact/core/service/internt_connection_monitor.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/data_collect/cubit/data_collet_state.dart';
import 'package:data4impact/repository/offline_mode_repo.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class DataCollectCubit extends Cubit<DataCollectState> {
  final StudyService studyService;
  final AudioRecordingService audioRecordingService = AudioRecordingService();
  final FileUploadService fileUploadService;
  final AudioPlayer audioPlayer = AudioPlayer();
  bool _isNavigating = false;
  Timer? _recordingTimer;
  StreamSubscription? _audioPositionSubscription;
  StreamSubscription? _audioDurationSubscription;

  DataCollectCubit(
      {required this.studyService, required this.fileUploadService})
      : super(const DataCollectState()) {
    _setupAudioPlayerListeners();
  }

  void _setupAudioPlayerListeners() {
    _audioPositionSubscription =
        audioPlayer.onPositionChanged.listen((position) {
          emit(state.copyWith(audioPosition: position));
        });

    _audioDurationSubscription =
        audioPlayer.onDurationChanged.listen((duration) {
          emit(state.copyWith(audioDuration: duration));
        });

    audioPlayer.onPlayerComplete.listen((event) {
      emit(state.copyWith(isPlayingAudio: false));
    });
  }

  // Language methods
  void changeLanguage(String languageCode) {
    emit(state.copyWith(selectedLanguage: languageCode));
  }

  // Clear error method
  void clearError() {
    emit(state.copyWith(error: null));
  }

  // Location methods
  Future<void> getCurrentLocation() async {
    emit(state.copyWith(isLocationLoading: true));

    try {
      // Check permissions
      final permissionStatus = await Permission.location.request();

      if (permissionStatus.isGranted) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );

        emit(state.copyWith(
          locationData: LocationData(
            lat: position.latitude.toString(),
            lng: position.longitude.toString(),
          ),
          isLocationLoading: false,
        ));
      } else {
        ToastService.showErrorToast(message: 'Location permission denied');
        emit(state.copyWith(
          error: null,
          isLocationLoading: false,
        ));
      }
    } catch (e) {
      ToastService.showErrorToast(message: 'Failed to get location: $e');
      emit(state.copyWith(
        error: null,
        isLocationLoading: false,
      ));
    }
  }

  // Audio playback methods
  Future<void> playAudio() async {
    if (state.audioFilePath == null) return;

    try {
      await audioPlayer.play(DeviceFileSource(state.audioFilePath!));
      emit(state.copyWith(isPlayingAudio: true));
    } catch (e) {
      ToastService.showErrorToast(message: 'Failed to play audio: $e');
      emit(state.copyWith(error: null));
    }
  }

  Future<void> pauseAudio() async {
    try {
      await audioPlayer.pause();
      emit(state.copyWith(isPlayingAudio: false));
    } catch (e) {
      ToastService.showErrorToast(message: 'Failed to pause audio: $e');
      emit(state.copyWith(error: null));
    }
  }

  Future<void> stopAudio() async {
    try {
      await audioPlayer.stop();
      emit(state.copyWith(
        isPlayingAudio: false,
        audioPosition: Duration.zero,
      ));
    } catch (e) {
      ToastService.showErrorToast(message: 'Failed to stop audio: $e');
      emit(state.copyWith(error: null));
    }
  }

  Future<void> seekAudio(Duration position) async {
    try {
      await audioPlayer.seek(position);
    } catch (e) {
      ToastService.showErrorToast(message: 'Failed to seek audio: $e');
      emit(state.copyWith(error: null));
    }
  }

  Future<void> startRecording() async {
    try {
      await audioRecordingService.startRecording();
      emit(state.copyWith(
        isRecording: true,
        recordingDuration: 0,
      ));

      // Update recording duration every second
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!audioRecordingService.isRecording) {
          timer.cancel();
          return;
        }

        // Stop recording if we reach the max duration
        if (state.maxRecordingDuration > 0 &&
            state.recordingDuration >= state.maxRecordingDuration) {
          stopRecording();
          timer.cancel();
          return;
        }

        emit(state.copyWith(
          recordingDuration: audioRecordingService.recordingDuration,
        ));
      });
    } catch (e) {
      ToastService.showErrorToast(message: 'Failed to start recording: $e');
      emit(state.copyWith(error: null));
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await audioRecordingService.stopRecording();
      emit(state.copyWith(
        isRecording: false,
        audioFilePath: path,
      ));
      _recordingTimer?.cancel();
    } catch (e) {
      ToastService.showErrorToast(message: 'Failed to stop recording: $e');
      emit(state.copyWith(error: null));
    }
  }

  Future<void> uploadAudioFile(String studyId) async {
    if (state.audioFilePath == null) {
      ToastService.showErrorToast(message: 'No audio file to upload');
      emit(state.copyWith(error: null));
      return;
    }

    emit(state.copyWith(isUploadingAudio: true, error: null));

    try {
      final result = await fileUploadService!.uploadAudioFile(
        studyId,
        state.audioFilePath!,
      );

      emit(state.copyWith(
        isUploadingAudio: false,
        audioUploadResult: result,
      ));

      // Clean up local file after successful upload
      final file = File(state.audioFilePath!);
      if (await file.exists()) {
        await file.delete();
      }
      emit(state.copyWith(audioFilePath: null));
    } catch (e) {
      ToastService.showErrorToast(message: 'Failed to upload audio: $e');
      emit(state.copyWith(
        isUploadingAudio: false,
        error: null,
      ));
    }
  }

  Future<void> deleteRecording() async {
    try {
      // Stop any ongoing playback
      await stopAudio();

      // Delete the audio file if it exists
      if (state.audioFilePath != null) {
        final file = File(state.audioFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Also delete from audio recording service
      await audioRecordingService.deleteRecording();

      // Reset all audio-related state
      emit(state.copyWith(
        audioFilePath: null,
        recordingDuration: 0,
        isRecording: false,
        audioUploadResult: null,
        isUploadingAudio: false,
        isPlayingAudio: false,
        audioPosition: Duration.zero,
        audioDuration: Duration.zero,
      ));
    } catch (e) {
      ToastService.showErrorToast(message: 'Failed to delete recording: $e');
      emit(state.copyWith(error: null));
    }
  }

  @override
  Future<void> close() {
    _recordingTimer?.cancel();
    _audioPositionSubscription?.cancel();
    _audioDurationSubscription?.cancel();
    audioPlayer.dispose();
    audioRecordingService.dispose();
    return super.close();
  }

  Future<void> getStudyQuestions(String studyId) async {
    emit(state.copyWith(isLoading: true, error: null));

    final connected = InternetConnectionMonitor(
      checkOnInterval: false,
      checkInterval: const Duration(seconds: 5),
    );

    final isConnected = await connected.hasInternetConnection();

    if (isConnected) {
      try {
        final data = await studyService.getStudyQuestions(studyId);

        if (data is Map<String, dynamic> && data['error'] == true) {
          final errorMessage = data['message'] ?? 'Study is not in progress';
          emit(state.copyWith(
            isLoading: false,
            error: errorMessage as String,
          ));
          return;
        }

        final study = Study.fromJson(data);
        final studyJson = jsonEncode(data);

        // Save to offline storage
        await OfflineModeDataRepo().saveStudyQuestions(studyId, studyJson);

        await _processStudyData(study);

        // For interview studies, load respondents
        if (study.methodology == 'interview') {
          await loadStudyRespondents(studyId);
        }

      } on FormatException catch (e) {
        emit(state.copyWith(
          isLoading: false,
          error: e.message,
        ));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to load study: ${e.toString()}',
        ));
      }
    } else {
      // Offline mode - try to load from local storage
      try {
        final savedData = await OfflineModeDataRepo().getSavedStudyQuestions(studyId);

        if (savedData == null) {
          emit(state.copyWith(
            isLoading: false,
            error: 'No offline data available for this study',
          ));
          return;
        }

        final study = Study.fromJson(savedData);
        await _processStudyData(study);

      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to load offline study data: ${e.toString()}',
        ));
      }
    }
  }

  // Helper method to process study data (extracted from both online and offline flows)
  Future<void> _processStudyData(Study study) async {
    final isVoiceRequired = study.responseValidation?.requiredVoice ?? false;
    final isLocationRequired = study.responseValidation?.requiredLocation ?? false;
    final voiceDuration = study.responseValidation?.voiceDuration ?? 180; // Get duration from API, default to 180

    // Reset all state including hasSeenWelcome
    emit(state.copyWith(
      study: study,
      isLoading: false,
      currentQuestionIndex: 0,
      answers: {},
      requiredQuestions: {},
      skipQuestions: {},
      jumpTarget: null,
      navigationHistory: [],
      logicJumps: {},
      availableLanguages: study.languages ?? [],
      isLocationRequired: isLocationRequired,
      maxRecordingDuration: voiceDuration, // Set the max duration
      hasSeenWelcome: false,
      // Reset interview specific state
      respondents: const [],
      selectedRespondent: null,
      isManagingRespondents: study.methodology == 'interview',
      isCreatingRespondent: false,
      newRespondentData: {},
    ));

    if (isLocationRequired) {
      await getCurrentLocation();
    }

    if (isVoiceRequired) {
      await startRecording();
    }
  }

  void updateAnswer(String questionId, dynamic value) {
    if (_isNavigating) return;

    final newAnswers = Map<String, dynamic>.from(state.answers);
    newAnswers[questionId] = value;

    final newState = state.copyWith(answers: newAnswers);
    final evaluatedState = _evaluateLogic(newState);

    emit(evaluatedState);
  }

  DataCollectState _evaluateLogic(DataCollectState currentState) {
    if (currentState.study == null) return currentState;

    final study = currentState.study!;
    final answers = currentState.answers;
    Set<String> requiredQuestions = {};
    String? jumpTarget;
    Set<String> skipQuestions = {};

    for (final question in study.questions) {
      if (question.logic != null && question.logic!.isNotEmpty) {
        for (final logicItem in question.logic!) {
          if (logicItem is Map<String, dynamic>) {
            final conditions = logicItem['conditions'];
            final actions = logicItem['actions'];

            if (conditions != null && actions != null) {
              final conditionResult = _evaluateConditionGroup(
                study,
                answers,
                conditions as Map<String, dynamic>,
              );

              if (conditionResult) {
                final result = _performActions(actions as List);
                requiredQuestions.addAll(result.requiredQuestionIds);
                skipQuestions.addAll(result.skipQuestionIds);

                if (result.jumpTarget != null) {
                  final targetIndex = study.questions.indexWhere(
                        (q) => q.id == result.jumpTarget,
                  );

                  if (targetIndex != -1 &&
                      targetIndex != currentState.currentQuestionIndex) {
                    jumpTarget ??= result.jumpTarget;
                  }
                }
              }
            }
          }
        }
      }
    }

    // New logic: Determine which questions to skip based on current answers
    skipQuestions.addAll(_determineSkipQuestions(study, answers));

    return currentState.copyWith(
      requiredQuestions: requiredQuestions,
      jumpTarget: jumpTarget,
      skipQuestions: skipQuestions,
    );
  }

  Set<String> _determineSkipQuestions(Study study, Map<String, dynamic> answers) {
    Set<String> questionsToSkip = {};

    // Check each question to see if it should be accessible based on current answers
    for (final question in study.questions) {
      if (!_isQuestionAccessible(question, study, answers)) {
        questionsToSkip.add(question.id);
      }
    }

    return questionsToSkip;
  }

  bool _isQuestionAccessible(ApiQuestion targetQuestion, Study study, Map<String, dynamic> answers) {
    // A question is accessible if:
    // 1. There's no logic preventing it, OR
    // 2. There's explicit logic that leads to it

    // Find all questions that have logic pointing to this target question
    List<ApiQuestion> questionsWithLogicToTarget = [];

    for (final question in study.questions) {
      if (question.logic != null && question.logic!.isNotEmpty) {
        for (final logicItem in question.logic!) {
          if (logicItem is Map<String, dynamic>) {
            final actions = logicItem['actions'] as List?;
            if (actions != null) {
              for (final action in actions) {
                if (action['objective'] == 'jumpToQuestion' &&
                    action['target'] == targetQuestion.id) {
                  questionsWithLogicToTarget.add(question);
                  break;
                }
              }
            }
          }
        }
      }
    }

    // If no questions have logic pointing to this target, it's accessible by default
    if (questionsWithLogicToTarget.isEmpty) {
      return true;
    }

    // If there are questions with logic pointing to this target,
    // check if any of their conditions are satisfied
    for (final sourceQuestion in questionsWithLogicToTarget) {
      if (sourceQuestion.logic != null) {
        for (final logicItem in sourceQuestion.logic!) {
          if (logicItem is Map<String, dynamic>) {
            final conditions = logicItem['conditions'];
            final actions = logicItem['actions'] as List?;

            if (conditions != null && actions != null) {
              // Check if this logic item targets our question
              final targetsOurQuestion = actions.any((action) =>
              action['objective'] == 'jumpToQuestion' &&
                  action['target'] == targetQuestion.id
              );

              if (targetsOurQuestion) {
                // Check if the condition is satisfied
                final conditionResult = _evaluateConditionGroup(
                  study,
                  answers,
                  conditions as Map<String, dynamic>,
                );

                if (conditionResult) {
                  return true; // This path leads to our target question
                }
              }
            }
          }
        }
      }
    }

    // No satisfied conditions lead to this question, so it should be skipped
    return false;
  }

  bool _evaluateConditionGroup(
      Study study,
      Map<String, dynamic> answers,
      Map<String, dynamic> conditionGroup,
      ) {
    final connector = conditionGroup['connector'] ?? 'and';
    final conditions = conditionGroup['conditions'] as List<dynamic>? ?? [];

    final List<bool> results = [];

    for (final condition in conditions) {
      if (condition is Map<String, dynamic>) {
        if (condition['connector'] != null) {
          results.add(_evaluateConditionGroup(study, answers, condition));
        } else {
          results.add(_evaluateSingleCondition(study, answers, condition));
        }
      } else {
        results.add(false);
      }
    }

    return connector == 'or'
        ? results.any((result) => result)
        : results.every((result) => result);
  }

  bool _evaluateSingleCondition(
      Study study,
      Map<String, dynamic> answers,
      Map<String, dynamic> condition,
      ) {
    try {
      final leftOperand = condition['leftOperand'];
      final operator = condition['operator'];
      final rightOperand = condition['rightOperand'];

      if (leftOperand == null || operator == null) return false;

      final leftValue = _getLeftOperandValue(
          study, answers, leftOperand as Map<String, dynamic>);
      final rightValue = rightOperand != null
          ? _getRightOperandValue(answers, rightOperand as Map<String, dynamic>)
          : null;

      switch (operator) {
        case 'equals':
          return leftValue == rightValue;
        case 'doesNotEqual':
          return leftValue != rightValue;
        case 'contains':
          return leftValue.toString().contains(rightValue.toString());
        case 'doesNotContain':
          return !leftValue.toString().contains(rightValue.toString());
        case 'isSubmitted':
          return leftValue != null && leftValue.toString().isNotEmpty;
        case 'isSkipped':
          return leftValue == null || leftValue.toString().isEmpty;
        case 'isGreaterThan':
          return (leftValue as num) > (rightValue as num);
        case 'isLessThan':
          return (leftValue as num) < (rightValue as num);
        case 'includesOneOf':
          if (leftValue is List && rightValue is List) {
            return rightValue.any((item) => leftValue.contains(item));
          }
          return false;
        case 'equalsOneOf':
          if (rightValue is List) {
            return rightValue.contains(leftValue);
          }
          return false;
        case 'isAfter':
          if (leftValue is String && rightValue is String) {
            return DateTime.parse(leftValue)
                .isAfter(DateTime.parse(rightValue));
          }
          return false;
        case 'isBefore':
          if (leftValue is String && rightValue is String) {
            return DateTime.parse(leftValue)
                .isBefore(DateTime.parse(rightValue));
          }
          return false;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  dynamic _getLeftOperandValue(
      Study study,
      Map<String, dynamic> answers,
      Map<String, dynamic> leftOperand,
      ) {
    final type = leftOperand['type'];
    final value = leftOperand['value'];

    if (type == 'question') {
      final question = study.questions.firstWhere(
            (q) => q.id == value,
      );

      if (question.id.isNotEmpty) {
        return answers[question.id];
      }
    }
    return null;
  }

  dynamic _getRightOperandValue(
      Map<String, dynamic> answers,
      Map<String, dynamic> rightOperand,
      ) {
    final type = rightOperand['type'];
    final value = rightOperand['value'];

    if (type == 'question') {
      return answers[value];
    } else if (type == 'static') {
      return value;
    }
    return null;
  }

  ({
  Set<String> requiredQuestionIds,
  String? jumpTarget,
  Set<String> skipQuestionIds
  }) _performActions(
      List<dynamic> actions,
      ) {
    Set<String> requiredQuestionIds = {};
    String? jumpTarget;
    Set<String> skipQuestionIds = {};

    for (final action in actions) {
      final objective = action['objective'];
      final target = action['target'];

      switch (objective) {
        case 'requireAnswer':
          requiredQuestionIds.add(target as String);
          break;
        case 'jumpToQuestion':
          jumpTarget ??= target as String;
          break;
        case 'jumpToEnd':
          jumpTarget ??= 'end';
          break;
        case 'skipQuestion':
          skipQuestionIds.add(target as String);
          break;
      }
    }

    return (
    requiredQuestionIds: requiredQuestionIds,
    jumpTarget: jumpTarget,
    skipQuestionIds: skipQuestionIds,
    );
  }

  void nextQuestion({required String studyId}) {
    final currentIndex = state.currentQuestionIndex;
    final study = state.study;

    if (study == null) {
      return;
    }

    // Check if we're at the last question and should submit
    if (currentIndex >= study.questions.length - 1) {
      submitSurvey(studyId: studyId);
      return;
    }

    // Check if we're at a jump target and need to process it
    if (state.jumpTarget != null) {
      if (state.jumpTarget == 'end') {
        submitSurvey(studyId: studyId);
        return;
      } else {
        final targetIndex = study.questions.indexWhere(
              (q) => q.id == state.jumpTarget,
        );

        if (targetIndex == currentIndex) {
          emit(state.copyWith(jumpTarget: null));
          // Continue with normal flow below
        } else if (targetIndex != -1) {
          _isNavigating = true;

          final newLogicJumps = Map<int, int>.from(state.logicJumps);
          newLogicJumps[currentIndex] = targetIndex;

          final newHistory = List<int>.from(state.navigationHistory)
            ..add(currentIndex);

          emit(state.copyWith(
            currentQuestionIndex: targetIndex,
            jumpTarget: null,
            navigationHistory: newHistory,
            logicJumps: newLogicJumps,
          ));

          Future.delayed(const Duration(milliseconds: 100), () {
            _isNavigating = false;
          });
          return;
        } else {
          emit(state.copyWith(jumpTarget: null));
          // Continue with normal flow below
        }
      }
    }

    // Find the next accessible question
    int nextIndex = currentIndex + 1;

    while (nextIndex < study.questions.length) {
      final nextQuestion = study.questions[nextIndex];

      // Check if this question is accessible based on current answers
      if (_isQuestionAccessible(nextQuestion, study, state.answers)) {
        break; // Found an accessible question
      } else {
        nextIndex++; // Skip this question and check the next one
      }
    }

    if (nextIndex < study.questions.length) {
      _isNavigating = true;
      final newHistory = List<int>.from(state.navigationHistory)
        ..add(currentIndex);

      // Create new state and re-evaluate logic
      final newState = state.copyWith(
        currentQuestionIndex: nextIndex,
        jumpTarget: null,
        navigationHistory: newHistory,
      );

      final evaluatedState = _evaluateLogic(newState);

      emit(evaluatedState);

      Future.delayed(const Duration(milliseconds: 100), () {
        _isNavigating = false;
      });
    } else {
      submitSurvey(studyId: studyId);
    }
  }

  void previousQuestion() {
    if (state.navigationHistory.isNotEmpty) {
      final newHistory = List<int>.from(state.navigationHistory);
      final previousIndex = newHistory.removeLast();

      _isNavigating = true;
      emit(state.copyWith(
        currentQuestionIndex: previousIndex,
        jumpTarget: null,
        navigationHistory: newHistory,
      ));
      Future.delayed(const Duration(milliseconds: 100), () {
        _isNavigating = false;
      });
    } else if (state.currentQuestionIndex > 0) {
      int? sourceIndex;

      for (final entry in state.logicJumps.entries) {
        if (entry.value == state.currentQuestionIndex) {
          sourceIndex = entry.key;
          break;
        }
      }

      _isNavigating = true;
      if (sourceIndex != null) {
        emit(state.copyWith(
          currentQuestionIndex: sourceIndex,
          jumpTarget: null,
        ));
      } else {
        emit(state.copyWith(
          currentQuestionIndex: state.currentQuestionIndex - 1,
          jumpTarget: null,
        ));
      }
      Future.delayed(const Duration(milliseconds: 100), () {
        _isNavigating = false;
      });
    }
  }

  void jumpToQuestion(int index) {
    if (state.study != null &&
        index >= 0 &&
        index < state.study!.questions.length) {
      _isNavigating = true;
      final newHistory = List<int>.from(state.navigationHistory)
        ..add(state.currentQuestionIndex);

      emit(state.copyWith(
        currentQuestionIndex: index,
        jumpTarget: null,
        navigationHistory: newHistory,
      ));
      Future.delayed(const Duration(milliseconds: 100), () {
        _isNavigating = false;
      });
    }
  }

  bool canProceed(ApiQuestion question) {
    // Don't allow proceeding if location is still loading
    if (state.isLocationLoading) {
      return false;
    }

    final answer = state.answers[question.id];
    final isRequiredByLogic = state.requiredQuestions.contains(question.id);

    if (isRequiredByLogic) {
      switch (question.type) {
        case ApiQuestionType.multipleChoiceSingle:
        case ApiQuestionType.rating:
        case ApiQuestionType.date:
          return answer != null;
        case ApiQuestionType.multipleChoiceMulti:
          return answer != null && (answer as List).isNotEmpty;
        case ApiQuestionType.openText:
        case ApiQuestionType.longText: // Added longText type
          return answer != null && (answer as String).trim().isNotEmpty;
        case ApiQuestionType.ranking:
          return answer != null &&
              (answer as List).length == (question.choices?.length ?? 0);
        case ApiQuestionType.matrix:
          if (answer == null || answer is! Map) return false;
          final rowIds = question.rows?.map((row) => row['id']).toList() ?? [];
          for (var rowId in rowIds) {
            if (answer[rowId] == null) return false;
          }
          return true;
        case ApiQuestionType.cascade:
          return answer != null && answer is List && answer.isNotEmpty;
        default:
          return answer != null;
      }
    }

    if (!question.required) return true;

    switch (question.type) {
      case ApiQuestionType.multipleChoiceSingle:
      case ApiQuestionType.rating:
      case ApiQuestionType.date:
        return answer != null;
      case ApiQuestionType.multipleChoiceMulti:
        return answer != null && (answer as List).isNotEmpty;
      case ApiQuestionType.openText:
      case ApiQuestionType.longText: // Added longText type
        return answer != null && (answer as String).trim().isNotEmpty;
      case ApiQuestionType.ranking:
        return answer != null &&
            (answer as List).length == (question.choices?.length ?? 0);
      case ApiQuestionType.matrix:
        if (answer == null || answer is! Map) return false;
        final rowIds = question.rows?.map((row) => row['id']).toList() ?? [];
        for (var rowId in rowIds) {
          if (answer[rowId] == null) return false;
        }
        return true;
      case ApiQuestionType.cascade:
        if (answer == null || answer is! List) return false;
        return answer.isNotEmpty;
      default:
        return true;
    }
  }

  Map<String, dynamic> _formatAnswersForSubmission() {
    final Map<String, dynamic> formattedData = {};
    final study = state.study;

    if (study == null) return formattedData;

    for (final question in study.questions) {
      final answer = state.answers[question.id];
      if (answer != null) {
        // For multiple choice questions, we need to handle the answer format
        if (question.type == ApiQuestionType.multipleChoiceSingle) {
          // Single choice - store the selected choice ID
          formattedData[question.variable] = answer;
        } else if (question.type == ApiQuestionType.multipleChoiceMulti) {
          // Multiple choice - store list of selected choice IDs
          formattedData[question.variable] = answer;
        } else if (question.type == ApiQuestionType.ranking) {
          // Ranking - store the ordered list of choice IDs
          formattedData[question.variable] = answer;
        } else {
          // For open text, rating, date, etc. - store the value directly
          formattedData[question.variable] = answer;
        }
      }
    }

    return formattedData;
  }

  Future<void> submitSurvey({required String studyId}) async {
    final study = state.study;
    if (study == null) return;

    // Stop recording if it's active
    if (state.isRecording) {
      await stopRecording();
    }

    String? audioUrl;
    final isVoiceRequired = study.responseValidation?.requiredVoice ?? false;

    // Handle audio upload if online
    if (isVoiceRequired && state.audioFilePath != null && fileUploadService != null) {
      final connected = InternetConnectionMonitor(
        checkOnInterval: false,
        checkInterval: const Duration(seconds: 5),
      );

      final isConnected = await connected.hasInternetConnection();

      if (isConnected) {
        emit(state.copyWith(isSubmitting: true));

        try {
          final result = await fileUploadService!.uploadAudioFile(
            studyId,
            state.audioFilePath!,
          );

          audioUrl = result['filename'] as String?;

          emit(state.copyWith(
            audioUploadResult: result,
          ));

          // Clean up local file after successful upload
          final file = File(state.audioFilePath!);
          if (await file.exists()) {
            await file.delete();
          }

          // Reset audio file path after successful upload
          emit(state.copyWith(audioFilePath: null));
        } catch (e) {
          ToastService.showErrorToast(message: 'Failed to upload audio: $e');
          emit(state.copyWith(
            isSubmitting: false,
          ));
          return;
        }
      } else {
        // In offline mode, we'll store the audio file path for later upload
        audioUrl = state.audioFilePath; // Store the file path temporarily
      }
    }

    // Format the response data according to API specification
    final responseData = _formatResponseForSubmission(studyId, audioUrl);

    final connected = InternetConnectionMonitor(
      checkOnInterval: false,
      checkInterval: const Duration(seconds: 5),
    );

    final isConnected = await connected.hasInternetConnection();

    if (isConnected) {
      // Online mode - submit directly
      print('Survey submission (online): $responseData');

      try {
        final response = await studyService.submitSurveyResponse(
          studyId: studyId,
          responseData: responseData[0],
        );

        ToastService.showSuccessToast(message: 'Response submitted successfully');
        print('Response submitted successfully: $response');

        emit(
          state.copyWith(
            isSubmitting: false,
            submissionResult: response,
          ),
        );
      } catch (e) {
        ToastService.showErrorToast(message: 'Failed to submit survey: $e');
        emit(state.copyWith(
          isSubmitting: false,
        ));
      }
    } else {
      // Offline mode - store for later sync
      try {
        await OfflineModeDataRepo().saveOfflineAnswer(studyId, responseData[0]);

        ToastService.showSuccessToast(
            message: 'Response saved offline. Will sync when internet is available.'
        );

        emit(
          state.copyWith(
            isSubmitting: false,
            submissionResult: {'status': 'saved_offline'},
          ),
        );

      } catch (e) {
        ToastService.showErrorToast(message: 'Failed to save offline: $e');
        emit(state.copyWith(
          isSubmitting: false,
        ));
      }
    }
  }

  List<Map<String, dynamic>> _formatResponseForSubmission(String studyId, String? audioUrl) {
    final study = state.study;
    if (study == null) return [];

    // Convert answers to the required data format
    final List<Map<String, dynamic>> questionResponses = [];

    for (final question in study.questions) {
      final answer = state.answers[question.id];
      if (answer != null) {
        // Create the question response object
        final questionResponse = {
          "response": _formatAnswerValue(answer, question.type),
          "questionId": question.id,
          "questionVariable": question.variable,
          "questionType": question.type.toString().replaceAll('ApiQuestionType.', ''),
          "timestamp": DateTime.now().toIso8601String(),
        };

        questionResponses.add(questionResponse);
      }
    }

    // Build the main response object
    final submission = {
      "study": studyId,
      "duration": state.recordingDuration,
      "data": questionResponses, // This is the array of question responses
      "finished": true,
      "deviceType": "mobile",
      "respondent": state.selectedRespondent?['_id'],
      "geolocation": state.locationData?.toJson() ?? {},
      "submittedAt": DateTime.now().toIso8601String(),
    };

    // Add audio URL if available
    if (audioUrl != null) {
      if (audioUrl.startsWith('/')) {
        submission["audioFilePath"] = audioUrl;
      } else {
        submission["audioUrl"] = audioUrl;
      }
    }

    // Add optional fields if available
    if (state.selectedRespondent != null) {
      final respondent = state.selectedRespondent!;
      submission["group"] = respondent['group'];
      submission["wave"] = respondent['wave'];
      submission["cohort"] = respondent['cohort'];
      submission["subject"] = respondent['subject'];
    }

    // Return as array with one response object (as per API spec)
    return [submission]; // This is the key - wrap in array
  }

  dynamic _formatAnswerValue(dynamic answer, ApiQuestionType questionType) {
    switch (questionType) {
      case ApiQuestionType.multipleChoiceSingle:
        return answer; // Single choice ID
      case ApiQuestionType.multipleChoiceMulti:
        return answer is List ? answer : [answer]; // Array of choice IDs
      case ApiQuestionType.rating:
        return answer is int ? answer : int.tryParse(answer.toString());
      case ApiQuestionType.openText:
      case ApiQuestionType.longText:
        return answer.toString();
      case ApiQuestionType.date:
        return answer is DateTime ? answer.toIso8601String() : answer.toString();
      case ApiQuestionType.ranking:
        return answer is List ? answer : [answer]; // Array in ranked order
      case ApiQuestionType.matrix:
      // For matrix questions, format as map of rowId -> columnId/value
        return answer is Map ? answer : {'value': answer};
      case ApiQuestionType.cascade:
        return answer is List ? answer : [answer]; // Array of selected cascade values
      default:
        return answer.toString();
    }
  }

  // Interview specific methods
  Future<void> loadStudyRespondents(String studyId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final respondents = await studyService.getStudyRespondents(studyId);
      emit(state.copyWith(
        isLoading: false,
        respondents: respondents,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load respondents: ${e.toString()}',
      ));
    }
  }

  Future<void> createRespondent(String studyId, Map<String, dynamic> respondentData) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final result = await studyService.createStudyRespondent(
        studyId: studyId,
        respondentData: respondentData,
      );

      // Reload respondents to include the new one
      final respondents = await studyService.getStudyRespondents(studyId);

      emit(state.copyWith(
        isLoading: false,
        respondents: respondents,
        isCreatingRespondent: false,
        newRespondentData: {},
      ));

      ToastService.showSuccessToast(message: 'Respondent created successfully');
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to create respondent: ${e.toString()}',
      ));
    }
  }

  void selectRespondent(Map<String, dynamic> respondent) {
    emit(state.copyWith(
      selectedRespondent: respondent,
      isManagingRespondents: false,
    ));
  }

  void startInterview() {
    if (state.selectedRespondent == null) {
      ToastService.showErrorToast(message: 'Please select a respondent first');
      return;
    }

    emit(state.copyWith(
      currentQuestionIndex: 0,
      answers: {},
      isManagingRespondents: false,
    ));
  }

  void backToRespondentManagement() {
    emit(state.copyWith(
      isManagingRespondents: true,
      selectedRespondent: null,
      currentQuestionIndex: 0,
      answers: {},
    ));
  }

  void showCreateRespondentForm() {
    emit(state.copyWith(
      isCreatingRespondent: true,
      newRespondentData: {},
    ));
  }

  void cancelCreateRespondent() {
    emit(state.copyWith(
      isCreatingRespondent: false,
      newRespondentData: {},
    ));
  }

  void updateNewRespondentData(String key, dynamic value) {
    final newData = Map<String, dynamic>.from(state.newRespondentData);
    newData[key] = value;
    emit(state.copyWith(newRespondentData: newData));
  }
}