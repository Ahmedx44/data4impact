import 'package:data4impact/core/service/api_service/Model/study.dart';
import 'package:data4impact/core/service/dialog_loading.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/core/service/internt_connection_monitor.dart';
import 'package:data4impact/features/data_collect/cubit/data_collet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/data_collect_cubit.dart';

class InterviewDataCollection extends StatefulWidget {
  final String studyId;

  const InterviewDataCollection({super.key, required this.studyId});

  @override
  State<InterviewDataCollection> createState() =>
      _InterviewDataCollectionState();
}

class _InterviewDataCollectionState extends State<InterviewDataCollection> {
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, TextEditingController> _interviewAnswerControllers = {};
  String? _previousError;
  final ScrollController _scrollController = ScrollController();
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    context.read<DataCollectCubit>().getStudyQuestions(widget.studyId);
  }

  @override
  void dispose() {
    _textControllers.values.forEach((controller) => controller.dispose());
    _interviewAnswerControllers.values
        .forEach((controller) => controller.dispose());
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final connected = InternetConnectionMonitor(
      checkOnInterval: false,
      checkInterval: const Duration(seconds: 5),
    );
    final hasInternet = await connected.hasInternetConnection();
    if (mounted) {
      setState(() {
        _isOffline = !hasInternet;
      });
    }
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DataCollectCubit, DataCollectState>(
      listener: (context, state) {
        // Show toast for errors instead of changing screen
        if (state.error != null && state.error != _previousError) {
          ToastService.showErrorToast(message: state.error!);
          _previousError = state.error;
          context.read<DataCollectCubit>().clearError();
        }

        // Handle submission result
        // Handle submission result
        if (state.submissionResult != null) {
          if (!state.isManagingRespondents) {
            Navigator.pop(context);
          }
        }

        // Handle loading dialogs
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.isSubmitting) {
            DialogLoading.show(context);
          } else {
            DialogLoading.hide(context);
          }
        });
      },
      builder: (context, state) {
        // Initial loading error screen
        if (state.isLoading && state.error != null) {
          return _buildErrorScreen(state.error!);
        }

        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.study == null) {
          return _buildErrorScreen('No study data found');
        }

        final study = state.study!;

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
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context
                      .read<DataCollectCubit>()
                      .getStudyQuestions(widget.studyId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Interview - Manage Respondents',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        forceMaterialTransparency: true,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: state.isCreatingRespondent
          ? _buildCreateRespondentForm(state)
          : _buildScrollableRespondentsScreen(state),
      floatingActionButton: !state.isCreatingRespondent && !_isOffline
          ? FloatingActionButton(
              onPressed: () {
                context.read<DataCollectCubit>().showCreateRespondentForm();
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildScrollableRespondentsScreen(DataCollectState state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Study Info Card
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.record_voice_over_rounded,
                            size: 30,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.study!.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Interview Session',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surface
                            .withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.study!.description,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.8),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Questions: ${state.study!.questions.length}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Respondents List
            state.respondents.isEmpty
                ? _buildEmptyState()
                : _buildRespondentsList(state),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Respondents Yet',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first respondent',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRespondentsList(DataCollectState state) {
    return Column(
      children: [
        ...state.respondents.asMap().entries.map((entry) {
          final index = entry.key;
          final respondent = entry.value;
          return Card(
            margin: EdgeInsets.only(
              bottom: 12,
              top: index == 0 ? 8 : 0, // Add top margin only for first item
            ),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              title: Text(
                respondent['name']?.toString() ?? 'Unnamed Respondent',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Code: ${respondent['code']?.toString() ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                    if (respondent['group'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Group: ${respondent['group']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                    if (respondent['age'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Age: ${respondent['age']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  context.read<DataCollectCubit>().selectRespondent(respondent);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Start Interview',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCreateRespondentForm(DataCollectState state) {
    final homogeneityGroups = state.study?.homogeneity!.groups ?? [];
    // Use the new auto-generation method that works like group discussion
    final nextCode = _generateNextRespondentCode(state, state.respondents);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Respondent',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                // Respondent Name
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Respondent Name *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.3),
                  ),
                  onChanged: (value) {
                    context
                        .read<DataCollectCubit>()
                        .updateNewRespondentData('name', value);
                  },
                ),
                const SizedBox(height: 16),

                // Respondent Code (auto-generated but editable)
                TextFormField(
                  controller: TextEditingController(text: nextCode),
                  decoration: InputDecoration(
                    labelText: 'Respondent Code *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    helperText: 'Auto-generated code, you can modify if needed',
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.3),
                  ),
                  onChanged: (value) {
                    context
                        .read<DataCollectCubit>()
                        .updateNewRespondentData('code', value);
                  },
                ),
                const SizedBox(height: 16),

                // Age
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.3),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      context
                          .read<DataCollectCubit>()
                          .updateNewRespondentData('age', int.tryParse(value));
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
                          context
                              .read<DataCollectCubit>()
                              .cancelCreateRespondent();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.outline),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _createRespondent(state);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Add Respondent'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _generateNextRespondentCode(
      DataCollectState state, List<Map<String, dynamic>> respondents) {
    // Always use RES as prefix
    String studyPrefix = 'RES';

    // Extract all numbers from existing codes that match our prefix pattern
    final codePattern = RegExp('^$studyPrefix-(\\d+)\$');
    final numbers = <int>[];

    for (final respondent in respondents) {
      final code = respondent['code']?.toString() ?? '';
      if (code.isNotEmpty) {
        final match = codePattern.firstMatch(code);
        if (match != null) {
          final numberStr = match.group(1) ?? '0';
          final number = int.tryParse(numberStr) ?? 0;
          numbers.add(number);
        }
      }
    }

    // Find the highest number used so far
    int nextNumber;
    if (numbers.isNotEmpty) {
      final highestNumber = numbers.reduce((a, b) => a > b ? a : b);
      nextNumber = highestNumber + 1;
    } else {
      // No existing codes with this pattern, start from 1
      nextNumber = 1;
    }

    // Format with leading zeros for better sorting
    return '$studyPrefix-${nextNumber.toString().padLeft(2, '0')}';
  }

  void _createRespondent(DataCollectState state) {
    final respondentData = Map<String, dynamic>.from(state.newRespondentData);

    // Ensure required fields are present
    if (respondentData['name'] == null ||
        respondentData['name'].toString().isEmpty) {
      ToastService.showErrorToast(message: 'Please enter respondent name');
      return;
    }

    // Auto-generate code if not provided or empty
    if (respondentData['code'] == null ||
        respondentData['code'].toString().isEmpty) {
      final autoCode = _generateNextRespondentCode(state, state.respondents);
      respondentData['code'] = autoCode;
      context
          .read<DataCollectCubit>()
          .updateNewRespondentData('code', autoCode);
    }

    context
        .read<DataCollectCubit>()
        .createRespondent(widget.studyId, respondentData);
  }

  Widget _buildInterviewQuestionsScreen(DataCollectState state) {
    final study = state.study!;
    final currentQuestionIndex = state.currentQuestionIndex;

    if (state.isSubmitting) {
      DialogLoading.show(context);
    }

    final question = study.questions[currentQuestionIndex];

    // Initialize answer controller for this question
    final answerController = _interviewAnswerControllers.putIfAbsent(
      question.id,
      () => TextEditingController(
          text: state.answers[question.id]?.toString() ?? ''),
    );

    if (state.answers[question.id]?.toString() != answerController.text) {
      answerController.text = state.answers[question.id]?.toString() ?? '';
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Question ${currentQuestionIndex + 1}/${study.questions.length}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        forceMaterialTransparency: true,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          // Language selector dropdown
          if (study.languages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: DropdownButton<String>(
                value: state.selectedLanguage,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    context.read<DataCollectCubit>().changeLanguage(newValue);
                  }
                },
                items: [
                  const DropdownMenuItem<String>(
                    value: 'default',
                    child: Text('Default'),
                  ),
                  ...study.languages.map<DropdownMenuItem<String>>((language) {
                    return DropdownMenuItem<String>(
                      value: language['code'] as String,
                      child: Text(language['name'] as String? ?? 'Unknown'),
                    );
                  }).toList(),
                ],
                underline: const SizedBox(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              context.read<DataCollectCubit>().backToRespondentManagement();
            },
          ),
        ],
      ),
      body: BlocListener<DataCollectCubit, DataCollectState>(
        listener: (context, state) {
          // Handle loading state changes
          if (state.isSubmitting) {
            DialogLoading.show(context);
          } else {
            DialogLoading.hide(context);
          }

          // Handle submission result
          // Handle submission result
          if (state.submissionResult != null) {
            // Navigate away or show success message
            if (!state.isManagingRespondents) {
              Navigator.pop(context);
            }
          }

          // Handle errors
          if (state.error != null) {
            ToastService.showErrorToast(message: state.error!);
            context.read<DataCollectCubit>().clearError();
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Progress bar
                      LinearProgressIndicator(
                        value:
                            (currentQuestionIndex + 1) / study.questions.length,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 16),

                      // Respondent info card
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: Text(
                                  state.selectedRespondent?['code']
                                          ?.toString()
                                          .substring(4) ??
                                      '?',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.selectedRespondent?['name']
                                              ?.toString() ??
                                          'Unnamed Respondent',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (state.selectedRespondent?['group'] !=
                                        null)
                                      Text(
                                        'Group: ${state.selectedRespondent?['group']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                    if (state.selectedRespondent?['age'] !=
                                        null)
                                      Text(
                                        'Age: ${state.selectedRespondent?['age']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Question content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Question title
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    question.getTitle(state.selectedLanguage),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                                if (question.required)
                                  Text(
                                    '*',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Question subtitle
                            if (question.getSubtitle(state.selectedLanguage) !=
                                null)
                              Text(
                                question.getSubtitle(state.selectedLanguage)!,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                            const SizedBox(height: 24),

                            // Probing questions
                            if (question.probings != null &&
                                question.probings!.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Probing Questions:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...question.probings!.map((probing) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '•',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              probing['label']?[state
                                                          .selectedLanguage]
                                                      .toString() ??
                                                  probing['label']?['default']
                                                      .toString() ??
                                                  '',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  const SizedBox(height: 24),
                                ],
                              ),

                            // Answer text field - Made more compact for keyboard
                            Container(
                              constraints: BoxConstraints(
                                minHeight: 150,
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.4,
                              ),
                              child: TextField(
                                controller: answerController,
                                onChanged: (value) {
                                  context
                                      .read<DataCollectCubit>()
                                      .updateAnswer(question.id, value);
                                },
                                onTap: _scrollToBottom,
                                maxLines: null,
                                minLines: 6,
                                decoration: InputDecoration(
                                  labelText: 'Interview Response',
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant
                                      .withOpacity(0.3),
                                  errorText: question.required &&
                                          (state.answers[question.id] == null ||
                                              (state.answers[question.id]
                                                      as String)
                                                  .isEmpty)
                                      ? 'This field is required'
                                      : null,
                                  errorStyle: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Navigation buttons
                      Row(
                        children: [
                          // Back to respondents button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: state.isSubmitting
                                  ? null
                                  : () {
                                      context
                                          .read<DataCollectCubit>()
                                          .backToRespondentManagement();
                                    },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onSurface,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                              ),
                              child: const Text('Back to Respondents'),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Next/Submit button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: state.isSubmitting
                                  ? null
                                  : context
                                          .read<DataCollectCubit>()
                                          .canProceed(question)
                                      ? () {
                                          if (currentQuestionIndex ==
                                              study.questions.length - 1) {
                                            // Show loading dialog when submitting
                                            context
                                                .read<DataCollectCubit>()
                                                .submitSurvey(
                                                    studyId: widget.studyId,
                                                    flowType: 'interview');
                                          } else {
                                            context
                                                .read<DataCollectCubit>()
                                                .nextQuestion(
                                                    studyId: widget.studyId,
                                                    flowType: 'interview');
                                          }
                                        }
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context
                                            .read<DataCollectCubit>()
                                            .canProceed(question) &&
                                        !state.isSubmitting
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant,
                                foregroundColor: context
                                            .read<DataCollectCubit>()
                                            .canProceed(question) &&
                                        !state.isSubmitting
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: state.isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      currentQuestionIndex ==
                                              study.questions.length - 1
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
              ),
            );
          },
        ),
      ),
    );
  }
}
