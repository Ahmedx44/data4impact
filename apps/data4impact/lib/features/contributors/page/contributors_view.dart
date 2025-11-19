import 'package:data4impact/features/contributors/cubit/contributors_cubit.dart';
import 'package:data4impact/features/contributors/cubit/contributors_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

class ContributorsView extends StatefulWidget {
  const ContributorsView({super.key});

  @override
  State<ContributorsView> createState() => _ContributorsViewState();
}

class _ContributorsViewState extends State<ContributorsView> {
  @override
  void initState() {
    super.initState();
    context.read<ContributorsCubit>().fetchContributors();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contributors'),
        centerTitle: true,
      ),
      body: BlocBuilder<ContributorsCubit, ContributorsState>(
        builder: (context, state) {
          if (state.status == ContributorsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == ContributorsStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading contributors',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? 'Unknown error',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.onSurface.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ContributorsCubit>().fetchContributors();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state.status == ContributorsStatus.success) {
            if (state.contributors.isEmpty) {
              return Center(
                child: Text(
                  'No contributors found',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.onSurface.withOpacity(0.7),
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.contributors.length,
              itemBuilder: (context, index) {
                final contributor =
                    state.contributors[index] as Map<String, dynamic>;
                final user = contributor['user'] as Map<String, dynamic>? ?? {};
                final firstName = user['firstName'] as String? ?? '';
                final lastName = user['lastName'] as String? ?? '';
                final email = user['email'] as String? ?? '';
                final roles = user['roles'] as List<dynamic>? ?? [];
                final roleNames = roles
                    .map((r) => (r as Map<String, dynamic>)['name'] as String)
                    .join(', ');

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.outline.withOpacity(0.3)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: theme.primary.withOpacity(0.1),
                          child: Text(
                            firstName.isNotEmpty
                                ? firstName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$firstName $lastName',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              if (roleNames.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    roleNames,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.onSecondaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
