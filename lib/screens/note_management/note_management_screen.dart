import 'package:flutter/material.dart';
import 'package:timetailor/core/shared/styled_text.dart';

class NoteManagementScreen extends StatefulWidget {
  const NoteManagementScreen({super.key});

  @override
  State<NoteManagementScreen> createState() => _NoteManagementScreenState();
}

class _NoteManagementScreenState extends State<NoteManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const AppBarText("Notes"),
        centerTitle: true,
      ),
      body: const Placeholder(),
    );
  }
}
