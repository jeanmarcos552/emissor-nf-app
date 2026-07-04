// test/widgets/app_text_field_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emissor_nfe/src/theme/app_theme.dart';
import 'package:emissor_nfe/src/widgets/app_text_field.dart';

void main() {
  testWidgets('AppTextField exibe label e mensagem de erro', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: const Scaffold(
        body: AppTextField(label: 'E-mail', errorText: 'E-mail inválido'),
      ),
    ));
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('E-mail inválido'), findsOneWidget);
  });
}
