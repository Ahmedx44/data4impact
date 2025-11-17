import 'package:data4impact/features/home/widget/assignment_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssignmentView extends StatelessWidget {
  final List<Map<String, dynamic>> collectors;

  const AssignmentView({super.key, required this.collectors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assignment',
              style: GoogleFonts.lexendDeca(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Your active data collection tasks',
              style: GoogleFonts.lexendDeca(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
        SizedBox(
          height: 400,
          child: ListView(
            children: collectors.map((collector) {
              return Column(
                children: [
                  AssignmentCard(collector: collector),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}