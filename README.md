# Emissor NF-e — App (Flutter)

App multiplataforma (web + Android) que consome a API do
**[emissor-nf](https://github.com/jeanmarcos552/emissor-nf)** (Laravel + sped-nfe)
para emissão de NF-e (modelo 55) direto com a SEFAZ.

**Fluxo:** login/registro → lista de empresas → adicionar CNPJ (busca automática)
→ upload do certificado A1 → status SEFAZ / notas / nova NF-e.

## Requisitos
- Flutter **3.44+ / Dart 3.12+**
- A API (backend) rodando — por padrão em `http://localhost:8080`

## Rodar
```bash
flutter pub get

# Web (backend em http://localhost:8080)
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api
# headless:
flutter run -d web-server --web-port 9100 --dart-define=API_BASE_URL=http://localhost:8080/api

# Android (emulador): o host do PC é 10.0.2.2
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api
```

Build web de produção: `flutter build web --release` (saída em `build/web/`).

> `API_BASE_URL` tem default `http://localhost:8080/api` (ver
> [lib/src/config.dart](lib/src/config.dart)); em web local roda sem `--dart-define`.

## Estrutura
```
lib/
├── main.dart                 # bootstrap de sessão + roteamento inicial
└── src/
    ├── config.dart           # API_BASE_URL
    ├── auth_store.dart       # token persistido (shared_preferences)
    ├── api/nfe_api.dart      # cliente HTTP (auth, empresas, certificado, NF-e)
    ├── models/               # Empresa, Nfe, SefazStatus, ...
    └── screens/              # login, empresas, certificado, dashboard, notas
```

## Status
- Compila limpo (`flutter analyze` sem issues; widget test passando; build web OK).
- Fluxo de conta/empresa/certificado/rascunho funcional contra a API.
- **Emitir** depende de um certificado A1 (.pfx) válido cadastrado na empresa.
# emissor-nf-app
