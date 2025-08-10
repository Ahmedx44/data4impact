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

  const MilestoneItem({
    required this.title,
    required this.date,
    required this.status,
  });
}

class MilestoneTrackingWidget extends StatelessWidget {
  const MilestoneTrackingWidget({super.key});

  // Static milestone data
  static const List<MilestoneItem> milestones = [
    MilestoneItem(
      title: 'Study Launch',
      date: 'Completed on 1/20/2024',
      status: MilestoneStatus.completed,
    ),
    MilestoneItem(
      title: '25% Milestone',
      date: 'Completed on 1/20/2024',
      status: MilestoneStatus.completed,
    ),
    MilestoneItem(
      title: '50% Milestone',
      date: 'Completed on 1/26/2024',
      status: MilestoneStatus.completed,
    ),
    MilestoneItem(
      title: '75% Milestone',
      date: 'In progress on 1/30/2024',
      status: MilestoneStatus.inProgress,
    ),
    MilestoneItem(
      title: 'Study Completion',
      date: 'Target on 1/30/2024',
      status: MilestoneStatus.pending,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              'Milestone Tracking',
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

            SizedBox(
              height: 300,
              child: ListView.builder(
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
                Text(
                  milestone.title,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
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