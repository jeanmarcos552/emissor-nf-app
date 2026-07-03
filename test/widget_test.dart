import 'package:emissor_nfe/main.dart';
import 'package:emissor_nfe/src/api/nfe_api.dart';
import 'package:emissor_nfe/src/auth_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Sem sessão, abre a tela de login', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final api = NfeApi(auth: AuthStore());

    await tester.pumpWidget(EmissorApp(api: api));
    await tester.pump();

    // A tela de login mostra o título e o botão Entrar.
    expect(find.text('Emissor NF-e'), findsWidgets);
    expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
  });
}
