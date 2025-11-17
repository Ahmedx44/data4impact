// teams_stat_card.dart - Responsive Minimal Version
import 'package:flutter/material.dart';

class TeamStatsCard extends StatelessWidget {
  final String title;
  final int value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isPercentage;
  final String? customValue;

  const TeamStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.color = Colors.blue,
    this.isPercentage = false,
    this.customValue,
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
    final double cardPadding = isSmallScreen ? 12 : (isMediumScreen ? 16 : 20);
    final double spacing = isSmallScreen ? 8 : (isMediumScreen ? 12 : 16);

    return Container(
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
        padding: EdgeInsets.all(cardPadding),
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

            SizedBox(height: spacing),

            // Value - Responsive font size
            Text(
              customValue ?? (isPercentage ? '$value%' : value.toString()),
              style: TextStyle(
                fontSize: _getValueFontSize(screenWidth),
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: isSmallScreen ? 2 : 4),

            // Title - Responsive font size
            Text(
              title,
              style: TextStyle(
                fontSize: _getTitleFontSize(screenWidth),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                letterSpacing: 0.3,
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
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
    if (screenWidth < 360) return 11;    // Very small screens
    if (screenWidth < 400) return 12;    // Small screens
    if (screenWidth < 600) return 13;    // Medium screens
    return 14;                           // Large screens
  }

  double _getSubtitleFontSize(double screenWidth) {
    if (screenWidth < 360) return 9;     // Very small screens
    if (screenWidth < 400) return 10;    // Small screens
    if (screenWidth < 600) return 11;    // Medium screens
    return 12;                           // Large screens
  }
}