import 'package:data4impact/core/service/api_service/Model/api_question.dart';
import 'package:data4impact/core/service/api_service/Model/homogeneity_models.dart';
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.8),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<DataCollectCubit>()
                          .getStudyQuestions(widget.studyId);
                      context
                          .read<DataCollectCubit>()
                          .loadStudyGroups(widget.studyId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.5),
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
          'Select Discussion Group',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08),
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
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
                                  Icons.group_work_rounded,
                                  size: 30,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.study?.name ?? 'Study Groups',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Group Discussion Setup',
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
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Select an existing group or create a new one to start your discussion session',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.8),
                                      height: 1.4,
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
              ),
              Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: state.groups.isEmpty
                    ? _buildEmptyGroupsState()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Available Groups (${state.groups.length})',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${state.groups.length} Groups',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.5,
                              ),
                              child: ListView.separated(
                                physics: const ClampingScrollPhysics(),
                                itemCount: state.groups.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final group = state.groups[index];
                                  return _buildGroupCard(group);
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: state.groups.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                context.read<DataCollectCubit>().showCreateGroupForm();
                _showCreateGroupDialog();
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Group'),
            ),
    );
  }

  Widget _buildEmptyGroupsState() {
    return Container(
      padding: const EdgeInsets.all(40),
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.group_add_rounded,
              size: 50,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Groups Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first discussion group to start collecting data from multiple participants',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context.read<DataCollectCubit>().showCreateGroupForm();
              _showCreateGroupDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  'Create First Group',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.read<DataCollectCubit>().selectGroup(group);
            context
                .read<DataCollectCubit>()
                .loadGroupRespondents(widget.studyId);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.group_rounded,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group['name']?.toString() ?? 'Unnamed Group',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      if (group['description'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          group['description'].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'GO',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRespondentSelectionScreen(DataCollectState state) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Select Respondents',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            context.read<DataCollectCubit>().backToGroupSelection();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.diversity_3_rounded,
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
                                  state.selectedGroup?['name']?.toString() ??
                                      'Group Discussion',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Select Respondents for the discussion',
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
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (state.selectedGroupRespondents.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${state.selectedGroupRespondents.length} participant${state.selectedGroupRespondents.length == 1 ? '' : 's'} selected',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Ready',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: state.groupRespondents.isEmpty
                ? _buildEmptyRespondentsState()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Available Respondents (${state.groupRespondents.length})',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              // Show only one button at a time
                              if (state.selectedGroupRespondents.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    // Deselect all currently selected respondents
                                    for (final respondent
                                        in state.selectedGroupRespondents) {
                                      context
                                          .read<DataCollectCubit>()
                                          .toggleRespondentSelection(
                                              respondent);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      state.selectedGroupRespondents.length ==
                                              state.groupRespondents.length
                                          ? 'Deselect All'
                                          : 'Deselect ${state.selectedGroupRespondents.length}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                GestureDetector(
                                  onTap: () {
                                    // Select all respondents
                                    for (final respondent
                                        in state.groupRespondents) {
                                      context
                                          .read<DataCollectCubit>()
                                          .toggleRespondentSelection(
                                              respondent);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Select All',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: state.groupRespondents.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final respondent = state.groupRespondents[index];
                              final isSelected = state.selectedGroupRespondents
                                  .any((r) => r['_id'] == respondent['_id']);
                              return _buildRespondentCard(
                                  respondent, isSelected, index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          if (state.selectedGroupRespondents.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  context.read<DataCollectCubit>().startGroupDiscussion();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.start_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Start Group Discussion',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: (state.selectedGroupRespondents == null ||
              state.selectedGroupRespondents!.isEmpty)
          ? FloatingActionButton.extended(
              onPressed: _showCreateRespondentDialog,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Add Respondent'),
            )
          : null,
    );
  }

  Widget _buildEmptyRespondentsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 50,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Respondents',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add Respondents to this group to start your discussion session',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRespondentCard(
      Map<String, dynamic> respondent, bool isSelected, int index) {
    return Card(
      elevation: isSelected ? 2 : 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    Theme.of(context).colorScheme.primary.withOpacity(0.02),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: CheckboxListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            respondent['name']?.toString() ?? 'Unnamed Participant',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              if (respondent['code'] != null)
                _buildRespondentDetail('ID', respondent['code'] as String),
              if (respondent['age'] != null)
                _buildRespondentDetail('Age', respondent['age'] as String),
              if (respondent['gender'] != null)
                _buildRespondentDetail(
                    'Gender', respondent['gender'] as String),
            ],
          ),
          value: isSelected,
          onChanged: (value) {
            context
                .read<DataCollectCubit>()
                .toggleRespondentSelection(respondent);
          },
          secondary: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.surfaceVariant,
                        Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(0.7),
                      ],
                    ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          activeColor: Theme.of(context).colorScheme.primary,
          checkColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildRespondentDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
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

    // Check if all respondents are completed - show completion screen
    if (state.currentRespondentIndex >= state.selectedGroupRespondents.length) {
      return _buildCompletionScreen(study, state);
    }

    if (state.jumpTarget == 'end') {
      return _buildCompletionScreen(study, state);
    }

    // If we've gone beyond the questions, move to next respondent
    if (currentQuestionIndex >= study.questions.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<DataCollectCubit>()
            .nextRespondentInGroup(studyId: widget.studyId);
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
              _buildProgressSection(state, study, currentQuestionIndex),
              const SizedBox(height: 24),
              _buildParticipantInfoCard(state, currentRespondent),
              const SizedBox(height: 24),
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
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
                                          question
                                              .getTitle(state.selectedLanguage),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                      if (question.required)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error
                                                .withOpacity(0.1),
                                            borderRadius:
                                            BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Required',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (question.getSubtitle(
                                      state.selectedLanguage) !=
                                      null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      question
                                          .getSubtitle(state.selectedLanguage)!,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
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
              _buildNavigationButtons(state, study, currentQuestionIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
      DataCollectState state, Study study, int currentQuestionIndex) {
    final cubit = context.read<DataCollectCubit>();
    final question = study.questions[currentQuestionIndex];

    return Row(
      children: [
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
        Expanded(
          child: ElevatedButton(
            onPressed: cubit.canProceed(question)
                ? () {
              // For group discussions on last question, move to next respondent
              if (state.selectedGroupRespondents.isNotEmpty &&
                  currentQuestionIndex == study.questions.length - 1) {
                cubit.nextRespondentInGroup(studyId: widget.studyId);
              } else {
                cubit.nextQuestion(studyId: widget.studyId);
              }
            }
                : null,
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
              shadowColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getButtonText(state, study, currentQuestionIndex),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _getButtonIcon(state, study, currentQuestionIndex),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getButtonText(DataCollectState state, Study study, int currentQuestionIndex) {
    if (state.selectedGroupRespondents.isNotEmpty) {
      if (currentQuestionIndex == study.questions.length - 1) {
        if (state.currentRespondentIndex < state.selectedGroupRespondents.length - 1) {
          return 'Next Participant';
        } else {
          return 'Finish';
        }
      }
    }
    return 'Next Question';
  }

  IconData _getButtonIcon(DataCollectState state, Study study, int currentQuestionIndex) {
    if (state.selectedGroupRespondents.isNotEmpty) {
      if (currentQuestionIndex == study.questions.length - 1) {
        if (state.currentRespondentIndex < state.selectedGroupRespondents.length - 1) {
          return Icons.person_rounded;
        } else {
          return Icons.done_all_rounded;
        }
      }
    }
    return Icons.arrow_forward_rounded;
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
                  // The transition is automatic, but this button can be used to proceed immediately
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
              Text(
                'Group Discussion Completed! 🎉',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
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
                          Icons.check_circle_rounded,
                          '${state.storedGroupResponses.length}',
                          'Responses',
                          Theme.of(context).colorScheme.tertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Submit all responses
                      context.read<DataCollectCubit>().submitSurvey(studyId: widget.studyId);
                    },
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
                          'Submit All Responses',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.send_rounded, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      _showResponseSummary(state, study);
                    },
                    child: Text(
                      'Review Responses',
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

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
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

  Widget _buildProgressSection(
      DataCollectState state, Study study, int currentQuestionIndex) {
    return Column(
      children: [
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
        LinearProgressIndicator(
          value: (state.currentRespondentIndex + 1) /
              state.selectedGroupRespondents.length,
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

  Widget _buildParticipantInfoCard(
      DataCollectState state, dynamic currentRespondent) {
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
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.selectedGroup?['name'] as String? ??
                          'Unnamed Group',
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
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
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
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
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
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
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

  Widget _buildQuestionInput(ApiQuestion question, DataCollectState state) {
    final cubit = context.read<DataCollectCubit>();
    final answer = state.answers[question.id];
    final isRequiredByLogic = state.requiredQuestions.contains(question.id);
    final isActuallyRequired = question.required || isRequiredByLogic;

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
          maxLines: null,
          minLines: 8,
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


  void _showResponseSummary(DataCollectState state, Study study) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Response Summary'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: state.selectedGroupRespondents.length,
            itemBuilder: (context, index) {
              final respondent = state.selectedGroupRespondents[index];
              final respondentId = respondent['_id'];
              final responses = state.storedGroupResponses[respondentId] ?? {};
              final completedQuestions = responses.length;

              return ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(respondent['name']  as String ?? 'Unknown'),
                subtitle: Text('$completedQuestions/${study.questions.length} questions answered'),
                trailing: completedQuestions == study.questions.length
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.warning, color: Colors.orange),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }


  void _showCreateGroupDialog() {
    final currentState = context.read<DataCollectCubit>().state;
    final study = currentState.study;

    if (study == null) {
      ToastService.showErrorToast(message: 'Study data not loaded yet');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<DataCollectCubit, DataCollectState>(
          builder: (context, state) {
            final homogeneityGroups = study.homogeneityGroups;

            return Dialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
              insetPadding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.group_add_rounded,
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
                                    'Create New Group',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Set up a new discussion group',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Group Name',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: TextField(
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      hintText: 'Enter group name...',
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      hintStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.4),
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 16,
                                    ),
                                    onChanged: (value) => context
                                        .read<DataCollectCubit>()
                                        .updateNewGroupData('name', value),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Required field',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Optional group description...',
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      hintStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.4),
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 16,
                                    ),
                                    maxLines: 3,
                                    minLines: 2,
                                    onChanged: (value) => context
                                        .read<DataCollectCubit>()
                                        .updateNewGroupData(
                                            'description', value),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Describe the purpose or characteristics of this group',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Homogeneity Group',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Optional',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.5),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: DropdownButtonFormField<String?>(
                                    value:
                                        state.newGroupData['homogeneityGroup']
                                            as String?,
                                    items: [
                                      DropdownMenuItem<String?>(
                                        value: null,
                                        child: Text(
                                          'Select homogeneity group...',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                      ...homogeneityGroups.map((group) {
                                        final groupId = group.id as String?;
                                        final groupName =
                                            group.name as String? ??
                                                'Unnamed Group';

                                        return DropdownMenuItem<String?>(
                                          value: groupId,
                                          child: Text(groupName),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (value) => context
                                        .read<DataCollectCubit>()
                                        .updateNewGroupData(
                                            'homogeneityGroup', value),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                    isExpanded: true,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${homogeneityGroups.length} group(s) available',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  context
                                      .read<DataCollectCubit>()
                                      .cancelCreateGroup();
                                  Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onSurface,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.4),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (state.newGroupData['name'] != null &&
                                      state.newGroupData['name']
                                          .toString()
                                          .isNotEmpty) {
                                    context
                                        .read<DataCollectCubit>()
                                        .createStudyGroup(
                                            widget.studyId, state.newGroupData);
                                    Navigator.pop(context);
                                  } else {
                                    ToastService.showErrorToast(
                                        message: 'Group name is required');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.group_add_rounded, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Create Group',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateRespondentDialog() {
    final state = context.read<DataCollectCubit>().state;

    if (state.study == null || state.selectedGroup == null) {
      ToastService.showErrorToast(message: 'Please wait while data loads');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute<Widget>(
        builder: (context) => CreateRespondentScreen(
          studyId: widget.studyId,
          study: state.study!,
          selectedGroup: state.selectedGroup!,
        ),
      ),
    ).then((shouldRefresh) {
      if (shouldRefresh == true) {
        context.read<DataCollectCubit>().loadGroupRespondents(widget.studyId);
      }
    });
  }
}

class CreateRespondentScreen extends StatefulWidget {
  final String studyId;
  final Study study;
  final Map<String, dynamic> selectedGroup;

  const CreateRespondentScreen({
    super.key,
    required this.studyId,
    required this.study,
    required this.selectedGroup,
  });

  @override
  State<CreateRespondentScreen> createState() => _CreateRespondentScreenState();
}

class _CreateRespondentScreenState extends State<CreateRespondentScreen> {
  final Map<String, TextEditingController> _respondentFieldControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeRespondentCreation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<DataCollectCubit>().state;
      final initialCode = _generateRespondentCode(state);
      context
          .read<DataCollectCubit>()
          .updateNewRespondentData('code', initialCode);

      // Also update the controller if it exists
      final controller = _respondentFieldControllers['code'];
      if (controller != null) {
        controller.text = initialCode;
      }
    });
  }

  void _initializeRespondentCreation() {
    final cubit = context.read<DataCollectCubit>();
    cubit.startCreateRespondentFlow();
  }

  @override
  void dispose() {
    _respondentFieldControllers.values
        .forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataCollectCubit, DataCollectState>(
      builder: (context, state) {
        final study = widget.study;
        final selectedGroup = widget.selectedGroup;
        final homogeneityFields = study.homogeneity?.fields ?? [];

        final selectedHomogeneityGroup =
            selectedGroup['homogeneityGroup'] != null
                ? study.homogeneity?.groups?.firstWhere(
                    (group) => group.id == selectedGroup['homogeneityGroup'],
                    orElse: () => HomogeneityGroup(
                      id: '',
                      name: '',
                      criteria: [],
                      description: '',
                    ),
                  )
                : null;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text(
              'Create New Respondent',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.08),
                                  Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.person_add_rounded,
                                          size: 30,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Add New Participant',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Create a new respondent for ${selectedGroup['name']}',
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
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Basic Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Respondent Name *',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Enter respondent name...',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.4),
                                  ),
                                ),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 16,
                                ),
                                onChanged: (value) {
                                  context
                                      .read<DataCollectCubit>()
                                      .updateNewRespondentData('name', value);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Respondent Code *',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: TextField(
                                enabled: false,
                                controller: _getCodeController(state),
                                decoration: InputDecoration(
                                  hintText: 'Enter respondent code...',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.4),
                                  ),
                                ),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 16,
                                ),
                                onChanged: (value) {
                                  context
                                      .read<DataCollectCubit>()
                                      .updateNewRespondentData('code', value);
                                },
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.autorenew_rounded,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
                                  'Group Information',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Group: ${selectedGroup['name']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.8),
                                  ),
                                ),
                                if (selectedHomogeneityGroup != null &&
                                    selectedHomogeneityGroup.id.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Homogeneity: ${selectedHomogeneityGroup.name}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (selectedHomogeneityGroup != null &&
                            selectedHomogeneityGroup.id.isNotEmpty) ...[
                          Text(
                            'Group Criteria Validation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.warning_rounded,
                                        size: 16,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Must meet group criteria:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ..._buildCriteriaList(
                                      selectedHomogeneityGroup),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (homogeneityFields.isNotEmpty) ...[
                          Text(
                            'Custom Fields',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._buildDynamicFields(state, homogeneityFields,
                              selectedHomogeneityGroup),
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _validateRespondentFormSilent(
                                    state, selectedHomogeneityGroup)
                                ? () {
                                    if (_validateRespondentForm(
                                        state, selectedHomogeneityGroup)) {
                                      _createRespondent(state, selectedGroup);
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _validateRespondentFormSilent(
                                      state, selectedHomogeneityGroup)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                              foregroundColor: _validateRespondentFormSilent(
                                      state, selectedHomogeneityGroup)
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.4),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: state.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ))
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_add_rounded, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Create Respondent',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: state.isLoading
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onSurface,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.4),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  TextEditingController _getCodeController(DataCollectState state) {
    return _respondentFieldControllers.putIfAbsent('code', () {
      final currentCode = state.newRespondentData['code']?.toString() ??
          _generateRespondentCode(state);
      return TextEditingController(text: currentCode);
    });
  }

  List<Widget> _buildDynamicFields(
    DataCollectState state,
    List<HomogeneityField> fields,
    HomogeneityGroup? homogeneityGroup,
  ) {
    final criteriaFields = homogeneityGroup != null
        ? homogeneityGroup.criteria.map((c) => c.field.id).toList()
        : [];

    return fields.map((field) {
      final fieldId = field.id;
      final fieldName = field.name;
      final fieldType = field.type;
      final isRequired = criteriaFields.contains(fieldId);

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  fieldName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (isRequired) ...[
                  const SizedBox(width: 6),
                  Text(
                    '*',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            _buildFieldInput(field, isRequired, state),
            if (isRequired) ...[
              const SizedBox(height: 4),
              _buildFieldValidation(field, state, homogeneityGroup),
            ],
          ],
        ),
      );
    }).toList();
  }

  Widget _buildFieldInput(
      HomogeneityField field, bool isRequired, DataCollectState state) {
    final fieldId = field.id;
    final fieldType = field.type;
    final options = field.options;

    final currentValue = state.newRespondentData[fieldId]?.toString() ?? '';

    // Get or create controller for this field
    final controller = _respondentFieldControllers.putIfAbsent(
        fieldId, () => TextEditingController(text: currentValue));

    // Update controller value if it doesn't match the current state
    if (controller.text != currentValue) {
      controller.text = currentValue;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child:
          _buildFieldByType(field, fieldType, isRequired, controller, options),
    );
  }

  Widget _buildFieldByType(
    HomogeneityField field,
    String fieldType,
    bool isRequired,
    TextEditingController controller,
    List<String> options,
  ) {
    final fieldId = field.id;

    switch (fieldType) {
      case 'text':
        return TextField(
          controller: controller,
          decoration: _buildInputDecoration(field, isRequired, controller.text),
          onChanged: (value) {
            context
                .read<DataCollectCubit>()
                .updateNewRespondentData(fieldId, value);
          },
        );

      case 'number':
        return TextField(
          controller: controller,
          decoration: _buildInputDecoration(field, isRequired, controller.text),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            context
                .read<DataCollectCubit>()
                .updateNewRespondentData(fieldId, value);
          },
        );

      case 'select':
        return DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? null : controller.text,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Select...'),
            ),
            ...options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
          ],
          onChanged: (value) {
            controller.text = value ?? '';
            context
                .read<DataCollectCubit>()
                .updateNewRespondentData(fieldId, value);
          },
          decoration: _buildInputDecoration(field, isRequired, controller.text),
        );

      case 'date':
        return TextField(
          controller: controller,
          decoration: _buildInputDecoration(field, isRequired, controller.text)
              .copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                Icons.calendar_today_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  final dateString =
                      selectedDate.toIso8601String().split('T')[0];
                  controller.text = dateString;
                  context
                      .read<DataCollectCubit>()
                      .updateNewRespondentData(fieldId, dateString);
                }
              },
            ),
          ),
          readOnly: true,
        );

      case 'boolean':
        final boolValue = controller.text == 'true';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Switch(
                value: boolValue,
                onChanged: (value) {
                  controller.text = value.toString();
                  context
                      .read<DataCollectCubit>()
                      .updateNewRespondentData(fieldId, value);
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                field.name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );

      default:
        return TextField(
          controller: controller,
          decoration: _buildInputDecoration(field, isRequired, controller.text),
          onChanged: (value) {
            context
                .read<DataCollectCubit>()
                .updateNewRespondentData(fieldId, value);
          },
        );
    }
  }

  InputDecoration _buildInputDecoration(
      HomogeneityField field, bool isRequired, String currentValue) {
    return InputDecoration(
      hintText: 'Enter ${field.name}...',
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      errorText:
          isRequired && currentValue.isEmpty ? 'This field is required' : null,
    );
  }

  Widget _buildFieldValidation(HomogeneityField field, DataCollectState state,
      HomogeneityGroup? homogeneityGroup) {
    final fieldId = field.id;
    final fieldValue = state.newRespondentData[fieldId];

    if (homogeneityGroup == null) return const SizedBox();

    try {
      final criterion = homogeneityGroup.criteria.firstWhere(
        (c) => c.field.id == fieldId,
      );

      final operator = criterion.operator;
      final expectedValue = criterion.value;

      bool isValid =
          _validateCriterion(field, fieldValue, operator, expectedValue);

      return Row(
        children: [
          Icon(
            isValid ? Icons.check_circle_rounded : Icons.error_rounded,
            size: 14,
            color: isValid
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 4),
          Text(
            isValid ? 'Meets criteria' : 'Does not meet criteria',
            style: TextStyle(
              fontSize: 12,
              color: isValid
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      );
    } catch (e) {
      return const SizedBox();
    }
  }

  String _generateRespondentCode(DataCollectState state) {
    final selectedGroup = widget.selectedGroup;

    String groupPrefix = 'NEW';
    if (selectedGroup['name'] != null) {
      final groupName = selectedGroup['name'] as String;
      groupPrefix = groupName.length >= 3
          ? groupName.substring(0, 3).toUpperCase()
          : groupName.toUpperCase().padRight(3, 'X');
    }

    final existingRespondents =
        (selectedGroup['respondents'] as List<dynamic>?) ?? [];

    int highestNumber = 0;
    final codePattern = RegExp('^$groupPrefix-(\\d+)\$');

    for (final respondent in existingRespondents) {
      final existingCode = respondent['code']?.toString();

      if (existingCode != null && existingCode.isNotEmpty) {
        final match = codePattern.firstMatch(existingCode);

        if (match != null) {
          final numberStr = match.group(1) ?? '0';
          final number = int.tryParse(numberStr) ?? 0;

          if (number > highestNumber) {
            highestNumber = number;
          }
        } else {}
      } else {}
    }

    // Generate next sequential code
    final newCode =
        '$groupPrefix-${(highestNumber + 1).toString().padLeft(2, '0')}';

    return newCode;
  }

  List<Widget> _buildCriteriaList(HomogeneityGroup homogeneityGroup) {
    final criteria = homogeneityGroup.criteria;
    return criteria.map((criterion) {
      final field = criterion.field;
      final operator = criterion.operator;
      final value = criterion.value;

      String operatorText = '';
      switch (operator) {
        case 'equals':
          operatorText = '=';
          break;
        case 'doesNotEqual':
          operatorText = '≠';
          break;
        case 'greaterThan':
          operatorText = '>';
          break;
        case 'lessThan':
          operatorText = '<';
          break;
        case 'greaterThanOrEqual':
          operatorText = '≥';
          break;
        case 'lessThanOrEqual':
          operatorText = '≤';
          break;
        default:
          operatorText = operator;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          '• ${field.name} $operatorText $value',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      );
    }).toList();
  }

  bool _validateCriterion(
    HomogeneityField field,
    dynamic actualValue,
    String operator,
    String expectedValue,
  ) {
    if (actualValue == null || actualValue.toString().isEmpty) {
      return false;
    }

    final fieldType = field.type;

    switch (fieldType) {
      case 'number':
        final actualNum = double.tryParse(actualValue.toString());
        final expectedNum = double.tryParse(expectedValue);

        if (actualNum == null || expectedNum == null) return false;

        switch (operator) {
          case 'equals':
            return actualNum == expectedNum;
          case 'doesNotEqual':
            return actualNum != expectedNum;
          case 'greaterThan':
            return actualNum > expectedNum;
          case 'lessThan':
            return actualNum < expectedNum;
          case 'greaterThanOrEqual':
            return actualNum >= expectedNum;
          case 'lessThanOrEqual':
            return actualNum <= expectedNum;
          default:
            return false;
        }

      case 'select':
      case 'text':
        switch (operator) {
          case 'equals':
            return actualValue.toString() == expectedValue;
          case 'doesNotEqual':
            return actualValue.toString() != expectedValue;
          case 'contains':
            return actualValue.toString().contains(expectedValue);
          case 'doesNotContain':
            return !actualValue.toString().contains(expectedValue);
          default:
            return false;
        }

      case 'boolean':
        final actualBool = actualValue is bool
            ? actualValue
            : actualValue.toString() == 'true';
        final expectedBool = expectedValue == 'true';

        switch (operator) {
          case 'equals':
            return actualBool == expectedBool;
          case 'doesNotEqual':
            return actualBool != expectedBool;
          default:
            return false;
        }

      default:
        return actualValue.toString().isNotEmpty;
    }
  }

  bool _validateRespondentFormSilent(
      DataCollectState state, HomogeneityGroup? homogeneityGroup) {
    final respondentName = state.newRespondentData['name'];

    if (respondentName == null || respondentName.toString().isEmpty) {
      return false;
    }

    if (homogeneityGroup != null) {
      final criteria = homogeneityGroup.criteria;

      for (final criterion in criteria) {
        final field = criterion.field;
        final fieldId = field.id;
        final fieldValue = state.newRespondentData[fieldId];
        final operator = criterion.operator;
        final expectedValue = criterion.value;

        if (!_validateCriterion(field, fieldValue, operator, expectedValue)) {
          return false;
        }
      }
    }

    return true;
  }

  bool _validateRespondentForm(
      DataCollectState state, HomogeneityGroup? homogeneityGroup) {
    final respondentName = state.newRespondentData['name'];

    if (respondentName == null || respondentName.toString().isEmpty) {
      ToastService.showErrorToast(message: 'Respondent name is required');
      return false;
    }

    if (homogeneityGroup != null) {
      final criteria = homogeneityGroup.criteria;

      for (final criterion in criteria) {
        final field = criterion.field;
        final fieldId = field.id;
        final fieldValue = state.newRespondentData[fieldId];
        final operator = criterion.operator;
        final expectedValue = criterion.value;

        if (!_validateCriterion(field, fieldValue, operator, expectedValue)) {
          ToastService.showErrorToast(
              message: '${field.name} does not meet group criteria');
          return false;
        }
      }
    }

    return true;
  }

  void _createRespondent(
      DataCollectState state, Map<String, dynamic> selectedGroup) async {
    final cubit = context.read<DataCollectCubit>();
    final respondentData = Map<String, dynamic>.from(state.newRespondentData);

    // Validate required fields
    if (respondentData['name'] == null ||
        respondentData['name'].toString().isEmpty) {
      ToastService.showErrorToast(message: 'Respondent name is required');
      return;
    }

    // Ensure code is set - use current value or generate new one
    if (respondentData['code'] == null ||
        respondentData['code'].toString().isEmpty) {
      respondentData['code'] = _generateRespondentCode(state);
    }

    respondentData['group'] = selectedGroup['_id'];

    try {
      print('debug: _createRespondent - calling cubit.createRespondent');
      await cubit.createRespondent(widget.studyId, respondentData);

      print('debug: _createRespondent - success, clearing controllers');

      // Clear all text controllers
      _respondentFieldControllers.forEach((key, controller) {
        controller.clear();
      });
      _respondentFieldControllers.clear();

      print('debug: _createRespondent - refreshing data and navigating back');

      // Refresh the data before navigating back
      await cubit.refreshGroupData(widget.studyId);

      // Then navigate back
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('debug: _createRespondent - error: $e');
      // Error handling
      ToastService.showErrorToast(message: 'Failed to create respondent: $e');
      // Don't pop on error
    }
  }
}
