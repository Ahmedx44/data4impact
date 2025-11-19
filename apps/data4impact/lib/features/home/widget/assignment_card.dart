import 'package:data4impact/features/study/cubit/study_cubit.dart';
import 'package:data4impact/features/study_detail/pages/study_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class AssignmentCard extends StatelessWidget {
  final Map<String, dynamic> collector;

  const AssignmentCard({super.key, required this.collector});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

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
      elevation: 2,
      shadowColor: theme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.outline.withOpacity(0.08),
          width: 1,
        ),
      ),
      color: theme.surface,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.surface,
              theme.surface,
              theme.surfaceContainerHighest.withOpacity(0.3),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header row with title and status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      HugeIcons.strokeRoundedTask01,
                      size: 20,
                      color: theme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studyName,
                          style: GoogleFonts.lexendDeca(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.onSurface,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        _StatusBadge(
                          text: isCompleted
                              ? "Completed"
                              : (isOverdue ? "Overdue" : "In Progress"),
                          color: isCompleted
                              ? Colors.green.withOpacity(0.1)
                              : (isOverdue
                                  ? theme.error.withOpacity(0.1)
                                  : theme.primary.withOpacity(0.1)),
                          textColor: isCompleted
                              ? Colors.green
                              : (isOverdue ? theme.error : theme.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Description
              Text(
                studyDescription.isNotEmpty
                    ? studyDescription
                    : 'Data collection assignment',
                style: GoogleFonts.lexendDeca(
                  fontSize: 14,
                  color: theme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 24),

              /// Progress section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        '$progressPercentage% ($responseCount/$maxLimit)',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.primary,
                                theme.primary.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primary.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// Footer with details and action button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedTime01,
                        size: 16,
                        color: isOverdue
                            ? theme.error
                            : theme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dueStatus,
                        style: GoogleFonts.lexendDeca(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isOverdue
                              ? theme.error
                              : theme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                    icon: Icon(
                      isCompleted
                          ? HugeIcons.strokeRoundedView
                          : HugeIcons.strokeRoundedArrowRight01,
                      size: 18,
                    ),
                    label: Text(
                      isCompleted ? 'View' : 'Continue',
                      style: GoogleFonts.lexendDeca(
                        fontWeight: FontWeight.w600,
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
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.lexendDeca(
          fontSize: fontSize,
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
