// team_detail_view.dart
import 'package:csv/csv.dart';
import 'package:data4impact/core/service/api_service/team_service.dart';
import 'package:data4impact/features/team/widget/teams_stat_card.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data4impact/core/service/api_service/Model/team_model.dart';
import 'package:data4impact/core/service/api_service/Model/member_model.dart';
import 'package:data4impact/features/home/cubit/home_cubit.dart';
import 'package:data4impact/features/home/cubit/home_state.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class TeamDetailView extends StatefulWidget {
  final TeamModel team;

  const TeamDetailView({super.key, required this.team});

  @override
  State<TeamDetailView> createState() => _TeamDetailViewState();
}

class _TeamDetailViewState extends State<TeamDetailView> {
  List<MemberModel> members = [];
  Map<String, bool> expandedMembers = {};
  Map<String, List<bool>> selectedStudies = {};
  Map<String, List<dynamic>> memberStudies = {};
  bool isLoading = true;
  String? error;
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    _loadTeamMembers();
  }

  Future<void> _loadTeamMembers() async {
    try {
      final teamService = TeamService(
        apiClient: context.read(),
        secureStorage: context.read(),
      );

      final response = await teamService.getTeamMembers(widget.team.id);

      // Handle the response properly - it's a List<dynamic>
      if (response is List) {
        setState(() {
          members = response.map((memberData) {
            return MemberModel.fromJson(memberData as Map<String,dynamic>);
          }).toList();

          for (var member in members) {
            expandedMembers[member.id] = false;
            memberStudies[member.id] = [];
            selectedStudies[member.id] = [];
          }

          isLoading = false;
          error = null;
        });
      } else {
        throw Exception('Invalid response format from server');
      }
    } catch (e) {
      print('Error loading team members: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _toggleMemberExpansion(String memberId) {
    setState(() {
      expandedMembers[memberId] = !expandedMembers[memberId]!;
      if (expandedMembers[memberId]! && memberStudies[memberId]!.isEmpty) {
        _loadMemberStudies(memberId);
      }
    });
  }

  Future<void> _loadMemberStudies(String memberId) async {
    try {
      // Get the member
      final member = members.firstWhere((m) => m.id == memberId);

      // Get collectors data from HomeCubit
      final homeState = context.read<HomeCubit>().state;
      final collectors = homeState.collectors;

      // Since we're having trouble matching, let's show ALL collectors
      List<dynamic> memberCollectors = List.from(collectors);

      // Convert collectors to studies format
      final studies = memberCollectors.map((collector) {
        final studyData = collector['study'] as Map<String, dynamic>?;
        final userData = collector['user'] as Map<String, dynamic>?;

        final studyName = studyData?['name'] ?? 'Unnamed Study';
        final studyStatus = collector['status'] ?? 'unknown';
        final isActive = studyStatus.toString().toLowerCase() == 'inprogress';

        print('🔍 Processing study: "$studyName" - status: $studyStatus, isActive: $isActive');

        return {
          'id': collector['_id'],
          'name': studyName,
          'description': studyData?['description'] ?? '',
          'responseCount': collector['responseCount'] ?? 0,
          'maxLimit': collector['maxLimit'] ?? 0,
          'status': studyStatus,
          'assignedDate': collector['assignedDate'] ?? '',
          'completedDate': collector['completedDate'] ?? '',
          'studyId': studyData?['_id'] ?? '',
          'allowOffline': collector['allowOffline'] ?? false,
          'project': collector['project'] ?? '',
          'cohorts': collector['cohorts'] ?? [],
          'userName': userData != null
              ? '${userData['firstName']} ${userData['lastName']}'
              : 'Unknown User',
          'userEmail': userData?['email'] ?? '',
          'createdAt': collector['createdAt'] ?? '',
          'updatedAt': collector['updatedAt'] ?? '',
          'isActive': isActive,
        };
      }).toList();

      print('🎉 Final studies count for ${member.fullName}: ${studies.length}');
      print('🎯 Active studies: ${studies.where((s) => s['isActive'] == true).length}');
      print('✅ Completed studies: ${studies.where((s) => s['status']?.toString().toLowerCase() == 'completed').length}');

      setState(() {
        memberStudies[memberId] = studies;
        selectedStudies[memberId] = List.generate(studies.length, (index) => false);
      });

    } catch (e) {
      print('❌ Error loading studies for member $memberId: $e');
      setState(() {
        memberStudies[memberId] = [];
        selectedStudies[memberId] = [];
      });
    }
  }

  void _toggleStudySelection(String memberId, int studyIndex, bool? value) {
    setState(() {
      selectedStudies[memberId]![studyIndex] = value ?? false;
    });
  }

  void _toggleSelectAllStudies(String memberId, bool? value) {
    setState(() {
      final newValue = value ?? false;
      selectedStudies[memberId] = List.generate(
          selectedStudies[memberId]!.length,
              (index) => newValue
      );
    });
  }

  double _calculatePerformance() {
    if (members.isEmpty) return 0.0;
    final activeMembers = members.where((member) => member.roles.isNotEmpty).length;
    return (activeMembers / members.length) * 100;
  }

  String _calculateGoalProgress() {
    const totalGoal = 15;
    final currentProgress = members.length;
    return '$currentProgress/$totalGoal';
  }

  int _calculatePendingMembers() {
    return members.where((member) => member.roles.isEmpty || !member.roles.contains('pending')).length;
  }

  int _getInProgressStudiesCount(String memberId) {
    final studies = memberStudies[memberId] ?? [];
    return studies.where((study) => study['status']?.toString().toLowerCase() == 'inprogress').length;
  }

  Future<void> _exportToCSV() async {
    try {
      // Collect all selected studies across all members
      final selectedStudyData = <Map<String, dynamic>>[];

      for (var member in members) {
        final memberId = member.id;
        final studies = memberStudies[memberId] ?? [];
        final selections = selectedStudies[memberId] ?? [];

        for (int i = 0; i < studies.length; i++) {
          if (selections.isNotEmpty && i < selections.length && selections[i]) {
            selectedStudyData.add({
              'member': member,
              'study': studies[i],
            });
          }
        }
      }

      if (selectedStudyData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select studies to export')),
        );
        return;
      }

      // For Android, check and request storage permission
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        if (sdkInt >= 30) {
          // Android 11+ - check for manage external storage
          if (!await Permission.manageExternalStorage.isGranted) {
            final status = await Permission.manageExternalStorage.request();
            if (!status.isGranted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Storage permission is required to download CSV')),
              );
              return;
            }
          }
        } else {
          // Android 10 and below - use regular storage permission
          if (!await Permission.storage.isGranted) {
            final status = await Permission.storage.request();
            if (!status.isGranted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Storage permission is required to download CSV')),
              );
              return;
            }
          }
        }
      }

      final headers = [
        'Name',
        'Email',
        'Role',
        'Study Name',
        'Study Description',
        'Status',
        'Response Count',
        'Max Limit',
        'Assigned Date',
        'Completed Date',
        'Created At',
        'subcity',
        'role',
      ];

      final rows = selectedStudyData.map((data) {
        final member = data['member'] as MemberModel;
        final study = data['study'] as Map<String, dynamic>;

        return [
          member.fullName ?? '',
          member.user.email ?? '',
          member.roles.isNotEmpty ? (member.roles.first ?? 'member') : 'member',
          study['name']?.toString() ?? '',
          study['description']?.toString() ?? '',
          study['status']?.toString() ?? '',
          study['responseCount']?.toString() ?? '0',
          study['maxLimit']?.toString() ?? '0',
          study['assignedDate']?.toString() ?? '',
          study['completedDate']?.toString() ?? '',
          study['createdAt']?.toString() ?? '',
          member.attributes['subcity']?.toString() ?? '',
          member.attributes['role']?.toString() ?? '',
        ];
      }).toList();

      await saveObjCsv(
        context: context,
        headers: headers,
        rows: rows,
      );

    } catch (e) {
      print('Export error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> saveObjCsv({
    required BuildContext context,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    try {
      final csvData = <List<String?>>[
        headers.map((h) => h as String?).toList(),
        ...rows.map((row) => row.map((cell) => cell as String?).toList()),
      ];

      final csv = const ListToCsvConverter().convert(csvData);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'team_studies_$timestamp.csv';

      String? filePath;

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;

        if (androidInfo.version.sdkInt >= 30) {
          // Android 11+ -
          filePath = await _saveForAndroid11Plus(filename, csv);
        } else {
          // Android 10 and below
          filePath = await _saveForAndroidLegacy(filename, csv);
        }
      } else if (Platform.isIOS) {
        // For iOS, use Documents directory
        final documentsDir = await getApplicationDocumentsDirectory();
        filePath = '${documentsDir.path}/$filename';
        final file = File(filePath);
        await file.writeAsString(csv);
      } else {
        // For desktop, use Downloads directory
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          filePath = '${downloadsDir.path}/$filename';
          final file = File(filePath);
          await file.writeAsString(csv);
        }
      }

      if (filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save file. Please check storage permissions.')),
        );
        return;
      }

      // Verify file was created
      final file = File(filePath);
      if (await file.exists()) {
        print('File successfully saved at: $filePath');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV saved successfully: $filename'),
            action: SnackBarAction(
              label: 'Open File',
              onPressed: () => _openCsvFile(file, context),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File was not created. Please try again.')),
        );
      }

    } catch (e) {
      print('Save CSV error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save CSV: $e')),
      );
    }
  }

  Future<String?> _saveForAndroidLegacy(String filename, String csvContent) async {
    try {
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      if (await downloadDir.exists()) {
        final file = File('${downloadDir.path}/$filename');
        await file.writeAsString(csvContent);
        return file.path;
      }
    } catch (e) {
      print('Failed to save to public Downloads: $e');
    }
    return null;
  }

  Future<String?> _saveForAndroid11Plus(String filename, String csvContent) async {
    try {
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      if (await downloadDir.exists()) {
        final file = File('${downloadDir.path}/$filename');
        await file.writeAsString(csvContent);
        return file.path;
      }
    } catch (e) {
      print('Failed to save to public Downloads (Android 11+): $e');
    }

    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        final file = File('${downloadsDir.path}/$filename');
        await file.writeAsString(csvContent);
        return file.path;
      }
    } catch (e) {
      print('Failed fallback: $e');
    }

    return null;
  }

  Future<void> _openCsvFile(File file, BuildContext context) async {
    try {
      final result = await OpenFile.open(file.path);

      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: ${result.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open file: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          widget.team.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          if (members.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.download_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                onPressed: _exportToCSV,
                tooltip: 'Export Selected Studies to CSV',
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, homeState) {
            return isLoading
                ? _buildLoadingState()
                : error != null
                ? _buildErrorState()
                : _buildContent(homeState);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Team Members...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to Load Members',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loadTeamMembers,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(HomeState homeState) {
    final performance = _calculatePerformance();
    final goalProgress = _calculateGoalProgress();
    final pendingMembers = _calculatePendingMembers();

    return Column(
      children: [
        // Stats Cards - Only 4 cards as requested
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            children: [
              TeamStatsCard(
                title: 'Total Members',
                value: members.length,
                subtitle: 'Team members',
                icon: Icons.people_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              TeamStatsCard(
                title: 'Performance',
                value: performance.toInt(),
                subtitle: '${performance.toStringAsFixed(1)}% efficiency',
                icon: Icons.trending_up_rounded,
                color: Colors.green,
                isPercentage: true,
              ),
              TeamStatsCard(
                title: 'Goal',
                value: 0, // We'll display custom text instead
                subtitle: goalProgress,
                icon: Icons.flag_rounded,
                color: Colors.orange,
                customValue: goalProgress, // Custom display for goal progress
              ),
              TeamStatsCard(
                title: 'Pending Members',
                value: pendingMembers,
                subtitle: 'Need attention',
                icon: Icons.pending_actions_rounded,
                color: Colors.red,
              ),
            ],
          ),
        ),

        // Members List Header
        if (members.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(
                  'Team Members',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    members.length.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Members List
        Expanded(
          child: members.isEmpty
              ? _buildEmptyState()
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final isExpanded = expandedMembers[member.id] ?? false;
                final studies = memberStudies[member.id] ?? [];
                final studySelections = selectedStudies[member.id] ?? [];
                final inProgressStudiesCount = _getInProgressStudiesCount(member.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 1,
                    child: Column(
                      children: [
                        // Member Header (Clickable)
                        InkWell(
                          onTap: () => _toggleMemberExpansion(member.id),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Member Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.fullName,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        member.user.email,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          ...member.roles.map((role) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getRoleColor(role, context),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              role.toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          )),
                                          if (member.attributes.isNotEmpty)
                                            ...member.attributes.entries.map((entry) => Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.surfaceVariant,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                                                ),
                                              ),
                                              child: Text(
                                                '${entry.key}: ${entry.value}',
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Studies count and expand icon
                                Column(
                                  children: [
                                    if (inProgressStudiesCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '$inProgressStudiesCount active',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Icon(
                                      isExpanded
                                          ? Icons.expand_less_rounded
                                          : Icons.expand_more_rounded,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Studies List (Expandable) - Only show in progress studies
                        if (isExpanded)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Studies Header with Select All
                                if (inProgressStudiesCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: studySelections.isNotEmpty &&
                                              studies.asMap().entries.where((entry) {
                                                final study = entry.value;
                                                return study['status']?.toString().toLowerCase() == 'inprogress';
                                              }).every((entry) {
                                                final index = entry.key;
                                                return index < studySelections.length ? studySelections[index] : false;
                                              }),
                                          onChanged: (value) => _toggleSelectAllStudies(member.id, value),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Select All Studies',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '$inProgressStudiesCount in progress studies',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Studies List - Only show in progress studies
                                if (studies.isNotEmpty)
                                  ...studies.asMap().entries.map((entry) {
                                    final studyIndex = entry.key;
                                    final study = entry.value;
                                    final isSelected = studyIndex < studySelections.length
                                        ? studySelections[studyIndex]
                                        : false;

                                    // REMOVED FILTERING - Show all studies
                                    // final isActive = study['isActive'] == true ||
                                    //                 study['status']?.toString().toLowerCase() == 'inprogress';
                                    //
                                    // if (!isActive) {
                                    //   return const SizedBox.shrink();
                                    // }

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                                            : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                                        ),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _toggleStudySelection(member.id, studyIndex, !isSelected),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Row(
                                              children: [
                                                Checkbox(
                                                  value: isSelected,
                                                  onChanged: (value) => _toggleStudySelection(member.id, studyIndex, value),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        study['name'] as String? ?? 'Unnamed Study',
                                                        style: TextStyle(
                                                          color: Theme.of(context).colorScheme.onSurface,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      if (study['description'] != null && study['description'].toString().isNotEmpty)
                                                        Text(
                                                          study['description'].toString(),
                                                          style: TextStyle(
                                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                                            fontSize: 12,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      const SizedBox(height: 6),
                                                      Wrap(
                                                        spacing: 12,
                                                        children: [
                                                          _buildStudyStat(
                                                            Icons.assignment_rounded,
                                                            '${study['responseCount'] ?? 0} responses',
                                                          ),
                                                          _buildStudyStat(
                                                            HugeIcons.strokeRoundedLimitation,
                                                            'Max: ${study['maxLimit'] ?? 0}',
                                                          ),
                                                          _buildStudyStat(
                                                            Icons.circle_rounded,
                                                            study['status'] as String? ?? '',
                                                            color: _getStatusColor(study['status'] as String?),
                                                          ),
                                                          if (study['allowOffline'] == true)
                                                            _buildStudyStat(
                                                              Icons.wifi_off_rounded,
                                                              'Offline',
                                                              color: Colors.orange,
                                                            ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),

                                // Loading or Empty State for Studies
                                if (studies.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Loading studies...',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // No in progress studies message
                                if (studies.isNotEmpty && inProgressStudiesCount == 0)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline_rounded,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'No in progress studies',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudyStat(IconData icon, String text, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'inprogress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.blue;
      default:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    }
  }

  Color _getRoleColor(String role, BuildContext context) {
    switch (role.toLowerCase()) {
      case 'supervisor':
        return Colors.blue.shade600;
      case 'collector':
        return Colors.green.shade600;
      case 'admin':
        return Colors.orange.shade600;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_alt_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Team Members',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This team has no members yet. Add members to get started with data collection.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}