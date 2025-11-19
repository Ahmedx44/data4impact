import 'package:data4impact/features/home/widget/assignment_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AssignmentView extends StatelessWidget {
  final List<Map<String, dynamic>> collectors;

  const AssignmentView({super.key, required this.collectors});

  @override
  Widget build(BuildContext context) {
    if (collectors.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: collectors.map((collector) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AssignmentCard(collector: collector),
            );
          }).toList(),
        ),
      ),
    );
  }
}
