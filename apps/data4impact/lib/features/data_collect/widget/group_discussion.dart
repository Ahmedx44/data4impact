import 'package:data4impact/features/data_collect/cubit/data_collet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/data_collect_cubit.dart';

class GroupDiscussionDataCollection extends StatefulWidget {
  final String studyId;

  const GroupDiscussionDataCollection({super.key, required this.studyId});

  @override
  State<GroupDiscussionDataCollection> createState() => _GroupDiscussionDataCollectionState();
}

class _GroupDiscussionDataCollectionState extends State<GroupDiscussionDataCollection> {
  @override
  void initState() {
    super.initState();
    // Initialize group discussion data collection
    context.read<DataCollectCubit>().getStudyQuestions(widget.studyId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataCollectCubit, DataCollectState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Group Discussion'),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group, size: 64),
                SizedBox(height: 16),
                Text(
                  'Group Discussion Data Collection',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('This is the group discussion data collection interface.'),
              ],
            ),
          ),
        );
      },
    );
  }
}