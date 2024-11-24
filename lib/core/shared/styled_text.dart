import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StyledText extends StatelessWidget {
  final String text;

  const StyledText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.kanit(
        textStyle: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class StyledHeading extends StatelessWidget {
  final String text;

  const StyledHeading(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      // text.toUpperCase(),
      text,
      style: GoogleFonts.kanit(
        textStyle: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

class StyledTitle extends StatelessWidget {
  final String text;

  const StyledTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      // text.toUpperCase(),
      text,
      style: GoogleFonts.kanit(
        textStyle: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
