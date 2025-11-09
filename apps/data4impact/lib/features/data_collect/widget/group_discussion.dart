// group_discussion.dart
import 'package:data4impact/core/service/api_service/Model/api_question.dart';
import 'package:data4impact/core/service/api_service/Model/study.dart';
import 'package:data4impact/core/service/dialog_loading.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/data_collect/cubit/data_collet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/data_collect_cubit.dart';

class GroupDiscussionDataCollection extends StatefulWidget {
  final String studyId;

  const GroupDiscussionDataCollection({super.key, required this.studyId});

  @override
  State<GroupDiscussionDataCollection> createState() => _GroupDiscussionDataCollectionState();
}

class _GroupDiscussionDataCollectionState extends State<GroupDiscussionDataCollection> {
  final Map<String, TextEditingController> _textControllers = {};
  String? _previousError;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<DataCollectCubit>();
    cubit.startGroupDiscussionFlow();
    cubit.getStudyQuestions(widget.studyId);
    cubit.loadStudyGroups(widget.studyId);
  }

  @override
  void dispose() {
    _textControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DataCollectCubit, DataCollectState>(
      listener: (context, state) {
        if (state.error != null && state.error != _previousError) {
          ToastService.showErrorToast(message: state.error!);
          _previousError = state.error;
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
        if (state.isLoading || (state.study == null && state.groups.isEmpty)) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.error != null && state.study == null && state.groups.isEmpty) {
          return _buildErrorScreen(state.error!);
        }

        if (state.study == null && state.groups.isNotEmpty) {
          return _buildGroupSelectionScreen(state);
        }

        if (state.study == null) {
          return _buildErrorScreen('No study data available');
        }

        final study = state.study!;

        if (state.isManagingGroups || state.selectedGroup == null) {
          return _buildGroupSelectionScreen(state);
        }

        if (state.isSelectingRespondents || state.selectedGroupRespondents.isEmpty) {
          return _buildRespondentSelectionScreen(state);
        }

        return _buildQuestionsScreen(state, study);
      },
    );
  }

  Widget _buildErrorScreen(String errorMessage) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
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
                  context.read<DataCollectCubit>().loadStudyGroups(widget.studyId);
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

  Widget _buildGroupSelectionScreen(DataCollectState state) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Select Group',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        forceMaterialTransparency: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.read<DataCollectCubit>().showCreateGroupForm();
              _showCreateGroupDialog();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.group_rounded,
                              size: 24,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.study?.name ?? 'Study',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Group Discussion',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Select a group or create a new one to begin the discussion',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Groups List
            Expanded(
              child: state.groups.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.group_off_rounded,
                      size: 80,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No Groups Available',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Create your first group to start',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DataCollectCubit>().showCreateGroupForm();
                        _showCreateGroupDialog();
                      },
                      child: const Text('Create Group'),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: state.groups.length,
                itemBuilder: (context, index) {
                  final group = state.groups[index];
                  return _buildGroupCard(group);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.group_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          group['name']?.toString() ?? 'Unnamed Group',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: group['description'] != null
            ? Text(group['description'].toString())
            : null,
        trailing: ElevatedButton(
          onPressed: () {
            context.read<DataCollectCubit>().selectGroup(group);
            context.read<DataCollectCubit>().loadGroupRespondents(widget.studyId);
          },
          child: const Text('Select'),
        ),
      ),
    );
  }

  Widget _buildRespondentSelectionScreen(DataCollectState state) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Select Participants',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        forceMaterialTransparency: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            context.read<DataCollectCubit>().backToGroupSelection();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreateRespondentDialog();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Group Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.group_rounded,
                          size: 30,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.selectedGroup?['name']?.toString() ?? 'Selected Group',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Select participants for the group discussion',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            if (state.selectedGroup?['homogeneityGroup'] != null) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Homogeneity: ${state.selectedGroup?['homogeneityGroup']}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Selected respondents count
            if (state.selectedGroupRespondents.isNotEmpty)
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${state.selectedGroupRespondents.length} participant(s) selected',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Respondents List
            Expanded(
              child: state.groupRespondents.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 80,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No Respondents Available',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Create respondents to add to the group',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _showCreateRespondentDialog();
                      },
                      child: const Text('Create Respondent'),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: state.groupRespondents.length,
                itemBuilder: (context, index) {
                  final respondent = state.groupRespondents[index];
                  final isSelected = state.selectedGroupRespondents.any(
                          (r) => r['_id'] == respondent['_id']);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        respondent['name']?.toString() ?? 'Unnamed Respondent',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (respondent['code'] != null)
                            Text('Code: ${respondent['code']}'),
                          if (respondent['age'] != null)
                            Text('Age: ${respondent['age']}'),
                          if (respondent['gender'] != null)
                            Text('Gender: ${respondent['gender']}'),
                        ],
                      ),
                      value: isSelected,
                      onChanged: (value) {
                        context.read<DataCollectCubit>().toggleRespondentSelection(respondent);
                      },
                      secondary: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Start Discussion Button
            if (state.selectedGroupRespondents.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<DataCollectCubit>().startGroupDiscussion();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start Group Discussion',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsScreen(DataCollectState state, Study study) {
    final currentQuestionIndex = state.currentQuestionIndex;
    final currentRespondent = state.currentRespondentIndex < state.selectedGroupRespondents.length
        ? state.selectedGroupRespondents[state.currentRespondentIndex]
        : null;

    if (state.jumpTarget == 'end') {
      return _buildCompletionScreen(study, state);
    }

    if (currentQuestionIndex >= study.questions.length) {
      // Move to next respondent or complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<DataCollectCubit>().nextRespondentInGroup(studyId: widget.studyId);
      });
      return _buildRespondentTransitionScreen(state);
    }

    final question = study.questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1}/${study.questions.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              'Participant ${state.currentRespondentIndex + 1}/${state.selectedGroupRespondents.length}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        forceMaterialTransparency: true,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
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
            // Progress bars
            Column(
              children: [
                LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / study.questions.length,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: (state.currentRespondentIndex + 1) / state.selectedGroupRespondents.length,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Group and respondent info card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          child: const Icon(Icons.group),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.selectedGroup?['name'] as String ?? 'Group',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Group Discussion',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(height: 1, color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                          foregroundColor: Theme.of(context).colorScheme.secondary,
                          radius: 16,
                          child: Text(
                            '${state.currentRespondentIndex + 1}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentRespondent?['name'] as String ?? 'Participant',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (currentRespondent?['code'] != null)
                                Text(
                                  'Code: ${currentRespondent?['code']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<DataCollectCubit>().backToRespondentSelection();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Theme.of(context).colorScheme.outline),
                    ),
                    child: const Text('Back to Participants'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: context.read<DataCollectCubit>().canProceed(question)
                        ? () {
                      if (currentQuestionIndex == study.questions.length - 1) {
                        // This will trigger moving to next respondent
                        context.read<DataCollectCubit>().nextQuestion(studyId: widget.studyId);
                      } else {
                        context.read<DataCollectCubit>().nextQuestion(studyId: widget.studyId);
                      }
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
                          ? 'Next Participant'
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
  }

  Widget _buildRespondentTransitionScreen(DataCollectState state) {
    final nextRespondentIndex = state.currentRespondentIndex;

    if (nextRespondentIndex >= state.selectedGroupRespondents.length) {
      return _buildCompletionScreen(state.study!, state);
    }

    final nextRespondent = state.selectedGroupRespondents[nextRespondentIndex];

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.switch_account_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Next Participant',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        radius: 30,
                        child: Text(
                          '${nextRespondentIndex + 1}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        nextRespondent['name']?.toString() ?? 'Participant',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      if (nextRespondent['code'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Code: ${nextRespondent['code']}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // The cubit will automatically handle moving to the next respondent
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... Include all the question input methods from LongitudinalDataCollection
  // _buildQuestionInput, _buildOpenTextInput, _buildSingleChoice, etc.
  // These are the same as in the LongitudinalDataCollection

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
    // ... Include all other question type builders from LongitudinalDataCollection
      default:
        return Center(child: Text('Unsupported question type: ${question.type}'));
    }
  }

  Widget _buildOpenTextInput(ApiQuestion question, dynamic answer, DataCollectCubit cubit, bool isRequired, String languageCode) {
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

  Widget _buildSingleChoice(ApiQuestion question, dynamic answer, DataCollectCubit cubit, bool isRequired, String languageCode) {
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
                    question.getChoiceLabel(choice as Map<String, dynamic>, languageCode),
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
                'Group Discussion Completed!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Thank you for completing the group discussion with all participants.',
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

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<DataCollectCubit, DataCollectState>(
          builder: (context, state) {
            return AlertDialog(
              title: const Text('Create New Group'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Group Name *',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => context.read<DataCollectCubit>().updateNewGroupData('name', value),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (value) => context.read<DataCollectCubit>().updateNewGroupData('description', value),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Homogeneity Group',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => context.read<DataCollectCubit>().updateNewGroupData('homogeneityGroup', value),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.read<DataCollectCubit>().cancelCreateGroup();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (state.newGroupData['name'] != null && state.newGroupData['name'].toString().isNotEmpty) {
                      context.read<DataCollectCubit>().createStudyGroup(widget.studyId, state.newGroupData);
                      Navigator.pop(context);
                    } else {
                      ToastService.showErrorToast(message: 'Group name is required');
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateRespondentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Respondent'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Respondent Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Respondent Code',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.refresh),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Group: Selected Group Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Criteria',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.warning, color: Theme.of(context).colorScheme.error, size: 16),
                    const SizedBox(width: 8),
                    const Text('Age greaterThan 18'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Age is required',
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Custom Fields',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Age *',
                    border: OutlineInputBorder(),
                    errorText: 'Age is required',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement create respondent logic
                ToastService.showSuccessToast(message: 'Respondent created successfully');
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}