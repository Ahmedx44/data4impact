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
  @override
  void initState() {
    super.initState();
    final cubit = context.read<DataCollectCubit>();
    cubit.getStudyQuestions(widget.studyId);
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
                // Progress indicator
                LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / study.questions.length,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 32),

                // Question content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.getTitle('default') as String,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Add subtitle if available
                      const SizedBox(height: 24),

                      // Question input based on type
                      Expanded(child: _buildQuestionInput(question, state)),
                    ],
                  ),
                ),

                // Navigation buttons
                Row(
                  children: [
                    if (currentQuestionIndex > 0)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context
                              .read<DataCollectCubit>()
                              .previousQuestion(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.surfaceVariant,
                            foregroundColor:
                                Theme.of(context).colorScheme.onSurface,
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
                        onPressed: context
                                .read<DataCollectCubit>()
                                .canProceed(question)
                            ? () =>
                                context.read<DataCollectCubit>().nextQuestion()
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context
                                  .read<DataCollectCubit>()
                                  .canProceed(question)
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceVariant,
                          foregroundColor: context
                                  .read<DataCollectCubit>()
                                  .canProceed(question)
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
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

    switch (question.type) {
      case ApiQuestionType.openText:
        return _buildOpenTextInput(question, answer, cubit);
      case ApiQuestionType.multipleChoiceSingle:
        return _buildSingleChoice(question, answer, cubit);
      case ApiQuestionType.multipleChoiceMulti:
        return _buildMultipleChoice(question, answer, cubit);
      case ApiQuestionType.rating:
        return _buildRating(question, answer, cubit);
      case ApiQuestionType.matrix:
        return _buildMatrix(question, answer, cubit);
      case ApiQuestionType.ranking:
        return _buildRanking(question, answer, cubit);
      case ApiQuestionType.date:
        return _buildDateInput(question, answer, cubit);
      case ApiQuestionType.cascade:
        return _buildCascade(question, answer, cubit);
      default:
        return Center(
            child: Text('Unsupported question type: ${question.type}'));
    }
  }

  Widget _buildOpenTextInput(
      ApiQuestion question, dynamic answer, DataCollectCubit cubit) {
    return TextField(
      onChanged: (value) => cubit.updateAnswer(question.id, value),
      decoration: InputDecoration(
        hintText: question.placeholder?['default'] != null
            ? question.placeholder!['default'].toString()
            : 'Type your answer here...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor:
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      maxLines: 5,
      minLines: 3,
    );
  }

  Widget _buildSingleChoice(
      ApiQuestion question, dynamic answer, DataCollectCubit cubit) {
    final choices = question.choices ?? [];

    return ListView.builder(
      shrinkWrap: true,
      itemCount: choices.length,
      itemBuilder: (context, index) {
        final choice = choices[index];
        final isSelected = answer == choice['id'];

        return ListTile(
          title: Text(choice['label']['default'] != null
              ? choice['label']['default'].toString()
              : 'Option ${index + 1}'),
          leading: Radio(
            value: choice['id'],
            groupValue: answer,
            onChanged: (value) => cubit.updateAnswer(question.id, value),
          ),
          onTap: () => cubit.updateAnswer(question.id, choice['id']),
        );
      },
    );
  }

  Widget _buildMultipleChoice(
      ApiQuestion question, dynamic answer, DataCollectCubit cubit) {
    final choices = question.choices ?? [];
    final selectedIds = (answer is List ? answer : []).toSet();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: choices.length,
      itemBuilder: (context, index) {
        final choice = choices[index];
        final isSelected = selectedIds.contains(choice['id']);

        return CheckboxListTile(
          title: Text(choice['label']['default'] != null
              ? choice['label']['default'].toString()
              : 'Option ${index + 1}'),
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
        );
      },
    );
  }

  Widget _buildRating(
      ApiQuestion question, dynamic answer, DataCollectCubit cubit) {
    final maxRating = question.range ?? 5;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(maxRating, (index) {
              final ratingValue = index + 1;
              return IconButton(
                icon: Icon(
                  ratingValue <= (answer != null ? answer as num : 0)
                      ? Icons.star
                      : Icons.star_border,
                  size: 40,
                  color: Colors.amber,
                ),
                onPressed: () => cubit.updateAnswer(question.id, ratingValue),
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
    );
  }

  Widget _buildMatrix(
      ApiQuestion question, dynamic answer, DataCollectCubit cubit) {
    final rows = question.rows ?? [];
    final columns = question.columns ?? [];
    final matrixAnswers = (answer is Map ? answer : {});

    return ListView.builder(
      shrinkWrap: true,
      itemCount: rows.length,
      itemBuilder: (context, rowIndex) {
        final row = rows[rowIndex];
        final rowId = row['id'];
        final selectedColumnId = matrixAnswers[rowId];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row['label']['default'] != null
                      ? row['label']['default'].toString()
                      : 'Row ${rowIndex + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: columns.map((column) {
                    final columnId = column['id'];
                    return ChoiceChip(
                      label: Text(column['label']['default'] !=null  ? column['label']['default'].toString() : 'Option'),
                      selected: selectedColumnId == columnId,
                      onSelected: (selected) {
                        final newAnswers =
                            Map<String, dynamic>.from(matrixAnswers);
                        if (selected) {
                          newAnswers[rowId as String] = columnId;
                        } else if (newAnswers[rowId] == columnId) {
                          newAnswers.remove(rowId);
                        }
                        cubit.updateAnswer(question.id, newAnswers);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRanking(
      ApiQuestion question, dynamic answer, DataCollectCubit cubit) {
    final choices = question.choices ?? [];
    List<dynamic> currentRanking = (answer is List ? List.from(answer) : []);

    // Initialize ranking if empty
    if (currentRanking.isEmpty) {
      currentRanking = List.from(choices.map((choice) => choice['id']));
    }

    return ReorderableListView(
      shrinkWrap: true,
      onReorder: (oldIndex, newIndex) {
        // Adjust index for the removed item
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
            child: Icon(
              Icons.drag_handle,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
      }).toList(),
    );
  }

  Widget _buildDateInput(
      ApiQuestion question, dynamic answer, DataCollectCubit cubit) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final selectedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );

          if (selectedDate != null) {
            cubit.updateAnswer(question.id, selectedDate.toIso8601String());
          }
        },
        child: Text(answer == null
            ? 'Select Date'
            : 'Selected: ${answer.toString().substring(0, 10)}'),
      ),
    );
  }

  Widget _buildCascade(
      ApiQuestion question, dynamic answer, DataCollectCubit cubit) {
    final cascades = question.cascades ?? [];
    List<dynamic> currentSelection = (answer is List ? List.from(answer) : []);

    // State to track expanded items
    final Map<String, bool> expandedStates = {};

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with instructions
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Expand and select one option from each branch:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

            // Display current selection
            if (currentSelection.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...currentSelection.map((selectedId) {
                      final item = _findCascadeItem(selectedId as String, cascades);
                      return Text(
                        '• ${item?['name']?['default']?.toString() ?? 'Unknown'}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

            // Expandable tree view
            Expanded(
              child: ListView(
                children: [
                  _buildCascadeTree(
                    cascades,
                    currentSelection,
                    cubit,
                    question.id,
                    0, // Initial indentation level
                    expandedStates,
                    setState,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCascadeTree(
      List<dynamic> items,
      List<dynamic> currentSelection,
      DataCollectCubit cubit,
      String questionId,
      int indentationLevel,
      Map<String, bool> expandedStates,
      StateSetter setState,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        final itemId = item['id'];
        final itemName = item['name']?['default']?.toString() ?? 'Unknown';
        final itemLabel = item['label']?['default']?.toString() ?? '';
        final hasChildren = item['children'] is List && (item['children'] as List).isNotEmpty;
        final isSelected = currentSelection.contains(itemId);
        final isExpanded = expandedStates[itemId] ?? false;

        // Check if any sibling is selected
        final bool hasSiblingSelected = items.any((sibling) =>
        sibling['id'] != itemId && currentSelection.contains(sibling['id']));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parent item
            InkWell(
              onTap: () {
                if (hasChildren) {
                  // Toggle expansion
                  setState(() {
                    expandedStates[itemId as String] = !isExpanded;
                  });
                } else {
                  // For leaf nodes, handle selection
                  _handleCascadeSelection(
                      itemId as String,
                      items,
                      currentSelection,
                      cubit,
                      questionId
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.only(
                  left: 16.0 + (indentationLevel * 24.0),
                  right: 16.0,
                  top: 12.0,
                  bottom: 12.0,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : (hasSiblingSelected
                      ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3)
                      : Colors.transparent),
                ),
                child: Row(
                  children: [
                    // Expand/collapse icon for items with children
                    if (hasChildren)
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      )
                    else
                      const SizedBox(width: 20),

                    const SizedBox(width: 8),

                    // Selection indicator (only for leaf nodes)
                    if (!hasChildren)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                            width: 2,
                          ),
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? Icon(
                          Icons.check,
                          size: 14,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                            : null,
                      )
                    else
                      const SizedBox(width: 20),

                    const SizedBox(width: 12),

                    // Item content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: hasChildren ? FontWeight.w600 : FontWeight.normal,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (itemLabel.isNotEmpty)
                            Text(
                              itemLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Show if a selection has been made in this branch
                    if (hasChildren && _hasSelectionInBranch(item, currentSelection))
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                ),
              ),
            ),

            // Child items (if expanded) with animation
            if (hasChildren && isExpanded)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _buildCascadeTree(
                  item['children'] as List<dynamic>,
                  currentSelection,
                  cubit,
                  questionId,
                  indentationLevel + 1,
                  expandedStates,
                  setState,
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  void _handleCascadeSelection(
      String selectedId,
      List<dynamic> siblings,
      List<dynamic> currentSelection,
      DataCollectCubit cubit,
      String questionId,
      ) {
    final newSelection = List<dynamic>.from(currentSelection);

    // Remove any siblings from the same level
    for (final sibling in siblings) {
      if (sibling['id'] != selectedId && newSelection.contains(sibling['id'])) {
        newSelection.remove(sibling['id']);
      }
    }

    // Add the new selection if not already selected
    if (!newSelection.contains(selectedId)) {
      newSelection.add(selectedId);
    } else {
      // If already selected, deselect it (toggle behavior)
      newSelection.remove(selectedId);
    }

    cubit.updateAnswer(questionId, newSelection);
  }

  bool _hasSelectionInBranch(dynamic item, List<dynamic> selection) {
    if (selection.contains(item['id'])) {
      return true;
    }

    if (item['children'] is List) {
      for (final child in item['children'] as List<dynamic>) {
        if (_hasSelectionInBranch(child, selection)) {
          return true;
        }
      }
    }

    return false;
  }

// Helper function to find an item by ID in the cascade structure
  dynamic _findCascadeItem(String itemId, List<dynamic> items) {
    for (final item in items) {
      if (item['id'] == itemId) {
        return item;
      }
      if (item['children'] is List) {
        final found = _findCascadeItem(itemId, item['children'] as List<dynamic>);
        if (found != null) {
          return found;
        }
      }
    }
    return null;
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
                child: const Text('Finish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
