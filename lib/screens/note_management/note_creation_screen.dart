import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';

class NoteCreationScreen extends ConsumerStatefulWidget {
  const NoteCreationScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NoteCreationScreenState();
}

class _NoteCreationScreenState extends ConsumerState<NoteCreationScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: const AppBarText("Create Note"),
      ),
      body: Column(
        children: [
          
        ],
      ),
    );;
  }
}