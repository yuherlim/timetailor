import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';

part 'bottom_sheet_scroll_controller_provider.g.dart'; // Generated file

@riverpod
class BottomSheetScrollControllerNotifier
    extends _$BottomSheetScrollControllerNotifier {

  @override
  DraggableScrollableController build() {
    // Register cleanup logic
    ref.onDispose(() {
      state.dispose();
    });

    return DraggableScrollableController();
  }

  void scrollToMiddleExtent() {
    state.animateTo(
      ref.read(middleBottomSheetExtentProvider),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void scrollToMaxExtent() {
    state.animateTo(
      ref.read(maxBottomSheetExtentProvider),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void scrollToInitialExtent() {
    state.animateTo(
      ref.read(initialBottomSheetExtentProvider),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
