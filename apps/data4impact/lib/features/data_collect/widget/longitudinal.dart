import 'package:data4impact/features/data_collect/cubit/data_collet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/data_collect_cubit.dart';

class LongitudinalDataCollection extends StatefulWidget {
  final String studyId;

  const LongitudinalDataCollection({super.key, required this.studyId});

  @override
  State<LongitudinalDataCollection> createState() => _LongitudinalDataCollectionState();
}

class _LongitudinalDataCollectionState extends State<LongitudinalDataCollection> {
  @override
  void initState() {
    super.initState();
    // Initialize longitudinal data collection
    context.read<DataCollectCubit>().getStudyQuestions(widget.studyId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataCollectCubit, DataCollectState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Longitudinal Study'),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timeline, size: 64),
                SizedBox(height: 16),
                Text(
                  'Longitudinal Data Collection',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('This is the longitudinal study data collection interface.'),
              ],
            ),
          ),
        );
      },
    );
  }
}