import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudyDetailActivityCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StudyDetailActivityCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.icon = Icons.star,
    this.color = Colors.blue,
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: GoogleFonts.lexendDeca(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: theme.onSurface.withOpacity(0.6),
                      letterSpacing: 0.8,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: GoogleFonts.lexendDeca(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.onSurface,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: GoogleFonts.lexendDeca(
                  fontSize: 12,
                  color: theme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}