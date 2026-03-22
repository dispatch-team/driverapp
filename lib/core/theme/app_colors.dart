import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

// ─── Primitive palette ────────────────────────────────────────────────────────
/// Raw color primitives. Use `AppColors` (semantic tokens) in UI widgets.
class AppPalette {
  AppPalette._();

  // Status / feedback
  static const Color success = Color(0xFF34A853);
  static const Color error   = Color(0xFFEA4335);
  static const Color warning = Color(0xFFFBBC04);
  static const Color info    = Color(0xFF4285F4);
}

// ─── Semantic color tokens ────────────────────────────────────────────────────
/// Theme-aware semantic tokens. Access anywhere via:
///   Theme.of(context).extension<AppColors>()!
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brand,
    required this.brandDim,
    required this.scaffold,
    required this.surface,
    required this.surfaceContainer,
    required this.inputFill,
    required this.borderSubtle,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textCaption,
    required this.textHint,
    required this.textLink,
    required this.iconSubtle,
    required this.patternOpacity,
    required this.buttonShadow,
    required this.navBackground,
    required this.navBorderColor,
    required this.navBlur,
  });

  /// Primary brand color.
  final Color brand;

  /// Dimmed brand used at gradient ends and pressed states.
  final Color brandDim;

  /// Page / Scaffold background.
  final Color scaffold;

  /// Card, dialog, and sheet background.
  final Color surface;

  /// Muted surface for card wrappers and section backgrounds.
  final Color surfaceContainer;

  /// Text field fill / input background.
  final Color inputFill;

  /// Subtle container borders and outlines.
  final Color borderSubtle;

  /// Horizontal dividers and list separators.
  final Color divider;

  /// High-emphasis text — headings.
  final Color textPrimary;

  /// Medium-emphasis body and subtitle text.
  final Color textSecondary;

  /// Low-emphasis captions and uppercase labels.
  final Color textCaption;

  /// Placeholder / hint text inside inputs.
  final Color textHint;

  /// Interactive link and accent text (e.g. "Forgot?").
  final Color textLink;

  /// Subtle icon color used inside input fields.
  final Color iconSubtle;

  /// Opacity of the decorative background dot pattern.
  final double patternOpacity;

  /// Drop shadow for the primary action button.
  final BoxShadow buttonShadow;

  /// Navigation / app bar background color.
  final Color navBackground;

  /// Navigation bar bottom border color.
  final Color navBorderColor;

  /// Whether the navigation bar applies a backdrop blur.
  final bool navBlur;

  // ─── Light theme ─────────────────────────────────────────────────────────

  static const AppColors light = AppColors(
    brand:            Color(0xFFFF8C00),
    brandDim:         Color(0xFF904D00),
    scaffold:         Color(0xFFF9F9FC),
    surface:          Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFF3F3F6),
    inputFill:        Color(0xFFF3F3F6),
    borderSubtle:     Colors.transparent,
    divider:          Color(0xFFDADCE0),
    textPrimary:      Color(0xFF1A1C1E),
    textSecondary:    Color(0xFF564334),
    textCaption:      Color(0xFF564334),
    textHint:         Color(0x80DDC1AE),
    textLink:         Color(0xFF904D00),
    iconSubtle:       Color(0x80DDC1AE),
    patternOpacity:   0.05,
    buttonShadow: BoxShadow(
      color:      Color(0x1A000000),
      blurRadius: 15,
      offset:     Offset(0, 10),
    ),
    navBackground:  Color(0xFFF9F9FC),
    navBorderColor: Colors.transparent,
    navBlur:        false,
  );

  // ─── Dark theme ──────────────────────────────────────────────────────────

  static const AppColors dark = AppColors(
    brand:            Color(0xFFFF8C00),
    brandDim:         Color(0xFFB26200),
    scaffold:         Color(0xFF020617),
    surface:          Color(0xFF0F172A),
    surfaceContainer: Color(0x800F172A),
    inputFill:        Color(0xFF020617),
    borderSubtle:     Color(0xFF1E293B),
    divider:          Color(0xFF1E293B),
    textPrimary:      Color(0xFFFFFFFF),
    textSecondary:    Color(0xFF94A3B8),
    textCaption:      Color(0xFF64748B),
    textHint:         Color(0xFF334155),
    textLink:         Color(0xFFFF8C00),
    iconSubtle:       Color(0xFF64748B),
    patternOpacity:   0.10,
    buttonShadow: BoxShadow(
      color:      Color(0x33FF8C00),
      blurRadius: 32,
      offset:     Offset(0, 8),
    ),
    navBackground:  Color(0xD9020617),
    navBorderColor: Color(0x801E293B),
    navBlur:        true,
  );

  // ─── ThemeExtension ───────────────────────────────────────────────────────

  @override
  AppColors copyWith({
    Color? brand,
    Color? brandDim,
    Color? scaffold,
    Color? surface,
    Color? surfaceContainer,
    Color? inputFill,
    Color? borderSubtle,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textCaption,
    Color? textHint,
    Color? textLink,
    Color? iconSubtle,
    double? patternOpacity,
    BoxShadow? buttonShadow,
    Color? navBackground,
    Color? navBorderColor,
    bool? navBlur,
  }) {
    return AppColors(
      brand:            brand            ?? this.brand,
      brandDim:         brandDim         ?? this.brandDim,
      scaffold:         scaffold         ?? this.scaffold,
      surface:          surface          ?? this.surface,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      inputFill:        inputFill        ?? this.inputFill,
      borderSubtle:     borderSubtle     ?? this.borderSubtle,
      divider:          divider          ?? this.divider,
      textPrimary:      textPrimary      ?? this.textPrimary,
      textSecondary:    textSecondary    ?? this.textSecondary,
      textCaption:      textCaption      ?? this.textCaption,
      textHint:         textHint         ?? this.textHint,
      textLink:         textLink         ?? this.textLink,
      iconSubtle:       iconSubtle       ?? this.iconSubtle,
      patternOpacity:   patternOpacity   ?? this.patternOpacity,
      buttonShadow:     buttonShadow     ?? this.buttonShadow,
      navBackground:    navBackground    ?? this.navBackground,
      navBorderColor:   navBorderColor   ?? this.navBorderColor,
      navBlur:          navBlur          ?? this.navBlur,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brand:            Color.lerp(brand,            other.brand,            t)!,
      brandDim:         Color.lerp(brandDim,         other.brandDim,         t)!,
      scaffold:         Color.lerp(scaffold,         other.scaffold,         t)!,
      surface:          Color.lerp(surface,          other.surface,          t)!,
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      inputFill:        Color.lerp(inputFill,        other.inputFill,        t)!,
      borderSubtle:     Color.lerp(borderSubtle,     other.borderSubtle,     t)!,
      divider:          Color.lerp(divider,          other.divider,          t)!,
      textPrimary:      Color.lerp(textPrimary,      other.textPrimary,      t)!,
      textSecondary:    Color.lerp(textSecondary,    other.textSecondary,    t)!,
      textCaption:      Color.lerp(textCaption,      other.textCaption,      t)!,
      textHint:         Color.lerp(textHint,         other.textHint,         t)!,
      textLink:         Color.lerp(textLink,         other.textLink,         t)!,
      iconSubtle:       Color.lerp(iconSubtle,       other.iconSubtle,       t)!,
      patternOpacity:   lerpDouble(patternOpacity,   other.patternOpacity,   t)!,
      buttonShadow:     BoxShadow.lerp(buttonShadow, other.buttonShadow,     t)!,
      navBackground:    Color.lerp(navBackground,    other.navBackground,    t)!,
      navBorderColor:   Color.lerp(navBorderColor,   other.navBorderColor,   t)!,
      navBlur:          t < 0.5 ? navBlur : other.navBlur,
    );
  }
}
