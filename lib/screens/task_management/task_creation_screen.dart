import 'package:flutter/material.dart';
import 'package:timetailor/core/shared/styled_text.dart';

class TaskCreationScreen extends StatefulWidget {
  const TaskCreationScreen({super.key});

  @override
  State<TaskCreationScreen> createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBarText("Task Creation"),
        centerTitle: true,
      ),
      body: const Scaffold(),
    );
  }
}