import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SkeletonStudyCard extends StatelessWidget {
  const SkeletonStudyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3,
      shadowColor: colorScheme.primary.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.08),
          width: 1,
        ),
      ),
      color: colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surface,
              colorScheme.surfaceVariant.withOpacity(0.3),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header with status and title
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skeleton status indicator with icon
                  Bone.circle(size: 40), // Icon container
                  SizedBox(width: 16),

                  // Skeleton title and status badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title skeleton
                        Bone.text(
                          words: 2,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 8),
                        // Status badge skeleton
                        Bone.text(
                          words: 1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Skeleton description
              const Bone.text(
                words: 3,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              /// Skeleton progress section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Bone.text(
                        words: 2,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Bone.text(
                        words: 1,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Skeleton progress bar
                  Bone(
                    width: double.infinity,
                    height: 12,
                    borderRadius: BorderRadius.circular(8),
                  ),

                  // Skeleton progress dots
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SkeletonProgressDot(),
                      _SkeletonProgressDot(),
                      _SkeletonProgressDot(),
                      _SkeletonProgressDot(),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// Skeleton action button
               Center(
                child: Bone(
                  width: 180,
                  height: 48,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Skeleton progress dot indicator
class _SkeletonProgressDot extends StatelessWidget {
  const _SkeletonProgressDot();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Bone.circle(size: 8),
        SizedBox(height: 4),
        Bone.text(
          words: 1,
          style: TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}