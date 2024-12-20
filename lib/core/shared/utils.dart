import 'package:flutter/material.dart';

class Utils {
  static void clearAllFormFieldFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
