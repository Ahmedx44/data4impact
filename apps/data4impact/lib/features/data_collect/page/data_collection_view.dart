import 'dart:async';
import 'dart:io';
import 'package:data4impact/core/service/api_service/Model/api_question.dart';
import 'package:data4impact/core/service/api_service/Model/study.dart';
import 'package:data4impact/core/service/dialog_loading.dart';
import 'package:data4impact/features/data_collect/cubit/data_collet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/data_collect_cubit.dart';

class DataCollectionView extends StatefulWidget {
  const DataCollectionView({super.key, required this.studyId});

  final String studyId;

  @override
  State<DataCollectionView> createState() => _DataCollectionViewState();
}

class _DataCollectionViewState extends State<DataCollectionView> {
  final Map<String, TextEditingController> _textControllers = {};

  @override
  void initState() {
    super.initState();
    final cubit = context.read<DataCollectCubit>();
    cubit.getStudyQuestions(widget.studyId);
  }

  @override
  void dispose() {
    _textControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataCollectCubit, DataCollectState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.isSubmitting) {
            DialogLoading.show(context);
          } else {
            DialogLoading.hide(context);
          }
        });


        if(state.submissionResult!=null){
          Navigator.canPop(context);
        }

        if (state.error != null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Error: ${state.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            ),
          );
        }

        if (state.study == null) {
          return const Scaffold(
            body: Center(child: Text('No study data found')),
          );
        }

        final study = state.study!;
        final currentQuestionIndex = state.currentQuestionIndex;



        if (state.jumpTarget == 'end') {
          return _buildCompletionScreen(study, state);
        }

        if (currentQuestionIndex >= study.questions.length) {
          return _buildCompletionScreen(study, state);
        }

        final question = study.questions[currentQuestionIndex];

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: Text(
              'Question ${currentQuestionIndex + 1}/${study.questions.length}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
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
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / study.questions.length,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),

                const SizedBox(height: 16),


                if (study.responseValidation?.requiredVoice ?? false)
                  _buildAudioRecordingUI(state),

                if (study.responseValidation?.requiredLocation ?? false)
                  _buildLocationStatus(state),

                const SizedBox(height: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              question.getTitle(state.selectedLanguage),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (question.required)
                            Text(
                              '*',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (question.getSubtitle(state.selectedLanguage) != null)
                        Text(
                          question.getSubtitle(state.selectedLanguage)!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      const SizedBox(height: 24),
                      Expanded(child: _buildQuestionInput(question, state)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // FIXED: Only show back button if we can go back
                    // For welcome screen, we need special handling
                    if (currentQuestionIndex > 0 || (currentQuestionIndex == 0 && study.isWelcomeCardEnabled && state.answers.isNotEmpty))
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.read<DataCollectCubit>().previousQuestion(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                            foregroundColor: Theme.of(context).colorScheme.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Back'),
                        ),
                      ),
                    if (currentQuestionIndex > 0 || (currentQuestionIndex == 0 && study.isWelcomeCardEnabled && state.answers.isNotEmpty))
                      const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: context.read<DataCollectCubit>().canProceed(question)
                            ? () {
                          context.read<DataCollectCubit>().nextQuestion(studyId: widget.studyId);
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.read<DataCollectCubit>().canProceed(question)
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceVariant,
                          foregroundColor: context.read<DataCollectCubit>().canProceed(question)
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          currentQuestionIndex == study.questions.length - 1
                              ? 'Submit'
                              : 'Next',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeScreen(Study study, DataCollectState state) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            Text(
              study.getWelcomeHeadline(state.selectedLanguage),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              study.getWelcomeHtml(state.selectedLanguage),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.read<DataCollectCubit>().nextQuestion(studyId: widget.studyId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Start Survey'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioRecordingUI(DataCollectState state) {
    final cubit = context.read<DataCollectCubit>();
    final remainingSeconds = 180 - state.recordingDuration;
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    // Check if we have a valid audio file that actually exists
    bool hasAudioFile = false;
    if (state.audioFilePath != null) {
      final file = File(state.audioFilePath!);
      hasAudioFile = file.existsSync();
    }

    return Column(
      children: [
        // Recording status and timer
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.isRecording ? Icons.mic : Icons.mic_none,
              color: state.isRecording ? Colors.red : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              state.isRecording
                  ? 'Recording: $minutes:$seconds remaining'
                  : hasAudioFile ? 'Audio recorded' : 'Audio recording ready',
              style: TextStyle(
                color: state.isRecording ? Colors.red : Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Recording controls - Show only when not recording AND no audio file exists
        if (!state.isRecording && !hasAudioFile)
          ElevatedButton(
            onPressed: () => cubit.startRecording(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mic, size: 16),
                SizedBox(width: 4),
                Text('Start Recording'),
              ],
            ),
          ),

        // Stop recording button - Show only when recording
        if (state.isRecording)
          ElevatedButton(
            onPressed: () => cubit.stopRecording(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stop, size: 16),
                SizedBox(width: 4),
                Text('Stop Recording'),
              ],
            ),
          ),

        // Audio playback controls (shown when audio is recorded but not uploading)
        if (hasAudioFile && !state.isRecording && !state.isUploadingAudio)
          Column(
            children: [
              const SizedBox(height: 16),
              Text(
                'Audio recorded: ${state.audioFilePath!.split('/').last}',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),

              // Audio player controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      state.isPlayingAudio ? Icons.pause : Icons.play_arrow,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      if (state.isPlayingAudio) {
                        cubit.pauseAudio();
                      } else {
                        cubit.playAudio();
                      }
                    },
                  ),

                  IconButton(
                    icon: Icon(
                      Icons.stop,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () => cubit.stopAudio(),
                  ),

                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 30,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Recording'),
                          content: const Text('Are you sure you want to delete this recording?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (shouldDelete == true && mounted) {
                        cubit.deleteRecording();
                      }
                    },
                  ),
                ],
              ),

              // Audio progress bar
              if (state.audioDuration.inSeconds > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Slider(
                        value: state.audioPosition.inSeconds.toDouble(),
                        min: 0,
                        max: state.audioDuration.inSeconds.toDouble(),
                        onChanged: (value) {
                          cubit.seekAudio(Duration(seconds: value.toInt()));
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(state.audioPosition.inSeconds),
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            _formatDuration(state.audioDuration.inSeconds),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),

        if (state.isUploadingAudio)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),

        if (state.audioUploadResult != null)
          Text(
            'Audio uploaded successfully!',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildLocationStatus(DataCollectState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state.isLocationLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (state.locationData != null)
            Icon(Icons.location_on, color: Colors.green, size: 16)
          else
            Icon(Icons.location_off, color: Colors.red, size: 16),

          const SizedBox(width: 8),

          if (state.isLocationLoading)
            const Text('Getting location...', style: TextStyle(fontSize: 14))
          else if (state.locationData != null)
            const Text('Location captured', style: TextStyle(fontSize: 14))
          else
            const Text('Location required', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildQuestionInput(ApiQuestion question, DataCollectState state) {
    final cubit = context.read<DataCollectCubit>();
    final answer = state.answers[question.id];
    final isRequiredByLogic = state.requiredQuestions.contains(question.id);
    final isActuallyRequired = question.required || isRequiredByLogic;

    switch (question.type) {
      case ApiQuestionType.openText:
        return _buildOpenTextInput(question, answer, cubit, isActuallyRequired, state.selectedLanguage);
      case ApiQuestionType.multipleChoiceSingle:
        return _buildSingleChoice(question, answer, cubit, isActuallyRequired, state.selectedLanguage);
      case ApiQuestionType.multipleChoiceMulti:
        return _buildMultipleChoice(question, answer, cubit, isActuallyRequired, state.selectedLanguage);
      case ApiQuestionType.rating:
        return _buildRating(question, answer, cubit, isActuallyRequired, state.selectedLanguage);
      case ApiQuestionType.matrix:
        return _buildMatrix(question, answer, cubit, isActuallyRequired, state.selectedLanguage);
      case ApiQuestionType.ranking:
        return _buildRanking(question, answer, cubit, isActuallyRequired, state.selectedLanguage);
      case ApiQuestionType.date:
        return _buildDateInput(question, answer, cubit, isActuallyRequired);
      case ApiQuestionType.cascade:
        return _buildCascade(question, answer, cubit, isActuallyRequired, state.selectedLanguage);
      default:
        return Center(child: Text('Unsupported question type: ${question.type}'));
    }
  }

  Widget _buildOpenTextInput(
      ApiQuestion question, dynamic answer, DataCollectCubit cubit, bool isRequired, String languageCode) {
    final controller = _textControllers.putIfAbsent(question.id, () {
      return TextEditingController(text: answer?.toString() ?? '');
    });

    if (answer?.toString() != controller.text) {
      controller.text = answer?.toString() ?? '';
    }

    return TextField(
      controller: controller,
      onChanged: (value) => cubit.updateAnswer(question.id, value),
      decoration: InputDecoration(
        hintText: question.getPlaceholder(languageCode) ?? 'Type your answer here...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        errorText: isRequired && (answer == null || (answer as String).isEmpty)
            ? 'This field is required'
            : null,
        errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      maxLines: 5,
      minLines: 3,
    );
  }

  Widget _buildSingleChoice(
      ApiQuestion question, dynamic answer, DataCollectCubit cubit, bool isRequired, String languageCode) {
    final choices = question.choices ?? [];

    return Column(
      children: [
        if (isRequired && answer == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Please select an option',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: choices.length,
            itemBuilder: (context, index) {
              final choice = choices[index];
              final isSelected = answer == choice['id'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    question.getChoiceLabel(choice as Map<String,dynamic>, languageCode),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  leading: Radio(
                    value: choice['id'],
                    groupValue: answer,
                    onChanged: (value) => cubit.updateAnswer(question.id, value),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () => cubit.updateAnswer(question.id, choice['id']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoice(
      ApiQuestion question, dynamic answer, DataCollectCubit cubit, bool isRequired, String languageCode) {
    final choices = question.choices ?? [];
    final selectedIds = (answer is List ? answer : []).toSet();

    return Column(
      children: [
        if (isRequired && selectedIds.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Please select at least one option',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: choices.length,
            itemBuilder: (context, index) {
              final choice = choices[index];
              final isSelected = selectedIds.contains(choice['id']);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: CheckboxListTile(
                  title: Text(
                    question.getChoiceLabel(choice as Map<String,dynamic>, languageCode),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  value: isSelected,
                  onChanged: (value) {
                    final newSelectedIds = Set.from(selectedIds);
                    if (value == true) {
                      newSelectedIds.add(choice['id']);
                    } else {
                      newSelectedIds.remove(choice['id']);
                    }
                    cubit.updateAnswer(question.id, newSelectedIds.toList());
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                  checkColor: Theme.of(context).colorScheme.onPrimary,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRating(
      ApiQuestion question, dynamic answer, DataCollectCubit cubit, bool isRequired, String languageCode) {
    final maxRating = question.range ?? 5;

    return Column(
      children: [
        if (isRequired && answer == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Please provide a rating',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
            ),
          ),
        Center(
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(maxRating, (index) {
                  final ratingValue = index + 1;
                  return GestureDetector(
                    onTap: () => cubit.updateAnswer(question.id, ratingValue),
                    child: Icon(
                      ratingValue <= (answer != null ? answer as num : 0)
                          ? Icons.star
                          : Icons.star_border,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Text(
                answer == null ? 'Tap to rate' : 'You rated: $answer/$maxRating',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              if (question.lowerLabel != null || question.upperLabel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (question.lowerLabel != null)
                        Text(
                          question.getLowerLabel(languageCode) ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (question.upperLabel != null)
                        Text(
                          question.getUpperLabel(languageCode) ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatrix(
      ApiQuestion question, dynamic answer, DataCollectCubit cubit, bool isRequired, String languageCode) {
    final rows = question.rows ?? [];
    final columns = question.columns ?? [];
    final matrixAnswers = (answer is Map ? answer : {});

    return Column(
      children: [
        if (isRequired)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Please answer all rows',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, rowIndex) {
              final row = rows[rowIndex];
              final rowId = row['id'];
              final selectedColumnId = matrixAnswers[rowId];

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.getRowLabel(row as Map<String,dynamic>, languageCode),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: columns.map((column) {
                          final columnId = column['id'];
                          final isSelected = selectedColumnId == columnId;

                          return FilterChip(
                            label: Text(
                              question.getColumnLabel(column as Map<String,dynamic>, languageCode),
                              style: TextStyle(
                                color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              final newAnswers = Map<String, dynamic>.from(matrixAnswers);
                              if (selected) {
                                newAnswers[rowId as String] = columnId;
                              } else if (newAnswers[rowId] == columnId) {
                                newAnswers.remove(rowId);
                              }
                              cubit.updateAnswer(question.id, newAnswers);
                            },
                            backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
                            selectedColor: Theme.of(context).colorScheme.primary,
                            checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRanking(
      ApiQuestion question, dynamic answer, DataCollectCubit cubit, bool isRequired, String languageCode) {
    final choices = question.choices ?? [];
    List<dynamic> currentRanking = (answer is List ? List.from(answer) : []);

    if (currentRanking.isEmpty) {
      currentRanking = List.from(choices.map((choice) => choice['id']));
    }

    return Column(
      children: [
        if (isRequired)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Please rank all options',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
            ),
          ),
        Expanded(
          child: ReorderableListView(
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) newIndex--;
              setState(() {
                final item = currentRanking.removeAt(oldIndex);
                currentRanking.insert(newIndex, item);
                cubit.updateAnswer(question.id, List.from(currentRanking));
              });
            },
            children: currentRanking.asMap().entries.map((entry) {
              final index = entry.key;
              final choiceId = entry.value;
              final choice = choices.firstWhere(
                    (c) => c['id'] == choiceId,
                orElse: () => {'label': {'default': 'Unknown'}},
              );

              return ListTile(
                key: Key('$choiceId'),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  question.getChoiceLabel(choice as Map<String,dynamic>, languageCode),
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: ReorderableDragStartListener(
                  index: index,
                  child: Icon(Icons.drag_handle, color: Theme.of(context).colorScheme.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateInput(
      ApiQuestion question, dynamic answer, DataCollectCubit cubit, bool isRequired) {
    return Column(
      children: [
        if (isRequired && answer == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Please select a date',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
            ),
          ),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: answer != null ? DateTime.parse(answer as String) : DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );

              if (selectedDate != null) {
                cubit.updateAnswer(question.id, selectedDate.toIso8601String());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: Text(
              answer == null ? 'Select Date' : 'Selected: ${answer.toString().substring(0, 10)}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCascade(
      ApiQuestion question, dynamic answer, DataCollectCubit cubit, bool isRequired, String languageCode) {
    final cascades = question.cascades ?? [];
    List<dynamic> currentSelection = (answer is List ? List.from(answer) : []);

    return Column(
      children: [
        if (isRequired && currentSelection.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Please make a selection',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
            ),
          ),
        Expanded(
          child: _buildCascadeTree(cascades, currentSelection, cubit, question.id, languageCode, question),
        ),
      ],
    );
  }

  Widget _buildCascadeTree(
      List<dynamic> items, List<dynamic> currentSelection, DataCollectCubit cubit, String questionId, String languageCode, ApiQuestion question)  {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final itemId = item['id'];
        final itemName = question.getCascadeName(item as Map<String,dynamic>, languageCode);
        final hasChildren = item['children'] is List && (item['children'] as List).isNotEmpty;
        final isSelected = currentSelection.contains(itemId);

        return ExpansionTile(
          title: Text(
            itemName,
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          leading: !hasChildren ? Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                width: 2,
              ),
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            ),
            child: isSelected ? Icon(Icons.check, size: 14, color: Theme.of(context).colorScheme.onPrimary) : null,
          ) : null,
          children: hasChildren ? [
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: _buildCascadeTree(item['children'] as List<dynamic>, currentSelection, cubit, questionId, languageCode,question),
            )
          ] : [],
          onExpansionChanged: (expanded) {
            if (!hasChildren && !expanded) {
              cubit.updateAnswer(questionId, [itemId]);
            }
          },
        );
      },
    );
  }

  Widget _buildCompletionScreen(Study study, DataCollectState state) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                study.getEndingHeadline(state.selectedLanguage),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                study.getEndingSubheader(state.selectedLanguage),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (study.showEndingButton)
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Finish'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}