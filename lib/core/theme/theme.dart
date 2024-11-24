import 'package:flutter/material.dart';

class AppColors {
  static Color primaryColor = const Color.fromRGBO(13, 71, 161, 1); // Deep Vibrant Blue
  static Color primaryAccent = const Color.fromRGBO(21, 101, 192, 1); // Brighter, contrasting Blue
  static Color secondaryColor = const Color.fromRGBO(45, 45, 45, 1);
  static Color secondaryAccent = const Color.fromRGBO(35, 35, 35, 1);
  static Color titleColor = const Color.fromRGBO(200, 200, 200, 1);
  static Color textColor = const Color.fromRGBO(150, 150, 150, 1);
  static Color successColor = const Color.fromRGBO(9, 149, 110, 1);
  static Color highlightColor = const Color.fromRGBO(212, 172, 13, 1);
}

ThemeData primaryTheme = ThemeData(
  //seed
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primaryColor,
  ),

  //scaffold background color
  scaffoldBackgroundColor: AppColors.secondaryAccent,

  //app bar theme colors
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.secondaryColor,
    foregroundColor: AppColors.textColor,
    surfaceTintColor: Colors.transparent,
    centerTitle: true,
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: AppColors.textColor,
      fontSize: 16,
      letterSpacing: 1,
    ),
    headlineMedium: TextStyle(
      color: AppColors.titleColor,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    ),
    titleMedium: TextStyle(
      color: AppColors.titleColor,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    ),
  ),
  cardTheme: CardTheme(
    color: AppColors.secondaryColor.withOpacity(0.5),
    surfaceTintColor: Colors
        .transparent, // used to remove default red tint from the seed color.
    shape: const RoundedRectangleBorder(),
    shadowColor: Colors.transparent,
    margin: const EdgeInsets.only(bottom: 16.0),
  ),

  //input decoration theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.secondaryColor.withOpacity(0.5),
    border: InputBorder.none,
    labelStyle: TextStyle(
      color: AppColors.textColor,
    ),
    prefixIconColor: AppColors.textColor,
  ),

  //dialog theme
  dialogTheme: DialogTheme(
    backgroundColor: AppColors.secondaryColor,
    surfaceTintColor: Colors.transparent,
  ),
);
