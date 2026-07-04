import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth_store.dart';
import '../config.dart';
import '../models/empresa.dart';
import '../models/nfe.dart';
import '../models/sefaz_status.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

/// Cliente HTTP da API multi-tenant do Emissor de NF-e.
class NfeApi {
  final http.Client _client;
  final String _base;
  final AuthStore auth;

  NfeApi({required this.auth, http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _base = baseUrl ?? AppConfig.apiBaseUrl;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (auth.isLoggedIn) 'Authorization': 'Bearer ${auth.token}',
      };

  // ----- Auth -----

  Future<void> register(String name, String email, String password) async {
    final res = await _client.post(
      Uri.parse('$_base/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      }),
    );
    final body = _decode(res);
    await auth.save(body['token'] as String, (body['user']?['name'] ?? name).toString());
  }

  Future<void> login(String email, String password) async {
    final res = await _client.post(
      Uri.parse('$_base/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = _decode(res);
    await auth.save(body['token'] as String, (body['user']?['name'] ?? email).toString());
  }

  Future<void> logout() async {
    try {
      await _client.post(Uri.parse('$_base/auth/logout'), headers: _headers);
    } finally {
      await auth.clear();
    }
  }

  /// Valida o token atual chamando `GET /auth/me`.
  /// Retorna false se não há sessão, se o token expirou (401) ou em erro de rede.
  Future<bool> validarSessao() async {
    if (!auth.isLoggedIn) return false;
    try {
      final res = await _client.get(Uri.parse('$_base/auth/me'), headers: _headers);
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  // ----- Empresas -----

  Future<List<Empresa>> listarEmpresas() async {
    final res = await _client.get(Uri.parse('$_base/empresas'), headers: _headers);
    final body = _decodeList(res);
    return body.map((e) => Empresa.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CnpjInfo> buscarCnpj(String cnpj) async {
    final res = await _client.get(Uri.parse('$_base/cnpj/$cnpj'), headers: _headers);
    return CnpjInfo.fromJson(_decode(res));
  }

  Future<Empresa> criarEmpresa(Map<String, dynamic> payload) async {
    final res = await _client.post(Uri.parse('$_base/empresas'),
        headers: _headers, body: jsonEncode(payload));
    return Empresa.fromJson(_decode(res));
  }

  // ----- Certificado -----

  /// Envia o .pfx por bytes (funciona em web e mobile).
  Future<Map<String, dynamic>> uploadCertificado(
      int empresaId, List<int> bytes, String filename, String senha) async {
    final req = http.MultipartRequest('POST', Uri.parse('$_base/empresas/$empresaId/certificado'))
      ..headers['Authorization'] = 'Bearer ${auth.token}'
      ..headers['Accept'] = 'application/json'
      ..fields['senha'] = senha
      ..files.add(http.MultipartFile.fromBytes('certificado', bytes, filename: filename));
    final res = await http.Response.fromStream(await req.send());
    return _decode(res);
  }

  // ----- SEFAZ / NF-e (escopadas por empresa) -----

  Future<SefazStatus> sefazStatus(int empresaId) async {
    final res = await _client.get(Uri.parse('$_base/empresas/$empresaId/sefaz/status'), headers: _headers);
    return SefazStatus.fromJson(_decode(res));
  }

  Future<List<Nfe>> listarNfe(int empresaId) async {
    final res = await _client.get(Uri.parse('$_base/empresas/$empresaId/nfe'), headers: _headers);
    final body = _decode(res);
    final data = (body['data'] as List<dynamic>? ?? []);
    return data.map((e) => Nfe.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Nfe> criarNfe(int empresaId, Map<String, dynamic> payload) async {
    final res = await _client.post(Uri.parse('$_base/empresas/$empresaId/nfe'),
        headers: _headers, body: jsonEncode(payload));
    return Nfe.fromJson(_decode(res));
  }

  Future<Nfe> emitir(int empresaId, int nfeId) async {
    final res = await _client.post(Uri.parse('$_base/empresas/$empresaId/nfe/$nfeId/emitir'), headers: _headers);
    return Nfe.fromJson(_decode(res)['nfe'] as Map<String, dynamic>);
  }

  String danfeUrl(int empresaId, int nfeId) => '$_base/empresas/$empresaId/nfe/$nfeId/danfe';

  // ----- helpers -----

  Map<String, dynamic> _decode(http.Response res) {
    final body = res.body.isEmpty ? <String, dynamic>{} : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body as Map<String, dynamic>;
    throw ApiException(_msg(body, res.statusCode));
  }

  List<dynamic> _decodeList(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw ApiException(_msg(res.body.isEmpty ? {} : jsonDecode(res.body), res.statusCode));
  }

  String _msg(dynamic body, int code) {
    if (body is Map) {
      if (body['mensagem'] != null) return body['mensagem'].toString();
      if (body['message'] != null) return body['message'].toString();
    }
    if (code == 401) return 'Sessão expirada. Faça login novamente.';
    return 'Erro $code';
  }
}
