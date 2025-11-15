import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DialogLoading {
  static bool _isOpen = false;

  static void show(
      BuildContext context, {
        String? message,
        Color? barrierColor,
        bool barrierDismissible = false,
      }) {
    if (_isOpen) return;
    _isOpen = true;

    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      builder: (BuildContext context) {
        return _LoadingContent(message: message);
      },
    );
  }

  static void hide(BuildContext context) {
    if (_isOpen) {
      _isOpen = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

class _LoadingContent extends StatelessWidget {
  final String? message;

  const _LoadingContent({this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(40),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? colorScheme.surface
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated loading indicator
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: SpinKitFadingCircle(
                  color: colorScheme.primary,
                  size: 40.0,
                ),
              ),

              const SizedBox(height: 16),

              // Optional message
              if (message != null) ...[
                Text(
                  message!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkTheme
                        ? colorScheme.onSurface
                        : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Text(
                  'Loading...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkTheme
                        ? colorScheme.onSurface.withOpacity(0.7)
                        : Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Alternative loading style with pulse animation
class _LoadingContentPulse extends StatelessWidget {
  final String? message;

  const _LoadingContentPulse({this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? colorScheme.surface
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            gradient: isDarkTheme
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surface.withOpacity(0.9),
              ],
            )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 25,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulse animation container
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const SpinKitPulse(
                  color: Colors.white,
                  size: 35.0,
                ),
              ),

              const SizedBox(height: 20),

              // Message with better typography
              Text(
                message ?? 'Please wait',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isDarkTheme
                      ? colorScheme.onSurface
                      : Colors.grey[800],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 8),

              // Subtle subtitle
              Text(
                'This will just take a moment',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDarkTheme
                      ? colorScheme.onSurface.withOpacity(0.6)
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
