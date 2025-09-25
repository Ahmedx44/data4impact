import 'dart:convert';
import 'package:data4impact/features/collectors/page/collector_detail_view.dart';
import 'package:data4impact/features/home/cubit/home_cubit.dart';
import 'package:data4impact/features/home/cubit/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CollectorsView extends StatefulWidget {
  const CollectorsView({super.key});

  @override
  State<CollectorsView> createState() => _CollectorsPageState();
}

class _CollectorsPageState extends State<CollectorsView> {
  final TextEditingController _searchController = TextEditingController();
  List<Profile> _allProfiles = [];
  List<Profile> _filteredProfiles = [];

  @override
  void initState() {
    super.initState();
    _initializeProfiles();
    _searchController.addListener(_filterProfiles);
  }

  void _initializeProfiles() {
    _allProfiles = [
      Profile(
        name: "Harun Jeylan",
        email: "harunyey@gmail.com",
        phone: "+31 884 444 0555",
        experience: "3 years",
        specialization: "Survey Design, Consumer Research",
        activeStudies: 3,
        completedStudies: 19,
        avgRating: "Avg 2.3 min/response",
        status: "Active",
      ),
      Profile(
        name: "Sarah Johnson",
        email: "sarah.j@example.com",
        phone: "+31 123 456 7890",
        experience: "5 years",
        specialization: "Market Analysis, Data Collection",
        activeStudies: 5,
        completedStudies: 24,
        avgRating: "Avg 1.8 min/response",
        status: "Active",
      ),
      Profile(
        name: "Michael Chen",
        email: "michael.c@example.com",
        phone: "+31 987 654 3210",
        experience: "2 years",
        specialization: "Qualitative Research",
        activeStudies: 2,
        completedStudies: 12,
        avgRating: "Avg 3.1 min/response",
        status: "On Leave",
      ),
      Profile(
        name: "Emma Wilson",
        email: "emma.w@example.com",
        phone: "+31 555 123 4567",
        experience: "4 years",
        specialization: "Statistical Analysis",
        activeStudies: 4,
        completedStudies: 21,
        avgRating: "Avg 2.0 min/response",
        status: "Active",
      ),
      Profile(
        name: "David Kim",
        email: "david.k@example.com",
        phone: "+31 789 456 1230",
        experience: "1 year",
        specialization: "Field Research",
        activeStudies: 1,
        completedStudies: 8,
        avgRating: "Avg 2.5 min/response",
        status: "Training",
      ),
    ];
    _filteredProfiles = List.from(_allProfiles);
  }

  void _filterProfiles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProfiles = _allProfiles.where((profile) {
        return profile.name.toLowerCase().contains(query) ||
            profile.email.toLowerCase().contains(query) ||
            profile.specialization.toLowerCase().contains(query) ||
            profile.status.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _exportData() {
    final jsonData = jsonEncode(_allProfiles.map((p) => p.toJson()).toList());
    Clipboard.setData(ClipboardData(text: jsonData));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile data copied to clipboard',
          style: GoogleFonts.lexendDeca(),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<HomeCubit,HomeState>(
      listener: (context, state) {
        if(state.projects.isNotEmpty){

        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surfaceVariant.withOpacity(0.1),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildProfileList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: Row(
          children: [
            Icon(
              Icons.filter_list_rounded,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search collectors...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    hintStyle: GoogleFonts.lexendDeca(
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                  style: GoogleFonts.lexendDeca(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: _exportData,
              icon: Icon(
                Icons.download_rounded,
                color: colorScheme.primary,
              ),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProfiles.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildProfileCard(_filteredProfiles[index], context),
        );
      },
    );
  }

  Widget _buildProfileCard(Profile profile, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute<Widget>(
                builder: (context) => CollectorDetailView(
                  profile: profile,
                ),
              ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              profile.name,
                              style: GoogleFonts.lexendDeca(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.email,
                          style: GoogleFonts.lexendDeca(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.phone,
                          style: GoogleFonts.lexendDeca(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: colorScheme.outline.withOpacity(0.1),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatItem(
                    context,
                    label: 'Experience',
                    value: profile.experience,
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    context,
                    label: 'Specialization',
                    value: profile.specialization,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatItem(
                    context,
                    label: 'Active Studies',
                    value: profile.activeStudies.toString(),
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    context,
                    label: 'Completed',
                    value: profile.completedStudies.toString(),
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    context,
                    label: 'Avg. Time',
                    value: profile.avgRating,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context,
      {required String label, required String value}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.lexendDeca(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.lexendDeca(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class Profile {
  final String name;
  final String email;
  final String phone;
  final String experience;
  final String specialization;
  final int activeStudies;
  final int completedStudies;
  final String avgRating;
  final String status;

  Profile({
    required this.name,
    required this.email,
    required this.phone,
    required this.experience,
    required this.specialization,
    required this.activeStudies,
    required this.completedStudies,
    required this.avgRating,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'experience': experience,
      'specialization': specialization,
      'activeStudies': activeStudies,
      'completedStudies': completedStudies,
      'avgRating': avgRating,
      'status': status,
    };
  }
}
