import 'package:data4impact/core/theme/app_text_Style.dart';
import 'package:data4impact/core/theme/color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ApiErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final Exception? errorDetails;

  const ApiErrorWidget({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
    this.errorDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 24),

              Text(
                'Oops! Something went wrong',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                errorMessage,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),

              const SizedBox(height: 16),

              if (errorDetails != null && kDebugMode) ...[
                Text(
                  'Error details: ${errorDetails.toString()}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}