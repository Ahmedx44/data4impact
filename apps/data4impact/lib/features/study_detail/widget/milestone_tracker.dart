import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum MilestoneStatus {
  completed,
  inProgress,
  pending,
}

class MilestoneItem {
  final String title;
  final String date;
  final MilestoneStatus status;
  final double progressThreshold;

  const MilestoneItem({
    required this.title,
    required this.date,
    required this.status,
    required this.progressThreshold,
  });
}

class MilestoneTrackingWidget extends StatelessWidget {
  final Map<String, dynamic> studyData;

  const MilestoneTrackingWidget({
    super.key,
    required this.studyData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Generate milestones based on study data
    final milestones = _generateMilestones(studyData);

    return Card(
      elevation: 1,
      shadowColor: colorScheme.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Study Progress Timeline',
              style: GoogleFonts.lexendDeca(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Key milestones and achievements',
              style: GoogleFonts.lexendDeca(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),

            // Progress indicator
            _buildOverallProgress(studyData, colorScheme),
            const SizedBox(height: 16),

            SizedBox(
              height: 236,
              child: milestones.isEmpty
                  ? Center(
                child: Text(
                  'No milestones available',
                  style: GoogleFonts.lexendDeca(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: milestones.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: index == milestones.length - 1 ? 0 : 12),
                    child: _buildMilestoneItem(milestones[index], colorScheme),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build overall progress indicator
  Widget _buildOverallProgress(Map<String, dynamic> studyData, ColorScheme colorScheme) {
    final responseCount = studyData['responseCount'] ?? 0;
    final sampleSize = studyData['sampleSize'] ?? 1;
    final progress = sampleSize as int > 0 ? responseCount / sampleSize : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Progress',
              style: GoogleFonts.lexendDeca(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: GoogleFonts.lexendDeca(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: double.tryParse(progress.toString()),
          backgroundColor: colorScheme.surfaceVariant,
          color: colorScheme.primary,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          '$responseCount/$sampleSize responses collected',
          style: GoogleFonts.lexendDeca(
            fontSize: 10,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  List<MilestoneItem> _generateMilestones(Map<String, dynamic> studyData) {
    final responseCount = studyData['responseCount'] ?? 0;
    final sampleSize = studyData['sampleSize'] ?? 100;
    final progress = sampleSize as int  > 0 ? responseCount / sampleSize : 0;
    final status = studyData['status'] ?? 'draft';
    final createdAt = studyData['createdAt'] != null
        ? DateTime.parse(studyData['createdAt'] as String)
        : DateTime.now();
    final updatedAt = studyData['updatedAt'] != null
        ? DateTime.parse(studyData['updatedAt'] as String)
        : DateTime.now();
    final closeOnDate = studyData['closeOnDate'] != null
        ? DateTime.parse(studyData['closeOnDate'] as String)
        : null;

    final milestones = <MilestoneItem>[];

    // Study Launch milestone - always completed if study exists
    milestones.add(MilestoneItem(
      title: 'Study Launch',
      date: 'Started on ${_formatDate(createdAt)}',
      status: MilestoneStatus.completed,
      progressThreshold: 0.0,
    ));

    // Progress milestones based on response collection
    final progressMilestones = [
      {'threshold': 0.25, 'title': '25% Response Target'},
      {'threshold': 0.5, 'title': '50% Response Target'},
      {'threshold': 0.75, 'title': '75% Response Target'},
      {'threshold': 0.9, 'title': '90% Response Target'},
    ];

    for (final milestone in progressMilestones) {
      final threshold = milestone['threshold'] as double;
      final milestoneProgress = progress;
      MilestoneStatus milestoneStatus;

      if (milestoneProgress as int >= threshold) {
        milestoneStatus = MilestoneStatus.completed;
      } else if (threshold == 0.75 && milestoneProgress > 0.5) {
        milestoneStatus = MilestoneStatus.inProgress;
      } else {
        milestoneStatus = MilestoneStatus.pending;
      }

      String dateText;
      if (milestoneStatus == MilestoneStatus.completed) {
        // Estimate completion date based on progress rate
        final daysSinceStart = updatedAt.difference(createdAt).inDays;
        final completionDate = daysSinceStart > 0
            ? createdAt.add(
          Duration(
            days: ((daysSinceStart as num) / (progress as num) * (threshold as num)).toInt(),
          ),
        )
            : createdAt;
        dateText = 'Achieved on ${_formatDate(completionDate)}';
      } else if (milestoneStatus == MilestoneStatus.inProgress) {
        dateText = 'In progress - ${(progress * 100).toStringAsFixed(1)}% complete';
      } else {
        // Estimate target date
        final daysSinceStart = updatedAt.difference(createdAt).inDays;
        final targetDate = daysSinceStart > 0 && progress as num > 0
            ? createdAt.add(Duration(days: (daysSinceStart / progress * threshold).toInt()))
            : (closeOnDate ?? createdAt.add(const Duration(days: 30)));
        dateText = 'Target: ${_formatDate(targetDate)}';
      }

      milestones.add(MilestoneItem(
        title: milestone['title'] as String,
        date: dateText,
        status: milestoneStatus,
        progressThreshold: threshold,
      ));
    }

    // Study completion milestone
    final completionStatus = progress as num >= 1.0
        ? MilestoneStatus.completed
        : (status == 'completed' ? MilestoneStatus.completed : MilestoneStatus.pending);

    String completionDateText;
    if (completionStatus == MilestoneStatus.completed) {
      completionDateText = 'Completed on ${_formatDate(updatedAt)}';
    } else if (closeOnDate != null) {
      completionDateText = 'Target: ${_formatDate(closeOnDate)}';
    } else {
      completionDateText = 'Target: To be determined';
    }

    milestones.add(MilestoneItem(
      title: 'Study Completion',
      date: completionDateText,
      status: completionStatus,
      progressThreshold: 1.0,
    ));

    return milestones;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildMilestoneItem(MilestoneItem milestone, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Status Icon
          _buildStatusIcon(milestone.status, colorScheme),
          const SizedBox(width: 12),

          // Milestone Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        milestone.title,
                        style: GoogleFonts.lexendDeca(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (milestone.progressThreshold > 0)
                      Text(
                        '${(milestone.progressThreshold * 100).toInt()}%',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  milestone.date,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(MilestoneStatus status, ColorScheme colorScheme) {
    switch (status) {
      case MilestoneStatus.completed:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: colorScheme.onPrimary,
            size: 16,
          ),
        );
      case MilestoneStatus.inProgress:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.primary,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.schedule,
            color: colorScheme.onPrimaryContainer,
            size: 14,
          ),
        );
      case MilestoneStatus.pending:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.outline,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.schedule,
            color: colorScheme.onSurfaceVariant,
            size: 14,
          ),
        );
    }
  }
}