import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudyCard extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
  final String status;
  final VoidCallback callback;

  const StudyCard({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    required this.status,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine status colors and icons
    final (statusColor, statusIcon, displayStatus) = _getStatusDetails(status, colorScheme);

    return Card(
      elevation: 3,
      shadowColor: colorScheme.primary.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.08),
          width: 1,
        ),
      ),
      color: colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 10),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header with status and title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status indicator with icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusIcon,
                      size: 20,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Title and status badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: statusColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            displayStatus,
                            style: GoogleFonts.lexendDeca(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Description
              Text(
                description,
                style: GoogleFonts.lexendDeca(
                  fontSize: 15,
                  color: colorScheme.onSurface.withOpacity(0.75),
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 24),

              /// Progress section with visual indicators
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Collection Progress',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Animated progress bar with percentage indicator
                  Stack(
                    children: [
                      // Background track
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      // Progress fill
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutQuart,
                        height: 12,
                        width: MediaQuery.of(context).size.width * 0.7 * progress,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withOpacity(0.8),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Progress percentage indicator dots
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ProgressDot(progress: progress, threshold: 0.25, label: '25%', colorScheme: colorScheme),
                      _ProgressDot(progress: progress, threshold: 0.5, label: '50%', colorScheme: colorScheme),
                      _ProgressDot(progress: progress, threshold: 0.75, label: '75%', colorScheme: colorScheme),
                      _ProgressDot(progress: progress, threshold: 1.0, label: '100%', colorScheme: colorScheme),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// Action button centered at the bottom
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    // Add subtle shadow for depth
                    side: BorderSide.none,
                    // Smooth hover and press effects
                  ),
                  onPressed: callback,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Continue Study',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: colorScheme.onPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get status details
  (Color, IconData, String) _getStatusDetails(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'inprogress':
        return (colorScheme.primary, Icons.play_arrow_rounded, 'In Progress');
      case 'completed':
        return (const Color(0xFF10B981), Icons.check_circle_rounded, 'Completed');
      case 'draft':
        return (colorScheme.onSurface.withOpacity(0.6), Icons.edit_note_rounded, 'Draft');
      case 'overdue':
        return (colorScheme.error, Icons.warning_amber_rounded, 'Attention Needed');
      default:
        return (colorScheme.primary, Icons.help_outline_rounded, status);
    }
  }
}

// Progress dot indicator widget
class _ProgressDot extends StatelessWidget {
  final double progress;
  final double threshold;
  final String label;
  final ColorScheme colorScheme;

  const _ProgressDot({
    required this.progress,
    required this.threshold,
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = progress >= threshold;

    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? colorScheme.primary : colorScheme.surfaceVariant,
            border: Border.all(
              color: isCompleted ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
              width: isCompleted ? 0 : 1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lexendDeca(
            fontSize: 10,
            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
            color: isCompleted ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}