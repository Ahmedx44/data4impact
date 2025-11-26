import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudyCard extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
  final String status;
  final VoidCallback callback;
  final Color? accentColor;
  final bool isLimitReached;

  const StudyCard({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    required this.status,
    required this.callback,
    this.accentColor,
    this.isLimitReached = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardColor = accentColor ?? colorScheme.primary;

    final (statusColor, statusIcon, displayStatus) =
        _getStatusDetails(status, colorScheme);

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
                  /// Header with status
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
                    title,
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

                  /// Description
                  Text(
                    description,
                    style: GoogleFonts.lexendDeca(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.7),
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                            '${(progress * 100).toInt()}% Complete',
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
                      onPressed: callback,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLimitReached ? 'Limit Reached' : 'Continue Study',
                            style: GoogleFonts.lexendDeca(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isLimitReached
                                ? Icons.block_rounded
                                : Icons.arrow_forward_rounded,
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

  // Helper method to get status details
  (Color, IconData, String) _getStatusDetails(
      String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'inprogress':
        return (colorScheme.primary, Icons.play_arrow_rounded, 'In Progress');
      case 'completed':
        return (
          const Color(0xFF10B981),
          Icons.check_circle_rounded,
          'Completed'
        );
      case 'draft':
        return (
          colorScheme.onSurface.withOpacity(0.6),
          Icons.edit_note_rounded,
          'Draft'
        );
      case 'overdue':
        return (
          const Color(0xFFEF4444),
          Icons.warning_amber_rounded,
          'Attention Needed'
        );
      case 'pending':
        return (const Color(0xFFF59E0B), Icons.schedule_rounded, 'Pending');
      default:
        return (colorScheme.primary, Icons.help_outline_rounded, status);
    }
  }
}
