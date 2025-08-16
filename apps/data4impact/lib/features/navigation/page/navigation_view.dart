import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:data4impact/core/theme/color.dart';
import 'package:data4impact/features/collectors/page/collectors_page.dart';
import 'package:data4impact/features/home/page/home_page.dart';
import 'package:data4impact/features/inbox/page/indox_page.dart';
import 'package:data4impact/features/profile/pages/profile_view.dart';
import 'package:data4impact/features/study/pages/study_page.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class NavigationView extends StatefulWidget {
  const NavigationView({super.key});

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  int visit = 0;

  final items = const [
    TabItem(icon: HugeIcons.strokeRoundedHome01, title: 'Home'),
    TabItem(icon: HugeIcons.strokeRoundedInboxDownload, title: 'Inbox'),
    TabItem(icon: HugeIcons.strokeRoundedLayers01, title: 'Study'),
    TabItem(icon: HugeIcons.strokeRoundedUserGroup, title: 'Collectors'),
    TabItem(icon: HugeIcons.strokeRoundedUser, title: 'Profile'),
  ];

  final List<Widget> pages = const [
    HomePage(),
    InboxPage(),
    StudyPage(),
    CollectorsPage(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      body: IndexedStack(
        index: visit,
        children: pages,
      ),
      bottomNavigationBar: BottomBarDefault(
        items: items,
        backgroundColor: theme.surface,
        color: theme.onPrimary,
        colorSelected: AppColors.primary,
        indexSelected: visit,
        paddingVertical: 15,
        onTap: (int index) {
          setState(() {
            visit = index;
          });
        },
      ),
    );
  }
}
