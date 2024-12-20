import 'package:flutter/material.dart';

class ContentDivider extends StatelessWidget {
  const ContentDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: Colors.white, // Line color
      thickness: 1, // Line thickness
      height: 0,
    );
  }
}
