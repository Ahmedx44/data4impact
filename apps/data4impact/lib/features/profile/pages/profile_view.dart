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
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().fetchCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: state.isLoading
              ? _buildLoadingState()
              : _buildProfileContent(context, state),
        );
      },
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
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileState state) {
    return CustomScrollView(
      slivers: [
        // App Bar with Theme Toggle
        SliverAppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          floating: true,
          pinned: true,
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

        // Profile Header Section
        SliverToBoxAdapter(
          child: _buildProfileHeader(context, state),
        ),

        // Personal Information Section
        SliverToBoxAdapter(
          child: _buildPersonalInfoSection(context, state),
        ),

        // Experience Section
        SliverToBoxAdapter(
          child: _buildExperienceSection(context),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
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
                  onTap: () => _pickProfileImage(context, state),
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
            user?.role.toUpperCase() ?? 'LOADING ROLE',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.9),
              letterSpacing: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // Edit Profile Button
          ElevatedButton.icon(
            onPressed: () => _showEditProfileDialog(context, state),
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
              icon: Icons.fingerprint_outlined,
              label: 'User ID',
              value: user.id,
              showCopyButton: true,
            ),
          ],
        ),
      ),
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

  Widget _buildExperienceSection(BuildContext context) {
    final theme = Theme.of(context);

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
                  'Work Experience',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: theme.colorScheme.primary),
                  onPressed: () {
                    // Handle add experience
                  },
                ),
              ],
            ),
          ),
          _buildExperienceList(context),
        ],
      ),
    );
  }

  Widget _buildExperienceList(BuildContext context) {
    final experiences = [
      {
        'company': 'Impact Makers',
        'role': 'Lead Research Analyst',
        'period': 'May 2016 - Present',
        'duration': '4 years 8 months',
        'description': 'Specializations: Survey Design, Consumer Research\nManaged team of 15 researchers',
      },
      {
        'company': 'Data Insights Co.',
        'role': 'Senior Research Associate',
        'period': 'Jan 2014 - Apr 2016',
        'duration': '2 years 4 months',
        'description': 'Specializations: Data Analysis, Market Research\nLed client presentations and reports',
      },
    ];

    return Column(
      children: [
        ...experiences.map((exp) => _buildExperienceItem(context, exp)),
        _buildExperienceSummary(context),
      ],
    );
  }

  Widget _buildExperienceItem(BuildContext context, Map<String, String> experience) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  experience['company']!.substring(0, 2).toUpperCase(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        experience['company']!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.more_vert, size: 18),
                        onPressed: () {
                          // Handle menu options
                        },
                      ),
                    ],
                  ),
                  Text(
                    experience['role']!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: colorScheme.onSurface.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Text(
                        experience['period']!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 12, color: colorScheme.onSurface.withOpacity(0.5)),
                      const SizedBox(width: 2),
                      Text(
                        experience['duration']!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    experience['description']!,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceSummary(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_history, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Total: 8 years of professional experience',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickProfileImage(BuildContext context, ProfileState state) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      context.read<ProfileCubit>().startEditing();
      context.read<ProfileCubit>().setTempProfileImage(File(image.path));
      _showEditProfileDialog(context, state);
    }
  }

  void _showEditProfileDialog(BuildContext context, ProfileState state) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ProfileCubit>(),
        child: EditProfileDialog(
          user: state.user!,
          tempProfileImage: state.tempProfileImage,
        ),
      ),
    );
  }
}

class EditProfileDialog extends StatefulWidget {
  final CurrentUser user;
  final File? tempProfileImage;

  const EditProfileDialog({
    Key? key,
    required this.user,
    this.tempProfileImage,
  }) : super(key: key);

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _middleNameController = TextEditingController(text: widget.user.middleName ?? '');
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Profile',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Profile Image
            GestureDetector(
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  context.read<ProfileCubit>().setTempProfileImage(File(image.path));
                  setState(() {});
                }
              },
              child: Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.primary, width: 2),
                    ),
                    child: ClipOval(
                      child: widget.tempProfileImage != null
                          ? Image.file(widget.tempProfileImage!, fit: BoxFit.cover)
                          : widget.user.imageUrl != null
                          ? Image.network(
                        widget.user.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person, size: 30, color: colorScheme.primary);
                        },
                      )
                          : Icon(Icons.person, size: 30, color: colorScheme.primary),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit, size: 12, color: colorScheme.onPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Fields
            _buildTextField(_firstNameController, 'First Name', (value) {
              context.read<ProfileCubit>().updateField('firstName', value);
            }),
            const SizedBox(height: 12),
            _buildTextField(_middleNameController, 'Middle Name', (value) {
              context.read<ProfileCubit>().updateField('middleName', value);
            }),
            const SizedBox(height: 12),
            _buildTextField(_lastNameController, 'Last Name', (value) {
              context.read<ProfileCubit>().updateField('lastName', value);
            }),
            const SizedBox(height: 12),
            _buildTextField(_phoneController, 'Phone', (value) {
              context.read<ProfileCubit>().updateField('phone', value);
            }, keyboardType: TextInputType.phone),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<ProfileCubit>().cancelEditing();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await context.read<ProfileCubit>().saveProfile(context);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      Function(String) onChanged, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }
}