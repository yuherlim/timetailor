import 'package:flutter/material.dart';

SnackBar longDurationSnackBarWithAction({
  required String contentString,
  required String actionText,
  required void Function() onPressed,
}) {
  return SnackBar(
    content: Text(contentString),
    action: SnackBarAction(
      label: actionText,
      onPressed: onPressed,
    ),
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 4),
  );
}

SnackBar shortDurationSnackBar({
  required String contentString,
}) {
  return SnackBar(
    content: Text(contentString),
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 2),
  );
}
