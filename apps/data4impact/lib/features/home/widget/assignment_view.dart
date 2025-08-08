import 'package:data4impact/features/home/widget/assignment_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssignmentView extends StatelessWidget {
  const AssignmentView({super.key});

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
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text('Your active data collection tasks'),
            const SizedBox(height: 16),
          ],
        ),
       const Column(
          children:  [
            AssignmentCard(),
            SizedBox(height: 12),
            AssignmentCard(),
            SizedBox(height: 12),
            AssignmentCard(),
            SizedBox(height: 12),
            AssignmentCard(),
          ],
        ),
      ],
    );
  }
}