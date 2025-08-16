import 'package:data4impact/features/home/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AcceptInvitationView extends StatefulWidget {
  final Map<String, dynamic> segmentData;

  const AcceptInvitationView({
    super.key,
    required this.segmentData,
  });

  @override
  State<AcceptInvitationView> createState() => _AcceptInvitationViewState();
}

class _AcceptInvitationViewState extends State<AcceptInvitationView> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controllers = {};

    final fields = widget.segmentData['fields'];
    if (fields is List) {
      for (final field in fields.cast<Map<String, dynamic>>()) {
        if (field['id'] is String) {
          _controllers[field['id'] as String] = TextEditingController();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final segmentName = widget.segmentData['name'] ?? 'Unknown Segment';
    final projectName =
        'Majlis Strategies Research'; // You might want to fetch this from project data

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
          child: Form(
            key: _formKey,
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
                            'You are invited to join $projectName as a Data Collector for "$segmentName"',
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

                // Form title
                Text(
                  'Data Collection Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 16),

                // Dynamic form fields based on segment data
                ..._buildSegmentFields(theme, colorScheme, isDarkMode),

                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleRegistration,
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
                            'Complete Registration',
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
        ),
      ),
    );
  }

  List<Widget> _buildSegmentFields(
      ThemeData theme, ColorScheme colorScheme, bool isDarkMode) {
    final fields = widget.segmentData['fields'] as List? ?? [];

    return fields.map<Widget>((field) {
      final controller = _controllers[field['id']];
      final isRequired = field['required'] == true;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: controller,
          validator: isRequired
              ? (value) =>
                  value?.isEmpty ?? true ? 'This field is required' : null
              : null,
          decoration: InputDecoration(
            labelText: '${field['label']}${isRequired ? '*' : ''}',
            prefixIcon: _getIconForFieldType(field['type'] as String),
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            floatingLabelStyle: TextStyle(color: colorScheme.primary),
            filled: true,
            fillColor: isDarkMode
                ? colorScheme.surfaceVariant.withOpacity(0.3)
                : colorScheme.surfaceVariant.withOpacity(0.1),
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

  void _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Prepare the data to submit with type safety
      final Map<String, dynamic> formData = {};
      final fields = widget.segmentData['fields'];

      if (fields is List) {
        for (final field in fields.cast<Map<String, dynamic>>()) {
          final fieldId = field['id'] as String?;
          if (fieldId != null && _controllers.containsKey(fieldId)) {
            formData[fieldId] = _controllers[fieldId]!.text.trim();

            // Validate required fields
            if ((field['required'] as bool? ?? false) && formData[fieldId]!=null) {
              throw Exception('${field['label'] ?? 'Field'} is required');
            }
          }
        }
      }

      debugPrint('Form data to submit: $formData');

   /*   // Call the actual API instead of simulated delay
      final result = await context.read<HomeCubit>().(
        segmentId: widget.segmentData['_id'] as String,
        projectSlug: 'majlis-starategy', // You should get this from somewhere
        formData: formData,
      );*/

      if (!mounted) return;

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
