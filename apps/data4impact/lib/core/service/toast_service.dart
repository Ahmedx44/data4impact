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
            vertical: 12,
            horizontal: 16,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
          title: Text(
            message,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor ?? Colors.white,
            ),
          ),
          primaryColor: color,
          backgroundColor: backgroundColor ?? color,
          showProgressBar: false,
          applyBlurEffect: false,
          pauseOnHover: false,
          showIcon: true,
          autoCloseDuration: duration,
          animationDuration: const Duration(milliseconds: 300),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.15),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
          title: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          primaryColor: const Color(0xFFDC2626),
          backgroundColor: const Color(0xFFDC2626),
          showProgressBar: false,
          applyBlurEffect: false,
          pauseOnHover: false,
          icon: Icon(
            Icons.error_rounded,
            color: Colors.white,
            size: 20,
          ),
          showIcon: true,
          autoCloseDuration: duration,
          animationDuration: const Duration(milliseconds: 300),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.15),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
          title: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          primaryColor: const Color(0xFF16A34A),
          backgroundColor: const Color(0xFF16A34A),
          showProgressBar: false,
          applyBlurEffect: false,
          pauseOnHover: false,
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Colors.white,
            size: 20,
          ),
          showIcon: true,
          autoCloseDuration: duration,
          animationDuration: const Duration(milliseconds: 300),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.15),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
          title: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          primaryColor: const Color(0xFFEA580C),
          backgroundColor: const Color(0xFFEA580C),
          showProgressBar: false,
          applyBlurEffect: false,
          pauseOnHover: false,
          icon: Icon(
            Icons.warning_rounded,
            color: Colors.white,
            size: 20,
          ),
          showIcon: true,
          autoCloseDuration: duration,
          animationDuration: const Duration(milliseconds: 300),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.15),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
          title: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          primaryColor: const Color(0xFF2563EB),
          backgroundColor: const Color(0xFF2563EB),
          showProgressBar: false,
          applyBlurEffect: false,
          pauseOnHover: false,
          icon: Icon(
            Icons.info_rounded,
            color: Colors.white,
            size: 20,
          ),
          showIcon: true,
          autoCloseDuration: duration,
          animationDuration: const Duration(milliseconds: 300),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
        );
      },
    );
  }
}
