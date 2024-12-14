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
        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
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
        textStyle: Theme.of(context).textTheme.headlineSmall,
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
        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
      ),
    );
  }
}

class AppBarText extends StatelessWidget {
  final String text;

  const AppBarText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      // text.toUpperCase(),
      text,
      style: GoogleFonts.kanit(
        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 2,
            ),
      ),
    );
  }
}

class DateDayText extends StatelessWidget {
  final String text;

  const DateDayText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      // text.toUpperCase(),
      text,
      style: GoogleFonts.kanit(
        textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
      ),
    );
  }
}

class DateNumberText extends StatelessWidget {
  final String text;

  const DateNumberText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      // text.toUpperCase(),
      text,
      style: GoogleFonts.kanit(
        textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
      ),
    );
  }
}

class TimeIndicatorText extends StatelessWidget {
  final String text;

  const TimeIndicatorText(this.text, {super.key});

  Size getTextSize(BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(); // Layout the text to calculate its size

    return textPainter.size; // Returns width and height of the text
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      // text.toUpperCase(),
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
    );
  }
}

// class TimeperiodTextStyle extends StatelessWidget {

//   const TimeperiodTextStyle({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Theme.of(context).textTheme.bodyLarge?.copyWith(
//           fontWeight: FontWeight.bold,
//           letterSpacing: 1,
//         ) ?? TextStyle();
//   }
// }

