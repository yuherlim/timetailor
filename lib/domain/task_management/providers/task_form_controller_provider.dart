import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/domain/task_management/providers/task_form_provider.dart';

part 'task_form_controller_provider.g.dart';

@riverpod
TextEditingController taskTitleController(ref) {
  final formState = ref.watch(taskFormNotifierProvider);

  // Initialize the TextEditingController with the current task name
  final controller = TextEditingController(text: formState.name);

  // Update the form state only when user input changes
  controller.addListener(() {
    final currentText = controller.text;
    if (currentText != ref.read(taskFormNotifierProvider).name) {
      ref.read(taskFormNotifierProvider.notifier).updateName(currentText);
    }
  });

  // Dispose of the controller when it's no longer needed
  ref.onDispose(() {
    controller.dispose();
  });

   ref.keepAlive(); // Persist provider state until explicitly invalidated

  return controller;
}
