import 'package:data4impact/core/service/api_service/contributor_service.dart';
import 'package:data4impact/features/contributors/cubit/contributors_cubit.dart';
import 'package:data4impact/features/contributors/page/contributors_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContributorsPage extends StatelessWidget {
  const ContributorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContributorsCubit(
        contributorService: context.read<ContributorService>(),
      ),
      child: const ContributorsView(),
    );
  }
}
