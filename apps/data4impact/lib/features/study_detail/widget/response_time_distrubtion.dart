import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResponseTimeDistributionChart extends StatelessWidget {
  final Map<String, dynamic> studyData;

  const ResponseTimeDistributionChart({
    super.key,
    required this.studyData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Extract response data or use default values
    final responseCount = studyData['responseCount'] ?? 0;
    final sampleSize = studyData['sampleSize'] ?? 100;
    final progress = sampleSize as int > 0 ? responseCount / sampleSize : 0;

    // Generate sample data based on actual progress
    final dailyData = _generateWeeklyData(double.tryParse(progress.toString())??0, sampleSize);

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
            Text(
              'Response Progress',
              style: GoogleFonts.lexendDeca(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Daily progress vs target over time',
              style: GoogleFonts.lexendDeca(
                fontSize: 10,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            // Progress summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Progress:',
                  style: GoogleFonts.lexendDeca(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                Text(
                  '$responseCount/$sampleSize (${(progress * 100).toStringAsFixed(1)}%)',
                  style: GoogleFonts.lexendDeca(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: const BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.lexendDeca(
                              fontSize: 10,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[value.toInt()],
                              style: GoogleFonts.lexendDeca(
                                fontSize: 10,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          );
                        },
                        interval: 1,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colorScheme.outline.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  barGroups: dailyData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final value = entry.value;
                    return _makeGroup(index, value, colorScheme.primary);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<double> _generateWeeklyData(double progress, int sampleSize) {
    // Generate realistic weekly data based on overall progress
    final weeklyData = List<double>.generate(7, (index) => 0.0);
    final totalResponses = (progress * sampleSize).toInt();

    // Distribute responses across the week (simplified)
    for (int i = 0; i < totalResponses; i++) {
      final day = i % 7;
      weeklyData[day] += 1;
    }

    return weeklyData;
  }

  BarChartGroupData _makeGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}