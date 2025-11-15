import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/collectors/page/collectors_page.dart';
import 'package:data4impact/features/home/cubit/home_cubit.dart';
import 'package:data4impact/features/home/cubit/home_state.dart';
import 'package:data4impact/features/home/page/home_page.dart';
import 'package:data4impact/features/inbox/page/indox_page.dart';
import 'package:data4impact/features/login/page/login_page.dart';
import 'package:data4impact/features/profile/cubit/profile_cubit.dart';
import 'package:data4impact/features/profile/cubit/profile_state.dart';
import 'package:data4impact/features/profile/pages/profile_page.dart';
import 'package:data4impact/features/study/pages/study_page.dart';
import 'package:data4impact/features/team/page/team_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hugeicons/hugeicons.dart';

class NavigationView extends StatefulWidget {
  const NavigationView({super.key});

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  int visit = 0;
  late List<TabItem> items;
  late List<Widget> pages;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _sessionToken;
  bool _initialLoadCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeNavigationItems();
    _checkToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeCubit = context.read<HomeCubit>();

      if (homeCubit.state.projects.isEmpty && !homeCubit.state.isLoading) {
        homeCubit.fetchAllProjects();
      } else {}
    });
  }

  Future<void> _checkToken() async {
    _sessionToken = await _secureStorage.read(key: 'session_cookie');
    setState(() {});
  }

  void _initializeNavigationItems() {
    items = const [
      TabItem(icon: HugeIcons.strokeRoundedHome01, title: 'Home'),
      TabItem(icon: HugeIcons.strokeRoundedInboxDownload, title: 'Inbox'),
      TabItem(icon: HugeIcons.strokeRoundedLayers01, title: 'Study'),
      TabItem(icon: HugeIcons.strokeRoundedUserGroup, title: 'Team'),
      TabItem(icon: HugeIcons.strokeRoundedUser, title: 'Profile'),
    ];

    pages = const [
      HomePage(),
      InboxPage(),
      StudyPage(),
      TeamPage(),
      ProfilePage(),
    ];
  }

  void _initializeAdminNavigationItems() {
    print('Debug:: _initializeAdminNavigationItems called');
    items = const [
      TabItem(icon: HugeIcons.strokeRoundedHome01, title: 'Home'),
      TabItem(icon: HugeIcons.strokeRoundedInboxDownload, title: 'Inbox'),
      TabItem(icon: HugeIcons.strokeRoundedLayers01, title: 'Study'),
      TabItem(icon: HugeIcons.strokeRoundedUserGroup, title: 'Contributors'),
      TabItem(icon: HugeIcons.strokeRoundedUserGroup, title: 'Team'),
      TabItem(icon: HugeIcons.strokeRoundedUser, title: 'Profile'),
    ];

    pages = const [
      HomePage(),
      InboxPage(),
      StudyPage(),
      CollectorsPage(),
      TeamPage(),
      ProfilePage(),
    ];
  }

  bool _isAdmin(ProfileState state) {
    final isAdmin = state.user?.role?.toLowerCase() == 'admin' ||
        state.user?.role?.toLowerCase() == 'administrator';
    return isAdmin;
  }

  bool _hasValidUser(ProfileState state) {
    final hasValidUser = state.user != null &&
        state.user!.id != null &&
        state.user!.id!.isNotEmpty;
    return hasValidUser;
  }

  bool _hasSubjects(HomeState state) {
    final hasSubjects = state.projects.isNotEmpty;
    return hasSubjects;
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticScreen() {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('assets/image/d4i.png'),
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to Data4Impact!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "You're not in any organization yet. Check your invitations or request one from an admin",
                style: TextStyle(
                  fontSize: 15,
                  color: theme.onSurface.withAlpha(150),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Material(
                  color: theme.primary,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<Widget>(
                          builder: (context) => const InboxPage(
                            showAppBar: true,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Center(
                      child: Text(
                        'View Invitation',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.primary),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: _showLogoutConfirmationDialog,
                    borderRadius: BorderRadius.circular(14),
                    child: Center(
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    final theme = Theme.of(context).colorScheme;
    showDialog<Widget>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    HugeIcons.strokeRoundedLogout01,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Logout?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Are you sure you want to logout from your account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.onSurface.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.outline),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: theme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade500,
                              Colors.red.shade700,
                            ],
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              _performLogout();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  HugeIcons.strokeRoundedLogout01,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performLogout() async {
    try {
      await _secureStorage.delete(key: 'session_cookie');
      await _secureStorage.delete(key: 'current_project_id');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );

      ToastService.showSuccessToast(message: 'Logout successful');
    } catch (e) {
      ToastService.showErrorToast(message: 'Logout failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return BlocListener<HomeCubit, HomeState>(
      listener: (context, homeState) {
        if (_hasSubjects(homeState)) {
          final profileState = context.read<ProfileCubit>().state;
          if (_hasValidUser(profileState)) {
            if (_isAdmin(profileState)) {
              _initializeAdminNavigationItems();
            } else {
              _initializeNavigationItems();
            }
          }

          if (!_initialLoadCompleted) {
            setState(() {
              _initialLoadCompleted = true;
            });
          }
        }
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, homeState) {
          final profileState = context.watch<ProfileCubit>().state;

          // Show loading screen only during initial load when no projects exist
          if (homeState.fetchingProjects) {
            return _buildLoadingScreen();
          }

          final hasSubjects = _hasSubjects(homeState);
          final hasValidUser = _hasValidUser(profileState);

          if (!hasSubjects && !homeState.isLoading) {
            return _buildStaticScreen();
          }
          // Initialize navigation items based on user role
          if (hasValidUser) {
            if (_isAdmin(profileState)) {
              _initializeAdminNavigationItems();
            } else {
              _initializeNavigationItems();
            }
          } else {
            _initializeNavigationItems();
          }

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
        },
      ),
    );
  }
}