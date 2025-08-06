import 'package:data4impact/core/service/app_global_context.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  static final Set<String> _activeToasts = {};

  static void _safeShowToast({
    required BuildContext? context,
    required void Function(BuildContext ctx) showFunction,
    required String message,
  }) {
    // Check if this message is already being shown
    if (_activeToasts.contains(message)) {
      return;
    }

    final ctx = context ?? AppGlobalContext.context;
    if (ctx != null) {
      try {
        _activeToasts.add(message);
        showFunction(ctx);
        // Remove the message from active toasts after the duration
        Future.delayed(const Duration(seconds: 4), () {
          _activeToasts.remove(message);
        });
      } catch (e, s) {
        _activeToasts.remove(message);
      }
    }
  }

  static void showToast({
    required String message,
    required Color color,
    BuildContext? context,
    Color? backgroundColor,
    Color? textColor,
    ToastificationType type = ToastificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    _safeShowToast(
      context: context,
      message: message,
      showFunction: (ctx) {
        toastification.show(
          context: context,
          alignment: Alignment.topCenter,
          margin: const EdgeInsets.only(top: 50, left: 16, right: 16),
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          title: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor ?? Colors.white,
            ),
          ),
          primaryColor: color,
          backgroundColor: backgroundColor ?? color.withOpacity(0.95),
          showProgressBar: true,
          progressBarTheme: ProgressIndicatorThemeData(
            color: Colors.white.withOpacity(0.7),
            linearTrackColor: Colors.white.withOpacity(0.2),
          ),
          applyBlurEffect: true,
          pauseOnHover: false,
          showIcon: true,
          autoCloseDuration: duration,
          animationDuration: const Duration(milliseconds: 500),
          animationBuilder: (context, animation, alignment, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.elasticOut,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
      },
    );
  }

  static void showErrorToast({
    required String message,
    BuildContext? context,
    Duration duration = const Duration(seconds: 4),
  }) {
    _safeShowToast(
      context: context,
      message: message,
      showFunction: (ctx) {
        toastification.show(
          context: context,
          alignment: Alignment.topCenter,
          margin: const EdgeInsets.only(top: 50, left: 16, right: 16),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          title: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          primaryColor: Colors.red,
          backgroundColor: Colors.red.withOpacity(0.95),
          showProgressBar: true,
          progressBarTheme: ProgressIndicatorThemeData(
            color: Colors.white.withOpacity(0.7),
            linearTrackColor: Colors.white.withOpacity(0.2),
          ),
          applyBlurEffect: true,
          pauseOnHover: false,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          showIcon: true,
          autoCloseDuration: duration,
          animationDuration: const Duration(milliseconds: 500),
          animationBuilder: (context, animation, alignment, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.elasticOut,
              )),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.8,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              ),
            );
          },
        );
      },
    );
  }

  static void showSuccessToast({
    required String message,
    BuildContext? context,
    Duration duration = const Duration(seconds: 3),
  }) {
    _safeShowToast(
      context: context,
      message: message,
      showFunction: (ctx) {
        toastification.show(
          context: context,
          alignment: Alignment.topCenter,
          margin: const EdgeInsets.only(top: 50, left: 16, right: 16),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          title: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          primaryColor: Colors.green,
          backgroundColor: Colors.green.withOpacity(0.95),
          showProgressBar: true,
          progressBarTheme: ProgressIndicatorThemeData(
            color: Colors.white.withOpacity(0.7),
            linearTrackColor: Colors.white.withOpacity(0.2),
          ),
          applyBlurEffect: true,
          pauseOnHover: false,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          showIcon: true,
          autoCloseDuration: duration,
          animationDuration: const Duration(milliseconds: 500),
          animationBuilder: (context, animation, alignment, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.elasticOut,
              )),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.8,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              ),
            );
          },
        );
      },
    );
  }

  static void showWarningToast({
    required String message,
    BuildContext? context,
    Duration duration = const Duration(seconds: 3),
  }) {
    _safeShowToast(
      context: context,
      message: message,
      showFunction: (ctx) {
        toastification.show(
          context: context,
          alignment: Alignment.topCenter,
          margin: const EdgeInsets.only(top: 50, left: 16, right: 16),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          title: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          primaryColor: Colors.orange,
          backgroundColor: Colors.orange.withOpacity(0.95),
          showProgressBar: true,
          progressBarTheme: ProgressIndicatorThemeData(
            color: Colors.white.withOpacity(0.7),
            linearTrackColor: Colors.white.withOpacity(0.2),
          ),
          applyBlurEffect: true,
          pauseOnHover: false,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          showIcon: true,
          autoCloseDuration: duration,
          animationDuration: const Duration(milliseconds: 500),
          animationBuilder: (context, animation, alignment, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.elasticOut,
              )),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.8,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              ),
            );
          },
        );
      },
    );
  }

  static void showInfoToast({
    required String message,
    BuildContext? context,
    Duration duration = const Duration(seconds: 3),
  }) {
    _safeShowToast(
      context: context,
      message: message,
      showFunction: (ctx) {
        toastification.show(
          context: context,
          alignment: Alignment.topCenter,
          margin: const EdgeInsets.only(top: 50, left: 16, right: 16),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          title: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          primaryColor: Colors.blue,
          backgroundColor: Colors.blue.withOpacity(0.95),
          showProgressBar: true,
          progressBarTheme: ProgressIndicatorThemeData(
            color: Colors.white.withOpacity(0.7),
            linearTrackColor: Colors.white.withOpacity(0.2),
          ),
          applyBlurEffect: true,
          pauseOnHover: false,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          showIcon: true,
          autoCloseDuration: duration,
          animationDuration: const Duration(milliseconds: 500),
          animationBuilder: (context, animation, alignment, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.elasticOut,
              )),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.8,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              ),
            );
          },
        );
      },
    );
  }
}