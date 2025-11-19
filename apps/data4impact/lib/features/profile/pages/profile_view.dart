import 'package:data4impact/core/service/api_service/Model/current_user.dart';
import 'package:data4impact/core/service/api_service/Model/organization_model.dart';
import 'package:data4impact/core/theme/cubit/theme_cubit.dart';
import 'package:data4impact/features/home/cubit/home_cubit.dart';
import 'package:data4impact/features/profile/cubit/profile_cubit.dart';
import 'package:data4impact/features/profile/cubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfileView> {
  final ImagePicker _picker = ImagePicker();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().fetchCurrentUser();
  }

  // Hive Box Names
  static const List<String> hiveBoxes = [
    'projects_box',
    'studys_box',
    'current_user_box',
    'study_questions_box',
    'offline_answers_box',
    'study_cohorts_box',
    'study_waves_box',
    'study_respondents_box',
    'study_groups_box',
    'study_subjects_box',
  ];

  Future<void> _clearAllHiveData() async {
    try {
      for (final boxName in hiveBoxes) {
        try {
          final box = await Hive.openBox(boxName);
          await box.clear();
          await box.close();
        } catch (e) {}
      }
    } catch (e) {}
  }

  void _performLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Clear secure storage
      await _secureStorage.delete(key: 'session_cookie');
      await _secureStorage.delete(key: 'current_project_id');

      // Clear ALL Hive data
      await _clearAllHiveData();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Navigate to login page using HomeCubit's logout
      if (context.mounted) {
        context.read<HomeCubit>().logout(context);
      }
    } catch (e) {
      // Close loading dialog if there's an error
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            elevation: 0,
            forceMaterialTransparency: true,
            title: Text(
              'Profile',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () {
                  context.read<ProfileCubit>().toggleDarkMode();
                  context.read<ThemeCubit>().toggleTheme();
                },
              ),
            ],
          ),
          body: RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileCubit>().fetchCurrentUser();
              },
              child: _buildProfileContent(context, state)),
        );
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileState state) {
    // Show loading only for initial load, not for saving
    if (state.isLoading && state.user == null) {
      return _buildLoadingState();
    }

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // Profile Header Section
            SliverToBoxAdapter(
              child: _buildProfileHeader(context, state),
            ),

            // Personal Information Section
            SliverToBoxAdapter(
              child: _buildPersonalInfoSection(context, state),
            ),

            // Organization Section
            SliverToBoxAdapter(
              child: _buildOrganizationSection(context, state),
            ),

            // Security Overview Section
            SliverToBoxAdapter(
              child: _buildSecurityOverviewSection(context),
            ),

            // Logout Button Section
            SliverToBoxAdapter(
              child: _buildLogoutButton(context),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),

        // Show loading overlay only when saving
        if (state.isLoading && state.user != null)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your profile...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = state.user;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.8),
            colorScheme.primary.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Image with Edit Button
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: state.tempProfileImage != null
                      ? Image.file(
                          state.tempProfileImage!,
                          fit: BoxFit.cover,
                        )
                      : user?.imageUrl != null
                          ? Image.network(
                              user!.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderAvatar(colorScheme);
                              },
                            )
                          : _buildPlaceholderAvatar(colorScheme),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _pickProfileImage(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // User Name and Role
          Text(
            user?.fullName ?? 'Loading...',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          Text(
            user?.roles.isNotEmpty == true
                ? (user!.roles.first['name'] as String?)?.toUpperCase() ??
                    'USER'
                : 'USER',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.9),
              letterSpacing: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // Edit Profile Button
          ElevatedButton.icon(
            onPressed: state.isLoading
                ? null
                : () => _showEditProfileDialog(context, state),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.primaryContainer,
      child: Icon(
        Icons.person,
        size: 40,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context, ProfileState state) {
    final theme = Theme.of(context);
    final user = state.user;

    if (user == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Text(
              'Personal Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildInfoCard(context, user),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, CurrentUser user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Format the member since date
    String formatMemberSince(DateTime date) {
      return '${date.day}/${date.month}/${date.year}';
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              context,
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.email,
              isVerified: user.emailVerified,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: user.phone ?? 'Not provided',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.calendar_today_outlined,
              label: 'Member Since',
              value: formatMemberSince(DateTime.parse(user.createdAt)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationSection(BuildContext context, ProfileState state) {
    final theme = Theme.of(context);
    final organizations = state.organizations;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Organizations',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.loadingOrganizations)
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _buildOrganizationCard(context, organizations, state),
        ],
      ),
    );
  }

  Widget _buildOrganizationCard(BuildContext context,
      List<UserOrganization> organizations, ProfileState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (state.loadingOrganizations) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (organizations.isEmpty) {
      return Container(
        width: double.infinity,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 48,
                  color: colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'No Organizations',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You are not a member of any organizations yet.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: organizations
              .map((userOrg) => _buildOrganizationItem(context, userOrg))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildOrganizationItem(
      BuildContext context, UserOrganization userOrg) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final org = userOrg.organization;
    final profileService = context.read<ProfileCubit>().profileService;

    // Get the full image URL
    final imageUrl = profileService.getOrganizationImageUrl(org.logoUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Organization Logo
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildOrganizationPlaceholder(
                                colorScheme, org.name);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildOrganizationPlaceholder(
                                colorScheme, org.name);
                          },
                        ),
                      )
                    : _buildOrganizationPlaceholder(colorScheme, org.name),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      org.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Slug: ${org.slug}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Member since ${_formatDate(userOrg.joinedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (userOrg.roles.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        children: userOrg.roles
                            .map(
                              (role) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(role.name, colorScheme),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  role.name.toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationPlaceholder(
      ColorScheme colorScheme, String orgName) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          Icons.business,
          size: 24,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Color _getRoleColor(String roleName, ColorScheme colorScheme) {
    switch (roleName.toLowerCase()) {
      case 'owner':
        return Colors.orange.shade700;
      case 'admin':
        return Colors.red.shade700;
      case 'manager':
        return Colors.blue.shade700;
      case 'member':
        return Colors.green.shade700;
      default:
        return colorScheme.primary;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays < 1) {
        return 'Today';
      } else if (difference.inDays < 30) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years ${years == 1 ? 'year' : 'years'} ago';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  Widget _buildSecurityOverviewSection(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Text(
              'Security Overview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildSecurityCard(context),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            _buildSecurityItem(
              context,
              icon: Icons.lock_outlined,
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: () {
                _showChangePasswordDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ElevatedButton(
        onPressed: () {
          _showLogoutConfirmationDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(0.1),
          foregroundColor: Colors.red,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.red.withOpacity(0.8),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout,
              size: 20,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
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

                // Message
                Text(
                  'Are you sure you want to logout from your account? All local data will be cleared.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.onSurface.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    // Cancel Button
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

                    // Logout Button
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

  Widget _buildSecurityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: colorScheme.primary),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: colorScheme.onSurface.withOpacity(0.5),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isVerified = false,
    bool showCopyButton = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isVerified)
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: Colors.green,
                    ),
                  if (showCopyButton)
                    IconButton(
                      icon: Icon(
                        Icons.content_copy,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      onPressed: () {
                        // Implement copy functionality
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickProfileImage(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Immediately upload the image when selected
      await context.read<ProfileCubit>().uploadProfileImage(File(image.path));
    }
  }

  void _showEditProfileDialog(BuildContext context, ProfileState state) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ProfileCubit>(),
        child: state.user != null
            ? EditProfileDialog(
                user: state.user!,
              )
            : const SizedBox(),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(),
    );
  }
}

class EditProfileDialog extends StatefulWidget {
  final CurrentUser user;

  const EditProfileDialog({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _middleNameController =
        TextEditingController(text: widget.user.middleName ?? '');
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $fieldName';
    }
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<ProfileCubit>().saveProfile(context);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _onFieldChanged(String field, String value) {
    context.read<ProfileCubit>().updateField(field, value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = context.watch<ProfileCubit>().state;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      shadowColor: Colors.black26,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Profile',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            context.read<ProfileCubit>().cancelEditing();
                            Navigator.of(context).pop();
                          },
                    icon: Icon(Icons.close,
                        color: colorScheme.onSurface.withOpacity(0.6)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Update your personal information',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),

              // First Name
              Text(
                'First Name *',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _firstNameController,
                enabled: !state.isLoading,
                validator: (value) => _validateName(value, 'first name'),
                onChanged: (value) => _onFieldChanged('firstName', value),
                decoration: InputDecoration(
                  hintText: 'Enter your first name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Middle Name
              Text(
                'Middle Name',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _middleNameController,
                enabled: !state.isLoading,
                onChanged: (value) => _onFieldChanged('middleName', value),
                decoration: InputDecoration(
                  hintText: 'Enter your middle name (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Last Name
              Text(
                'Last Name *',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastNameController,
                enabled: !state.isLoading,
                validator: (value) => _validateName(value, 'last name'),
                onChanged: (value) => _onFieldChanged('lastName', value),
                decoration: InputDecoration(
                  hintText: 'Enter your last name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Phone
              Text(
                'Phone Number',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                enabled: !state.isLoading,
                validator: _validatePhone,
                keyboardType: TextInputType.phone,
                onChanged: (value) => _onFieldChanged('phone', value),
                decoration: InputDecoration(
                  hintText: 'Enter your phone number (optional)',
                  prefixIcon: Icon(Icons.phone,
                      color: colorScheme.onSurface.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: state.isLoading
                          ? null
                          : () {
                              context.read<ProfileCubit>().cancelEditing();
                              Navigator.of(context).pop();
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        side: BorderSide(color: colorScheme.outline),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: state.isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.onPrimary),
                              ),
                            )
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({Key? key}) : super(key: key);

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your current password';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password changed successfully'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      shadowColor: Colors.black26,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Change Password',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close,
                        color: colorScheme.onSurface.withOpacity(0.6)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your current password and set a new one',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),

              // Current Password
              Text(
                'Current Password',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                validator: _validateCurrentPassword,
                decoration: InputDecoration(
                  hintText: 'Enter current password',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() =>
                        _obscureCurrentPassword = !_obscureCurrentPassword),
                    icon: Icon(
                      _obscureCurrentPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // New Password
              Text(
                'New Password',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                validator: _validateNewPassword,
                decoration: InputDecoration(
                  hintText: 'Enter new password',
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                        () => _obscureNewPassword = !_obscureNewPassword),
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Must be at least 8 characters',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm New Password
              Text(
                'Confirm New Password',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                validator: _validateConfirmPassword,
                decoration: InputDecoration(
                  hintText: 'Confirm your new password',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword),
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        side: BorderSide(color: colorScheme.outline),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.onPrimary),
                              ),
                            )
                          : const Text(
                              'Update Password',
                              style: TextStyle(fontSize: 12),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
