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
  State<GroupDiscussionDataCollection> createState() =>
      _GroupDiscussionDataCollectionState();
}

class _GroupDiscussionDataCollectionState
    extends State<GroupDiscussionDataCollection> {
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

        if (state.error != null &&
            state.study == null &&
            state.groups.isEmpty) {
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

        if (state.isSelectingRespondents ||
            state.selectedGroupRespondents.isEmpty) {
          return _buildRespondentSelectionScreen(state);
        }

        return _buildQuestionsScreen(state, study);
      },
    );
  }

  Widget _buildErrorScreen(String errorMessage) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Illustration
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 32),

              // Error Title
              Text(
                'Something Went Wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Error Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Error Details',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Troubleshooting Tips
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Troubleshooting Tips',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTipItem('Check your internet connection'),
                      _buildTipItem('Verify the study is still active'),
                      _buildTipItem('Restart the application if needed'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<DataCollectCubit>().getStudyQuestions(widget.studyId);
                      context.read<DataCollectCubit>().loadStudyGroups(widget.studyId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
        ],
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
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
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.8),
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
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
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.2),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No Groups Available',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Create your first group to start',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<DataCollectCubit>()
                                  .showCreateGroupForm();
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
            context
                .read<DataCollectCubit>()
                .loadGroupRespondents(widget.studyId);
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
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
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
                              state.selectedGroup?['name']?.toString() ??
                                  'Selected Group',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Select participants for the group discussion',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            if (state.selectedGroup?['homogeneityGroup'] !=
                                null) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Homogeneity: ${state.selectedGroup?['homogeneityGroup']}',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.2),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No Respondents Available',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Create respondents to add to the group',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4),
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
                        final isSelected = state.selectedGroupRespondents
                            .any((r) => r['_id'] == respondent['_id']);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CheckboxListTile(
                            title: Text(
                              respondent['name']?.toString() ??
                                  'Unnamed Respondent',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
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
                              context
                                  .read<DataCollectCubit>()
                                  .toggleRespondentSelection(respondent);
                            },
                            secondary: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
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
    final currentRespondent =
    state.currentRespondentIndex < state.selectedGroupRespondents.length
        ? state.selectedGroupRespondents[state.currentRespondentIndex]
        : null;

    if (state.jumpTarget == 'end') {
      return _buildCompletionScreen(study, state);
    }

    if (currentQuestionIndex >= study.questions.length) {
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            context.read<DataCollectCubit>().backToRespondentSelection();
          },
        ),
        actions: [
          if (study.languages.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
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
                      child: Text(
                        language['name'] as String? ?? 'Unknown',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ],
                underline: const SizedBox(),
                icon: Icon(
                  Icons.translate_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
                dropdownColor: Theme.of(context).colorScheme.surface,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Progress Section
              _buildProgressSection(state, study, currentQuestionIndex),
              const SizedBox(height: 24),

              // Participant Info Card
              _buildParticipantInfoCard(state, currentRespondent),
              const SizedBox(height: 24),

              // Question Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.surface,
                        Theme.of(context).colorScheme.surface.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.help_outline_rounded,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(context).colorScheme.onSurface,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                      if (question.required)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Required',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.error,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (question.getSubtitle(state.selectedLanguage) != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      question.getSubtitle(state.selectedLanguage)!,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Question Input
                        Container(
                          constraints: const BoxConstraints(
                            minHeight: 200,
                          ),
                          child: _buildQuestionInput(question, state),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Navigation Buttons
              _buildNavigationButtons(state, study, currentQuestionIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(DataCollectState state, Study study, int currentQuestionIndex) {
    return Column(
      children: [
        // Progress Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            Text(
              '${currentQuestionIndex + 1}/${study.questions.length}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Question Progress Bar
        LinearProgressIndicator(
          value: (currentQuestionIndex + 1) / study.questions.length,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 16),

        // Participant Progress Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Participant Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            Text(
              '${state.currentRespondentIndex + 1}/${state.selectedGroupRespondents.length}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Participant Progress Bar
        LinearProgressIndicator(
          value: (state.currentRespondentIndex + 1) / state.selectedGroupRespondents.length,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.secondary,
          ),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildParticipantInfoCard(DataCollectState state, dynamic currentRespondent) {
    return Card(
      elevation: 2,
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
              Theme.of(context).colorScheme.secondary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Group Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.group_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Group',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.selectedGroup?['name'] as String? ?? 'Unnamed Group',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (state.selectedGroup?['homogeneityGroup'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Homogeneity: ${state.selectedGroup?['homogeneityGroup']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Divider
              Container(
                width: 1,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),

              // Participant Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Participant',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentRespondent?['name'] as String? ?? 'Unnamed',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (currentRespondent?['code'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Code: ${currentRespondent?['code']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
    );
  }

  Widget _buildNavigationButtons(DataCollectState state, Study study, int currentQuestionIndex) {
    final cubit = context.read<DataCollectCubit>();
    final question = study.questions[currentQuestionIndex];

    return Row(
      children: [
        // Back Button
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              cubit.backToRespondentSelection();
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back_rounded, size: 18),
                SizedBox(width: 8),
                Text('Back'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Next Button
        Expanded(
          child: ElevatedButton(
            onPressed: cubit.canProceed(question) ? () {
              if (currentQuestionIndex == study.questions.length - 1) {
                cubit.nextQuestion(studyId: widget.studyId);
              } else {
                cubit.nextQuestion(studyId: widget.studyId);
              }
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: cubit.canProceed(question)
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
              foregroundColor: cubit.canProceed(question)
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentQuestionIndex == study.questions.length - 1
                      ? 'Next Participant'
                      : 'Next Question',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  currentQuestionIndex == study.questions.length - 1
                      ? Icons.group_add_rounded
                      : Icons.arrow_forward_rounded,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
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
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        radius: 30,
                        child: Text(
                          '${nextRespondentIndex + 1}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        nextRespondent['name']?.toString() ?? 'Participant',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      if (nextRespondent['code'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Code: ${nextRespondent['code']}',
                          style: TextStyle(
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
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // The cubit will automatically handle moving to the next respondent
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionInput(ApiQuestion question, DataCollectState state) {
    final cubit = context.read<DataCollectCubit>();
    final answer = state.answers[question.id];
    final isRequiredByLogic = state.requiredQuestions.contains(question.id);
    final isActuallyRequired = question.required || isRequiredByLogic;
    print('question typeee: ${question.type}');

    switch (question.type) {
      case ApiQuestionType.openText:
        return _buildOpenTextInput(question, answer, cubit, isActuallyRequired,
            state.selectedLanguage);
      case ApiQuestionType.multipleChoiceSingle:
        return _buildSingleChoice(question, answer, cubit, isActuallyRequired,
            state.selectedLanguage);
      case ApiQuestionType.multipleChoiceMulti:
        return _buildMultipleChoice(question, answer, cubit, isActuallyRequired,
            state.selectedLanguage);
      case ApiQuestionType.rating:
        return _buildRating(question, answer, cubit, isActuallyRequired,
            state.selectedLanguage);
      case ApiQuestionType.matrix:
        return _buildMatrix(question, answer, cubit, isActuallyRequired,
            state.selectedLanguage);
      case ApiQuestionType.ranking:
        return _buildRanking(question, answer, cubit, isActuallyRequired,
            state.selectedLanguage);
      case ApiQuestionType.date:
        return _buildDateInput(question, answer, cubit, isActuallyRequired);
      case ApiQuestionType.longText:
        return _buildLongText(question, answer, cubit, isActuallyRequired);
      case ApiQuestionType.cascade:
        return _buildCascade(question, answer, cubit, isActuallyRequired,
            state.selectedLanguage);
      default:
        return Center(
            child: Text('Unsupported question type: ${question.type}'));
    }
  }

  Widget _buildLongText(ApiQuestion question, dynamic answer,
      DataCollectCubit cubit, bool isRequired) {
    final controller = _textControllers.putIfAbsent(question.id, () {
      return TextEditingController(text: answer?.toString() ?? '');
    });

    if (answer?.toString() != controller.text) {
      controller.text = answer?.toString() ?? '';
    }

    return Column(
      children: [
        TextField(
          controller: controller,
          onChanged: (value) => cubit.updateAnswer(question.id, value),
          decoration: InputDecoration(
            hintText: 'Enter your detailed response...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            errorText:
                isRequired && (answer == null || (answer as String).isEmpty)
                    ? 'This field is required'
                    : null,
            errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          maxLines: null, // Allows infinite lines
          minLines: 8, // Starts with a larger text area
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 8),
        if (isRequired && (answer == null || (answer as String).isEmpty))
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'This field is required',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOpenTextInput(ApiQuestion question, dynamic answer,
      DataCollectCubit cubit, bool isRequired, String languageCode) {
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
        hintText:
            question.getPlaceholder(languageCode) ?? 'Type your answer here...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        filled: true,
        fillColor:
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        errorText: isRequired && (answer == null || (answer as String).isEmpty)
            ? 'This field is required'
            : null,
        errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      maxLines: 5,
      minLines: 3,
    );
  }

  Widget _buildSingleChoice(ApiQuestion question, dynamic answer,
      DataCollectCubit cubit, bool isRequired, String languageCode) {
    final choices = question.choices ?? [];

    return Column(
      children: [
        if (isRequired && answer == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Please select an option',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 14),
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
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    question.getChoiceLabel(
                        choice as Map<String, dynamic>, languageCode),
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  leading: Radio(
                    value: choice['id'],
                    groupValue: answer,
                    onChanged: (value) =>
                        cubit.updateAnswer(question.id, value),
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

  Widget _buildMultipleChoice(ApiQuestion question, dynamic answer,
      DataCollectCubit cubit, bool isRequired, String languageCode) {
    final choices = question.choices ?? [];
    final selectedIds = (answer is List ? answer : []).toSet();

    return Column(
      children: [
        if (isRequired && selectedIds.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Please select at least one option',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 14),
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
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: CheckboxListTile(
                  title: Text(
                    question.getChoiceLabel(
                        choice as Map<String, dynamic>, languageCode),
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
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

  Widget _buildRating(ApiQuestion question, dynamic answer,
      DataCollectCubit cubit, bool isRequired, String languageCode) {
    final maxRating = question.range ?? 5;

    return Column(
      children: [
        if (isRequired && answer == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Please provide a rating',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 14),
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
                answer == null
                    ? 'Tap to rate'
                    : 'You rated: $answer/$maxRating',
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildMatrix(ApiQuestion question, dynamic answer,
      DataCollectCubit cubit, bool isRequired, String languageCode) {
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
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 14),
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
                        question.getRowLabel(
                            row as Map<String, dynamic>, languageCode),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
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
                              question.getColumnLabel(
                                  column as Map<String, dynamic>, languageCode),
                              style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            selected: isSelected,
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
                            backgroundColor: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surfaceVariant,
                            selectedColor:
                                Theme.of(context).colorScheme.primary,
                            checkmarkColor:
                                Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
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

  Widget _buildRanking(ApiQuestion question, dynamic answer,
      DataCollectCubit cubit, bool isRequired, String languageCode) {
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
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 14),
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
                orElse: () => {
                  'label': {'default': 'Unknown'}
                },
              );

              return ListTile(
                key: Key('$choiceId'),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary, width: 2),
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
                  question.getChoiceLabel(
                      choice as Map<String, dynamic>, languageCode),
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: ReorderableDragStartListener(
                  index: index,
                  child: Icon(Icons.drag_handle,
                      color: Theme.of(context).colorScheme.primary),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateInput(ApiQuestion question, dynamic answer,
      DataCollectCubit cubit, bool isRequired) {
    return Column(
      children: [
        if (isRequired && answer == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Please select a date',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 14),
            ),
          ),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: answer != null
                    ? DateTime.parse(answer as String)
                    : DateTime.now(),
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
              answer == null
                  ? 'Select Date'
                  : 'Selected: ${answer.toString().substring(0, 10)}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCascade(ApiQuestion question, dynamic answer,
      DataCollectCubit cubit, bool isRequired, String languageCode) {
    final cascades = question.cascades ?? [];
    List<dynamic> currentSelection = (answer is List ? List.from(answer) : []);

    return Column(
      children: [
        if (isRequired && currentSelection.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Please make a selection',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 14),
            ),
          ),
        Expanded(
          child: _buildCascadeTree(cascades, currentSelection, cubit,
              question.id, languageCode, question),
        ),
      ],
    );
  }

  Widget _buildCascadeTree(
      List<dynamic> items,
      List<dynamic> currentSelection,
      DataCollectCubit cubit,
      String questionId,
      String languageCode,
      ApiQuestion question) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final itemId = item['id'];
        final itemName =
            question.getCascadeName(item as Map<String, dynamic>, languageCode);
        final hasChildren =
            item['children'] is List && (item['children'] as List).isNotEmpty;
        final isSelected = currentSelection.contains(itemId);

        return ExpansionTile(
          title: Text(
            itemName,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          leading: !hasChildren
              ? Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(Icons.check,
                          size: 14,
                          color: Theme.of(context).colorScheme.onPrimary)
                      : null,
                )
              : null,
          children: hasChildren
              ? [
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: _buildCascadeTree(
                        item['children'] as List<dynamic>,
                        currentSelection,
                        cubit,
                        questionId,
                        languageCode,
                        question),
                  )
                ]
              : [],
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon with Animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Success Title
              Text(
                'Discussion Completed! 🎉',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Success Message
              Text(
                'You have successfully completed the group discussion with all ${state.selectedGroupRespondents.length} participants.',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Stats Card
              Card(
                elevation: 2,
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
                        Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.group_rounded,
                          '${state.selectedGroupRespondents.length}',
                          'Participants',
                          Theme.of(context).colorScheme.primary,
                        ),
                        _buildStatItem(
                          Icons.question_answer_rounded,
                          '${study.questions.length}',
                          'Questions',
                          Theme.of(context).colorScheme.secondary,
                        ),
                        _buildStatItem(
                          Icons.timer_rounded,
                          'Completed',
                          '100%',
                          Theme.of(context).colorScheme.tertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Finish Discussion',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.done_all_rounded, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      // Option to start new discussion or view results
                    },
                    child: Text(
                      'View Discussion Summary',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
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
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
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
                      onChanged: (value) => context
                          .read<DataCollectCubit>()
                          .updateNewGroupData('name', value),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (value) => context
                          .read<DataCollectCubit>()
                          .updateNewGroupData('description', value),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Homogeneity Group',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => context
                          .read<DataCollectCubit>()
                          .updateNewGroupData('homogeneityGroup', value),
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
                    if (state.newGroupData['name'] != null &&
                        state.newGroupData['name'].toString().isNotEmpty) {
                      context
                          .read<DataCollectCubit>()
                          .createStudyGroup(widget.studyId, state.newGroupData);
                      Navigator.pop(context);
                    } else {
                      ToastService.showErrorToast(
                          message: 'Group name is required');
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
                    Icon(Icons.warning,
                        color: Theme.of(context).colorScheme.error, size: 16),
                    const SizedBox(width: 8),
                    const Text('Age greaterThan 18'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Age is required',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error, fontSize: 12),
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
                ToastService.showSuccessToast(
                    message: 'Respondent created successfully');
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
