import 'package:flutter/material.dart';

class AssignmentCard extends StatelessWidget {
  const AssignmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// LEFT SIDE (Details, title, status, progress)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Top Row: Title + Overdue Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Brand Awareness Analysis',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Overdue',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  /// Subtitle
                  const Text(
                    'Measuring brand recognition and recall across target demographics',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),

                  const SizedBox(height: 12),

                  /// Status and Earnings
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Overdue',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.circle, size: 8, color: Colors.black),
                      const SizedBox(width: 4),
                      const Text(
                        '5 days overdue',
                        style: TextStyle(fontSize: 8),
                      ),
                      const Spacer(),
                      const Text(
                        'Earnings: \$2,520.00',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// Linear Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.77,
                      minHeight: 12,
                      backgroundColor: Colors.grey[300],
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            /// RIGHT SIDE (Progress Circle and Button)
            Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 35,
                      height: 35,
                      child: CircularProgressIndicator(
                        value: 0.77,
                        strokeWidth: 4,
                        backgroundColor: Colors.grey[300],
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                      ),
                    ),
                    const Text(
                      '77%',
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('385/500',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Text('Responses', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: const Text('Continue',style: TextStyle(fontSize: 10),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}