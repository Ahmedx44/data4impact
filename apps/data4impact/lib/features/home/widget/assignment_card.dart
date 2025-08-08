import 'package:flutter/material.dart';

class AssignmentCard extends StatelessWidget {
  const AssignmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.15),
        ),
      ),
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// LEFT SIDE
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title & Tag
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Brand Awareness Analysis',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _StatusBadge(
                        text: "Overdue",
                        color: theme.colorScheme.errorContainer,
                        textColor: theme.colorScheme.onErrorContainer,
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// Subtitle
                  Text(
                    'Measuring brand recognition and recall across target demographics',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Status & Earnings
                  Row(
                    children: [
                      _StatusBadge(
                        text: "Overdue",
                        color: theme.colorScheme.primary.withOpacity(0.15),
                        textColor: theme.colorScheme.primary,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.circle,
                          size: 6, color: theme.colorScheme.onSurface),
                      const SizedBox(width: 4),
                      Text(
                        '5 days overdue',
                        style:
                            theme.textTheme.labelSmall!.copyWith(fontSize: 8),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Earnings: \$2,520.00',
                        style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600, fontSize: 8),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 0.77,
                      minHeight: 10,
                      backgroundColor:
                          theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            /// RIGHT SIDE
            Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        value: 0.77,
                        strokeWidth: 4,
                        backgroundColor:
                            theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      '77%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '385/500',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Responses',
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  onPressed: () {},
                  child: Text(
                    'Continue',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
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
}

/// Small reusable status badge
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
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50),
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
