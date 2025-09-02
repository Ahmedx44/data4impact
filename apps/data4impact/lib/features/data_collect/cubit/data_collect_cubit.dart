import 'package:bloc/bloc.dart';
import 'package:data4impact/core/service/api_service/Model/api_question.dart';
import 'package:data4impact/core/service/api_service/Model/study.dart';
import 'package:data4impact/core/service/api_service/study_service.dart';
import 'package:data4impact/features/data_collect/cubit/data_collet_state.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

class DataCollectCubit extends Cubit<DataCollectState> {
  final StudyService studyService;
  bool _isNavigating = false; // Add navigation flag

  DataCollectCubit({required this.studyService}) : super(const DataCollectState());

  Future<void> getStudyQuestions(String studyId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final data = await studyService.getStudyQuestions(studyId);

      print('API Response type: ${data.runtimeType}');
      print('API Response data: $data');

      // Check if the response is an error FIRST
      if (data is Map<String, dynamic> && data['error'] == true) {
        final errorMessage = data['message'] ?? 'Study is not in progress';
        print('Error response detected: $errorMessage');
        emit(state.copyWith(
          isLoading: false,
          error: errorMessage as String,
        ));
        return;
      }

      print('Parsing as Study object...');
      final study = Study.fromJson(data);
      print('Study parsed successfully: ${study.name}');

      emit(state.copyWith(
        study: study,
        isLoading: false,
        currentQuestionIndex: 0,
        answers: {},
        requiredQuestions: {},
        jumpTarget: null,
      ));
    } on FormatException catch (e) {
      print('FormatException caught: ${e.message}');
      emit(state.copyWith(
        isLoading: false,
        error: e.message,
      ));
    } catch (e) {
      print('General exception caught: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load study: ${e.toString()}',
      ));
    }
  }

  void updateAnswer(String questionId, dynamic value) {
    if (_isNavigating) return; // Don't evaluate logic during navigation

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

    // Evaluate logic for all questions
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
                conditions as Map<String,dynamic>,
              );

              if (conditionResult) {
                final result = _performActions(actions as List);
                requiredQuestions.addAll(result.requiredQuestionIds);
                jumpTarget ??= result.jumpTarget;
              }
            }
          }
        }
      }
    }

    return currentState.copyWith(
      requiredQuestions: requiredQuestions,
      jumpTarget: jumpTarget,
    );
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
          // This is a nested condition group
          results.add(_evaluateConditionGroup(study, answers, condition));
        } else {
          // This is a single condition
          results.add(_evaluateSingleCondition(study, answers, condition));
        }
      } else {
        results.add(false); // Invalid condition format
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

      final leftValue = _getLeftOperandValue(study, answers, leftOperand as Map<String,dynamic>);
      final rightValue = rightOperand != null
          ? _getRightOperandValue(answers, rightOperand as Map<String,dynamic>)
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
            return DateTime.parse(leftValue).isAfter(DateTime.parse(rightValue));
          }
          return false;
        case 'isBefore':
          if (leftValue is String && rightValue is String) {
            return DateTime.parse(leftValue).isBefore(DateTime.parse(rightValue));
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
      // Find the question by ID and get its answer
      final question = study.questions.firstWhere(
            (q) => q.id == value,
      );

      if (question != null) {
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

  ({Set<String> requiredQuestionIds, String? jumpTarget}) _performActions(
      List<dynamic> actions,
      ) {
    Set<String> requiredQuestionIds = {};
    String? jumpTarget;

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
      }
    }

    return (
    requiredQuestionIds: requiredQuestionIds,
    jumpTarget: jumpTarget,
    );
  }

  void nextQuestion() {
    final currentIndex = state.currentQuestionIndex;
    final study = state.study;

    if (study == null) return;

    // Handle jump logic
    if (state.jumpTarget != null) {
      if (state.jumpTarget == 'end') {
        submitSurvey();
        return;
      } else {
        // Find the index of the target question
        final targetIndex = study.questions.indexWhere(
              (q) => q.id == state.jumpTarget,
        );

        if (targetIndex != -1) {
          _isNavigating = true; // Set navigation flag
          emit(state.copyWith(
            currentQuestionIndex: targetIndex,
            jumpTarget: null,
          ));
          // Reset flag after navigation
          Future.delayed(const Duration(milliseconds: 100), () {
            _isNavigating = false;
          });
          return;
        }
      }
    }

    // Normal progression
    final nextIndex = currentIndex + 1;
    if (nextIndex < study.questions.length) {
      _isNavigating = true; // Set navigation flag
      emit(state.copyWith(
        currentQuestionIndex: nextIndex,
        jumpTarget: null,
      ));
      // Reset flag after navigation
      Future.delayed(const Duration(milliseconds: 100), () {
        _isNavigating = false;
      });
    } else {
      submitSurvey();
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      _isNavigating = true; // Set navigation flag
      emit(state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
        jumpTarget: null, // Clear any jump targets
      ));
      // Reset flag after navigation
      Future.delayed(const Duration(milliseconds: 100), () {
        _isNavigating = false;
      });
    }
  }

  void jumpToQuestion(int index) {
    if (state.study != null && index >= 0 && index < state.study!.questions.length) {
      _isNavigating = true; // Set navigation flag
      emit(state.copyWith(
        currentQuestionIndex: index,
        jumpTarget: null, // Clear any jump targets
      ));
      // Reset flag after navigation
      Future.delayed(const Duration(milliseconds: 100), () {
        _isNavigating = false;
      });
    }
  }

  bool canProceed(ApiQuestion question) {
    final answer = state.answers[question.id];
    final isRequiredByLogic = state.requiredQuestions.contains(question.id);

    // If question is required by logic, use stricter validation
    if (isRequiredByLogic) {
      switch (question.type) {
        case ApiQuestionType.multipleChoiceSingle:
        case ApiQuestionType.rating:
        case ApiQuestionType.date:
          return answer != null;
        case ApiQuestionType.multipleChoiceMulti:
          return answer != null && (answer as List).isNotEmpty;
        case ApiQuestionType.openText:
          return answer != null && (answer as String).trim().isNotEmpty;
        case ApiQuestionType.ranking:
          return answer != null && (answer as List).length == (question.choices?.length ?? 0);
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

    // Original validation for non-logic-required questions
    if (!question.required) return true;

    switch (question.type) {
      case ApiQuestionType.multipleChoiceSingle:
      case ApiQuestionType.rating:
      case ApiQuestionType.date:
        return answer != null;
      case ApiQuestionType.multipleChoiceMulti:
        return answer != null && (answer as List).isNotEmpty;
      case ApiQuestionType.openText:
        return answer != null && (answer as String).trim().isNotEmpty;
      case ApiQuestionType.ranking:
        return answer != null && (answer as List).length == (question.choices?.length ?? 0);
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

  void submitSurvey() {
    // Handle survey submission
    print('Survey answers: ${state.answers}');
    // Here you would typically send the answers to your API
  }
}