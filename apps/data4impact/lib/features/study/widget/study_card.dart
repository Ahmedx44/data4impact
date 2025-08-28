import 'package:flutter/material.dart';

class StudyCard extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
  final String status;
  final String? dueDate;
  final VoidCallback callback;

  const StudyCard({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    required this.status,
    required this.callback,
    this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = status == 'overdue';

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
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                _StatusBadge(
                  text: status,
                  color: isOverdue
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.primaryContainer,
                  textColor: isOverdue
                      ? theme.colorScheme.onErrorContainer
                      : theme.colorScheme.onPrimaryContainer,
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Description
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
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
                      '${(progress * 100).toStringAsFixed(0)}%',
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
                    backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    color: theme.colorScheme.primary,
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
                    if (dueDate != null)
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
                            isOverdue ? 'Overdue' : 'Due $dueDate',
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  onPressed: callback,
                  child: const Text('Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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