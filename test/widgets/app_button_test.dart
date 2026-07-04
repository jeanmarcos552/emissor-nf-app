// test/widgets/app_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emissor_nfe/src/theme/app_theme.dart';
import 'package:emissor_nfe/src/widgets/app_button.dart';

void main() {
  testWidgets('AppButton mostra o label', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(body: AppButton(label: 'Entrar', onPressed: () {})),
    ));
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('AppButton em loading mostra spinner e não dispara onPressed',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: AppButton(
            label: 'Entrar', loading: true, onPressed: () => tapped = true),
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(tapped, isFalse);
  });
}
