import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';

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
              fontSize: 11,
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
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
    );
  }
}

class OverlappingIndicatorText extends ConsumerWidget {
  final String text;

  const OverlappingIndicatorText(this.text, {super.key});

  Size getTextSize(BuildContext context, [bool isSmallScreen = false]) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: isSmallScreen ? 8 : 11,
              height: isSmallScreen ? 1.75 : null,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(); // Layout the text to calculate its size

    return textPainter.size; // Returns width and height of the text
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSmallScreen = ref.watch(smallScreenTimeSlotHeightProvider) == ref.watch(defaultTimeSlotHeightProvider);

    return Text(
      // text.toUpperCase(),
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: isSmallScreen ? 8 : 11,
            height: isSmallScreen ? 1.75 : null,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
    );
  }
}

class BottomSheetDurationText extends StatelessWidget {
  final String text;

  const BottomSheetDurationText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      // text.toUpperCase(),
      text,
      style: GoogleFonts.kanit(
        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 2,
            ),
      ),
    );
  }
}

class NormalTaskNameText extends StatelessWidget {
  final String text;

  const NormalTaskNameText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      // text.toUpperCase(),
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class MiniTaskNameText extends ConsumerWidget {
  final String text;

  const MiniTaskNameText(this.text, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBigScreen = ref.watch(defaultTimeSlotHeightProvider) == ref.watch(bigScreenTimeSlotHeightProvider);

    return Text(
      // text.toUpperCase(),
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: isBigScreen ? 10 : 8,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class SmallTaskNameText extends StatelessWidget {
  final String text;

  const SmallTaskNameText(this.text, {super.key});

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
      overflow: TextOverflow.ellipsis,
    );
  }
}

class SmallTaskTimeText extends ConsumerWidget {
  final String text;

  const SmallTaskTimeText(this.text, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSmallScreen = ref.watch(smallScreenTimeSlotHeightProvider) == ref.watch(defaultTimeSlotHeightProvider);

    return Text(
      // text.toUpperCase(),
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: isSmallScreen ? 8 : 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class TitleTextInHistory extends StatelessWidget {
  final String text;

  const TitleTextInHistory(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      // text.toUpperCase(),
      text,
      style: GoogleFonts.kanit(
        textStyle: Theme.of(context).textTheme.headlineSmall,
        fontSize: 20
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

