// team_detail_view.dart
import 'package:csv/csv.dart';
import 'package:data4impact/core/service/api_service/team_service.dart';
import 'package:data4impact/features/team/widget/teams_stat_card.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data4impact/core/service/api_service/Model/team_model.dart';
import 'package:data4impact/core/service/api_service/Model/member_model.dart';
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
  List<bool> selectedMembers = [];
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

      setState(() {
        members = response.map((memberData) => MemberModel.fromJson(memberData as Map<String,dynamic>)).toList();
        selectedMembers = List.generate(members.length, (index) => false);
        isLoading = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      selectAll = value ?? false;
      selectedMembers = List.generate(members.length, (index) => selectAll);
    });
  }

  void _toggleMemberSelection(int index, bool? value) {
    setState(() {
      selectedMembers[index] = value ?? false;
      selectAll = selectedMembers.every((isSelected) => isSelected);
    });
  }

  Future<void> _exportToCSV() async {
    try {
      final selectedIndexes = selectedMembers.asMap().entries.where((entry) => entry.value).map((entry) => entry.key).toList();

      if (selectedIndexes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select members to export')),
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

      // Create CSV data
      final headers = [
        'Name',
        'Email',
        'Role',
        'Study',
        'Status',
        'Response Count',
        'Max Limit',
        'Created At',
        ..._getAttributeHeaders(),
      ];

      final rows = selectedIndexes.map((index) {
        final member = members[index];
        return [
          member.fullName,
          member.user.email,
          member.roles.isNotEmpty ? member.roles.first : 'member',
          'Household',
          'inProgress',
          '2',
          '10',
          member.user.createdAt?.toString() ?? '',
          ..._getAttributeValues(member.attributes),
        ];
      }).toList();

      await saveObjCsv(
        context: context,
        headers: headers,
        rows: rows,
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> saveObjCsv({
    required BuildContext context,
    required List<String> headers,
    required List<List<String?>> rows,
  }) async {
    try {
      final csvData = <List<String?>>[headers, ...rows];
      final csv = const ListToCsvConverter().convert(csvData);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'team_members_$timestamp.csv';

      String? filePath;

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;

        if (androidInfo.version.sdkInt >= 30) {
          // Android 11+ - Try multiple approaches
          filePath = await _saveForAndroid11Plus(filename, csv);
        } else {
          // Android 10 and below - Use traditional method
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save CSV: $e')),
      );
    }
  }

  Future<String?> _saveForAndroidLegacy(String filename, String csvContent) async {
    try {
      // Use the direct path to the public Downloads folder
      final downloadDir = Directory('/storage/emulated/0/Download');

      // Ensure directory exists
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Verify directory exists before saving
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
      // For Android 11+, try the direct Downloads path first
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

    // Fallback to other methods if direct path fails
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

  List<String> _getAttributeHeaders() {
    return ['subcity', 'role'];
  }

  List<String> _getAttributeValues(Map<String, dynamic> attributes) {
    return attributes.values.map((value) => value?.toString() ?? '').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
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
                tooltip: 'Export Selected to CSV',
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? _buildLoadingState()
            : error != null
            ? _buildErrorState()
            : _buildContent(),
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

  Widget _buildContent() {
    final selectedCount = selectedMembers.where((isSelected) => isSelected).length;

    return Column(
      children: [

        // Stats Cards
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
              ),
              TeamStatsCard(
                title: 'Active',
                value: members.length,
                subtitle: 'Active members',
                icon: Icons.check_circle_rounded,
              ),
              TeamStatsCard(
                title: 'Supervisors',
                value: members.where((member) => member.roles.contains('supervisor')).length,
                subtitle: 'Team supervisors',
                icon: Icons.supervisor_account_rounded,
              ),
              TeamStatsCard(
                title: 'Collectors',
                value: members.where((member) => member.roles.contains('collector')).length,
                subtitle: 'Data collectors',
                icon: Icons.assignment_rounded,
              ),
            ],
          ),
        ),

        // Selection Header
        if (members.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Checkbox(
                  value: selectAll,
                  onChanged: _toggleSelectAll,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Select All',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (selectedCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$selectedCount selected',
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
                final isSelected = selectedMembers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 1,
                    child: InkWell(
                      onTap: () => _toggleMemberSelection(index, !isSelected),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Checkbox
                            Checkbox(
                              value: isSelected,
                              onChanged: (value) => _toggleMemberSelection(index, value),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),

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

                            // Chevron
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
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