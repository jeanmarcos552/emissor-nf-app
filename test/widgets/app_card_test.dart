// test/widgets/app_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emissor_nfe/src/theme/app_theme.dart';
import 'package:emissor_nfe/src/widgets/app_card.dart';

void main() {
  testWidgets('AppCard renderiza o filho', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: const Scaffold(body: AppCard(child: Text('conteúdo'))),
    ));
    expect(find.text('conteúdo'), findsOneWidget);
  });

  testWidgets('AppCard com onTap é clicável', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: AppCard(onTap: () => tapped = true, child: const Text('x')),
      ),
    ));
    await tester.tap(find.text('x'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
