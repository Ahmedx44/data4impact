// features/data_collect/widget/interview.dart
import 'package:data4impact/core/service/api_service/Model/api_question.dart';
import 'package:data4impact/core/service/dialog_loading.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/data_collect/cubit/data_collet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/data_collect_cubit.dart';

class InterviewDataCollection extends StatefulWidget {
  final String studyId;

  const InterviewDataCollection({super.key, required this.studyId});

  @override
  State<InterviewDataCollection> createState() => _InterviewDataCollectionState();
}

class _InterviewDataCollectionState extends State<InterviewDataCollection> {
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, TextEditingController> _interviewAnswerControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize interview data collection
    context.read<DataCollectCubit>().getStudyQuestions(widget.studyId);
  }

  @override
  void dispose() {
    _textControllers.values.forEach((controller) => controller.dispose());
    _interviewAnswerControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DataCollectCubit, DataCollectState>(
      listener: (context, state) {
        if (state.error != null) {
          ToastService.showErrorToast(message: state.error!);
          context.read<DataCollectCubit>().clearError();
        }

        if (state.submissionResult != null) {
          Navigator.pop(context);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.isSubmitting) {
            DialogLoading.show(context);
          } else {
            DialogLoading.hide(context);
          }
        });
      },
      builder: (context, state) {
        if (state.isLoading && state.study == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.study == null) {
          return _buildErrorScreen('No study data found');
        }

        // Show respondent management screen
        if (state.isManagingRespondents || state.selectedRespondent == null) {
          return _buildRespondentManagementScreen(state);
        }

        // Show interview questions screen
        return _buildInterviewQuestionsScreen(state);
      },
    );
  }

  Widget _buildErrorScreen(String errorMessage) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.read<DataCollectCubit>().getStudyQuestions(widget.studyId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRespondentManagementScreen(DataCollectState state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview - Manage Respondents'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          if (!state.isCreatingRespondent)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<DataCollectCubit>().loadStudyRespondents(widget.studyId);
              },
            ),
        ],
      ),
      body: state.isCreatingRespondent
          ? _buildCreateRespondentForm(state)
          : _buildRespondentsList(state),
      floatingActionButton: !state.isCreatingRespondent
          ? FloatingActionButton(
        onPressed: () {
          context.read<DataCollectCubit>().showCreateRespondentForm();
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  Widget _buildRespondentsList(DataCollectState state) {
    return Column(
      children: [
        // Study Info Card
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.study!.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.study!.description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Questions: ${state.study!.questions.length}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),

        // Respondents List
        Expanded(
          child: state.respondents.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Respondents Yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first respondent',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: state.respondents.length,
            itemBuilder: (context, index) {
              final respondent = state.respondents[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    respondent['name']?.toString() ?? 'Unnamed Respondent',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code: ${respondent['code']?.toString() ?? 'N/A'}'),
                      if (respondent['group'] != null)
                        Text('Group: ${respondent['group']}'),
                      if (respondent['age'] != null)
                        Text('Age: ${respondent['age']}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      context.read<DataCollectCubit>().selectRespondent(respondent);
                    },
                    child: const Text('Start Interview'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCreateRespondentForm(DataCollectState state) {
    final homogeneityGroups = state.study?.homogeneity?['groups'] ?? [];
    final nextCode = _generateNextRespondentCode(state.respondents);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Respondent',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          // Respondent Name
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Respondent Name *',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              context.read<DataCollectCubit>().updateNewRespondentData('name', value);
            },
          ),
          const SizedBox(height: 16),

          // Respondent Code (auto-generated but editable)
          TextFormField(
            initialValue: nextCode,
            decoration: const InputDecoration(
              labelText: 'Respondent Code *',
              border: OutlineInputBorder(),
              helperText: 'Auto-generated code, you can modify if needed',
            ),
            onChanged: (value) {
              context.read<DataCollectCubit>().updateNewRespondentData('code', value);
            },
          ),
          const SizedBox(height: 16),

          // Homogeneity Group
          // Homogeneity Group
          /*DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Select Homogeneity Group',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('No Group'),
              ),
              // Convert to list first, then spread is not needed
              ...homogeneityGroups.isNotEmpty
                  ? homogeneityGroups.map<DropdownMenuItem<String>>((group) {
                return DropdownMenuItem<String>(
                  value: group['name']?.toString(),
                  child: Text(group['name']?.toString() ?? 'Unnamed Group'),
                );
              }).toList()
                  : <DropdownMenuItem<String>>[],
            ],
            onChanged: (value) {
              context.read<DataCollectCubit>().updateNewRespondentData('group', value);
            },
          ),*/
          const SizedBox(height: 16),

          // Age
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isNotEmpty) {
                context.read<DataCollectCubit>().updateNewRespondentData('age', int.tryParse(value));
              }
            },
          ),
          const SizedBox(height: 32),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<DataCollectCubit>().cancelCreateRespondent();
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _createRespondent(state);
                  },
                  child: const Text('Add Respondent'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _generateNextRespondentCode(List<Map<String, dynamic>> respondents) {
    final existingCodes = respondents
        .map((r) => r['code']?.toString() ?? '')
        .where((code) => code.startsWith('RES-'))
        .toList();

    if (existingCodes.isEmpty) {
      return 'RES-1';
    }

    final numbers = existingCodes
        .map((code) => int.tryParse(code.replaceAll('RES-', '')) ?? 0)
        .toList();

    final maxNumber = numbers.isNotEmpty ? numbers.reduce((a, b) => a > b ? a : b) : 0;
    return 'RES-${maxNumber + 1}';
  }

  void _createRespondent(DataCollectState state) {
    final respondentData = Map<String, dynamic>.from(state.newRespondentData);

    // Ensure required fields are present
    if (respondentData['name'] == null || respondentData['name'].toString().isEmpty) {
      ToastService.showErrorToast(message: 'Please enter respondent name');
      return;
    }

    if (respondentData['code'] == null || respondentData['code'].toString().isEmpty) {
      ToastService.showErrorToast(message: 'Please enter respondent code');
      return;
    }

    context.read<DataCollectCubit>().createRespondent(widget.studyId, respondentData);
  }

  Widget _buildInterviewQuestionsScreen(DataCollectState state) {
    final study = state.study!;
    final currentQuestionIndex = state.currentQuestionIndex;
    final question = study.questions[currentQuestionIndex];

    // Initialize answer controller for this question
    final answerController = _interviewAnswerControllers.putIfAbsent(
      question.id,
          () => TextEditingController(text: state.answers[question.id]?.toString() ?? ''),
    );

    if (state.answers[question.id]?.toString() != answerController.text) {
      answerController.text = state.answers[question.id]?.toString() ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1}/${study.questions.length}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              state.selectedRespondent?['name']?.toString() ?? 'Respondent',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              context.read<DataCollectCubit>().backToRespondentManagement();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / study.questions.length,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),

            // Respondent info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: Text(state.selectedRespondent?['code']?.toString().substring(4) ?? '?'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.selectedRespondent?['name']?.toString() ?? 'Unnamed Respondent',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (state.selectedRespondent?['group'] != null)
                            Text('Group: ${state.selectedRespondent?['group']}'),
                          if (state.selectedRespondent?['age'] != null)
                            Text('Age: ${state.selectedRespondent?['age']}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Question
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.getTitle(state.selectedLanguage),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Probing questions
                    if (question.probings != null && question.probings!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Probing Questions:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...question.probings!.map((probing) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                '• ${probing['label']?[state.selectedLanguage] ?? probing['label']?['default'] ?? ''}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Answer text field
                    TextField(
                      controller: answerController,
                      onChanged: (value) {
                        context.read<DataCollectCubit>().updateAnswer(question.id, value);
                      },
                      maxLines: 10,
                      minLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Interview Response',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Navigation buttons
            Row(
              children: [
                // Back to respondents button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<DataCollectCubit>().backToRespondentManagement();
                    },
                    child: const Text('Back to Respondents'),
                  ),
                ),
                const SizedBox(width: 16),

                // Next/Submit button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (currentQuestionIndex == study.questions.length - 1) {
                        context.read<DataCollectCubit>().submitSurvey(studyId: widget.studyId);
                      } else {
                        context.read<DataCollectCubit>().nextQuestion(studyId: widget.studyId);
                      }
                    },
                    child: Text(
                      currentQuestionIndex == study.questions.length - 1
                          ? 'Submit Interview'
                          : 'Next Question',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}