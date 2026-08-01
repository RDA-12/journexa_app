import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A theme class for Journexa application.
///
/// Uses generated theme by Material Theme Builder Figma plugin.
/// Uses medium contrast of theme colors.
class JournexaTheme {
  /// Creates new [JournexaTheme]
  const JournexaTheme(this.textTheme);

  /// A set of text styles for the [ThemeData] that follows the typography.
  final TextTheme textTheme;

  /// The light color scheme.
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff273267),
      surfaceTint: Color(0xff505b92),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff5f6aa2),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff323548),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff696c81),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff4a2c44),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff86627d),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffbf8ff),
      onSurface: Color(0xff101116),
      onSurfaceVariant: Color(0xff35363e),
      outline: Color(0xff51525b),
      outlineVariant: Color(0xff6c6c76),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff303036),
      inversePrimary: Color(0xffb9c3ff),
      primaryFixed: Color(0xff5f6aa2),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff465188),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff696c81),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff515468),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff86627d),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff6c4a64),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc7c5cd),
      surfaceBright: Color(0xfffbf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff5f2fa),
      surfaceContainer: Color(0xffe9e7ef),
      surfaceContainerHigh: Color(0xffdedce3),
      surfaceContainerHighest: Color(0xffd2d1d8),
    );
  }

  /// Return [ThemeData] for light color scheme.
  ThemeData light() {
    return theme(lightScheme());
  }

  /// The dark color scheme.
  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffd5daff),
      surfaceTint: Color(0xffb9c3ff),
      onPrimary: Color(0xff152155),
      primaryContainer: Color(0xff828dc8),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffd9dbf3),
      onSecondary: Color(0xff212537),
      secondaryContainer: Color(0xff8d8fa6),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfffccfef),
      onTertiary: Color(0xff381c33),
      tertiaryContainer: Color(0xffac85a1),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff121318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdcdbe6),
      outline: Color(0xffb1b1bb),
      outlineVariant: Color(0xff908f99),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe3e1e9),
      inversePrimary: Color(0xff39447a),
      primaryFixed: Color(0xffdde1ff),
      onPrimaryFixed: Color(0xff000a3d),
      primaryFixedDim: Color(0xffb9c3ff),
      onPrimaryFixedVariant: Color(0xff273267),
      secondaryFixed: Color(0xffdfe1f9),
      onSecondaryFixed: Color(0xff0d1021),
      secondaryFixedDim: Color(0xffc3c5dd),
      onSecondaryFixedVariant: Color(0xff323548),
      tertiaryFixed: Color(0xffffd7f3),
      onTertiaryFixed: Color(0xff21071d),
      tertiaryFixedDim: Color(0xffe5bad8),
      onTertiaryFixedVariant: Color(0xff4a2c44),
      surfaceDim: Color(0xff121318),
      surfaceBright: Color(0xff44444a),
      surfaceContainerLowest: Color(0xff06070c),
      surfaceContainerLow: Color(0xff1d1d23),
      surfaceContainer: Color(0xff27272d),
      surfaceContainerHigh: Color(0xff323238),
      surfaceContainerHighest: Color(0xff3d3d43),
    );
  }

  /// Return [ThemeData] for dark color scheme.
  ThemeData dark() {
    return theme(darkScheme());
  }

  /// Creates new [ThemeData] with [colorScheme]
  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );
}

/// Creates a [TextTheme] that uses different fonts for body and display text.
TextTheme createTextTheme(
  BuildContext context,
  String bodyFontString,
  String displayFontString,
) {
  final baseTextTheme = Theme.of(context).textTheme;
  final bodyTextTheme = GoogleFonts.getTextTheme(
    bodyFontString,
    baseTextTheme,
  );
  final displayTextTheme = GoogleFonts.getTextTheme(
    displayFontString,
    baseTextTheme,
  );
  final textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
  );
  return textTheme;
}

/// Extension to helps access theme data
extension ThemeX on BuildContext {
  /// Return [TextTheme] of the [ThemeData]
  TextTheme get text => TextTheme.of(this);

  /// Return [ColorScheme] of the [ThemeData]
  ColorScheme get color => ColorScheme.of(this);
}
