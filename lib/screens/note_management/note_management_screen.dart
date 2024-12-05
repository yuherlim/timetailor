import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/shared/styled_text.dart';

class NoteManagementScreen extends ConsumerStatefulWidget {
  const NoteManagementScreen({super.key});

  @override
  ConsumerState<NoteManagementScreen> createState() =>
      _NoteManagementScreenState();
}

class _NoteManagementScreenState extends ConsumerState<NoteManagementScreen> {
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
