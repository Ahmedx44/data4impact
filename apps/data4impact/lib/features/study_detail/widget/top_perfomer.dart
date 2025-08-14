import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopPerformersWidget extends StatelessWidget {
  const TopPerformersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              'Top Performers',
              style: GoogleFonts.lexendDeca(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Highest performing data collectors',
              style: GoogleFonts.lexendDeca(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 300,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildPerformerItem(
                    rank: '#1',
                    name: 'Hanan Jeylan Wako',
                    responses: '247 responses',
                    color: colorScheme,
                  ),
                  const SizedBox(height: 8),
                  _buildPerformerItem(
                    rank: '#2',
                    name: 'Ziyad Ahmed Ali',
                    responses: '230 responses',
                    color: colorScheme,
                  ),
                  const SizedBox(height: 8),
                  _buildPerformerItem(
                    rank: '#3',
                    name: 'Selahadin Hamid Abdellah',
                    responses: '229 responses',
                    color: colorScheme,
                  ),
                  const SizedBox(height: 8),
                  _buildPerformerItem(
                    rank: '#4',
                    name: 'Abdurahman Kasim Kalid',
                    responses: '227 responses',
                    color: colorScheme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformerItem({
    required String rank,
    required String name,
    required String responses,
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
                  responses,
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
