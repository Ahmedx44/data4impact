import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EarningView extends StatelessWidget {
  const EarningView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Top Earnings Summary
        Row(
          children: const [
            Expanded(
              child: _EarningSummaryCard(
                title: "Total Earnings",
                amount: "\$12,523.13",
                subtitle: "All time",
                icon: Icons.star,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _EarningSummaryCard(
                title: "This Month",
                amount: "\$3,756.94",
                subtitle: "+15% from last month",
                icon: Icons.star,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        /// Earnings Breakdown Header
        Text(
          "Earnings Breakdown",
          style: GoogleFonts.lexendDeca(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          "Detailed view of your earnings by assignment",
          style: GoogleFonts.lexendDeca(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),

        /// Earnings List
        SizedBox(
          height: 300,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: List.generate(
              6,
                  (index) => const _EarningBreakdownCard(
                    title: "Shopping Preferences Survey",
                    responses: "385 responses completed",
                    amount: "\$5,053.13",
                    base: "\$4,812.50",
                    bonus: "\$240.63",
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Summary Card
class _EarningSummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final IconData icon;

  const _EarningSummaryCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(icon, size: 18, color: theme.colorScheme.primary),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: GoogleFonts.lexendDeca(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.lexendDeca(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Earnings Breakdown Item
class _EarningBreakdownCard extends StatelessWidget {
  final String title;
  final String responses;
  final String amount;
  final String base;
  final String bonus;

  const _EarningBreakdownCard({
    required this.title,
    required this.responses,
    required this.amount,
    required this.base,
    required this.bonus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Left Side
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  responses,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),

            /// Right Side
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Base: $base + Bonus: $bonus",
                  style: GoogleFonts.lexendDeca(
                    fontSize: 8,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
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
