// team_stats_card.dart
import 'package:flutter/material.dart';

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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing based on screen width
    final bool isSmallScreen = screenWidth < 360;
    final bool isMediumScreen = screenWidth < 400;

    final double iconSize = isSmallScreen ? 16 : (isMediumScreen ? 18 : 20);
    final double iconPadding = isSmallScreen ? 8 : (isMediumScreen ? 10 : 12);
    final double spacing = isSmallScreen ? 8 : (isMediumScreen ? 12 : 16);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Theme.of(context).colorScheme.surface
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: iconSize,
                  ),
                ),

               const  SizedBox(height: 15),

                // Value - Responsive font size
                Text(
                  customValue ?? (isPercentage ? '$value%' : value.toString()),
                  style: TextStyle(
                    fontSize: _getValueFontSize(screenWidth),
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: isSmallScreen ? 2 : 4),

                // Title - Responsive font size
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: _getTitleFontSize(screenWidth),
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: isSmallScreen ? 2 : 4),

                // Subtitle - Responsive font size
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: _getSubtitleFontSize(screenWidth),
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getValueFontSize(double screenWidth) {
    if (screenWidth < 360) return 20;    // Very small screens
    if (screenWidth < 400) return 22;    // Small screens
    if (screenWidth < 600) return 24;    // Medium screens
    return 28;                           // Large screens
  }

  double _getTitleFontSize(double screenWidth) {
    if (screenWidth < 360) return 10;    // Very small screens
    if (screenWidth < 400) return 11;    // Small screens
    if (screenWidth < 600) return 12;    // Medium screens
    return 13;                           // Large screens
  }

  double _getSubtitleFontSize(double screenWidth) {
    if (screenWidth < 360) return 9;     // Very small screens
    if (screenWidth < 400) return 10;    // Small screens
    if (screenWidth < 600) return 11;    // Medium screens
    return 12;                           // Large screens
  }
}