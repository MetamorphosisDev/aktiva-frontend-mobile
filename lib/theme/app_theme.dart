import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AKTIVA colour palette.
///
/// A deep navy identity on warm cream paper, with blue for links, soft blue for
/// tints and a warm orange that is used only for tiny accents.
///
/// Balance to aim for: ~70% white/cream, ~20% navy/blue, ~8% neutral grey,
/// ~2% orange.
class AppColors {
  AppColors._();

  // ---- Primary (deep navy) ----
  static const Color primary = Color(0xFF172554);
  static const Color primaryDark = Color(0xFF0F1A3D);
  static const Color primaryLight = Color(0xFFDBEAFE);
  static const Color primaryDisabled = Color(0xFFAEB6C8);

  // ---- Secondary (blue) ----
  static const Color blue = Color(0xFF2563EB);

  // ---- Accent (warm orange, tiny highlights only) ----
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFDF0D5);
  static const Color accentDark = Color(0xFFB45309);

  // ---- Surfaces ----
  static const Color background = Color(0xFFFAF8F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color subtleFill = Color(0xFFF2EFE7);

  // ---- Text ----
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  static const Color border = Color(0xFFE5E7EB);
  static const Color imagePlaceholder = Color(0xFFEFECE4);

  // ---- Destructive ----
  static const Color danger = Color(0xFFB42318);
  static const Color dangerLight = Color(0xFFFEF3F2);
}

/// Consistent spacing scale (multiples that read well on mobile).
class AppSpacing {
  AppSpacing._();

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Horizontal page padding used by every screen.
  static const double screen = 20;
}

/// Corner radius scale. Modern, but never over-rounded.
class AppRadius {
  AppRadius._();

  static const double button = 13;
  static const double field = 13;
  static const double card = 16;
  static const double image = 14;
  static const double sheet = 22;
  static const double pill = 100;
}

/// Type scale built on Plus Jakarta Sans.
class AppText {
  AppText._();

  static TextStyle _jakarta({
    required double size,
    required FontWeight weight,
    double height = 1.4,
    double spacing = 0,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
      color: color,
    );
  }

  /// 28–32px — screen headlines.
  static TextStyle get display => _jakarta(
    size: 30,
    weight: FontWeight.w700,
    height: 1.14,
    spacing: -0.6,
  );

  /// 24px — large headings.
  static TextStyle get headline =>
      _jakarta(size: 24, weight: FontWeight.w700, height: 1.2, spacing: -0.4);

  /// 20–22px — section headings and app bar titles.
  static TextStyle get title => _jakarta(
    size: 20,
    weight: FontWeight.w700,
    height: 1.25,
    spacing: -0.2,
  );

  /// 17–18px — card titles.
  static TextStyle get cardTitle =>
      _jakarta(size: 17, weight: FontWeight.w600, height: 1.35);

  /// 15–16px — long form reading copy.
  static TextStyle get bodyLarge =>
      _jakarta(size: 16, weight: FontWeight.w400, height: 1.75);

  /// 14–15px — default body copy.
  static TextStyle get body =>
      _jakarta(size: 14.5, weight: FontWeight.w400, height: 1.6);

  /// 14px — supporting copy.
  static TextStyle get bodySecondary => _jakarta(
    size: 14,
    weight: FontWeight.w400,
    height: 1.55,
    color: AppColors.textSecondary,
  );

  /// 13px — field labels and small emphasis.
  static TextStyle get label =>
      _jakarta(size: 13, weight: FontWeight.w600, height: 1.4);

  /// 12–13px — captions and metadata.
  static TextStyle get caption => _jakarta(
    size: 12.5,
    weight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  /// 11px — uppercase eyebrows such as categories.
  static TextStyle get eyebrow => _jakarta(
    size: 11,
    weight: FontWeight.w700,
    height: 1.3,
    spacing: 1.0,
    color: AppColors.textSecondary,
  );
}

/// App-wide [ThemeData]. Kept intentionally small: individual screens style
/// their own widgets so the design stays predictable.
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
  );
}

/// Shared text field styling so every form looks identical.
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
      focusedBorder: _border(AppColors.primary, width: 1.6),
      disabledBorder: _border(AppColors.border),
      errorBorder: _border(AppColors.danger),
      focusedErrorBorder: _border(AppColors.danger, width: 1.6),
    );
  }
}
