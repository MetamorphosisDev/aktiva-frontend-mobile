import 'package:flutter/material.dart';

/// Beginner-level color palette - mostly monochrome with a simple blue accent
class AppColors {
  AppColors._();

  // PRIMARY
  static const Color primary = Colors.black;
  static const Color primaryDark = Colors.black;
  static const Color primaryLight = Color(0xFFE0E0E0);
  static const Color primaryDisabled = Color(0xFF9E9E9E);

  // ACCENT
  static const Color accent = Color(0xFF1976D2);

  // SURFACES
  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  static const Color subtleFill = Color(0xFFF5F5F5);

  // TEXT
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFFBDBDBD);

  static const Color border = Color(0xFFE0E0E0);
  static const Color imagePlaceholder = Color(0xFFEEEEEE);

  // DESTRUCTIVE
  static const Color danger = Colors.black;
  static const Color dangerLight = Color(0xFFF5F5F5);
}

/// Consistent spacing scale
class AppSpacing {
  AppSpacing._();

  static const double xs = 8;
  static const double sm = 16;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 24;

  /// Horizontal page padding used by every screen.
  static const double screen = 16;
}

/// Corner radius scale - minimal rounding
class AppRadius {
  AppRadius._();

  static const double button = 4;
  static const double field = 4;
  static const double card = 4;
  static const double image = 4;
  static const double sheet = 4;
  static const double pill = 4;
}

/// Type scale - default Flutter/Material typography
class AppText {
  AppText._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    double height = 1.4,
    double spacing = 0,
    Color color = AppColors.textPrimary,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
      color: color,
    );
  }

  /// Screen headlines
  static TextStyle get display => _base(
    size: 24,
    weight: FontWeight.w500,
    height: 1.2,
  );

  /// Large headings
  static TextStyle get headline => _base(size: 20, weight: FontWeight.w500, height: 1.3);

  /// Section headings and app bar titles
  static TextStyle get title => _base(size: 18, weight: FontWeight.w500, height: 1.3);

  /// Card titles
  static TextStyle get cardTitle => _base(size: 16, weight: FontWeight.w500, height: 1.4);

  /// Long form reading copy
  static TextStyle get bodyLarge => _base(size: 16, weight: FontWeight.w400, height: 1.5);

  /// Default body copy
  static TextStyle get body => _base(size: 14, weight: FontWeight.w400, height: 1.5);

  /// Supporting copy
  static TextStyle get bodySecondary => _base(
    size: 14,
    weight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  /// Field labels and small emphasis
  static TextStyle get label => _base(size: 13, weight: FontWeight.w500, height: 1.4);

  /// Captions and metadata
  static TextStyle get caption => _base(
    size: 12,
    weight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// Uppercase eyebrows such as categories
  static TextStyle get eyebrow => _base(
    size: 11,
    weight: FontWeight.w500,
    height: 1.3,
    spacing: 0.5,
    color: AppColors.textSecondary,
  );
}

/// App-wide [ThemeData]. Basic Material theme.
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    useMaterial3: false,
    fontFamily: 'Roboto',
  );
}

/// Shared text field styling
class AppInput {
  AppInput._();

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static InputDecoration decoration({
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    BoxConstraints? prefixIconConstraints,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppText.body.copyWith(color: AppColors.textTertiary),
      filled: true,
      fillColor: AppColors.surface,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefixIconConstraints: prefixIconConstraints,
      isDense: true,
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: _border(AppColors.border),
      enabledBorder: _border(AppColors.border),
      focusedBorder: _border(AppColors.primary, width: 1.5),
      disabledBorder: _border(AppColors.border),
      errorBorder: _border(AppColors.danger),
      focusedErrorBorder: _border(AppColors.danger, width: 1.5),
    );
  }
}