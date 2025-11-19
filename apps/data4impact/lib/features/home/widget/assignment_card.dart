import 'package:data4impact/features/study/cubit/study_cubit.dart';
import 'package:data4impact/features/study_detail/pages/study_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class AssignmentCard extends StatelessWidget {
  final Map<String, dynamic> collector;

  const AssignmentCard({super.key, required this.collector});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    // Extract data from collector
    final study = collector['study'] as Map<String, dynamic>? ?? {};
    final studyName = study['name'] as String? ?? 'Unknown Study';
    final studyDescription = study['description'] as String? ?? '';
    final responseCount = collector['responseCount'] as int? ?? 0;
    final maxLimit = collector['maxLimit'] as int? ?? 0;
    final status = collector['study']['status'] as String? ?? '';
    final assignedDate = collector['assignedDate'] as String? ?? '';
    final completedDate = collector['completedDate'] as String? ?? '';
    final dueDate = collector['dueDate'] as String? ?? '';

    // Calculate progress
    final progress = maxLimit > 0 ? responseCount / maxLimit : 0.0;
    final progressPercentage = (progress * 100).toInt();

    // Determine status and colors
    final isCompleted = status == 'completed';
    final dueStatus = _getDueStatus(assignedDate, dueDate, completedDate, isCompleted);

    // Get appropriate colors based on status
    final statusColors = _getStatusColors(theme, dueStatus, isCompleted);

    return Card(
      elevation: 2,
      shadowColor: theme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.outline.withOpacity(0.08),
          width: 1,
        ),
      ),
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : theme.surface,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColors.iconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted
                        ? HugeIcons.strokeRoundedCheckmarkCircle02
                        : HugeIcons.strokeRoundedTask01,
                    color: statusColors.iconColor,
                    size: 22,
                  ),
                ),
                _StatusBadge(
                  text: dueStatus.statusText,
                  color: statusColors.badgeBackground,
                  textColor: statusColors.badgeText,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Progress percentage with animated appearance
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 800),
              tween: Tween<double>(begin: 0.0, end: progressPercentage / 100.0),
              builder: (context, value, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(value * 100).toInt()}%',
                      style: GoogleFonts.lexendDeca(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.onSurface,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      studyName,
                      style: GoogleFonts.lexendDeca(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.onSurface.withOpacity(0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Response count and progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Responses',
                      style: GoogleFonts.lexendDeca(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '$responseCount/$maxLimit',
                      style: GoogleFonts.lexendDeca(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColors.iconColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.surfaceContainerHighest.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                statusColors.iconColor,
                                statusColors.iconColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: statusColors.iconColor.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Footer with due date and action button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Due date information
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedTime01,
                        size: 16,
                        color: statusColors.iconColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dueStatus.statusText,
                              style: GoogleFonts.lexendDeca(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusColors.badgeText,
                              ),
                            ),
                            if (dueStatus.daysRemaining != null)
                              Text(
                                dueStatus.daysRemaining!,
                                style: GoogleFonts.lexendDeca(
                                  fontSize: 11,
                                  color: theme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Continue/View button
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: statusColors.iconColor,
                  ),
                  onPressed: () {
                    final studyCubit = context.read<StudyCubit>();
                    final studyData = studyCubit.getStudyById(study['_id'] as String);

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
                    size: 16,
                  ),
                  label: Text(
                    isCompleted ? 'View' : 'Continue',
                    style: GoogleFonts.lexendDeca(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  DueStatus _getDueStatus(String assignedDate, String dueDate, String completedDate, bool isCompleted) {
    if (isCompleted) {
      final completed = _parseDate(completedDate);
      return DueStatus(
        statusText: 'Completed',
        daysRemaining: completed != null ? 'on ${DateFormat('MMM dd, yyyy').format(completed)}' : null,
      );
    }

    final due = _parseDate(dueDate);
    if (due == null) {
      return DueStatus(statusText: 'No due date');
    }

    final now = DateTime.now();
    final difference = due.difference(now);

    if (difference.inDays < 0) {
      return DueStatus(
        statusText: 'Overdue',
        daysRemaining: '${difference.inDays.abs()} days ago',
      );
    } else if (difference.inDays == 0) {
      return DueStatus(
        statusText: 'Due Today',
        daysRemaining: 'Ends today',
      );
    } else if (difference.inDays == 1) {
      return DueStatus(
        statusText: 'Due Tomorrow',
        daysRemaining: '1 day remaining',
      );
    } else if (difference.inDays <= 7) {
      return DueStatus(
        statusText: 'Due Soon',
        daysRemaining: '${difference.inDays} days remaining',
      );
    } else {
      return DueStatus(
        statusText: 'In Progress',
        daysRemaining: 'Due ${DateFormat('MMM dd').format(due)}',
      );
    }
  }

  DateTime? _parseDate(String dateString) {
    if (dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString).toLocal();
    } catch (e) {
      return null;
    }
  }

  StatusColors _getStatusColors(ColorScheme theme, DueStatus dueStatus, bool isCompleted) {
    if (isCompleted) {
      return StatusColors(
        iconColor: Colors.green,
        iconBackground: Colors.green.withOpacity(0.1),
        badgeBackground: Colors.green.withOpacity(0.1),
        badgeText: Colors.green,
      );
    }

    switch (dueStatus.statusText) {
      case 'Overdue':
        return StatusColors(
          iconColor: theme.error,
          iconBackground: theme.error.withOpacity(0.1),
          badgeBackground: theme.error.withOpacity(0.1),
          badgeText: theme.error,
        );
      case 'Due Today':
      case 'Due Tomorrow':
      case 'Due Soon':
        return StatusColors(
          iconColor: Colors.orange,
          iconBackground: Colors.orange.withOpacity(0.1),
          badgeBackground: Colors.orange.withOpacity(0.1),
          badgeText: Colors.orange,
        );
      default:
        return StatusColors(
          iconColor: theme.primary,
          iconBackground: theme.primary.withOpacity(0.1),
          badgeBackground: theme.primary.withOpacity(0.1),
          badgeText: theme.primary,
        );
    }
  }
}

class DueStatus {
  final String statusText;
  final String? daysRemaining;

  DueStatus({required this.statusText, this.daysRemaining});
}

class StatusColors {
  final Color iconColor;
  final Color iconBackground;
  final Color badgeBackground;
  final Color badgeText;

  StatusColors({
    required this.iconColor,
    required this.iconBackground,
    required this.badgeBackground,
    required this.badgeText,
  });
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.lexendDeca(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}