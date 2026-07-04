// test/widgets/status_badge_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emissor_nfe/src/widgets/status_badge.dart';

void main() {
  testWidgets('StatusBadge.nfe(autorizada) mostra "Autorizada"',
      (tester) async {
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StatusBadge.nfe('autorizada'))));
    expect(find.text('Autorizada'), findsOneWidget);
  });

  testWidgets('StatusBadge.certificado(false) mostra "Sem certificado"',
      (tester) async {
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StatusBadge.certificado(false))));
    expect(find.text('Sem certificado'), findsOneWidget);
  });
}
