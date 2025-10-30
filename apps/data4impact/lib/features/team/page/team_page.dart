import 'package:data4impact/core/service/api_service/team_service.dart';
import 'package:data4impact/features/team/cubit/team_cubit.dart';
import 'package:data4impact/features/team/page/team_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TeamCubit(teamService: context.read<TeamService>()),
      child: const TeamView(),
    );
  }
}
