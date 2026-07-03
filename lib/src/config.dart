/// Configuração do app.
///
/// A URL base da API pode ser sobrescrita em tempo de build:
///   flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080/api
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // 8080 é a porta publicada pelo docker-compose do backend.
    // Em emulador Android use http://10.0.2.2:8080/api
    defaultValue: 'http://localhost:8080/api',
  );
}
