import 'package:data4impact/core/service/api_service/Model/current_user.dart';
import 'package:data4impact/core/theme/cubit/theme_cubit.dart';
import 'package:data4impact/features/profile/cubit/profile_cubit.dart';
import 'package:data4impact/features/profile/cubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:skeletonizer/skeletonizer.dart'; // Import the package

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
          backgroundColor: colorScheme.surfaceVariant.withOpacity(0.05),
          body: Skeletonizer(
            enabled: state.isLoading, // Enable skeleton when loading
            child: state.isLoading
                ? _buildSkeletonProfile(context)
                : RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileCubit>().refreshUserData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildProfileHeader(context, state.user),
                    if (state.user != null)
                      _buildPersonalInfoSection(context, state.user!),
                    _buildExperienceSection(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonProfile(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Skeleton Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withOpacity(0.9),
                  colorScheme.primary.withOpacity(0.5),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                        Row(
                          children: [
                            Bone.icon(), // Skeleton theme toggle icon
                          ],
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          // Skeleton profile image
                          Bone.circle(size: 120),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                Bone.text(words: 2), // Skeleton name
                                const SizedBox(height: 8),
                                Bone.text(words: 1), // Skeleton role
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 110,
                        right: MediaQuery.of(context).size.width / 2 - 80,
                        child: Bone.circle(size: 36), // Skeleton camera icon
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Skeleton Personal Info Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Bone.text(words: 2), // Skeleton section title
                        Bone.icon(), // Skeleton edit icon
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ...List.generate(4, (index) => _buildSkeletonInfoTile(context)),
                ],
              ),
            ),
          ),

          // Skeleton Experience Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Bone.text(words: 2), // Skeleton section title
                        Bone.icon(), // Skeleton add icon
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ...List.generate(2, (index) => _buildSkeletonExperienceItem(context)),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Bone.text(words: 3), // Skeleton total experience
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSkeletonInfoTile(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone.circle(size: 40), // Skeleton icon
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone.text(words: 1), // Skeleton title
                    const SizedBox(height: 4),
                    Bone.text(words: 2), // Skeleton value
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          color: colorScheme.outline.withOpacity(0.1),
          indent: 20,
          endIndent: 20,
        ),
      ],
    );
  }

  Widget _buildSkeletonExperienceItem(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone.square(size: 40), // Skeleton company logo
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Bone.text(words: 2), // Skeleton company name
                        Bone.icon(), // Skeleton edit icon
                      ],
                    ),
                    const SizedBox(height: 4),
                    Bone.text(words: 3), // Skeleton role
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Bone.text(words: 1), // Skeleton period
                        const SizedBox(width: 8),
                        Bone.text(words: 1), // Skeleton duration
                      ],
                    ),
                    const SizedBox(height: 8),
                    Bone.text(words: 4), // Skeleton description
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          indent: 20,
          endIndent: 20,
        ),
      ],
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
            colorScheme.primary.withOpacity(0.9),
            colorScheme.primary.withOpacity(0.5),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  Row(
                    children: [
                      BlocBuilder<ProfileCubit, ProfileState>(
                        builder: (context, state) {
                          return IconButton(
                            icon: Icon(
                              state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                              color: colorScheme.onPrimary,
                            ),
                            onPressed: () {
                              context.read<ProfileCubit>().toggleDarkMode();
                              context.read<ThemeCubit>().toggleTheme();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
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
                    const SizedBox(height: 16),
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
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user?.role.toUpperCase() ?? 'Loading role...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimary.withOpacity(0.9),
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 110,
                  right: MediaQuery.of(context).size.width / 2 - 80,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
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
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context, CurrentUser user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
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
                    icon: Icon(Icons.edit, color: colorScheme.primary),
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
              status: user.emailVerified,
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
        bool? status,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: colorScheme.primary,
                ),
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            value,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (status != null)
                          Icon(
                            status ? Icons.check_circle : Icons.error,
                            color: status ? Colors.green : colorScheme.error,
                            size: 16,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: colorScheme.outline.withOpacity(0.1),
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }

  Widget _buildExperienceSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Work Experience',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: colorScheme.primary),
                    onPressed: () {
                      // Handle add experience
                    },
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
              duration: '4 years 8 months',
              description:
              'Specializations: Survey Design, Consumer Research\nManaged team of 15 researchers',
            ),
            _buildExperienceItem(
              context,
              company: 'Data Insights Co.',
              role: 'Senior Research Associate',
              period: 'Jan 2014 - Apr 2016',
              duration: '2 years 4 months',
              description:
              'Specializations: Data Analysis, Market Research\nLed client presentations and reports',
              isLast: true,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.work_history,
                      color: colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Total: 8 years of professional experience',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
        required String duration,
        required String description,
        bool isLast = false,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          company,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, size: 18, color: colorScheme.primary),
                          onPressed: () {
                            // Handle edit experience
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Text(
                          period,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
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
          Divider(
            height: 1,
            color: colorScheme.outline.withOpacity(0.1),
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}