import 'package:data4impact/core/service/api_service/Model/current_user.dart';
import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/core/service/api_service/collection_service.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/home/cubit/home_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AcceptInvitationView extends StatefulWidget {
  final Map<String, dynamic> segmentData;
  final HomeState homeState;
  final String projectSlug;

  const AcceptInvitationView({
    super.key,
    required this.segmentData,
    required this.homeState,
    required this.projectSlug,
  });

  @override
  State<AcceptInvitationView> createState() => _AcceptInvitationViewState();
}

class _AcceptInvitationViewState extends State<AcceptInvitationView> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  bool _isSubmitting = false;
  CurrentUser? _currentUser;
  Map<String, dynamic>? _existingCollector;
  bool _isLoading = true;

  late AuthService _authService;
  late CollectorService _collectorService;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    _authService = AuthService(
      apiClient: context.read<ApiClient>(),
      secureStorage: context.read<FlutterSecureStorage>(),
    );
    _collectorService = CollectorService(
      apiClient: context.read<ApiClient>(),
      secureStorage: context.read<FlutterSecureStorage>(),
    );
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Get current user
      _currentUser = await _authService.getCurrentUser();

      if (_currentUser == null) return;

      // Get collectors
      final collectors = await _collectorService.getCollectors(
        segment: widget.segmentData['_id'] as String,
        projectSlug: widget.projectSlug,
      );

      if (collectors != null) {
        for (var collector in collectors) {
          if (collector['userId'] == _currentUser!.id) {
            _existingCollector = collector as Map<String, dynamic>;
            break;
          }
        }
      }

      // Initialize controllers
      final fields = widget.segmentData['fields'] as List? ?? [];
      for (final field in fields.cast<Map<String, dynamic>>()) {
        final fieldLabel = (field['label'] as String).toLowerCase();
        final controller = TextEditingController();

        // Match field label to attribute key
        if (_existingCollector != null) {
          final attributes = _existingCollector!['attributes'] as Map? ?? {};

          // Special handling for known fields
          if (fieldLabel.contains('zone') && attributes.containsKey('zone')) {
            controller.text = attributes['zone'].toString();
          }
          else if (fieldLabel.contains('kebele') && attributes.containsKey('kebele')) {
            controller.text = attributes['kebele'].toString();
          }
          // For other fields
          else if (attributes.containsKey(fieldLabel)) {
            controller.text = attributes[fieldLabel].toString();
          }
          // Prefill from user data if empty
          else if (field['prefield'] == true) {
            if (fieldLabel.contains('email')) {
              controller.text = _currentUser?.email?.toString() ?? '';
            }
            else if (fieldLabel.contains('phone')) {
              controller.text = _currentUser?.phone?.toString() ?? '';
            }
            else if (fieldLabel.contains('name')) {
              if (fieldLabel.contains('first')) {
                controller.text = _currentUser?.firstName?.toString() ?? '';
              }
              else if (fieldLabel.contains('last')) {
                controller.text = _currentUser?.lastName?.toString() ?? '';
              }
              else {
                controller.text = _currentUser?.fullName?.toString() ?? '';
              }
            }
          }
        }

        // Store controller using field ID
        _controllers[field['id'] as String] = controller;
      }
    } catch (e) {
      ToastService.showErrorToast(message: 'Failed to load data');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final segmentName = widget.segmentData['name'] ?? 'Unknown Segment';
    final projectName = widget.homeState.selectedProject?.title;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        body: Center(
          child: CircularProgressIndicator(
            color: colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Accept Invitation',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Card(
                elevation: 0,
                color: colorScheme.primaryContainer.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You are registering as a Data Collector for "$segmentName"',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onBackground,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Your Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 16),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Dynamic form fields based on segment data
                    ..._buildSegmentFields(theme, colorScheme),
                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _handleRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          'Register',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  List<Widget> _buildSegmentFields(ThemeData theme, ColorScheme colorScheme) {
    final fields = widget.segmentData['fields'] as List? ?? [];

    return fields.map<Widget>((field) {
      final fieldId = field['id'] as String;
      final controller = _controllers[fieldId];
      final isRequired = field['required'] == true;
      final label = field['label'] as String;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: controller,
          validator: isRequired
              ? (value) =>
          value?.isEmpty ?? true ? 'This field is required' : null
              : null,
          decoration: InputDecoration(
            labelText: '$label${isRequired ? '*' : ''}',
            prefixIcon: _getIconForFieldType(field['type'] as String),
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            floatingLabelStyle: TextStyle(color: colorScheme.primary),
            filled: true,
            fillColor: colorScheme.surfaceVariant.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 1.5,
              ),
            ),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          keyboardType: _getKeyboardTypeForFieldType(field['type'] as String),
          obscureText: field['type'] == 'password',
        ),
      );
    }).toList();
  }

  Widget? _getIconForFieldType(String type) {
    switch (type) {
      case 'email':
        return Icon(Icons.email_outlined);
      case 'text':
        return Icon(Icons.text_fields);
      case 'number':
        return Icon(Icons.numbers);
      case 'phone':
        return Icon(Icons.phone);
      case 'password':
        return Icon(Icons.lock_outline);
      default:
        return Icon(Icons.text_fields);
    }
  }

  TextInputType _getKeyboardTypeForFieldType(String type) {
    switch (type) {
      case 'email':
        return TextInputType.emailAddress;
      case 'number':
        return TextInputType.number;
      case 'phone':
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final collectorId = _existingCollector?['_id'] as String?;

    try {
      final Map<String, dynamic> formData = {};
      final fields = widget.segmentData['fields'] as List? ?? [];

      for (final field in fields.cast<Map<String, dynamic>>()) {
        final fieldId = field['id'] as String;
        final fieldLabel = (field['label'] as String).toLowerCase();

        final attributes = _existingCollector?['attributes'] as Map? ?? {};

        // Use existing attribute if available, otherwise use controller value
        formData[fieldId] = attributes.containsKey(fieldLabel)
            ? attributes[fieldLabel].toString()
            : _controllers[fieldId]!.text.trim();
      }

      // Call the service
      await _collectorService.joinAsCollector(
        collectorId: collectorId!,
        attributes: formData,
      );

      ToastService.showSuccessToast(message: 'Successfully registered as collector');

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ToastService.showErrorToast(message: e.toString());
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }



  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}