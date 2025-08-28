import 'package:data4impact/core/service/api_service/Model/current_user.dart';
import 'package:data4impact/core/theme/cubit/theme_cubit.dart';
import 'package:data4impact/features/profile/cubit/profile_cubit.dart';
import 'package:data4impact/features/profile/cubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfileView> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Fetch user data when the profile view is opened
    context.read<ProfileCubit>().fetchCurrentUser();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colorScheme.surfaceVariant.withOpacity(0.1),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildProfileHeader(context, state.user),
                ),
                pinned: true,
                actions: [
                  // Dark mode toggle button
                  IconButton(
                    icon: Icon(
                      state.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      context.read<ProfileCubit>().toggleDarkMode();
                      // Also update the global theme
                      context.read<ThemeCubit>().toggleTheme();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: colorScheme.onPrimary),
                    onPressed: () {
                      // Handle edit profile
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
                    onPressed: () {
                      context.read<ProfileCubit>().refreshUserData();
                    },
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  if (state.user != null) _buildPersonalInfoSection(context, state.user!),
                  _buildExperienceSection(context),
                  const SizedBox(height: 20),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, CurrentUser? user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary.withOpacity(0.8),
            colorScheme.primary.withOpacity(0.4),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 120,
                height: 120,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _profileImage != null
                      ? Image.file(
                    _profileImage!,
                    fit: BoxFit.cover,
                  )
                      : user?.imageUrl != null
                      ? Image.network(
                    user!.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      );
                    },
                  )
                      : Container(
                    color: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 15,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  user?.fullName ?? 'Loading...',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.role.toUpperCase() ?? 'Loading role...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context, CurrentUser user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Personal Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    color: colorScheme.primary,
                    onPressed: () {
                      // Handle edit personal info
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _buildInfoTile(
              context,
              icon: Icons.email,
              title: 'Email',
              value: user.email,
            ),
            _buildInfoTile(
              context,
              icon: Icons.phone,
              title: 'Phone',
              value: user.phone ?? 'No phone number provided',
            ),
            _buildInfoTile(
              context,
              icon: Icons.verified_user,
              title: 'Email Verified',
              value: user.emailVerified ? 'Verified' : 'Not Verified',
            ),
            _buildInfoTile(
              context,
              icon: Icons.person,
              title: 'User ID',
              value: user.id,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
        bool isLast = false,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 24,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              color: colorScheme.outline.withOpacity(0.1),
            ),
          ),
      ],
    );
  }

  Widget _buildExperienceSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Experience',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        color: colorScheme.primary,
                        onPressed: () {
                          // Handle add experience
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        color: colorScheme.primary,
                        onPressed: () {
                          // Handle edit experience
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _buildExperienceItem(
              context,
              company: 'Impact Makers',
              role: 'Lead Research Analyst',
              period: 'May 2016 - Present',
              description:
              'Specializations: Survey Design, Consumer Research\nManaged team of 15 researchers',
            ),
            _buildExperienceItem(
              context,
              company: 'Data Insights Co.',
              role: 'Senior Research Associate',
              period: 'Jan 2014 - Apr 2016',
              description:
              'Specializations: Data Analysis, Market Research\nLed client presentations and reports',
              isLast: true,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '8 years of professional experience',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceItem(
      BuildContext context, {
        required String company,
        required String role,
        required String period,
        required String description,
        bool isLast = false,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    company.substring(0, 2).toUpperCase(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      period,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              color: colorScheme.outline.withOpacity(0.1),
            ),
          ),
      ],
    );
  }
}