import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/shared/styled_button.dart';
import 'package:timetailor/core/shared/styled_text.dart';

class AddNoteButton extends ConsumerStatefulWidget {
  const AddNoteButton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddNoteButtonState();
}

class _AddNoteButtonState extends ConsumerState<AddNoteButton> {
  @override
  Widget build(BuildContext context) {
    return StyledButton(
      onPressed: () => print("add note button pressed."),
      child: const ButtonText("Add note"),
    );
  }
}
