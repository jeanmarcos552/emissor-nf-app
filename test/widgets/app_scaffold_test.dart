// test/widgets/app_scaffold_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emissor_nfe/src/theme/app_theme.dart';
import 'package:emissor_nfe/src/widgets/app_scaffold.dart';

void main() {
  testWidgets('AppScaffold mostra título e corpo', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: const AppScaffold(title: 'Empresas', body: Text('conteúdo')),
    ));
    expect(find.text('Empresas'), findsOneWidget);
    expect(find.text('conteúdo'), findsOneWidget);
  });
}
