import 'package:data4impact/core/theme/app_text_Style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:data4impact/core/theme/color.dart';

class ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const ErrorScreen(this.errorDetails, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final isDebugMode = kDebugMode;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon - changes based on debug mode
              Icon(
                isDebugMode ? Icons.bug_report_rounded : Icons.error_outline_rounded,
                size: 80,
                color: isDebugMode ? AppColors.accent : AppColors.error,
              ),
              const SizedBox(height: 24),

              // Error Title - changes based on debug mode
              Text(
                isDebugMode ? 'Debug Mode: Error Occurred' : 'Oops! Something went wrong',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: isDebugMode ? AppColors.accent : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Error Message - changes based on debug mode
              Text(
                isDebugMode
                    ? 'You\'re in debug mode. Here are the error details:'
                    : 'We encountered an unexpected error. Our developers have been notified and are working on a fix.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Error Details Card - expanded in debug mode
              Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: isDebugMode ? AppColors.accent : AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isDebugMode ? 'Debug Error Details:' : 'Error Information:',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: isDebugMode ? AppColors.accent : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (isDebugMode)
                        _buildDebugErrorDetails(isDark)
                      else
                        _buildProductionErrorDetails(isDark),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(isDebugMode ? Icons.code_rounded : Icons.refresh_rounded),
                    label: Text(
                      isDebugMode ? 'Debug Options' : 'Restart App',
                      style: AppTextStyles.labelLarge,
                    ),
                    onPressed: () {
                      if (isDebugMode) {
                        // Show debug options or copy error details
                        _showDebugOptions(context);
                      } else {
                        // Add your restart logic here
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDebugMode ? AppColors.accent : AppColors.primary,
                      foregroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: Text(
                      'Go Back',
                      style: AppTextStyles.labelLarge,
                    ),
                    onPressed: () {
                      Navigator.maybePop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDebugMode ? AppColors.accent : AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      side: BorderSide(color: isDebugMode ? AppColors.accent : AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),

              // Support Text - changes based on debug mode
              const SizedBox(height: 24),
              Text(
                isDebugMode
                    ? 'This error is only visible in debug mode. Users will see a friendly message.'
                    : 'If the problem persists, please contact support',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDebugErrorDetails(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exception:',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          errorDetails.exceptionAsString(),
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 12),

        if (errorDetails.stack != null) ...[
          Text(
            'Stack Trace:',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            errorDetails.stack.toString(),
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? Colors.white60 : Colors.black45,
              fontSize: 10,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.library_books_rounded, size: 16, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(
              'Library: ${errorDetails.library ?? "Unknown"}',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? Colors.white60 : Colors.black45,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductionErrorDetails(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notifications_active_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              'Developers have been notified',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              'Working on a solution',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Error reference: ${_generateErrorId()}',
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? Colors.white60 : Colors.black45,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  String _generateErrorId() {
    return 'ERR-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _showDebugOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Debug Options', style: AppTextStyles.titleMedium),
        content: Text('Copy error details to clipboard?', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.labelLarge),
          ),
          TextButton(
            onPressed: () {
              // Implement copy to clipboard functionality
              Navigator.pop(context);
            },
            child: Text('Copy', style: AppTextStyles.labelLarge),
          ),
        ],
      ),
    );
  }
}