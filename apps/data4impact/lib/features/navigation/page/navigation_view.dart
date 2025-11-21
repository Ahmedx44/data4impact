import 'dart:ui';

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
  bool _initialDataLoaded = false;
  bool _showStaticScreen = false;
  bool _isInitialLoad = true;

  final List<bool> _pagesInitialized = [];
  final List<Widget> _pages = [];
  final PageStorageBucket _pageStorageBucket = PageStorageBucket();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeNavigationItems();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _checkToken();
      await _fetchInitialData();

      if (mounted) {
        setState(() {
          _initialDataLoaded = true;
          _isInitialLoad = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialDataLoaded = true;
          _isInitialLoad = false;
        });
      }
    }
  }

  Future<void> _checkToken() async {
    _sessionToken = await _secureStorage.read(key: 'session_cookie');
  }

  Future<void> _fetchInitialData() async {
    final homeCubit = context.read<HomeCubit>();
    final profileCubit = context.read<ProfileCubit>();

    await homeCubit.fetchAllProjects();
    await profileCubit.fetchCurrentUser();

    if (homeCubit.state.selectedProject != null) {
      await homeCubit.fetchMyCollectors();
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

  // Glass effect floating island-style bottom navigation bar using Stack
  Widget _buildFloatingGlassBottomNavigationBar() {
    final theme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Adaptive sizing based on screen width
    final bool isTablet = screenWidth >= 600;
    final double iconSize = isTablet ? 24.0 : 22.0;
    final double fontSize = isTablet ? 12.0 : 11.0;
    final double barHeight = isTablet ? 72 : 68;

    return Stack(
      children: [
        Container(
          height: barHeight + 16,
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Container(
            height: barHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.85),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: -2,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: theme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5.0,
                  sigmaY: 5.0,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final isSelected = index == visit;

                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  visit = index;
                                });
                              },
                              splashColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? theme.primary.withOpacity(0.15)
                                      : Colors.transparent,
                                  border: isSelected
                                      ? Border.all(
                                    color: theme.primary.withOpacity(0.4),
                                    width: 1.5,
                                  )
                                      : null,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Icon with smooth transition and floating effect
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      transform: Matrix4.identity()
                                        ..scale(isSelected ? 1.15 : 1.0)
                                        ..translate(
                                          0.0,
                                          isSelected ? -2.0 : 0.0,
                                        ),
                                      child: Icon(
                                        item.icon as IconData,
                                        size: iconSize,
                                        color: isSelected
                                            ? theme.primary
                                            : theme.onSurface.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Text with smooth color transition
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 300),
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? theme.primary
                                            : theme.onSurface.withOpacity(0.7),
                                        letterSpacing: isSelected ? 0.5 : 0.0,
                                      ),
                                      child: Text(
                                        item.title as String,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context).colorScheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<HomeCubit, HomeState>(
          listener: (context, homeState) {
            if (!homeState.fetchingProjects && _isInitialLoad) {
              final hasProjects = homeState.projects.isNotEmpty;
              setState(() {
                _showStaticScreen = !hasProjects;
                _initialDataLoaded = true;
                _isInitialLoad = false;
              });
            }
          },
        ),
      ],
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, homeState) {
          // Show loading only during initial load
          if (_isInitialLoad && !_initialDataLoaded) {
            return _buildLoadingScreen();
          }

          if (_showStaticScreen && !homeState.fetchingProjects) {
            return _buildStaticScreen();
          }

          return BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
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
                body: Stack(
                  children: [
                    // Main content
                    IndexedStack(
                      index: visit,
                      children: [
                        for (int i = 0; i < items.length; i++) _buildPage(i),
                      ],
                    ),
                    // Floating glass bottom navigation bar
                    if (!_showStaticScreen)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _buildFloatingGlassBottomNavigationBar(),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}