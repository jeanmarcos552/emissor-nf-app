import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emissor_nfe/src/api/nfe_api.dart';
import 'package:emissor_nfe/src/auth_store.dart';
import 'package:emissor_nfe/src/screens/nfe_form_screen.dart';
import 'package:emissor_nfe/src/theme/app_theme.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('adicionar item incrementa a contagem de itens', (tester) async {
    final api = NfeApi(
        auth: AuthStore()..token = 't',
        client: MockClient((r) async => http.Response('{}', 200)));
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: NfeFormScreen(api: api, empresaId: 1),
    ));
    expect(find.text('Itens (1)'), findsOneWidget);
    await tester.ensureVisible(find.text('Item'));
    await tester.tap(find.text('Item'));
    await tester.pumpAndSettle();
    expect(find.text('Itens (2)'), findsOneWidget);
  });
}
