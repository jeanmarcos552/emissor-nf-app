// test/theme/app_colors_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emissor_nfe/src/theme/app_colors.dart';

void main() {
  test('tokens de cor batem com o design system', () {
    expect(AppColors.primary, const Color(0xFFCF9F4D));
    expect(AppColors.secondary, const Color(0xFF5431BC));
    expect(AppColors.success, const Color(0xFF4DCFA6));
    expect(AppColors.danger, const Color(0xFFDA5050));
    expect(AppColors.scaffoldBg, const Color(0xFF161616));
    expect(AppColors.text, const Color(0xFFD6D6D6));
    expect(AppColors.cardBg, const Color(0x485431BC));
    expect(AppColors.cardBorder, const Color(0x755431BC));
  });
}
