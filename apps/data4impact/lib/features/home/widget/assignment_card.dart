import 'package:data4impact/features/study/cubit/study_cubit.dart';
import 'package:data4impact/features/study_detail/pages/study_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AssignmentCard extends StatelessWidget {
  final Map<String, dynamic> collector;

  const AssignmentCard({super.key, required this.collector});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Extract data from collector
    final study = collector['study'] as Map<String, dynamic>? ?? {};
    final studyName = study['name'] as String? ?? 'Unknown Study';
    final studyDescription = study['description'] as String? ?? '';
    final responseCount = collector['responseCount'] as int? ??
        study['responseCount'] as int? ??
        0;
    final maxLimit =
        collector['maxLimit'] as int? ?? study['sampleSize'] as int? ?? 0;
    final status = collector['study']['status'] as String? ?? '';
    final assignedDate = collector['assignedDate'] as String? ?? '';
    final completedDate = collector['completedDate'] as String? ?? '';
    final dueDate = collector['dueDate'] as String? ?? '';

    // Calculate progress
    final progress = maxLimit > 0 ? responseCount / maxLimit : 0.0;
    final isLimitReached = maxLimit > 0 && responseCount >= maxLimit;

    // Determine status and colors
    final isCompleted = status == 'completed';
    final dueStatus =
        _getDueStatus(assignedDate, dueDate, completedDate, isCompleted);

    // Get appropriate colors based on status
    final cardColor = _getCardColor(colorScheme, dueStatus, isCompleted);
    final (statusColor, statusIcon, displayStatus) =
        _getStatusDetails(dueStatus.statusText, isCompleted, colorScheme);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      color: colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surface,
              colorScheme.surfaceVariant.withOpacity(0.3),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.03),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header with status and progress percentage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusIcon,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              displayStatus,
                              style: GoogleFonts.lexendDeca(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Progress percentage in circle
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: cardColor.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: GoogleFonts.lexendDeca(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: cardColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Title
                  Text(
                    studyName,
                    style: GoogleFonts.lexendDeca(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  /// Description or due date info
                  if (studyDescription.isNotEmpty)
                    Text(
                      studyDescription,
                      style: GoogleFonts.lexendDeca(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.7),
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  else if (dueStatus.daysRemaining != null)
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dueStatus.daysRemaining!,
                          style: GoogleFonts.lexendDeca(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  /// Progress bar with labels
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Collection Progress',
                            style: GoogleFonts.lexendDeca(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            '$responseCount/$maxLimit Responses',
                            style: GoogleFonts.lexendDeca(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: cardColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Progress bar with gradient
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutQuart,
                                width: constraints.maxWidth * progress,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      cardColor,
                                      cardColor.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: cardColor.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: cardColor,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: () {
                        if (isLimitReached) {
                          ToastService.showErrorToast(
                            message:
                                'Maximum response limit reached for this study.',
                          );
                          return;
                        }

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
                                collectorResponseCount: responseCount,
                                collectorMaxLimit: maxLimit,
                              ),
                            ),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isCompleted
                                ? 'View Details'
                                : (isLimitReached
                                    ? 'Limit Reached'
                                    : 'Continue Study'),
                            style: GoogleFonts.lexendDeca(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isCompleted
                                ? Icons.visibility_rounded
                                : (isLimitReached
                                    ? Icons.block_rounded
                                    : Icons.arrow_forward_rounded),
                            size: 18,
                            color: colorScheme.onPrimary,
                          ),
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
    );
  }

  DueStatus _getDueStatus(
    String assignedDate,
    String dueDate,
    String completedDate,
    bool isCompleted,
  ) {
    if (isCompleted) {
      final completed = _parseDate(completedDate);
      return DueStatus(
        statusText: 'Completed',
        daysRemaining: completed != null
            ? 'Completed on ${DateFormat('MMM dd, yyyy').format(completed)}'
            : null,
      );
    }

    final due = _parseDate(dueDate);
    if (due == null) {
      return DueStatus(statusText: 'In Progress');
    }

    final now = DateTime.now();
    final difference = due.difference(now);

    if (difference.inDays < 0) {
      return DueStatus(
        statusText: 'Overdue',
        daysRemaining: 'Overdue by ${difference.inDays.abs()} days',
      );
    } else if (difference.inDays == 0) {
      return DueStatus(
        statusText: 'Due Today',
        daysRemaining: 'Due today',
      );
    } else if (difference.inDays == 1) {
      return DueStatus(
        statusText: 'Due Tomorrow',
        daysRemaining: 'Due tomorrow',
      );
    } else if (difference.inDays <= 7) {
      return DueStatus(
        statusText: 'Due Soon',
        daysRemaining: 'Due in ${difference.inDays} days',
      );
    } else {
      return DueStatus(
        statusText: 'In Progress',
        daysRemaining: 'Due ${DateFormat('MMM dd, yyyy').format(due)}',
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

  Color _getCardColor(
    ColorScheme colorScheme,
    DueStatus dueStatus,
    bool isCompleted,
  ) {
    if (isCompleted) {
      return const Color(0xFF10B981); // Green
    }

    switch (dueStatus.statusText) {
      case 'Overdue':
        return const Color(0xFFEF4444); // Red
      case 'Due Today':
      case 'Due Tomorrow':
      case 'Due Soon':
        return const Color(0xFFF59E0B); // Orange
      default:
        return colorScheme.primary;
    }
  }

  // Helper method to get status details
  (Color, IconData, String) _getStatusDetails(
    String statusText,
    bool isCompleted,
    ColorScheme colorScheme,
  ) {
    if (isCompleted) {
      return (
        const Color(0xFF10B981),
        Icons.check_circle_rounded,
        'Completed',
      );
    }

    switch (statusText) {
      case 'Overdue':
        return (
          const Color(0xFFEF4444),
          Icons.warning_amber_rounded,
          'Overdue'
        );
      case 'Due Today':
        return (
          const Color(0xFFF59E0B),
          Icons.schedule_rounded,
          'Due Today',
        );
      case 'Due Tomorrow':
        return (
          const Color(0xFFF59E0B),
          Icons.schedule_rounded,
          'Due Tomorrow'
        );
      case 'Due Soon':
        return (
          const Color(0xFFF59E0B),
          Icons.schedule_rounded,
          'Due Soon',
        );
      case 'In Progress':
        return (
          colorScheme.primary,
          Icons.play_arrow_rounded,
          'In Progress',
        );
      default:
        return (
          colorScheme.primary,
          Icons.help_outline_rounded,
          statusText,
        );
    }
  }
}

class DueStatus {
  final String statusText;
  final String? daysRemaining;

  DueStatus({required this.statusText, this.daysRemaining});
}
