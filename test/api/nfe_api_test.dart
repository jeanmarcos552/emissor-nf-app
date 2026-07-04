import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:emissor_nfe/src/api/nfe_api.dart';
import 'package:emissor_nfe/src/auth_store.dart';

void main() {
  test('validarSessao retorna true quando /auth/me responde 200', () async {
    final auth = AuthStore()..token = 'tok';
    final client = MockClient((req) async {
      expect(req.url.path, endsWith('/auth/me'));
      return http.Response('{"id":1,"name":"Jean"}', 200);
    });
    final api = NfeApi(auth: auth, client: client);
    expect(await api.validarSessao(), isTrue);
  });

  test('validarSessao retorna false quando /auth/me responde 401', () async {
    final auth = AuthStore()..token = 'tok';
    final client = MockClient((req) async => http.Response('', 401));
    final api = NfeApi(auth: auth, client: client);
    expect(await api.validarSessao(), isFalse);
  });

  test('validarSessao retorna false quando não há sessão', () async {
    final auth = AuthStore(); // token null
    final client = MockClient((req) async => http.Response('', 200));
    final api = NfeApi(auth: auth, client: client);
    expect(await api.validarSessao(), isFalse);
  });
}
