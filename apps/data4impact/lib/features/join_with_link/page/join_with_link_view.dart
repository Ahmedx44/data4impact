import 'package:data4impact/features/home/cubit/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data4impact/features/home/cubit/home_cubit.dart';

class JoinWithLinkView extends StatefulWidget {
  const JoinWithLinkView({super.key});

  @override
  State<JoinWithLinkView> createState() => _JoinWithLinkViewState();
}

class _JoinWithLinkViewState extends State<JoinWithLinkView> {
  final TextEditingController _linkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _validateAndJoin() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<HomeCubit>();
    try {
      await cubit.joinSegmentViaLink(_linkController.text,context);
      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Study'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withOpacity(0.9),
              colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.group_add,
                          size: 48,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Join Research Study",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Enter your invitation link below to join as a data collector",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _linkController,
                        decoration: InputDecoration(
                          labelText: "Invitation Link",
                          hintText: "https://data4impact.et/imf/majlis-starategy/segments/...",
                          prefixIcon: const Icon(Icons.link),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outline.withOpacity(0.5),
                            ),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an invitation link';
                          }
                          final uri = Uri.tryParse(value);
                          if (uri == null || !uri.hasAbsolutePath) {
                            return 'Please enter a valid URL';
                          }
                          if (!value.toLowerCase().startsWith('http')) {
                            return 'URL should start with http:// or https://';
                          }
                          if (!value.toLowerCase().contains('data4impact.et')) {
                            return 'Please enter a valid Data4Impact link';
                          }
                          // Check for the expected path format
                          if (!value.toLowerCase().contains('/imf/') ||
                              !value.toLowerCase().contains('/segments/')) {
                            return 'Link should follow format: .../imf/{project}/segments/{id}';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 32),
                      BlocBuilder<HomeCubit, HomeState>(
                        builder: (context, state) {
                          return SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: state.invitationLoading ? null : _validateAndJoin,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                              ),
                              child: state.invitationLoading
                                  ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ))
                                  : const Text(
                                "Join Study",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}