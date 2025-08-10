import 'package:flutter/material.dart';

class AcceptInvitationView extends StatefulWidget {
  const AcceptInvitationView({super.key});

  @override
  State<AcceptInvitationView> createState() => _AcceptInvitationViewState();
}

class _AcceptInvitationViewState extends State<AcceptInvitationView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _regioneController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _worada1Controller = TextEditingController();
  final TextEditingController _worada2Controller = TextEditingController();
  final TextEditingController _kebaleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

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
                            'You are invited to join Majlis Strategies Research as Rural Data Collector',
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
                  'Location Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 16),

                // Form fields
                _buildTextField(
                  'Regione*',
                  _regioneController,
                  colorScheme,
                  theme,
                  isDarkMode,
                  icon: Icons.location_on_outlined,
                  validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Zone*',
                  _zoneController,
                  colorScheme,
                  theme,
                  isDarkMode,
                  icon: Icons.map_outlined,
                  validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Worada 1',
                  _worada1Controller,
                  colorScheme,
                  theme,
                  isDarkMode,
                  icon: Icons.place_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Worada 2',
                  _worada2Controller,
                  colorScheme,
                  theme,
                  isDarkMode,
                  icon: Icons.place_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Kebale*',
                  _kebaleController,
                  colorScheme,
                  theme,
                  isDarkMode,
                  icon: Icons.home_work_outlined,
                  validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
                ),

                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _handleRegistration,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
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
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      ColorScheme colorScheme,
      ThemeData theme,
      bool isDarkMode, {
        IconData? icon,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: colorScheme.onSurfaceVariant)
            : null,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
    );
  }

  void _handleRegistration() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Process registration
    debugPrint('Regione: ${_regioneController.text}');
    debugPrint('Zone: ${_zoneController.text}');
    debugPrint('Worada 1: ${_worada1Controller.text}');
    debugPrint('Worada 2: ${_worada2Controller.text}');
    debugPrint('Kebale: ${_kebaleController.text}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Registration submitted successfully!'),

        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'OK',

          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _regioneController.dispose();
    _zoneController.dispose();
    _worada1Controller.dispose();
    _worada2Controller.dispose();
    _kebaleController.dispose();
    super.dispose();
  }
}