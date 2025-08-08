import 'package:data4impact/features/home/widget/performance_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PerformanceView extends StatelessWidget {
  const PerformanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance',
          style: GoogleFonts.lexendDeca(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Text('Your performance summary'),
        const SizedBox(height: 16),

        /// Grid of performance cards
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            PerformanceCard(
              title: "Top Response Count",
              subtitle: "Quick Turnaround",
            ),
            PerformanceCard(
              title: "Fast Responder",
              subtitle: "Quick Turnaround",
            ),
            PerformanceCard(
              title: "Reliable",
              subtitle: "On-Time Delivery",
            ),
            PerformanceCard(
              title: "Top Performer",
              subtitle: "High Ratings",
            ),
          ],
        ),
      ],
    );
  }
}
