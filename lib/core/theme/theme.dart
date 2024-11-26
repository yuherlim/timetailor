import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4282867090),
      surfaceTint: Color(4282867090),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4292469503),
      onPrimaryContainer: Color(4278196549),
      secondary: Color(4283915889),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4292666105),
      onSecondaryContainer: Color(4279507756),
      tertiary: Color(4285683058),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4294825978),
      onTertiaryContainer: Color(4280947500),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      background: Color(4294637823),
      onBackground: Color(4279900960),
      surface: Color(4294637823),
      onSurface: Color(4279900960),
      surfaceVariant: Color(4292993772),
      onSurfaceVariant: Color(4282664527),
      outline: Color(4285888384),
      outlineVariant: Color(4291151568),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281282614),
      inverseOnSurface: Color(4294045943),
      inversePrimary: Color(4289775359),
      primaryFixed: Color(4292469503),
      onPrimaryFixed: Color(4278196549),
      primaryFixedDim: Color(4289775359),
      onPrimaryFixedVariant: Color(4281222520),
      secondaryFixed: Color(4292666105),
      onSecondaryFixed: Color(4279507756),
      secondaryFixedDim: Color(4290823900),
      onSecondaryFixedVariant: Color(4282402393),
      tertiaryFixed: Color(4294825978),
      onTertiaryFixed: Color(4280947500),
      tertiaryFixedDim: Color(4292918237),
      onTertiaryFixedVariant: Color(4284038490),
      surfaceDim: Color(4292532704),
      surfaceBright: Color(4294637823),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294243322),
      surfaceContainer: Color(4293848564),
      surfaceContainerHigh: Color(4293453807),
      surfaceContainerHighest: Color(4293059305),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4280959348),
      surfaceTint: Color(4282867090),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4284314537),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4282139221),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4285428872),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4283775573),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4287261321),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      background: Color(4294637823),
      onBackground: Color(4279900960),
      surface: Color(4294637823),
      onSurface: Color(4279900960),
      surfaceVariant: Color(4292993772),
      onSurfaceVariant: Color(4282401611),
      outline: Color(4284309351),
      outlineVariant: Color(4286151299),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281282614),
      inverseOnSurface: Color(4294045943),
      inversePrimary: Color(4289775359),
      primaryFixed: Color(4284314537),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4282669967),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4285428872),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4283784303),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4287261321),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4285551216),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292532704),
      surfaceBright: Color(4294637823),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294243322),
      surfaceContainer: Color(4293848564),
      surfaceContainerHigh: Color(4293453807),
      surfaceContainerHighest: Color(4293059305),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4278263633),
      surfaceTint: Color(4282867090),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4280959348),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4279968307),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4282139221),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4281407795),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4283775573),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      background: Color(4294637823),
      onBackground: Color(4279900960),
      surface: Color(4294637823),
      onSurface: Color(4278190080),
      surfaceVariant: Color(4292993772),
      onSurfaceVariant: Color(4280362027),
      outline: Color(4282401611),
      outlineVariant: Color(4282401611),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281282614),
      inverseOnSurface: Color(4294967295),
      inversePrimary: Color(4293389311),
      primaryFixed: Color(4280959348),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4279249756),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4282139221),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4280691774),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4283775573),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4282197054),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292532704),
      surfaceBright: Color(4294637823),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294243322),
      surfaceContainer: Color(4293848564),
      surfaceContainerHigh: Color(4293453807),
      surfaceContainerHighest: Color(4293059305),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4289775359),
      surfaceTint: Color(4289775359),
      onPrimary: Color(4279578208),
      primaryContainer: Color(4281222520),
      onPrimaryContainer: Color(4292469503),
      secondary: Color(4290823900),
      onSecondary: Color(4280889410),
      secondaryContainer: Color(4282402393),
      onSecondaryContainer: Color(4292666105),
      tertiary: Color(4292918237),
      onTertiary: Color(4282459970),
      tertiaryContainer: Color(4284038490),
      onTertiaryContainer: Color(4294825978),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      background: Color(4279374616),
      onBackground: Color(4293059305),
      surface: Color(4279374616),
      onSurface: Color(4293059305),
      surfaceVariant: Color(4282664527),
      onSurfaceVariant: Color(4291151568),
      outline: Color(4287598745),
      outlineVariant: Color(4282664527),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293059305),
      inverseOnSurface: Color(4281282614),
      inversePrimary: Color(4282867090),
      primaryFixed: Color(4292469503),
      onPrimaryFixed: Color(4278196549),
      primaryFixedDim: Color(4289775359),
      onPrimaryFixedVariant: Color(4281222520),
      secondaryFixed: Color(4292666105),
      onSecondaryFixed: Color(4279507756),
      secondaryFixedDim: Color(4290823900),
      onSecondaryFixedVariant: Color(4282402393),
      tertiaryFixed: Color(4294825978),
      onTertiaryFixed: Color(4280947500),
      tertiaryFixedDim: Color(4292918237),
      onTertiaryFixedVariant: Color(4284038490),
      surfaceDim: Color(4279374616),
      surfaceBright: Color(4281874751),
      surfaceContainerLowest: Color(4278980115),
      surfaceContainerLow: Color(4279900960),
      surfaceContainer: Color(4280164133),
      surfaceContainerHigh: Color(4280822319),
      surfaceContainerHighest: Color(4281546042),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4290169599),
      surfaceTint: Color(4289775359),
      onPrimary: Color(4278195258),
      primaryContainer: Color(4286222536),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4291087073),
      onSecondary: Color(4279178790),
      secondaryContainer: Color(4287271077),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4293181410),
      onTertiary: Color(4280552743),
      tertiaryContainer: Color(4289169062),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      background: Color(4279374616),
      onBackground: Color(4293059305),
      surface: Color(4279374616),
      onSurface: Color(4294769407),
      surfaceVariant: Color(4282664527),
      onSurfaceVariant: Color(4291414740),
      outline: Color(4288783020),
      outlineVariant: Color(4286677900),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293059305),
      inverseOnSurface: Color(4280822319),
      inversePrimary: Color(4281353849),
      primaryFixed: Color(4292469503),
      onPrimaryFixed: Color(4278193968),
      primaryFixedDim: Color(4289775359),
      onPrimaryFixedVariant: Color(4280038502),
      secondaryFixed: Color(4292666105),
      onSecondaryFixed: Color(4278849825),
      secondaryFixedDim: Color(4290823900),
      onSecondaryFixedVariant: Color(4281284168),
      tertiaryFixed: Color(4294825978),
      onTertiaryFixed: Color(4280158241),
      tertiaryFixedDim: Color(4292918237),
      onTertiaryFixedVariant: Color(4282854728),
      surfaceDim: Color(4279374616),
      surfaceBright: Color(4281874751),
      surfaceContainerLowest: Color(4278980115),
      surfaceContainerLow: Color(4279900960),
      surfaceContainer: Color(4280164133),
      surfaceContainerHigh: Color(4280822319),
      surfaceContainerHighest: Color(4281546042),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294769407),
      surfaceTint: Color(4289775359),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4290169599),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294769407),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4291087073),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294965754),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4293181410),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      background: Color(4279374616),
      onBackground: Color(4293059305),
      surface: Color(4279374616),
      onSurface: Color(4294967295),
      surfaceVariant: Color(4282664527),
      onSurfaceVariant: Color(4294769407),
      outline: Color(4291414740),
      outlineVariant: Color(4291414740),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293059305),
      inverseOnSurface: Color(4278190080),
      inversePrimary: Color(4278986841),
      primaryFixed: Color(4292863743),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4290169599),
      onPrimaryFixedVariant: Color(4278195258),
      secondaryFixed: Color(4292929277),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4291087073),
      onSecondaryFixedVariant: Color(4279178790),
      tertiaryFixed: Color(4294958332),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4293181410),
      onTertiaryFixedVariant: Color(4280552743),
      surfaceDim: Color(4279374616),
      surfaceBright: Color(4281874751),
      surfaceContainerLowest: Color(4278980115),
      surfaceContainerLow: Color(4279900960),
      surfaceContainer: Color(4280164133),
      surfaceContainerHigh: Color(4280822319),
      surfaceContainerHighest: Color(4281546042),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme().toColorScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary, 
    required this.surfaceTint, 
    required this.onPrimary, 
    required this.primaryContainer, 
    required this.onPrimaryContainer, 
    required this.secondary, 
    required this.onSecondary, 
    required this.secondaryContainer, 
    required this.onSecondaryContainer, 
    required this.tertiary, 
    required this.onTertiary, 
    required this.tertiaryContainer, 
    required this.onTertiaryContainer, 
    required this.error, 
    required this.onError, 
    required this.errorContainer, 
    required this.onErrorContainer, 
    required this.background, 
    required this.onBackground, 
    required this.surface, 
    required this.onSurface, 
    required this.surfaceVariant, 
    required this.onSurfaceVariant, 
    required this.outline, 
    required this.outlineVariant, 
    required this.shadow, 
    required this.scrim, 
    required this.inverseSurface, 
    required this.inverseOnSurface, 
    required this.inversePrimary, 
    required this.primaryFixed, 
    required this.onPrimaryFixed, 
    required this.primaryFixedDim, 
    required this.onPrimaryFixedVariant, 
    required this.secondaryFixed, 
    required this.onSecondaryFixed, 
    required this.secondaryFixedDim, 
    required this.onSecondaryFixedVariant, 
    required this.tertiaryFixed, 
    required this.onTertiaryFixed, 
    required this.tertiaryFixedDim, 
    required this.onTertiaryFixedVariant, 
    required this.surfaceDim, 
    required this.surfaceBright, 
    required this.surfaceContainerLowest, 
    required this.surfaceContainerLow, 
    required this.surfaceContainer, 
    required this.surfaceContainerHigh, 
    required this.surfaceContainerHighest, 
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
}

extension MaterialSchemeUtils on MaterialScheme {
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    );
  }
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
