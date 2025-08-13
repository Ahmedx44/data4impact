import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DialogLoading {
  static bool _isOpen = false;

  static void show(BuildContext context) {
    if (_isOpen) return;
    _isOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const _LoadingContent();
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
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child:  SizedBox(
          height: 50,
          width: 50,
          child: SpinKitFadingCircle(
            color: Theme.of(context).colorScheme.primary
          ),
        ),
      ),
    );
  }
}
