import 'package:shared_preferences/shared_preferences.dart';

/// Guarda o token da sessão (persistido) e a empresa atualmente selecionada.
/// Simplificado para o scaffold; um app real usaria um state manager.
class AuthStore {
  static const _kToken = 'auth_token';
  static const _kUser = 'user_name';

  String? token;
  String? userName;

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_kToken);
    userName = prefs.getString(_kUser);
  }

  Future<void> save(String token, String userName) async {
    this.token = token;
    this.userName = userName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    await prefs.setString(_kUser, userName);
  }

  Future<void> clear() async {
    token = null;
    userName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUser);
  }
}
