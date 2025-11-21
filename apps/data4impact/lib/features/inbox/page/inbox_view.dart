import 'package:data4impact/core/service/dialog_loading.dart';
import 'package:data4impact/features/inbox/cubit/inbox_cubit.dart';
import 'package:data4impact/features/inbox/cubit/inbox_state.dart';
import 'package:data4impact/features/inbox/widget/invitationcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

class InboxView extends StatefulWidget {
  const InboxView({super.key, this.showAppBar});
  final bool? showAppBar;

  @override
  _InboxViewState createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<InboxCubit>().getInvitation();
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
      appBar: (widget.showAppBar == true)
          ? AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(5),
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              Navigator.pop(context);
            },
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        title: const Text(
          'Inbox',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : null,
      backgroundColor: colorScheme.surface,
      body: BlocListener<InboxCubit, InboxState>(
          listener: (context, state) {
            if (state.isAccepting) {
              DialogLoading.show(context);
            } else {
              DialogLoading.hide(context);
            }
          },
          child: SafeArea(
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
                      indicatorPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      labelColor: colorScheme.primary,
                      unselectedLabelColor:
                      colorScheme.onSurface.withAlpha(255),
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
                        Tab(text: 'Notifications'),
                        Tab(text: 'Invitation'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildNotificationTab(colorScheme, theme),
                        _buildInvitationTab(colorScheme, theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildNotificationTab(ColorScheme colorScheme, ThemeData theme) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationTab(ColorScheme colorScheme, ThemeData theme) {
    return BlocBuilder<InboxCubit, InboxState>(
      builder: (context, state) {
        final invitations = state.invitations ?? [];

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<InboxCubit>().getInvitation(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (invitations.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Invitations',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: invitations.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final invitation = invitations[index];
            return InvitationCard(
              invitation: invitation,
              onAccept: () {
                context
                    .read<InboxCubit>()
                    .acceptInviatation(invitationId: invitation.id);
              },
              onReject: () {
                context
                    .read<InboxCubit>()
                    .declineInvitation(invitationId: invitation.id);
              },
            );
          },
        );
      },
    );
  }
}