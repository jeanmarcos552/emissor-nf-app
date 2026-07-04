import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emissor_nfe/src/theme/app_colors.dart';
import 'package:emissor_nfe/src/theme/app_theme.dart';

void main() {
  test('AppTheme.dark configura o tema escuro do design', () {
    final t = AppTheme.dark();
    expect(t.brightness, Brightness.dark);
    expect(t.scaffoldBackgroundColor, AppColors.scaffoldBg);
    expect(t.colorScheme.primary, AppColors.secondary); // botões roxos
    expect(t.textTheme.bodyMedium?.fontFamily, 'Montserrat');
  });
}
