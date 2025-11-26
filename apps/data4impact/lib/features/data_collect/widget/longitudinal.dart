import 'package:data4impact/core/service/api_service/Model/api_question.dart';
import 'package:data4impact/core/service/api_service/Model/study.dart';
import 'package:data4impact/core/service/dialog_loading.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/data_collect/cubit/data_collet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/data_collect_cubit.dart';

class LongitudinalDataCollection extends StatefulWidget {
  final String studyId;

  const LongitudinalDataCollection({super.key, required this.studyId});

  @override
  State<LongitudinalDataCollection> createState() =>
      _LongitudinalDataCollectionState();
}

class _LongitudinalDataCollectionState
    extends State<LongitudinalDataCollection> {
  final Map<String, TextEditingController> _textControllers = {};
  String? _previousError;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<DataCollectCubit>();
    cubit.startLongitudinalFlow();
    cubit.getStudyQuestions(widget.studyId);
    cubit.loadStudyCohorts(widget.studyId);
  }

  @override
  void dispose() {
    _textControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not scheduled';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
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
          if (state.isManagingSubjects) {
          } else {
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
        if (state.isLoading || (state.study == null && state.cohorts.isEmpty)) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.error != null &&
            state.study == null &&
            state.cohorts.isEmpty) {
          return _buildErrorScreen(state.error!);
        }

        if (state.study == null && state.cohorts.isNotEmpty) {
          return _buildCohortSelectionScreen(state);
        }

        if (state.study == null) {
          return _buildErrorScreen('No study data available');
        }

        final study = state.study!;

        if (state.isManagingCohorts || state.selectedCohort == null) {
          return _buildCohortSelectionScreen(state);
        }

        if (state.isManagingWaves || state.selectedWave == null) {
          return _buildWaveSelectionScreen(state);
        }

        if (state.isManagingSubjects || state.selectedSubject == null) {
          return _buildSubjectSelectionScreen(state);
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
                  context
                      .read<DataCollectCubit>()
                      .loadStudyCohorts(widget.studyId);
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

  Widget _buildCohortSelectionScreen(DataCollectState state) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Select Cohort',
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
                              Icons.psychology_rounded,
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
                                  'Longitudinal Leadership Study',
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
                                'Select a cohort to begin data collection',
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

            // Cohorts Grid
            Expanded(
              child: state.cohorts.isEmpty
                  ? Center(
                      child: state.isLoading
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 20),
                                Text(
                                  'Loading cohorts...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            )
                          : Column(
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
                                  'No Cohorts Available',
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
                                  'Contact the study administrator\\nto create cohorts',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: state.cohorts.length,
                      itemBuilder: (context, index) {
                        final cohort = state.cohorts[index];
                        final isActive = cohort['isActive'] ?? true;
                        final environment =
                            cohort['environment']?.toString().toLowerCase() ??
                                'control';

                        return _buildCohortCard(cohort, index, isActive as bool,
                            environment, widget.studyId);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCohortCard(Map<String, dynamic> cohort, int index, bool isActive,
      String environment, String studyId) {
    // Define colors based on environment
    final Color primaryColor;
    final String environmentLabel;

    switch (environment) {
      case 'treatment':
        primaryColor = Colors.green;
        environmentLabel = 'Treatment';
        break;
      case 'intervention':
        primaryColor = Colors.orange;
        environmentLabel = 'Intervention';
        break;
      default:
        primaryColor = Theme.of(context).colorScheme.primary;
        environmentLabel = 'Control';
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? primaryColor.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1.5,
        ),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isActive
              ? () {
                  context
                      .read<DataCollectCubit>()
                      .selectCohortAndShowWaves(cohort);
                  context.read<DataCollectCubit>().loadStudySubjects(studyId);
                  context
                      .read<DataCollectCubit>()
                      .loadStudyWaves(widget.studyId);
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cohort Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isActive
                            ? primaryColor.withOpacity(0.12)
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.group_rounded,
                          size: 20,
                          color: isActive
                              ? primaryColor
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isActive
                            ? primaryColor.withOpacity(0.12)
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isActive
                              ? primaryColor.withOpacity(0.3)
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        environmentLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? primaryColor
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cohort Name
                Text(
                  cohort['name']?.toString() ?? 'Cohort ${index + 1}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Cohort Description
                if (cohort['description'] != null &&
                    cohort['description'].toString().isNotEmpty)
                  Text(
                    cohort['description'].toString(),
                    style: TextStyle(
                      fontSize: 13,
                      color: isActive
                          ? Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7)
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 16),

                // Cohort Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (cohort['sampleSize'] != null)
                        _buildCohortDetail(
                          Icons.people_rounded,
                          '${cohort['sampleSize']} Participants',
                          isActive,
                        ),
                      if (cohort['recruitmentStartDate'] != null)
                        _buildCohortDetail(
                          Icons.calendar_today_rounded,
                          'Started ${_formatDate(cohort['recruitmentStartDate'] as String)}',
                          isActive,
                        ),
                      const SizedBox(height: 16),

                      // Select Button
                      Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isActive
                              ? primaryColor
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: isActive
                              ? null
                              : Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.1),
                                  width: 1,
                                ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Select Cohort',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? Colors.white
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.5),
                                ),
                              ),
                              if (isActive) ...[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ],
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
    );
  }

  Widget _buildCohortDetail(IconData icon, String text, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 12,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                color: isActive
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveSelectionScreen(DataCollectState state) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Select Wave',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        forceMaterialTransparency: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            context.read<DataCollectCubit>().backToCohortSelection();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1.2,
                ),
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Icon Container
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.assessment_rounded,
                        size: 28,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cohort Name
                          Text(
                            state.selectedCohort?['name']?.toString() ??
                                'Selected Cohort',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Instruction Text
                          Text(
                            'Choose a wave to continue data collection',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Environment Badge
                          if (state.selectedCohort?['environment'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Environment: ${state.selectedCohort!['environment']}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Chevron icon
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Waves Grid
            Expanded(
              child: state.waves.isEmpty
                  ? Center(
                      child: state.isLoading
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 20),
                                Text(
                                  'Loading waves...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.waves_rounded,
                                  size: 80,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.2),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'No Waves Available',
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
                                  'Contact the study administrator\nto create waves for this cohort',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: state.waves.length,
                      itemBuilder: (context, index) {
                        final wave = state.waves[index];
                        final isActive = wave['isActive'] ?? true;

                        return _buildWaveCard(wave, index, isActive as bool);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveCard(Map<String, dynamic> wave, int index, bool isActive) {
    final responsesCount = wave['responsesCount'] as int? ?? 0;
    final state = context.read<DataCollectCubit>().state;
    final allStudySubjects = state.subjects;
    final totalSubjectsCount = allStudySubjects.length;

    final bool allSubjectsResponded =
        totalSubjectsCount > 0 && responsesCount >= totalSubjectsCount;

    final bool isSelectable = isActive && !allSubjectsResponded;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: allSubjectsResponded
              ? Colors.green
              : isActive
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wave Number and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: allSubjectsResponded
                            ? Colors.green.withOpacity(0.15)
                            : isActive
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.15)
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: allSubjectsResponded
                            ? Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: Colors.green,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isActive
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.5),
                                ),
                              ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: allSubjectsResponded
                                ? Colors.green.withOpacity(0.1)
                                : isActive
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1)
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            allSubjectsResponded
                                ? 'Completed'
                                : isActive
                                    ? 'Active'
                                    : 'Inactive',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: allSubjectsResponded
                                  ? Colors.green
                                  : isActive
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.5),
                            ),
                          ),
                        ),
                        if (totalSubjectsCount > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            allSubjectsResponded
                                ? 'All $totalSubjectsCount responded'
                                : '$responsesCount/$totalSubjectsCount responded',
                            style: TextStyle(
                              fontSize: 10,
                              color: allSubjectsResponded
                                  ? Colors.green
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Wave Name
                Text(
                  wave['name']?.toString() ?? 'Wave ${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: allSubjectsResponded
                        ? Colors.green
                        : isActive
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Wave Description
                if (wave['description'] != null &&
                    wave['description'].toString().isNotEmpty)
                  Text(
                    wave['description'].toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: allSubjectsResponded
                          ? Colors.green.withOpacity(0.7)
                          : isActive
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7)
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 12),

                // Wave Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (wave['scheduledDate'] != null)
                        _buildWaveDetail(
                          Icons.calendar_today_rounded,
                          'Scheduled: ${_formatDate(wave['scheduledDate'] as String)}',
                          isSelectable,
                          isCompleted: allSubjectsResponded,
                        ),
                      if (totalSubjectsCount > 0)
                        _buildWaveDetail(
                          Icons.people_rounded,
                          '$totalSubjectsCount Total Subject(s)',
                          isSelectable,
                          isCompleted: allSubjectsResponded,
                        ),
                      const SizedBox(height: 12),

                      // Select Button
                      InkWell(
                        onTap: isSelectable
                            ? () {
                                context
                                    .read<DataCollectCubit>()
                                    .selectWave(wave);
                                context
                                    .read<DataCollectCubit>()
                                    .loadStudySubjects(widget.studyId);
                              }
                            : allSubjectsResponded
                                ? () {
                                    ToastService.showInfoToast(
                                      message:
                                          'All respondents have already responded to this wave',
                                    );
                                  }
                                : null,
                        child: Container(
                          width: double.infinity,
                          height: 36,
                          decoration: BoxDecoration(
                            color: allSubjectsResponded
                                ? Colors.green
                                : isSelectable
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              allSubjectsResponded
                                  ? 'Completed'
                                  : 'Select Wave',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: allSubjectsResponded || isSelectable
                                    ? Colors.white
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.4),
                              ),
                            ),
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
    );
  }

  Widget _buildWaveDetail(IconData icon, String text, bool isSelectable,
      {bool isCompleted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 12,
            color: isCompleted
                ? Colors.green
                : isSelectable
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                color: isCompleted
                    ? Colors.green.withOpacity(0.8)
                    : isSelectable
                        ? Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7)
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSelectionScreen(DataCollectState state) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Select Subject',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        forceMaterialTransparency: true,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<DataCollectCubit>().backToWaveSelection();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Wave Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.waves),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.selectedWave?['name']?.toString() ??
                                'Selected Wave',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cohort: ${state.selectedCohort?['name']}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (state.selectedWave?['scheduledDate'] != null)
                            Text(
                              'Scheduled: ${_formatDate(state.selectedWave?['scheduledDate'] as String)}',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            'Select a subject for data collection',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          // Add wave response count info
                          if (state.selectedWave?['responsesCount'] !=
                              null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${state.selectedWave?['responsesCount']} responses collected',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
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
            const SizedBox(height: 16),

            // Subjects List
            Expanded(
              child: state.subjects.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Subjects Available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please contact the study administrator',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: state.subjects.length,
                      itemBuilder: (context, index) {
                        final subject = state.subjects[index];
                        final attributes =
                            subject['attributes'] as Map<String, dynamic>? ??
                                {};

                        final selectedWave = state.selectedWave;
                        final subjects = state.subjects[index];
                        final waveSubjectIds = List<String>.from(
                            selectedWave!['subjects'] as List);

                        final isSubjectCompleted =
                            waveSubjectIds.contains(subject['_id']);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: isSubjectCompleted ? 2 : 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSubjectCompleted
                                  ? Colors.green
                                  : Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withOpacity(0.3),
                              width: isSubjectCompleted ? 2 : 1,
                            ),
                          ),
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: isSubjectCompleted
                                    ? Colors.green.withOpacity(0.03)
                                    : null,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isSubjectCompleted
                                      ? Colors.green.withOpacity(0.1)
                                      : Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1),
                                  foregroundColor: isSubjectCompleted
                                      ? Colors.green
                                      : Theme.of(context).colorScheme.primary,
                                  radius: 20,
                                  child: isSubjectCompleted
                                      ? const Icon(Icons.check, size: 16)
                                      : Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        subject['name']?.toString() ??
                                            'Subject ${index + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: isSubjectCompleted
                                              ? Colors.green
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                        ),
                                      ),
                                    ),
                                    if (isSubjectCompleted) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color:
                                                Colors.green.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.check_circle,
                                              size: 12,
                                              color: Colors.green,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Completed',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    if (attributes['Participant ID'] != null)
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              120,
                                        ),
                                        child: Text(
                                          'ID: ${attributes['Participant ID']}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isSubjectCompleted
                                                ? Colors.green.withOpacity(0.8)
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                    if (attributes['Age'] != null) ...[
                                      const SizedBox(height: 2),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              120,
                                        ),
                                        child: Text(
                                          'Age: ${attributes['Age']}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isSubjectCompleted
                                                ? Colors.green.withOpacity(0.8)
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (attributes['Gender'] != null) ...[
                                      const SizedBox(height: 2),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              120,
                                        ),
                                        child: Text(
                                          'Gender: ${attributes['Gender']}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isSubjectCompleted
                                                ? Colors.green.withOpacity(0.8)
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (attributes['Position / Title'] !=
                                        null) ...[
                                      const SizedBox(height: 2),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              120,
                                        ),
                                        child: Text(
                                          'Position: ${attributes['Position / Title']}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isSubjectCompleted
                                                ? Colors.green.withOpacity(0.8)
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isSmallScreen =
                                        constraints.maxWidth < 400;

                                    return isSubjectCompleted
                                        ? ElevatedButton(
                                            onPressed: () {
                                              final subjectName =
                                                  subject['name']?.toString() ??
                                                      'This subject';
                                              ToastService.showInfoToast(
                                                message:
                                                    '$subjectName has already responded to this wave',
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    isSmallScreen ? 12 : 16,
                                                vertical: 8,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              elevation: 0,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            child: Text(
                                              isSmallScreen
                                                  ? 'Done'
                                                  : 'Completed',
                                              style: TextStyle(
                                                fontSize:
                                                    isSmallScreen ? 12 : 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          )
                                        : ElevatedButton(
                                            onPressed: () {
                                              context
                                                  .read<DataCollectCubit>()
                                                  .selectSubject(subject);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              foregroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    isSmallScreen ? 12 : 16,
                                                vertical: 8,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              elevation: 0,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            child: Text(
                                              'Select',
                                              style: TextStyle(
                                                fontSize:
                                                    isSmallScreen ? 12 : 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          );
                                  },
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              )),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsScreen(DataCollectState state, Study study) {
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
            icon: const Icon(Icons.person),
            onPressed: () {
              context.read<DataCollectCubit>().backToSubjectSelection();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress bar
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

            // Study context info card
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
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: const Icon(Icons.person),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.selectedSubject?['name']?.toString() ??
                                    'Selected Subject',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Cohort: ${state.selectedCohort?['name']} • Wave: ${state.selectedWave?['name']}',
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
                    const SizedBox(height: 8),
                    // Add study info
                    Text(
                      'Longitudinal Leadership Study',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
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
                // Back to subjects button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<DataCollectCubit>().backToSubjectSelection();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceVariant,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                    child: const Text('Back to Subjects'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        context.read<DataCollectCubit>().canProceed(question)
                            ? () {
                                if (currentQuestionIndex ==
                                    study.questions.length - 1) {
                                  context.read<DataCollectCubit>().submitSurvey(
                                      studyId: widget.studyId,
                                      flowType: 'longitudinal');
                                } else {
                                  context.read<DataCollectCubit>().nextQuestion(
                                      studyId: widget.studyId,
                                      flowType: 'longitudinal');
                                }
                              }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          context.read<DataCollectCubit>().canProceed(question)
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceVariant,
                      foregroundColor:
                          context.read<DataCollectCubit>().canProceed(question)
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
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
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
