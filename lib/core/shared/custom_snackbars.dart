import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class CustomSnackbars {
  static void longDurationSnackBarWithAction({
    required String contentString,
    required String actionText,
    required void Function() onPressed,
  }) {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(contentString),
      action: SnackBarAction(
        label: actionText,
        onPressed: onPressed,
      ),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ));
  }

  static void shortDurationSnackBar({
    required String contentString,
  }) {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(contentString),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }
}
