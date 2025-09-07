import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:data4impact/core/theme/color.dart';
import 'package:data4impact/features/collectors/page/collectors_page.dart';
import 'package:data4impact/features/home/page/home_page.dart';
import 'package:data4impact/features/inbox/page/indox_page.dart';
import 'package:data4impact/features/profile/pages/profile_page.dart';
import 'package:data4impact/features/profile/pages/profile_view.dart';
import 'package:data4impact/features/study/pages/study_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hugeicons/hugeicons.dart';

class NavigationView extends StatefulWidget {
  const NavigationView({super.key});

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  int visit = 0;
  String? userRole;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  late List<TabItem> items;
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _initializeNavigationItems();
  }

  Future<void> _loadUserRole() async {
    final role = await secureStorage.read(key: 'user_role');
    setState(() {
      userRole = role;
      _initializeNavigationItems();
    });
  }

  void _initializeNavigationItems() {
    // Base navigation items
    final baseItems = [
      const TabItem(icon: HugeIcons.strokeRoundedHome01, title: 'Home'),
      const TabItem(icon: HugeIcons.strokeRoundedInboxDownload, title: 'Inbox'),
      const TabItem(icon: HugeIcons.strokeRoundedLayers01, title: 'Study'),
      const TabItem(icon: HugeIcons.strokeRoundedUser, title: 'Profile'),
    ];

    final basePages = [
      const HomePage(),
      const InboxPage(),
      const StudyPage(),
      const ProfilePage(),
    ];

    // Add Contributors tab if user is not a regular user
    if (userRole != null && userRole != 'user') {
      items = [
        ...baseItems.sublist(0, 3), // Home, Inbox, Study
        const TabItem(icon: HugeIcons.strokeRoundedUserGroup, title: 'Contributors'),
        ...baseItems.sublist(3), // Profile
      ];

      pages = [
        ...basePages.sublist(0, 3),
        const CollectorsPage(),
        ...basePages.sublist(3),
      ];
    } else {
      items = baseItems;
      pages = basePages;
    }
  }

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
        color: theme.onSurface,
        colorSelected: theme.primary,
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