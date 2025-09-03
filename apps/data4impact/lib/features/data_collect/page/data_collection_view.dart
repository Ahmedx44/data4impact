import 'package:data4impact/core/service/api_service/Model/api_question.dart';
import 'package:data4impact/core/service/api_service/Model/study.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataCollectCubit, DataCollectState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.error != null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text('Error: ${state.error}'),
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
          return _buildCompletionScreen(study);
        }

        if (currentQuestionIndex >= study.questions.length) {
          return _buildCompletionScreen(study);
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
                const SizedBox(height: 32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              question.getTitle('default') as String,
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
                      if (question.headline['subtitle'] != null)
                        Text(
                          question.headline['subtitle'].toString(),
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
                Row(
                  children: [
                    if (currentQuestionIndex > 0)
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
                    if (currentQuestionIndex > 0) const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: context.read<DataCollectCubit>().canProceed(question)
                            ? () {
                          print('DEBUG: Next/Submit button pressed');
                          print('DEBUG: Current index: $currentQuestionIndex, Total questions: ${study.questions.length}');
                          print('DEBUG: Is last question: ${currentQuestionIndex == study.questions.length - 1}');
                          context.read<DataCollectCubit>().nextQuestion();
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

  Widget _buildQuestionInput(ApiQuestion question, DataCollectState state) {
    final cubit = context.read<DataCollectCubit>();
    final answer = state.answers[question.id];
    final isRequiredByLogic = state.requiredQuestions.contains(question.id);
    final isActuallyRequired = question.required || isRequiredByLogic;

    switch (question.type) {
      case ApiQuestionType.openText:
        return _buildOpenTextInput(question, answer, cubit, isActuallyRequired);
      case ApiQuestionType.multipleChoiceSingle:
        return _buildSingleChoice(question, answer, cubit, isActuallyRequired);
      case ApiQuestionType.multipleChoiceMulti:
        return _buildMultipleChoice(question, answer, cubit, isActuallyRequired);
      case ApiQuestionType.rating:
        return _buildRating(question, answer, cubit, isActuallyRequired);
      case ApiQuestionType.matrix:
        return _buildMatrix(question, answer, cubit, isActuallyRequired);
      case ApiQuestionType.ranking:
        return _buildRanking(question, answer, cubit, isActuallyRequired);
      case ApiQuestionType.date:
        return _buildDateInput(question, answer, cubit, isActuallyRequired);
      case ApiQuestionType.cascade:
        return _buildCascade(question, answer, cubit, isActuallyRequired);
      default:
        return Center(child: Text('Unsupported question type: ${question.type}'));
    }
  }

  Widget _buildOpenTextInput(
      ApiQuestion question, dynamic answer, DataCollectCubit cubit, bool isRequired) {
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
        hintText: question.placeholder?['default'] != null
            ? question.placeholder!['default'].toString()
            : 'Type your answer here...',
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
      ApiQuestion question, dynamic answer, DataCollectCubit cubit, bool isRequired) {
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
                    choice['label']['default'] != null ? choice['label']['default'].toString() : 'Option ${index + 1}',
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
      ApiQuestion question, dynamic answer, DataCollectCubit cubit, bool isRequired) {
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
                    choice['label']['default'] != null ? choice['label']['default'].toString() : 'Option ${index + 1}',
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
      ApiQuestion question, dynamic answer, DataCollectCubit cubit, bool isRequired) {
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatrix(
      ApiQuestion question, dynamic answer, DataCollectCubit cubit, bool isRequired) {
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
                        row['label']['default'] != null ? row['label']['default'].toString() : 'Row ${rowIndex + 1}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                              column['label']['default'] != null ? column['label']['default'].toString() : 'Option',
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
      ApiQuestion question, dynamic answer, DataCollectCubit cubit, bool isRequired) {
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
                  choice['label']['default']?.toString() ?? 'Option ${index + 1}',
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
      ApiQuestion question, dynamic answer, DataCollectCubit cubit, bool isRequired) {
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
          child: _buildCascadeTree(cascades, currentSelection, cubit, question.id),
        ),
      ],
    );
  }

  Widget _buildCascadeTree(
      List<dynamic> items, List<dynamic> currentSelection, DataCollectCubit cubit, String questionId) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final itemId = item['id'];
        final itemName = item['name']?['default']?.toString() ?? 'Unknown';
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
              child: _buildCascadeTree(item['children'] as List<dynamic>, currentSelection, cubit, questionId),
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

  Widget _buildCompletionScreen(Study study) {
    final ending = study.ending;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                ending['headline']?['default']?.toString() ?? 'Thank you!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                ending['subheader']?['default']?.toString() ?? 'Your response has been recorded.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
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