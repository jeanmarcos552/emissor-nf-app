# Design — Front Flutter repaginado + integração com a API

- **Data:** 2026-07-04
- **App:** `emissor-nf-app` (Flutter, web + Android)
- **API:** backend Laravel/Sanctum (`sped-nfe`), multi-tenant — `docker-compose` na porta `8080`
- **Referência de design:** `app-sejab2-admin` (React Native/Expo) — usada **apenas como referência visual**; nenhum componente `.tsx` é reutilizado diretamente.

## Contexto

O app Flutter já existe e está funcional: possui o cliente HTTP completo (`lib/src/api/nfe_api.dart`), persistência de sessão (`auth_store.dart`), modelos (`empresa`, `nfe`, `sefaz_status`) e todas as telas do fluxo (login, empresas, certificado, painel, NF-e, status). O que falta é: (1) aplicar a linguagem visual do design de referência (dourado/roxo, tema escuro, Montserrat) e (2) reorganizar a navegação em um fluxo guiado de primeiro acesso, mantendo o suporte a múltiplas empresas.

**Decisões já tomadas:**
- **Framework:** manter Flutter (não migrar para React Native). Os componentes RN servem só como referência de aparência.
- **Navegação:** híbrida — assistente guiado no primeiro acesso, lista + painel quando já houver empresa configurada.
- **Abordagem de estilo:** tema central (`ThemeData`) + um conjunto enxuto de widgets reutilizáveis. A maioria das telas é restilizada pelo tema global; widgets próprios cobrem o que o tema não alcança.

## Arquitetura de pastas

Mantém o que existe e acrescenta camadas de tema/widgets/onboarding:

```
lib/src/
  api/nfe_api.dart        (mantém; ajustes: me(), tratamento 401)
  auth_store.dart          (mantém)
  config.dart              (mantém)
  models/                  (mantém)
  theme/
    app_colors.dart        # tokens do theme/index.ts
    app_theme.dart         # ThemeData escuro + Montserrat + temas de componente
  widgets/
    app_scaffold.dart      # fundo #161616 + AppBar padrão
    app_card.dart          # card roxo translúcido, raio 16, borda 1.5
    app_button.dart        # variantes primary/outline/success/link + loading
    app_text_field.dart    # label dourado + ícone + estado de erro (danger)
    status_badge.dart      # pill de status (NF-e / certificado)
    step_indicator.dart    # "Passo x/3" do wizard
  onboarding/
    onboarding_flow.dart   # orquestra o wizard (CNPJ -> certificado -> pronto)
  screens/                 # cada tela ajustada para usar os widgets/tema
```

## Design system (tradução `theme/index.ts` → Flutter)

**Tokens de cor** (`app_colors.dart`):

| Token | Valor | Uso |
|---|---|---|
| primary (dourado) | `#cf9f4d` | labels, ícones, links, acentos |
| secondary (roxo) | `#5431bc` | fundo de botões |
| success | `rgb(77,207,166)` | status ok / botão success |
| danger | `#da5050` | erros, status negado |
| warning | `#f59e0b` | avisos (ex.: sem certificado) |
| info | `#1356b4` | informações |
| gray | `#a1a1a1` | subtítulos, textos secundários |
| scaffold bg | `#161616` | fundo geral |
| card bg | `#5431bc48` | fundo do card (roxo translúcido) |
| card border | `#5431bc75` | borda do card (1.5px) |
| text | `#d6d6d6` | texto padrão |

**Tipografia — Montserrat:** título 20/700, subtítulo 16/600 (cinza), corpo 14, small 12.
Os arquivos `.ttf` (Montserrat-Medium, Montserrat-SemiBold) serão empacotados em `assets/fonts/` e declarados no `pubspec.yaml`. Origem: copiar do `app-sejab2-admin` se existirem; caso contrário, baixar as fontes oficiais do Montserrat.

**ThemeData (`app_theme.dart`):**
- `ColorScheme.dark` com `primary = roxo` (para `FilledButton` sair roxo como no RN); dourado aplicado explicitamente em labels/links/ícones.
- `inputDecorationTheme`: campo escuro, label dourado, borda arredondada, erro em vermelho (danger) com ícone de aviso.
- Raios: card 16, botão 12.
- `textTheme` baseado em Montserrat.

