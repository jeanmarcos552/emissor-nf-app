// lib/src/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Tokens de cor traduzidos do `theme/index.ts` do app-sejab2-admin.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFCF9F4D); // dourado
  static const Color secondary = Color(0xFF5431BC); // roxo
  static const Color success = Color(0xFF4DCFA6);
  static const Color danger = Color(0xFFDA5050);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF1356B4);
  static const Color gray = Color(0xFFA1A1A1);

  static const Color scaffoldBg = Color(0xFF161616);
  static const Color text = Color(0xFFD6D6D6);

  static const Color cardBg = Color(0x485431BC); // roxo translúcido (alpha 0x48)
  static const Color cardBorder = Color(0x755431BC); // borda do card (alpha 0x75)
}
