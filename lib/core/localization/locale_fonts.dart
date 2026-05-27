import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Returns [TextStyle] appropriate for the current locale.
/// When Amharic is active, falls back to bundled NotoSansEthiopic which
/// supports Ethiopic Unicode (U+1200–U+137F). Otherwise uses Google Fonts.

bool get _isAmharic => Get.locale?.languageCode == 'am';

/// Body / label style — falls back to Inter.
TextStyle localeBodyStyle({
  required double fontSize,
  required FontWeight fontWeight,
  required Color color,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
  Color? decorationColor,
}) {
  if (_isAmharic) {
    return TextStyle(
      fontFamily: 'NotoSansEthiopic',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }
  return GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    decoration: decoration,
    decorationColor: decorationColor,
  );
}

/// Heading style — falls back to Space Grotesk.
TextStyle localeHeadingStyle({
  required double fontSize,
  required FontWeight fontWeight,
  required Color color,
  double? letterSpacing,
  double? height,
}) {
  if (_isAmharic) {
    return TextStyle(
      fontFamily: 'NotoSansEthiopic',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      // Amharic script reads comfortably at slightly looser leading.
      height: height ?? 1.3,
      letterSpacing: letterSpacing,
    );
  }
  return GoogleFonts.spaceGrotesk(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
}