**Widgets** espelham os componentes RN lidos (raio, borda, sombra, label com ícone, erro com ícone de aviso): `AppButton` (primary/outline/success/link + estado loading), `AppCard` (variantes por cor), `AppTextField` (label + ícone + erro), `AppScaffold`, `StatusBadge`, `StepIndicator`.

## Navegação híbrida

```
main -> carrega sessão (AuthStore)
 ├─ não logado ─────────────────────► Tela de Auth (entrar / criar conta)
 └─ logado ─► GET /empresas
        ├─ sem empresa OU 1ª empresa sem certificado válido ─► WIZARD
        └─ empresa configurada ──────────────────────────────► Lista de empresas ─► Painel
```

**Wizard (primeiro acesso) — 3 passos** (a criação de conta acontece na tela de Auth, antes do wizard):
1. **Buscar CNPJ** → `GET /cnpj/{cnpj}` → exibe razão social/endereço encontrados → complementa IE, regime (CRT) e ambiente → `POST /empresas`.
2. **Certificado A1** → seleciona `.pfx` + senha → `POST /empresas/{id}/certificado` → valida resposta.
3. **Pronto** ✅ → CTA "Emitir primeira NF-e" → navega ao painel/emissão.

A ação "Adicionar empresa" na lista reaproveita os passos 1–2 do wizard.

## Telas (todas repaginadas)

- **Auth:** card central, logo, campos, botão roxo; alterna entre entrar e criar conta.
- **Lista de empresas:** cards com `StatusBadge` de certificado; FAB "Adicionar CNPJ".
- **Painel da empresa:** cabeçalho com dados + status SEFAZ; ações: NF-e, Nova NF-e, Certificado.
- **NF-e (lista):** cards com status/valor + acesso à DANFE.
- **Nova NF-e:** mantém o escopo **simplificado atual** (destinatário + itens), agora suportando **múltiplos itens** → salva rascunho (`POST .../nfe`) → botão **Emitir** (`POST .../nfe/{id}/emitir`).
- **Certificado** e **Status SEFAZ:** repaginadas.

## Integração com a API

O cliente já existe e bate com as rotas do Laravel/Sanctum (`routes/api.php`). Ajustes:
- Startup valida o token com `GET /auth/me`; se falhar, limpa a sessão e volta para Auth.
- `buscarCnpj` alimenta o passo 1 do wizard.
- Tratamento centralizado de **401** → limpa sessão e redireciona para Auth.
- Base URL via `config.dart` (`--dart-define=API_BASE_URL`): padrão `http://localhost:8080/api`; **emulador Android** usa `http://10.0.2.2:8080/api`. Backend sobe via `docker-compose` no WSL.

Endpoints usados: `auth/register`, `auth/login`, `auth/logout`, `auth/me`, `cnpj/{cnpj}`, `empresas` (index/store), `empresas/{id}/certificado` (store), `empresas/{id}/sefaz/status`, `empresas/{id}/nfe` (index/store), `empresas/{id}/nfe/{id}/emitir`, `empresas/{id}/nfe/{id}/danfe`.

## Erros & estados

- `ApiException` → snackbar/erro inline em vermelho (danger).
- Loading no `AppButton` (spinner) e nas listas.
- Estados vazios estilizados ("Nenhuma empresa…", "Nenhuma NF-e…").

## Testes & verificação

- Testes de widget: `AppButton` (renderiza label; mostra spinner quando loading), `AppTextField` (exibe mensagem de erro), smoke test do `AppTheme`.
- Implementação seguirá **TDD** (teste antes do código de cada widget/comportamento).
- Verificação final: `flutter analyze` e `flutter test` sem erros, e **execução do app** (web/Chrome) contra o backend no WSL para validar o fluxo ponta a ponta (auth → CNPJ → certificado → emitir).

## Fora de escopo (YAGNI)

Formulário fiscal completo de NF-e; tema claro; cancelamento, carta de correção (CC-e), inutilização e distribuição (rotas existem no backend, mas ficam para depois).
