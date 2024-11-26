import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timetailor/core/theme/custom_theme.dart';

TextStyle headingStyle({TextStyle? style}) {
  final baseStyle = GoogleFonts.kanit(
    textStyle: primaryTheme.textTheme.headlineMedium,
  );
  return baseStyle.merge(style);
}
