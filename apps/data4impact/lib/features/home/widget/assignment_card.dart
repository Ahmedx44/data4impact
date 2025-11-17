import 'package:data4impact/features/study/cubit/study_cubit.dart';
import 'package:data4impact/features/study_detail/pages/study_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssignmentCard extends StatelessWidget {
  final Map<String, dynamic> collector;

  const AssignmentCard({super.key, required this.collector});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Extract data from collector
    final study = collector['study'] as Map<String, dynamic>? ?? {};
    final studyName = study['name'] as String? ?? 'Unknown Study';
    final studyDescription =
        study['description'] as String? ?? 'No description available';
    final responseCount = collector['responseCount'] as int? ?? 0;
    final maxLimit = collector['maxLimit'] as int? ?? 0;
    final status = collector['status'] as String? ?? 'inProgress';
    final assignedDate = collector['assignedDate'] as String? ?? '';
    final completedDate = collector['completedDate'] as String? ?? '';

    // Calculate progress
    final progress = maxLimit > 0 ? responseCount / maxLimit : 0.0;
    final progressPercentage = (progress * 100).toInt();

    // Determine status and colors
    final isCompleted = status == 'completed';
    final isOverdue = !isCompleted && _isOverdue(assignedDate);

    // Calculate due date status
    final dueStatus = _getDueStatus(assignedDate, completedDate, isCompleted);

    return Card(
      elevation: 1,
      shadowColor: theme.colorScheme.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header row with title and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    studyName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusBadge(
                  text: isCompleted
                      ? "Completed"
                      : (isOverdue ? "Overdue" : "In Progress"),
                  color: isCompleted
                      ? Colors.green.shade100
                      : (isOverdue
                          ? theme.colorScheme.errorContainer
                          : theme.colorScheme.primaryContainer),
                  textColor: isCompleted
                      ? Colors.green.shade800
                      : (isOverdue
                          ? theme.colorScheme.onErrorContainer
                          : theme.colorScheme.onPrimaryContainer),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Description
            Text(
              studyDescription.isNotEmpty
                  ? studyDescription
                  : 'Data collection assignment',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            /// Response information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Responses',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '$responseCount',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Target',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '$maxLimit',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Progress section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$progressPercentage% ($responseCount/$maxLimit)',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor:
                        theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    color:
                        isCompleted ? Colors.green : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Footer with details and action button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: isOverdue
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dueStatus,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isOverdue
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    final studyCubit = context.read<StudyCubit>();
                    final studyData =
                        studyCubit.getStudyById(study['_id'] as String);

                    if (studyData != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute<Widget>(
                          builder: (context) => StudyDetailPage(
                            studyId: study['_id'] as String,
                            studyData: studyData,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(isCompleted ? 'View' : 'Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isOverdue(String assignedDate) {
    // Implement your overdue logic here
    // For now, return false as a placeholder
    return false;
  }

  String _getDueStatus(
      String assignedDate, String completedDate, bool isCompleted) {
    if (isCompleted) {
      return 'Completed';
    }

    // Implement your due date calculation logic here
    // For now, return a placeholder
    return 'Due in 3 days';
  }
}

/// Status badge component
class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final double fontSize;
  final EdgeInsets padding;

  const _StatusBadge({
    required this.text,
    required this.color,
    required this.textColor,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
