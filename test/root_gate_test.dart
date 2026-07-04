// test/root_gate_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emissor_nfe/main.dart';
import 'package:emissor_nfe/src/api/nfe_api.dart';
import 'package:emissor_nfe/src/auth_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('sem sessão, RootGate mostra a tela de login', (tester) async {
    final auth = AuthStore(); // não logado
    final api = NfeApi(auth: auth, client: MockClient((r) async => http.Response('', 200)));
    await tester.pumpWidget(EmissorApp(api: api));
    await tester.pumpAndSettle();
    expect(find.text('Entrar'), findsWidgets); // botão/label da tela de login
  });

  testWidgets('logado sem empresa vai para o onboarding', (tester) async {
    final auth = AuthStore()..token = 'tok';
    final client = MockClient((req) async {
      if (req.url.path.endsWith('/auth/me')) return http.Response('{"id":1}', 200);
      if (req.url.path.endsWith('/empresas')) return http.Response('[]', 200);
      return http.Response('', 404);
    });
    final api = NfeApi(auth: auth, client: client);
    await tester.pumpWidget(EmissorApp(api: api));
    await tester.pumpAndSettle();
    expect(find.text('Buscar CNPJ'), findsWidgets); // passo 1 do wizard
  });
}
