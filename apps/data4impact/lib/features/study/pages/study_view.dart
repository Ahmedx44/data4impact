import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:data4impact/core/service/api_service/study_service.dart';
import 'package:data4impact/features/study/cubit/study_cubit.dart';
import 'package:data4impact/features/study/cubit/study_state.dart';
import 'package:data4impact/features/study/widget/study_card.dart';
import 'package:data4impact/features/study_detail/pages/study_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudyView extends StatefulWidget {
  final String projectSlug;

  const StudyView({super.key, required this.projectSlug});

  @override
  _StudyViewState createState() => _StudyViewState();
}

class _StudyViewState extends State<StudyView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Material(
                color: colorScheme.surface,
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                  splashFactory: NoSplash.splashFactory,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurface.withAlpha(255),
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                  dividerColor: Colors.transparent,
                  dividerHeight: 0,
                  tabs: const [
                    Tab(text: 'Active Study'),
                    Tab(text: 'Old Study'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildActiveStudiesTab(),
                    _buildOldStudiesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveStudiesTab() {
    return BlocBuilder<StudyCubit, StudyState>(
      builder: (context, state) {
        if (state is StudyInitial || state is StudyLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StudyError) {
          return Center(child: Text(state.message));
        } else if (state is StudyLoaded) {
          final activeStudies = state.studies.where((study) =>
          study['status'] == 'inProgress' || study['status'] == 'draft');

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeStudies.length,
            itemBuilder: (context, index) {
              final study = activeStudies.elementAt(index);
              return GestureDetector(
                child: StudyCard(
                  title: study['name']as String,
                  description: study['description'] as String,
                  progress: (study['responseCount']!  / study['sampleSize']) as double ,
                  status: study['status'] as String,
                  dueDate: study['closeOnDate']!=null?study['closeOnDate'] as String:'',
                  callback: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<Widget>(
                        builder: (context) =>  StudyDetailPage(studyId: study['_id'] as String),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildOldStudiesTab() {
    return BlocBuilder<StudyCubit, StudyState>(
      builder: (context, state) {
        if (state is StudyInitial || state is StudyLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StudyError) {
          return Center(child: Text(state.message));
        } else if (state is StudyLoaded) {
          final oldStudies = state.studies.where((study) =>
          study['status'] != 'inProgress' && study['status'] != 'draft');

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: oldStudies.length,
            itemBuilder: (context, index) {
              final study = oldStudies.elementAt(index);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (context) => StudyDetailPage(studyId: study['_id'] as String),
                    ),
                  );
                },
                child: StudyCard(
                  title: study['name']as String,
                  description: study['description'] as String,
                  progress: (study['responseCount']!  / study['sampleSize']) as double ,
                  status: study['status'] as String,
                  dueDate: study['closeOnDate'] as String,
                  callback: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<Widget>(
                        builder: (context) =>  StudyDetailPage(studyId: study['_id'] as String),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}