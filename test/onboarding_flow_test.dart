// test/onboarding_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emissor_nfe/src/api/nfe_api.dart';
import 'package:emissor_nfe/src/auth_store.dart';
import 'package:emissor_nfe/src/onboarding/onboarding_flow.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('OnboardingFlow começa no passo Buscar CNPJ', (tester) async {
    final auth = AuthStore()..token = 'tok';
    final api = NfeApi(
        auth: auth, client: MockClient((r) async => http.Response('{}', 200)));
    await tester.pumpWidget(MaterialApp(
      home: OnboardingFlow(api: api, onDone: () {}, onLogout: () {}),
    ));
    expect(find.text('Buscar CNPJ'), findsWidgets);
  });
}
