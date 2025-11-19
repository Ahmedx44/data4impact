import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityCard extends StatelessWidget {
  final String title;
  final int value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isPercentage;
  final String? customValue;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.icon = Icons.group_rounded,
    this.color = Colors.blue,
    this.isPercentage = false,
    this.customValue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                  if (isPercentage)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$value%',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                customValue ?? value.toString(),
                style: GoogleFonts.lexendDeca(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.onSurface,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.lexendDeca(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.onSurface.withOpacity(0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: GoogleFonts.lexendDeca(
                  fontSize: 12,
                  color: theme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
