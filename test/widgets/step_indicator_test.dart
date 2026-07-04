// test/widgets/step_indicator_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emissor_nfe/src/widgets/step_indicator.dart';

void main() {
  testWidgets('StepIndicator renderiza uma barra por passo', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: StepIndicator(current: 2, total: 3)),
    ));
    // Uma barra (Expanded) por passo.
    expect(find.byType(Expanded), findsNWidgets(3));
  });
}
