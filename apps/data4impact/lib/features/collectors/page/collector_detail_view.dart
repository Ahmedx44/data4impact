import 'package:data4impact/features/collectors/page/collectors_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CollectorDetailView extends StatelessWidget {
  final Profile profile;

  const CollectorDetailView({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Collector Details',
          style: GoogleFonts.lexendDeca(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 48,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                profile.name,
                style: GoogleFonts.lexendDeca(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: profile.status == "Active"
                      ? Colors.green.withOpacity(0.1)
                      : profile.status == "On Leave"
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  profile.status,
                  style: GoogleFonts.lexendDeca(
                    color: profile.status == "Active"
                        ? Colors.green
                        : profile.status == "On Leave"
                        ? Colors.orange
                        : Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildDetailSection(
              context,
              title: "Contact Information",
              items: [
                _buildDetailItem(context, Icons.email, "Email", profile.email),
                _buildDetailItem(context, Icons.phone, "Phone", profile.phone),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailSection(
              context,
              title: "Professional Information",
              items: [
                _buildDetailItem(
                    context, Icons.work, "Experience", profile.experience),
                _buildDetailItem(context, Icons.star, "Specialization",
                    profile.specialization),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailSection(
              context,
              title: "Performance Metrics",
              items: [
                _buildDetailItem(context, Icons.assignment_turned_in,
                    "Active Studies", profile.activeStudies.toString()),
                _buildDetailItem(context, Icons.assignment, "Completed Studies",
                    profile.completedStudies.toString()),
                _buildDetailItem(context, Icons.timer, "Average Response Time",
                    profile.avgRating),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(
      BuildContext context, {required String title, required List<Widget> items}) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.lexendDeca(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
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