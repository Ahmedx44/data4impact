import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/contributors/page/contributors_page.dart';
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

class _NavigationViewState extends State<NavigationView>
    with AutomaticKeepAliveClientMixin {
  int visit = 0;
  late List<TabItem> items;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _sessionToken;
  bool _initialLoadCompleted = false;
  bool _showStaticScreen = false;

  final List<bool> _pagesInitialized = [];
  final List<Widget> _pages = [];
  final PageStorageBucket _pageStorageBucket = PageStorageBucket();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeNavigationItems();
    _checkToken();
    _checkInitialProjectState();
    _fetchUserData();
  }

  Future<void> _checkToken() async {
    _sessionToken = await _secureStorage.read(key: 'session_cookie');
    setState(() {});
  }

  void _fetchUserData() {
    final profileCubit = context.read<ProfileCubit>();
    profileCubit.fetchCurrentUser();
  }

  void _checkInitialProjectState() {
    final homeCubit = context.read<HomeCubit>();
    // Check current project state immediately
    if (!homeCubit.state.fetchingProjects && homeCubit.state.projects.isEmpty) {
      _showStaticScreen = true;
    }

    if (homeCubit.state.projects.isEmpty && !homeCubit.state.fetchingProjects) {
      homeCubit.fetchAllProjects().then((_) {
        if (mounted) {
          setState(() {
            _showStaticScreen = homeCubit.state.projects.isEmpty;
            _initialLoadCompleted = true;
          });
        }
      });
    }
  }

  void _initializeNavigationItems() {
    items = const [
      TabItem(icon: HugeIcons.strokeRoundedHome01, title: 'Home'),
      TabItem(icon: HugeIcons.strokeRoundedInboxDownload, title: 'Inbox'),
      TabItem(icon: HugeIcons.strokeRoundedLayers01, title: 'Study'),
      TabItem(icon: HugeIcons.strokeRoundedUserGroup, title: 'Team'),
      TabItem(icon: HugeIcons.strokeRoundedUser, title: 'Profile'),
    ];

    _pages.clear();
    _pagesInitialized.clear();
    for (int i = 0; i < items.length; i++) {
      _pages.add(Container()); // Placeholder
      _pagesInitialized.add(false);
    }
  }

  void _initializeAdminNavigationItems() {
    items = const [
      TabItem(icon: HugeIcons.strokeRoundedHome01, title: 'Home'),
      TabItem(icon: HugeIcons.strokeRoundedInboxDownload, title: 'Inbox'),
      TabItem(icon: HugeIcons.strokeRoundedLayers01, title: 'Study'),
      TabItem(icon: HugeIcons.strokeRoundedUserGroup, title: 'Contributors'),
      TabItem(icon: HugeIcons.strokeRoundedUserGroup, title: 'Team'),
      TabItem(icon: HugeIcons.strokeRoundedUser, title: 'Profile'),
    ];

    _pages.clear();
    _pagesInitialized.clear();
    for (int i = 0; i < items.length; i++) {
      _pages.add(Container()); // Placeholder
      _pagesInitialized.add(false);
    }
  }

  Widget _buildPage(int index) {
    if (!_pagesInitialized[index]) {
      _pagesInitialized[index] = true;

      Widget page;
      if (items.length == 6) {
        switch (index) {
          case 0:
            page = const HomePage();
            break;
          case 1:
            page = const InboxPage();
            break;
          case 2:
            page = const StudyPage();
            break;
          case 3:
            page = const ContributorsPage();
            break;
          case 4:
            page = const TeamPage();
            break;
          case 5:
            page = const ProfilePage();
            break;
          default:
            page = Container();
        }
      } else {
        switch (index) {
          case 0:
            page = const HomePage();
            break;
          case 1:
            page = const InboxPage();
            break;
          case 2:
            page = const StudyPage();
            break;
          case 3:
            page = const TeamPage();
            break;
          case 4:
            page = const ProfilePage();
            break;
          default:
            page = Container();
        }
      }

      _pages[index] = PageStorage(
        bucket: _pageStorageBucket,
        child: page,
      );
    }

    return _pages[index];
  }

  bool _isAdmin(ProfileState state) {
    if (state.user?.role == null) {
      return false;
    }
    final role = state.user!.role!.toLowerCase();
    final isAdmin =
        role == 'admin' || role == 'administrator' || role == 'owner';
    return isAdmin;
  }

  bool _hasValidUser(ProfileState state) {
    final hasValidUser = state.user != null &&
        state.user!.id != null &&
        state.user!.id!.isNotEmpty;

    if (hasValidUser) {
    } else {}
    return hasValidUser;
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
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
    super.build(context);
    final theme = Theme.of(context).colorScheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<HomeCubit, HomeState>(
          listener: (context, homeState) {
            if (!homeState.fetchingProjects) {
              final hasProjects = homeState.projects.isNotEmpty;

              if (_showStaticScreen != !hasProjects) {
                setState(() {
                  _showStaticScreen = !hasProjects;
                  _initialLoadCompleted = true;
                });
              }
            }
          },
        ),
      ],
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, homeState) {
          if (_showStaticScreen && !homeState.fetchingProjects) {
            return _buildStaticScreen();
          }
          if (homeState.fetchingProjects && !_initialLoadCompleted) {
            return _buildLoadingScreen();
          }

          return BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              if (profileState.isLoading) {
                return _buildLoadingScreen();
              }

              final hasValidUser = _hasValidUser(profileState);

              if (hasValidUser) {
                final isAdmin = _isAdmin(profileState);

                if (isAdmin) {
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
                  children: [
                    for (int i = 0; i < items.length; i++) _buildPage(i),
                  ],
                ),
                bottomNavigationBar: _showStaticScreen
                    ? null
                    : BottomBarDefault(
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
          );
        },
      ),
    );
  }
}
