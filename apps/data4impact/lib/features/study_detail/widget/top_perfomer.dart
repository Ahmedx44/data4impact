import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopPerformersWidget extends StatelessWidget {
  final Map<String, dynamic> studyData;

  const TopPerformersWidget({
    super.key,
    required this.studyData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Extract collector data or use default values
    final collectorCount = studyData['collectorCount'] ?? 0;
    final responseCount = studyData['responseCount'] ?? 0;

    // Generate sample performers based on collector count
    final performers = _generatePerformers(collectorCount as int, responseCount as int);

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
              'Data Collectors',
              style: GoogleFonts.lexendDeca(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${performers.length} active collectors',
              style: GoogleFonts.lexendDeca(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 300,
              child: performers.isEmpty
                  ? Center(
                child: Text(
                  'No collectors assigned yet',
                  style: GoogleFonts.lexendDeca(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              )
                  : ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  ...performers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final performer = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: index == performers.length - 1 ? 0 : 8),
                      child: _buildPerformerItem(
                        rank: '#${index + 1}',
                        name: performer['name'].toString()??'',
                        responses: performer['responses'] as int,
                        color: colorScheme,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generatePerformers(int collectorCount, int totalResponses) {
    if (collectorCount == 0) return [];

    // Generate sample performer data
    final performers = <Map<String, dynamic>>[];
    final averageResponses = totalResponses ~/ collectorCount;

    for (int i = 0; i < collectorCount; i++) {
      final responseVariation = (i % 3) * 10; // Some variation
      final responses = averageResponses + responseVariation;

      performers.add({
        'name': _generateCollectorName(i),
        'responses': responses.clamp(0, totalResponses),
      });
    }

    // Sort by responses descending
    performers.sort((a, b) => (b['responses'] as int).compareTo(a['responses'] as int));

    // Return top 4 performers
    return performers.take(4).toList();
  }

  String _generateCollectorName(int index) {
    final names = [
      'Hanan Jeylan Wako',
      'Ziyad Ahmed Ali',
      'Selahadin Hamid Abdellah',
      'Abdurahman Kasim Kalid',
      'Mohammed Hassan',
      'Amina Mohammed',
      'Tesfaye Lemma',
      'Eyerusalem Bekele'
    ];
    return names[index % names.length];
  }

  Widget _buildPerformerItem({
    required String rank,
    required String name,
    required int responses,
    required ColorScheme color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              rank,
              style: GoogleFonts.lexendDeca(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name and responses
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$responses responses',
                  style: GoogleFonts.lexendDeca(
                    fontSize: 12,
                    color: color.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}