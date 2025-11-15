import 'package:data4impact/core/service/api_service/invitation_service.dart';
import 'package:data4impact/features/inbox/cubit/inbox_cubit.dart';
import 'package:data4impact/features/inbox/page/inbox_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key,this.showAppBar});
  final bool? showAppBar;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InboxCubit(invitationService: context.read<InvitationService>()),
      child:  InboxView(showAppBar: showAppBar),
    );
  }
}
