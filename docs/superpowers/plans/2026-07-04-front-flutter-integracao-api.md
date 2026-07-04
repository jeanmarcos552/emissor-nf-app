# Front Flutter Repaginado + Integração com a API — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aplicar o design system dourado/roxo (tema escuro + Montserrat) do `app-sejab2-admin` ao app Flutter `emissor-nf-app` e amarrar o fluxo ponta a ponta com a API Laravel/Sanctum: criar conta/login → buscar CNPJ → cadastrar empresa → enviar certificado → emitir NF-e.

**Architecture:** Um `ThemeData` escuro central estiliza a maioria das telas "de graça"; um conjunto enxuto de widgets reutilizáveis (`AppScaffold`, `AppButton`, `AppTextField`, `AppCard`, `StatusBadge`, `StepIndicator`) cobre o que o tema não alcança. A navegação é híbrida: um `RootGate` decide entre tela de auth, wizard de onboarding (primeiro acesso) e lista+painel (empresa já configurada). O cliente HTTP (`NfeApi`) já existe e bate com as rotas; recebe apenas `validarSessao()` e tratamento de 401.

**Tech Stack:** Flutter (Dart, SDK ≥3.4), Material 3, `http`, `shared_preferences`, `file_picker`, `intl`. Testes com `flutter_test` + `package:http/testing.dart` (`MockClient`).

## Global Constraints

- Nome do pacote (para imports): `emissor_nfe` → `package:emissor_nfe/...`.
- Não migrar de framework: **tudo em Flutter/Dart**. Componentes React Native são só referência visual.
- Tema **escuro apenas**. Fundo `#161616`, texto `#d6d6d6`.
- Tokens de cor exatos: primária `#cf9f4d`, secundária `#5431bc`, success `rgb(77,207,166)`=`#4dcfa6`, danger `#da5050`, warning `#f59e0b`, info `#1356b4`, gray `#a1a1a1`.
- Fonte **Montserrat** (Medium + SemiBold), empacotada em `assets/fonts/`.
- Escopo de emissão: destinatário + **múltiplos itens** (formulário simplificado). Sem campos fiscais completos, cancelamento, CC-e, inutilização ou distribuição.
- Cada task termina com `flutter analyze` sem erros novos e testes passando.
- Base URL da API via `--dart-define=API_BASE_URL`; padrão `http://localhost:8080/api`; emulador Android usa `http://10.0.2.2:8080/api`.

---

## Estrutura de arquivos

**Criar:**
- `lib/src/theme/app_colors.dart` — tokens de cor.
- `lib/src/theme/app_theme.dart` — `ThemeData` escuro + Montserrat.
- `lib/src/widgets/app_scaffold.dart` — scaffold padrão (fundo + AppBar).
- `lib/src/widgets/app_button.dart` — botão com variantes + loading.
- `lib/src/widgets/app_text_field.dart` — campo com label/ícone/erro.
- `lib/src/widgets/app_card.dart` — card roxo translúcido.
- `lib/src/widgets/status_badge.dart` — pill de status.
- `lib/src/widgets/step_indicator.dart` — barra de passos do wizard.
- `lib/src/onboarding/onboarding_flow.dart` — wizard de primeiro acesso.
- `lib/src/widgets/empresa_form.dart` — formulário CNPJ→empresa reutilizado (wizard + diálogo).
- `assets/fonts/Montserrat-Medium.ttf`, `assets/fonts/Montserrat-SemiBold.ttf`.
- Testes correspondentes em `test/`.

**Modificar:**
- `pubspec.yaml` — declarar fontes.
- `lib/src/api/nfe_api.dart` — adicionar `validarSessao()`.
- `lib/main.dart` — aplicar tema + `RootGate`.
- `lib/src/screens/*.dart` — restilizar todas as telas.

---

### Task 1: Tokens de cor (`AppColors`)

**Files:**
- Create: `lib/src/theme/app_colors.dart`
- Test: `test/theme/app_colors_test.dart`

**Interfaces:**
- Produces: `AppColors` com constantes `primary, secondary, success, danger, warning, info, gray, scaffoldBg, text, cardBg, cardBorder` (todas `static const Color`).

- [ ] **Step 1: Escrever o teste que falha**

```dart
// test/theme/app_colors_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emissor_nfe/src/theme/app_colors.dart';

void main() {
  test('tokens de cor batem com o design system', () {
    expect(AppColors.primary, const Color(0xFFCF9F4D));
    expect(AppColors.secondary, const Color(0xFF5431BC));
    expect(AppColors.success, const Color(0xFF4DCFA6));
    expect(AppColors.danger, const Color(0xFFDA5050));
    expect(AppColors.scaffoldBg, const Color(0xFF161616));
    expect(AppColors.text, const Color(0xFFD6D6D6));
    expect(AppColors.cardBg, const Color(0x485431BC));
    expect(AppColors.cardBorder, const Color(0x755431BC));
  });
}
```

- [ ] **Step 2: Rodar o teste e confirmar que falha**

Run: `flutter test test/theme/app_colors_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:emissor_nfe/src/theme/app_colors.dart'`.

- [ ] **Step 3: Implementar**

```dart
// lib/src/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Tokens de cor traduzidos do `theme/index.ts` do app-sejab2-admin.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFCF9F4D); // dourado
  static const Color secondary = Color(0xFF5431BC); // roxo
  static const Color success = Color(0xFF4DCFA6);
  static const Color danger = Color(0xFFDA5050);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF1356B4);
  static const Color gray = Color(0xFFA1A1A1);

  static const Color scaffoldBg = Color(0xFF161616);
  static const Color text = Color(0xFFD6D6D6);

  static const Color cardBg = Color(0x485431BC); // roxo translúcido (alpha 0x48)
  static const Color cardBorder = Color(0x755431BC); // borda do card (alpha 0x75)
}
```

- [ ] **Step 4: Rodar o teste e confirmar que passa**

Run: `flutter test test/theme/app_colors_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/src/theme/app_colors.dart test/theme/app_colors_test.dart
git commit -m "feat(theme): tokens de cor do design system"
```

---

### Task 2: Fontes Montserrat + tema (`AppTheme`)

**Files:**
- Create: `lib/src/theme/app_theme.dart`
- Create (copiar binários): `assets/fonts/Montserrat-Medium.ttf`, `assets/fonts/Montserrat-SemiBold.ttf`
- Modify: `pubspec.yaml`
- Test: `test/theme/app_theme_test.dart`

**Interfaces:**
- Consumes: `AppColors` (Task 1).
- Produces: `AppTheme.dark() → ThemeData`, `AppTheme.fontFamily → 'Montserrat'` (`static const String`).

- [ ] **Step 1: Copiar as fontes**

```bash
mkdir -p assets/fonts
cp "/c/Users/jeans/Documents/app-sejab2-admin/assets/fonts/Montserrat-Medium.ttf" assets/fonts/
cp "/c/Users/jeans/Documents/app-sejab2-admin/assets/fonts/Montserrat-SemiBold.ttf" assets/fonts/
ls assets/fonts
```
Expected: lista os dois `.ttf`.

- [ ] **Step 2: Declarar as fontes no `pubspec.yaml`**

Substituir o bloco `flutter:` no fim de `pubspec.yaml` por:

```yaml
flutter:
  uses-material-design: true
  fonts:
    - family: Montserrat
      fonts:
        - asset: assets/fonts/Montserrat-Medium.ttf
        - asset: assets/fonts/Montserrat-SemiBold.ttf
          weight: 600
```

Run: `flutter pub get`
Expected: `Got dependencies!`.

- [ ] **Step 3: Escrever o teste que falha**

```dart
// test/theme/app_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emissor_nfe/src/theme/app_colors.dart';
import 'package:emissor_nfe/src/theme/app_theme.dart';

void main() {
  test('AppTheme.dark configura o tema escuro do design', () {
    final t = AppTheme.dark();
    expect(t.brightness, Brightness.dark);
    expect(t.scaffoldBackgroundColor, AppColors.scaffoldBg);
    expect(t.colorScheme.primary, AppColors.secondary); // botões roxos
    expect(t.textTheme.bodyMedium?.fontFamily, 'Montserrat');
  });
}
```

- [ ] **Step 4: Rodar o teste e confirmar que falha**

Run: `flutter test test/theme/app_theme_test.dart`
Expected: FAIL — URI de `app_theme.dart` não existe.

- [ ] **Step 5: Implementar**

```dart
// lib/src/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tema escuro do Emissor NF-e, baseado no design dourado/roxo.
class AppTheme {
  AppTheme._();

  static const String fontFamily = 'Montserrat';

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: AppColors.secondary, // botões roxos (como no RN)
      onPrimary: Colors.white,
      secondary: AppColors.primary, // dourado para acentos
      onSecondary: Colors.black,
      surface: AppColors.scaffoldBg,
      onSurface: AppColors.text,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.scaffoldBg,
      colorScheme: scheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        labelStyle: const TextStyle(color: AppColors.primary),
        floatingLabelStyle: const TextStyle(color: AppColors.primary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        errorStyle: const TextStyle(color: AppColors.danger),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
              fontFamily: fontFamily, fontWeight: FontWeight.w700),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      snackBarTheme:
          const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
```

- [ ] **Step 6: Rodar o teste e confirmar que passa**

Run: `flutter test test/theme/app_theme_test.dart`
Expected: PASS.
Se o `flutter analyze` acusar rename de algum `*Theme`→`*ThemeData` (ex.: `SnackBarThemeData`) por causa da versão do SDK, aplique o rename sugerido e rode de novo.

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml assets/fonts lib/src/theme/app_theme.dart test/theme/app_theme_test.dart
git commit -m "feat(theme): ThemeData escuro + fontes Montserrat"
```

---

### Task 3: `AppScaffold`

**Files:**
- Create: `lib/src/widgets/app_scaffold.dart`
- Test: `test/widgets/app_scaffold_test.dart`

**Interfaces:**
- Consumes: `AppColors`.
- Produces: `AppScaffold({required Widget body, String? title, List<Widget>? actions, Widget? floatingActionButton, Widget? bottomNavigationBar, Widget? leading, PreferredSizeWidget? appBarBottom})`.

- [ ] **Step 1: Escrever o teste que falha**

```dart
// test/widgets/app_scaffold_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emissor_nfe/src/theme/app_theme.dart';
import 'package:emissor_nfe/src/widgets/app_scaffold.dart';

void main() {
  testWidgets('AppScaffold mostra título e corpo', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: const AppScaffold(title: 'Empresas', body: Text('conteúdo')),
    ));
    expect(find.text('Empresas'), findsOneWidget);
    expect(find.text('conteúdo'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Rodar e confirmar falha**

Run: `flutter test test/widgets/app_scaffold_test.dart`
Expected: FAIL — URI não existe.

- [ ] **Step 3: Implementar**

```dart
// lib/src/widgets/app_scaffold.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Scaffold padrão: fundo escuro + AppBar transparente.
class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? leading;
  final PreferredSizeWidget? appBarBottom;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.leading,
    this.appBarBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              leading: leading,
              actions: actions,
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.text,
              elevation: 0,
              bottom: appBarBottom,
            ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
```

- [ ] **Step 4: Rodar e confirmar que passa**

Run: `flutter test test/widgets/app_scaffold_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/src/widgets/app_scaffold.dart test/widgets/app_scaffold_test.dart
git commit -m "feat(widgets): AppScaffold"
```

---

### Task 4: `AppButton`

**Files:**
- Create: `lib/src/widgets/app_button.dart`
- Test: `test/widgets/app_button_test.dart`

**Interfaces:**
- Consumes: `AppColors`.
- Produces: `enum AppButtonVariant { primary, outline, success, link }` e `AppButton({required String label, required VoidCallback? onPressed, AppButtonVariant variant = AppButtonVariant.primary, IconData? icon, bool loading = false, bool expand = true})`.

- [ ] **Step 1: Escrever os testes que falham**

```dart
// test/widgets/app_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emissor_nfe/src/theme/app_theme.dart';
import 'package:emissor_nfe/src/widgets/app_button.dart';

void main() {
  testWidgets('AppButton mostra o label', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(body: AppButton(label: 'Entrar', onPressed: () {})),
    ));
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('AppButton em loading mostra spinner e não dispara onPressed',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: AppButton(
            label: 'Entrar', loading: true, onPressed: () => tapped = true),
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(tapped, isFalse);
  });
}
```

- [ ] **Step 2: Rodar e confirmar falha**

Run: `flutter test test/widgets/app_button_test.dart`
Expected: FAIL — URI não existe.

- [ ] **Step 3: Implementar**

```dart
// lib/src/widgets/app_button.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, outline, success, link }

/// Botão do design system, com variantes e estado de carregamento.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final onTap = loading ? null : onPressed;
    late final Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = FilledButton(onPressed: onTap, child: child);
      case AppButtonVariant.success:
        button = FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white),
          child: child,
        );
      case AppButtonVariant.outline:
        button = OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.text,
            side: const BorderSide(color: AppColors.secondary),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
          child: child,
        );
      case AppButtonVariant.link:
        button = TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          child: child,
        );
    }
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
```

- [ ] **Step 4: Rodar e confirmar que passa**

Run: `flutter test test/widgets/app_button_test.dart`
Expected: PASS (2 testes).

- [ ] **Step 5: Commit**

```bash
git add lib/src/widgets/app_button.dart test/widgets/app_button_test.dart
git commit -m "feat(widgets): AppButton com variantes e loading"
```

---

### Task 5: `AppTextField`

**Files:**
- Create: `lib/src/widgets/app_text_field.dart`
- Test: `test/widgets/app_text_field_test.dart`

**Interfaces:**
- Consumes: `AppColors`.
- Produces: `AppTextField({TextEditingController? controller, required String label, IconData? icon, String? errorText, bool obscureText = false, TextInputType? keyboardType, String? Function(String?)? validator, Widget? suffix})`.

- [ ] **Step 1: Escrever o teste que falha**

```dart
// test/widgets/app_text_field_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emissor_nfe/src/theme/app_theme.dart';
import 'package:emissor_nfe/src/widgets/app_text_field.dart';

void main() {
  testWidgets('AppTextField exibe label e mensagem de erro', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: const Scaffold(
        body: AppTextField(label: 'E-mail', errorText: 'E-mail inválido'),
      ),
    ));
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('E-mail inválido'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Rodar e confirmar falha**

Run: `flutter test test/widgets/app_text_field_test.dart`
Expected: FAIL — URI não existe.

- [ ] **Step 3: Implementar**

```dart
// lib/src/widgets/app_text_field.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Campo de texto do design system (label dourado, ícone, estado de erro).
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final IconData? icon;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.icon,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: AppColors.text),
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          prefixIcon: icon == null
              ? null
              : Icon(icon, size: 18, color: AppColors.primary),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Rodar e confirmar que passa**

Run: `flutter test test/widgets/app_text_field_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/src/widgets/app_text_field.dart test/widgets/app_text_field_test.dart
git commit -m "feat(widgets): AppTextField"
```

---

### Task 6: `AppCard`

**Files:**
- Create: `lib/src/widgets/app_card.dart`
- Test: `test/widgets/app_card_test.dart`

**Interfaces:**
- Consumes: `AppColors`.
- Produces: `AppCard({required Widget child, Color? background, Color? border, EdgeInsetsGeometry padding = const EdgeInsets.all(16), VoidCallback? onTap})`.

- [ ] **Step 1: Escrever o teste que falha**

```dart
// test/widgets/app_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emissor_nfe/src/theme/app_theme.dart';
import 'package:emissor_nfe/src/widgets/app_card.dart';

void main() {
  testWidgets('AppCard renderiza o filho', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: const Scaffold(body: AppCard(child: Text('conteúdo'))),
    ));
    expect(find.text('conteúdo'), findsOneWidget);
  });

  testWidgets('AppCard com onTap é clicável', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: AppCard(onTap: () => tapped = true, child: const Text('x')),
      ),
    ));
    await tester.tap(find.text('x'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Rodar e confirmar falha**

Run: `flutter test test/widgets/app_card_test.dart`
Expected: FAIL — URI não existe.

- [ ] **Step 3: Implementar**

```dart
// lib/src/widgets/app_card.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Card do design system: fundo roxo translúcido, raio 16, borda 1.5.
class AppCard extends StatelessWidget {
  final Widget child;
  final Color? background;
  final Color? border;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.background,
    this.border,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border ?? AppColors.cardBorder, width: 1.5),
      ),
      child: child,
    );
    if (onTap == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: content,
    );
  }
}
```

- [ ] **Step 4: Rodar e confirmar que passa**

Run: `flutter test test/widgets/app_card_test.dart`
Expected: PASS (2 testes).

- [ ] **Step 5: Commit**

```bash
git add lib/src/widgets/app_card.dart test/widgets/app_card_test.dart
git commit -m "feat(widgets): AppCard"
```

---

### Task 7: `StatusBadge`

**Files:**
- Create: `lib/src/widgets/status_badge.dart`
- Test: `test/widgets/status_badge_test.dart`

**Interfaces:**
- Consumes: `AppColors`.
- Produces: `StatusBadge({required String label, required Color color, IconData? icon})`, `StatusBadge.nfe(String status)`, `StatusBadge.certificado(bool ok)`.

- [ ] **Step 1: Escrever os testes que falham**

```dart
// test/widgets/status_badge_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emissor_nfe/src/widgets/status_badge.dart';

void main() {
  testWidgets('StatusBadge.nfe(autorizada) mostra "Autorizada"',
      (tester) async {
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StatusBadge.nfe('autorizada'))));
    expect(find.text('Autorizada'), findsOneWidget);
  });

  testWidgets('StatusBadge.certificado(false) mostra "Sem certificado"',
      (tester) async {
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StatusBadge.certificado(false))));
    expect(find.text('Sem certificado'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Rodar e confirmar falha**

Run: `flutter test test/widgets/status_badge_test.dart`
Expected: FAIL — URI não existe.

- [ ] **Step 3: Implementar**

```dart
// lib/src/widgets/status_badge.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Pill de status para NF-e e certificado.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  factory StatusBadge.nfe(String status) {
    switch (status) {
      case 'autorizada':
        return const StatusBadge(
            label: 'Autorizada',
            color: AppColors.success,
            icon: Icons.check_circle);
      case 'cancelada':
        return const StatusBadge(
            label: 'Cancelada', color: AppColors.gray, icon: Icons.block);
      case 'rejeitada':
      case 'denegada':
      case 'erro':
        return StatusBadge(
            label: status[0].toUpperCase() + status.substring(1),
            color: AppColors.danger,
            icon: Icons.error);
      case 'rascunho':
        return const StatusBadge(
            label: 'Rascunho', color: AppColors.info, icon: Icons.edit_note);
      default:
        return StatusBadge(label: status, color: AppColors.gray);
    }
  }

  factory StatusBadge.certificado(bool ok) => ok
      ? const StatusBadge(
          label: 'Certificado OK',
          color: AppColors.success,
          icon: Icons.verified_user)
      : const StatusBadge(
          label: 'Sem certificado',
          color: AppColors.warning,
          icon: Icons.gpp_maybe);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Rodar e confirmar que passa**

Run: `flutter test test/widgets/status_badge_test.dart`
Expected: PASS (2 testes).

- [ ] **Step 5: Commit**

```bash
git add lib/src/widgets/status_badge.dart test/widgets/status_badge_test.dart
git commit -m "feat(widgets): StatusBadge"
```

---

### Task 8: `StepIndicator`

**Files:**
- Create: `lib/src/widgets/step_indicator.dart`
- Test: `test/widgets/step_indicator_test.dart`

**Interfaces:**
- Consumes: `AppColors`.
- Produces: `StepIndicator({required int current, required int total})` (`current` é 1-based).

- [ ] **Step 1: Escrever o teste que falha**

```dart
// test/widgets/step_indicator_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emissor_nfe/src/widgets/step_indicator.dart';

void main() {
  testWidgets('StepIndicator renderiza uma barra por passo', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: StepIndicator(current: 2, total: 3)),
    ));
    // Uma barra (Expanded) por passo.
    expect(find.byType(Expanded), findsNWidgets(3));
  });
}
```

- [ ] **Step 2: Rodar e confirmar falha**

Run: `flutter test test/widgets/step_indicator_test.dart`
Expected: FAIL — URI não existe.

- [ ] **Step 3: Implementar**

```dart
// lib/src/widgets/step_indicator.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Barra de progresso do wizard: [current] de [total] (1-based).
class StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const StepIndicator({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final done = i < current;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: done
                  ? AppColors.primary
                  : AppColors.gray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
```

- [ ] **Step 4: Rodar e confirmar que passa**

Run: `flutter test test/widgets/step_indicator_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/src/widgets/step_indicator.dart test/widgets/step_indicator_test.dart
git commit -m "feat(widgets): StepIndicator"
```

---

### Task 9: `NfeApi.validarSessao()` + tratamento de 401

**Files:**
- Modify: `lib/src/api/nfe_api.dart` (adicionar método após `logout()`, ~linha 67)
- Test: `test/api/nfe_api_test.dart`

**Interfaces:**
- Consumes: `AuthStore` (campos públicos `token`, `isLoggedIn`), `NfeApi({required AuthStore auth, http.Client? client, String? baseUrl})`.
- Produces: `Future<bool> NfeApi.validarSessao()` — `true` se `GET /auth/me` responde 2xx; `false` se não logado, 401 ou erro de rede.

- [ ] **Step 1: Escrever os testes que falham**

```dart
// test/api/nfe_api_test.dart
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
```

- [ ] **Step 2: Rodar e confirmar falha**

Run: `flutter test test/api/nfe_api_test.dart`
Expected: FAIL — `The method 'validarSessao' isn't defined`.

- [ ] **Step 3: Implementar**

Em `lib/src/api/nfe_api.dart`, logo após o método `logout()` (antes do comentário `// ----- Empresas -----`), inserir:

```dart
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
```

- [ ] **Step 4: Rodar e confirmar que passa**

Run: `flutter test test/api/nfe_api_test.dart`
Expected: PASS (3 testes).

- [ ] **Step 5: Commit**

```bash
git add lib/src/api/nfe_api.dart test/api/nfe_api_test.dart
git commit -m "feat(api): validarSessao via GET /auth/me"
```

---

### Task 10: `main.dart` — tema + `RootGate` (navegação híbrida)

**Files:**
- Modify: `lib/main.dart` (reescrever)
- Test: `test/root_gate_test.dart`

**Interfaces:**
- Consumes: `AppTheme.dark()`, `NfeApi` (`validarSessao`, `listarEmpresas`), `AuthStore` (`isLoggedIn`, `clear`), `LoginScreen({required NfeApi api, required VoidCallback onAuthenticated})` (Task 11), `OnboardingFlow({required NfeApi api, required VoidCallback onDone, required VoidCallback onLogout})` (Task 12), `EmpresasScreen({required NfeApi api, required VoidCallback onLogout})` (Task 13), `Empresa` (`certificadoOk`).
- Produces: `EmissorApp({required NfeApi api})`, `RootGate({required NfeApi api})` que decide o destino inicial.

> **Nota de ordem:** este task compila referenciando `LoginScreen`, `OnboardingFlow` e `EmpresasScreen`. Como `LoginScreen` e `EmpresasScreen` já existem (serão restilizados nas Tasks 11 e 13) e `OnboardingFlow` é criado na Task 12, ao executar em sequência crie um stub mínimo de `OnboardingFlow` se preciso — mas o caminho recomendado é executar a Task 12 imediatamente após a 10. O teste desta task cobre só o `RootGate` com `MockClient`, sem depender do visual das telas.

- [ ] **Step 1: Escrever o teste que falha**

```dart
// test/root_gate_test.dart
import 'package:flutter/material.dart';
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
```

- [ ] **Step 2: Rodar e confirmar falha**

Run: `flutter test test/root_gate_test.dart`
Expected: FAIL — `RootGate`/imports ausentes (e o segundo teste depende da Task 12).

- [ ] **Step 3: Implementar `main.dart`**

```dart
// lib/main.dart
import 'package:flutter/material.dart';

import 'src/api/nfe_api.dart';
import 'src/auth_store.dart';
import 'src/models/empresa.dart';
import 'src/onboarding/onboarding_flow.dart';
import 'src/screens/empresas_screen.dart';
import 'src/screens/login_screen.dart';
import 'src/theme/app_theme.dart';
import 'src/widgets/app_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthStore();
  await auth.load();
  runApp(EmissorApp(api: NfeApi(auth: auth)));
}

class EmissorApp extends StatelessWidget {
  final NfeApi api;
  const EmissorApp({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emissor NF-e',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: RootGate(api: api),
    );
  }
}

enum _Dest { loading, auth, onboarding, empresas }

/// Decide o destino inicial: login, onboarding (1º acesso) ou lista de empresas.
class RootGate extends StatefulWidget {
  final NfeApi api;
  const RootGate({super.key, required this.api});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  _Dest _dest = _Dest.loading;

  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    setState(() => _dest = _Dest.loading);
    if (!widget.api.auth.isLoggedIn) {
      setState(() => _dest = _Dest.auth);
      return;
    }
    final ok = await widget.api.validarSessao();
    if (!ok) {
      await widget.api.auth.clear();
      if (mounted) setState(() => _dest = _Dest.auth);
      return;
    }
    try {
      final empresas = await widget.api.listarEmpresas();
      final precisaOnboarding =
          empresas.isEmpty || !empresas.first.certificadoOk;
      if (mounted) {
        setState(() =>
            _dest = precisaOnboarding ? _Dest.onboarding : _Dest.empresas);
      }
    } catch (_) {
      if (mounted) setState(() => _dest = _Dest.empresas);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_dest) {
      case _Dest.loading:
        return const AppScaffold(
            body: Center(child: CircularProgressIndicator()));
      case _Dest.auth:
        return LoginScreen(api: widget.api, onAuthenticated: _decide);
      case _Dest.onboarding:
        return OnboardingFlow(
            api: widget.api,
            onDone: _decide,
            onLogout: () => setState(() => _dest = _Dest.auth));
      case _Dest.empresas:
        return EmpresasScreen(
            api: widget.api,
            onLogout: () => setState(() => _dest = _Dest.auth));
    }
  }
}
```

- [ ] **Step 4: Rodar (aceitando dependência da Task 12)**

Run: `flutter test test/root_gate_test.dart`
Expected: o 1º teste PASSA após a Task 11 estar restilizada; o 2º PASSA após a Task 12. Se estiver executando estritamente em ordem, rode este arquivo de teste novamente ao concluir a Task 12.

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart test/root_gate_test.dart
git commit -m "feat: RootGate com navegacao hibrida + tema aplicado"
```

---

### Task 11: Tela de Auth (`LoginScreen`) restilizada

**Files:**
- Modify: `lib/src/screens/login_screen.dart` (reescrever `build` e helpers usando os widgets do design)

**Interfaces:**
- Consumes: `AppScaffold`, `AppCard`, `AppButton`, `AppTextField`, `AppColors`, `NfeApi` (`login`, `register`).
- Produces: `LoginScreen({required NfeApi api, required VoidCallback onAuthenticated})` (assinatura inalterada).

- [ ] **Step 1: Reescrever a tela**

```dart
// lib/src/screens/login_screen.dart
import 'package:flutter/material.dart';

import '../api/nfe_api.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  final NfeApi api;
  final VoidCallback onAuthenticated;
  const LoginScreen(
      {super.key, required this.api, required this.onAuthenticated});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isRegister = false;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_isRegister) {
        await widget.api.register(_name.text, _email.text, _password.text);
      } else {
        await widget.api.login(_email.text, _password.text);
      }
      widget.onAuthenticated();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AppCard(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.receipt_long,
                        size: 56, color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text('Emissor NF-e',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.text)),
                    const SizedBox(height: 4),
                    Text(_isRegister ? 'Crie sua conta' : 'Entre na sua conta',
                        style: const TextStyle(color: AppColors.gray)),
                    const SizedBox(height: 20),
                    if (_isRegister)
                      AppTextField(
                        controller: _name,
                        label: 'Nome',
                        icon: Icons.person_outline,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Informe seu nome'
                            : null,
                      ),
                    AppTextField(
                      controller: _email,
                      label: 'E-mail',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'E-mail inválido'
                          : null,
                    ),
                    AppTextField(
                      controller: _password,
                      label: 'Senha',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (v) => (v == null || v.length < 8)
                          ? 'Mínimo 8 caracteres'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: _isRegister ? 'Criar conta' : 'Entrar',
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 4),
                    AppButton(
                      label: _isRegister
                          ? 'Já tenho conta'
                          : 'Criar uma conta',
                      variant: AppButtonVariant.link,
                      onPressed: () =>
                          setState(() => _isRegister = !_isRegister),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Rodar analyze + o teste do RootGate**

Run: `flutter analyze lib/src/screens/login_screen.dart && flutter test test/root_gate_test.dart -N "sem sessão, RootGate mostra a tela de login"`
Expected: analyze sem erros; o teste "sem sessão…" PASSA (a tela mostra o botão "Entrar").

- [ ] **Step 3: Commit**

```bash
git add lib/src/screens/login_screen.dart
git commit -m "feat(ui): tela de auth repaginada"
```

---

### Task 12: Formulário CNPJ→empresa + Wizard de onboarding

**Files:**
- Create: `lib/src/widgets/empresa_form.dart` — formulário reutilizável (busca CNPJ + campos + cria empresa).
- Create: `lib/src/onboarding/onboarding_flow.dart` — wizard de 3 passos.
- Test: `test/onboarding_flow_test.dart`

**Interfaces:**
- Consumes: `AppScaffold`, `AppCard`, `AppButton`, `AppTextField`, `StepIndicator`, `AppColors`, `NfeApi` (`buscarCnpj`, `criarEmpresa`, `uploadCertificado`, `logout`), `Empresa`, `CnpjInfo`.
- Produces:
  - `EmpresaForm({required NfeApi api, required void Function(Empresa) onCreated})` — widget que busca CNPJ, coleta IE/CRT/ambiente e chama `criarEmpresa`, retornando a `Empresa` criada via `onCreated`.
  - `OnboardingFlow({required NfeApi api, required VoidCallback onDone, required VoidCallback onLogout})`.

- [ ] **Step 1: Escrever o teste que falha (wizard mostra passo 1)**

```dart
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
```

- [ ] **Step 2: Rodar e confirmar falha**

Run: `flutter test test/onboarding_flow_test.dart`
Expected: FAIL — URI de `onboarding_flow.dart` não existe.

- [ ] **Step 3: Implementar `EmpresaForm`**

```dart
// lib/src/widgets/empresa_form.dart
import 'package:flutter/material.dart';

import '../api/nfe_api.dart';
import '../models/empresa.dart';
import '../theme/app_colors.dart';
import 'app_button.dart';
import 'app_card.dart';
import 'app_text_field.dart';

/// Busca um CNPJ, coleta IE/regime/ambiente e cria a empresa na conta.
/// Reutilizado no wizard e no diálogo "Adicionar empresa".
class EmpresaForm extends StatefulWidget {
  final NfeApi api;
  final void Function(Empresa) onCreated;
  const EmpresaForm({super.key, required this.api, required this.onCreated});

  @override
  State<EmpresaForm> createState() => _EmpresaFormState();
}

class _EmpresaFormState extends State<EmpresaForm> {
  final _cnpj = TextEditingController();
  final _ie = TextEditingController();
  int _crt = 1;
  int _ambiente = 2;
  bool _buscando = false;
  bool _salvando = false;
  CnpjInfo? _info;
  String? _erro;

  String get _cnpjLimpo => _cnpj.text.replaceAll(RegExp(r'\D'), '');

  @override
  void dispose() {
    _cnpj.dispose();
    _ie.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    if (_cnpjLimpo.length != 14) {
      setState(() => _erro = 'CNPJ deve ter 14 dígitos');
      return;
    }
    setState(() {
      _buscando = true;
      _erro = null;
    });
    try {
      final info = await widget.api.buscarCnpj(_cnpjLimpo);
      setState(() => _info = info);
    } catch (e) {
      setState(() {
        _info = null;
        _erro = '$e';
      });
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  Future<void> _salvar() async {
    setState(() => _salvando = true);
    try {
      final empresa = await widget.api.criarEmpresa({
        'cnpj': _cnpjLimpo,
        'ie': _ie.text,
        'crt': _crt,
        'ambiente': _ambiente,
      });
      widget.onCreated(empresa);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _cnpj,
          label: 'CNPJ',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          errorText: _erro,
          suffix: IconButton(
            icon: _buscando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.search, color: AppColors.primary),
            onPressed: _buscando ? null : _buscar,
          ),
        ),
        if (_info != null) ...[
          const SizedBox(height: 8),
          AppCard(
            background: AppColors.success.withValues(alpha: 0.12),
            border: AppColors.success.withValues(alpha: 0.4),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_info!.razaoSocial ?? '-'}\n'
                    '${_info!.municipio ?? ''}/${_info!.uf ?? ''}',
                    style: const TextStyle(color: AppColors.text),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AppTextField(
              controller: _ie,
              label: 'Inscrição Estadual',
              icon: Icons.numbers),
          const SizedBox(height: 4),
          _RegimeDropdown(
              value: _crt, onChanged: (v) => setState(() => _crt = v)),
          const SizedBox(height: 8),
          _AmbienteDropdown(
              value: _ambiente,
              onChanged: (v) => setState(() => _ambiente = v)),
          const SizedBox(height: 16),
          AppButton(
            label: 'Cadastrar empresa',
            icon: Icons.check,
            loading: _salvando,
            onPressed: _salvar,
          ),
        ],
      ],
    );
  }
}

class _RegimeDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _RegimeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Regime (CRT)'),
      dropdownColor: AppColors.scaffoldBg,
      items: const [
        DropdownMenuItem(value: 1, child: Text('Simples Nacional')),
        DropdownMenuItem(value: 3, child: Text('Regime Normal')),
      ],
      onChanged: (v) => onChanged(v ?? 1),
    );
  }
}

class _AmbienteDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _AmbienteDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Ambiente'),
      dropdownColor: AppColors.scaffoldBg,
      items: const [
        DropdownMenuItem(value: 2, child: Text('Homologação (teste)')),
        DropdownMenuItem(value: 1, child: Text('Produção')),
      ],
      onChanged: (v) => onChanged(v ?? 2),
    );
  }
}
```

- [ ] **Step 4: Implementar `OnboardingFlow`**

```dart
// lib/src/onboarding/onboarding_flow.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../api/nfe_api.dart';
import '../models/empresa.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text_field.dart';
import '../widgets/empresa_form.dart';
import '../widgets/step_indicator.dart';

/// Wizard de primeiro acesso: CNPJ→empresa → certificado → pronto.
class OnboardingFlow extends StatefulWidget {
  final NfeApi api;
  final VoidCallback onDone;
  final VoidCallback onLogout;
  const OnboardingFlow(
      {super.key,
      required this.api,
      required this.onDone,
      required this.onLogout});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _step = 1; // 1=CNPJ, 2=certificado, 3=pronto
  Empresa? _empresa;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Primeiros passos',
      actions: [
        TextButton(
          onPressed: () async {
            await widget.api.logout();
            widget.onLogout();
          },
          child: const Text('Sair', style: TextStyle(color: AppColors.gray)),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StepIndicator(current: _step, total: 3),
              const SizedBox(height: 20),
              _buildStep(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 1:
        return AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Buscar CNPJ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.text, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Informe o CNPJ da empresa que vai emitir as notas.',
                  style: TextStyle(color: AppColors.gray)),
              const SizedBox(height: 16),
              EmpresaForm(
                api: widget.api,
                onCreated: (e) => setState(() {
                  _empresa = e;
                  _step = 2;
                }),
              ),
            ],
          ),
        );
      case 2:
        return _CertificadoStep(
          api: widget.api,
          empresa: _empresa!,
          onDone: () => setState(() => _step = 3),
        );
      default:
        return AppCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.verified, color: AppColors.success, size: 56),
              const SizedBox(height: 12),
              Text('Tudo pronto!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.text, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('${_empresa?.razaoSocial ?? ''} configurada e com certificado válido.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.gray)),
              const SizedBox(height: 20),
              AppButton(
                label: 'Ir para emissão de NF-e',
                icon: Icons.receipt_long,
                onPressed: widget.onDone,
              ),
            ],
          ),
        );
    }
  }
}

/// Passo 2 do wizard: upload do certificado A1.
class _CertificadoStep extends StatefulWidget {
  final NfeApi api;
  final Empresa empresa;
  final VoidCallback onDone;
  const _CertificadoStep(
      {required this.api, required this.empresa, required this.onDone});

  @override
  State<_CertificadoStep> createState() => _CertificadoStepState();
}

class _CertificadoStepState extends State<_CertificadoStep> {
  final _senha = TextEditingController();
  List<int>? _bytes;
  String? _fileName;
  bool _loading = false;

  @override
  void dispose() {
    _senha.dispose();
    super.dispose();
  }

  Future<void> _escolher() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pfx', 'p12'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _bytes = result.files.single.bytes;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _enviar() async {
    if (_bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione o arquivo .pfx')));
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.api.uploadCertificado(
          widget.empresa.id, _bytes!, _fileName ?? 'certificado.pfx', _senha.text);
      widget.onDone();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Certificado A1',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.text, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Envie o certificado digital (.pfx) de ${widget.empresa.razaoSocial}.',
              style: const TextStyle(color: AppColors.gray)),
          const SizedBox(height: 16),
          AppButton(
            label: _fileName ?? 'Selecionar arquivo .pfx',
            icon: Icons.attach_file,
            variant: AppButtonVariant.outline,
            onPressed: _escolher,
          ),
          const SizedBox(height: 8),
          AppTextField(
              controller: _senha,
              label: 'Senha do certificado',
              icon: Icons.lock_outline,
              obscureText: true),
          const SizedBox(height: 16),
          AppButton(
            label: 'Enviar certificado',
            icon: Icons.upload,
            loading: _loading,
            onPressed: _enviar,
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Rodar e confirmar que passa**

Run: `flutter test test/onboarding_flow_test.dart test/root_gate_test.dart`
Expected: PASS (wizard mostra "Buscar CNPJ"; e o 2º teste do RootGate agora passa).

- [ ] **Step 6: Commit**

```bash
git add lib/src/widgets/empresa_form.dart lib/src/onboarding/onboarding_flow.dart test/onboarding_flow_test.dart
git commit -m "feat(onboarding): wizard CNPJ -> certificado -> pronto + EmpresaForm reutilizavel"
```

---

### Task 13: Lista de empresas restilizada (+ diálogo reutilizando `EmpresaForm`)

**Files:**
- Modify: `lib/src/screens/empresas_screen.dart` (reescrever)

**Interfaces:**
- Consumes: `AppScaffold`, `AppCard`, `AppButton`, `StatusBadge`, `AppColors`, `EmpresaForm`, `NfeApi` (`listarEmpresas`, `logout`), `Empresa`, `CertificadoScreen` (Task 17), `EmpresaDashboard` (Task 14).
- Produces: `EmpresasScreen({required NfeApi api, required VoidCallback onLogout})` (assinatura inalterada).

- [ ] **Step 1: Reescrever a tela**

```dart
// lib/src/screens/empresas_screen.dart
import 'package:flutter/material.dart';

import '../api/nfe_api.dart';
import '../models/empresa.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/empresa_form.dart';
import '../widgets/status_badge.dart';
import 'certificado_screen.dart';
import 'empresa_dashboard.dart';

class EmpresasScreen extends StatefulWidget {
  final NfeApi api;
  final VoidCallback onLogout;
  const EmpresasScreen(
      {super.key, required this.api, required this.onLogout});

  @override
  State<EmpresasScreen> createState() => _EmpresasScreenState();
}

class _EmpresasScreenState extends State<EmpresasScreen> {
  late Future<List<Empresa>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => setState(() => _future = widget.api.listarEmpresas());

  Future<void> _adicionar() async {
    final criada = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.scaffoldBg,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Adicionar empresa',
                    style: TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                EmpresaForm(
                  api: widget.api,
                  onCreated: (_) => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (criada == true) _reload();
  }

  Future<void> _sair() async {
    await widget.api.logout();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Minhas empresas',
      actions: [
        IconButton(
            onPressed: _sair,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair'),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionar,
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_business),
        label: const Text('Adicionar CNPJ'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<Empresa>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(children: [
                Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Erro: ${snap.error}',
                        style: const TextStyle(color: AppColors.danger)))
              ]);
            }
            final empresas = snap.data ?? [];
            if (empresas.isEmpty) {
              return ListView(children: const [
                Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(
                      child: Text(
                          'Nenhuma empresa. Toque em "Adicionar CNPJ".',
                          style: TextStyle(color: AppColors.gray))),
                ),
              ]);
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: empresas.length,
              itemBuilder: (context, i) {
                final e = empresas[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            EmpresaDashboard(api: widget.api, empresa: e))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(e.nomeFantasia ?? e.razaoSocial,
                                  style: const TextStyle(
                                      color: AppColors.text,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                            const Icon(Icons.chevron_right,
                                color: AppColors.gray),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${e.cnpj} · ${e.uf ?? ''} · ${e.ambienteLabel}',
                            style: const TextStyle(
                                color: AppColors.gray, fontSize: 12)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            StatusBadge.certificado(e.certificadoOk),
                            const Spacer(),
                            if (!e.certificadoOk)
                              TextButton(
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) => CertificadoScreen(
                                              api: widget.api, empresa: e)));
                                  _reload();
                                },
                                child: const Text('Enviar certificado',
                                    style:
                                        TextStyle(color: AppColors.primary)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

Run: `flutter analyze lib/src/screens/empresas_screen.dart`
Expected: sem erros (pode haver avisos de dependência das Tasks 14/17, que existem como arquivos).

- [ ] **Step 3: Commit**

```bash
git add lib/src/screens/empresas_screen.dart
git commit -m "feat(ui): lista de empresas repaginada com AppCard + StatusBadge"
```

---

### Task 14: Painel da empresa restilizado

**Files:**
- Modify: `lib/src/screens/empresa_dashboard.dart` (reescrever)

**Interfaces:**
- Consumes: `AppScaffold`, `AppColors`, `NfeApi`, `Empresa`, `StatusScreen`, `NfeListScreen`, `NfeFormScreen`.
- Produces: `EmpresaDashboard({required NfeApi api, required Empresa empresa})` (assinatura inalterada).

- [ ] **Step 1: Reescrever a tela**

```dart
// lib/src/screens/empresa_dashboard.dart
import 'package:flutter/material.dart';

import '../api/nfe_api.dart';
import '../models/empresa.dart';
import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import 'nfe_form_screen.dart';
import 'nfe_list_screen.dart';
import 'status_screen.dart';

/// Painel de uma empresa: status da SEFAZ + notas.
class EmpresaDashboard extends StatefulWidget {
  final NfeApi api;
  final Empresa empresa;
  const EmpresaDashboard(
      {super.key, required this.api, required this.empresa});

  @override
  State<EmpresaDashboard> createState() => _EmpresaDashboardState();
}

class _EmpresaDashboardState extends State<EmpresaDashboard> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      StatusScreen(api: widget.api, empresaId: widget.empresa.id),
      NfeListScreen(api: widget.api, empresaId: widget.empresa.id),
    ];

    return AppScaffold(
      title: widget.empresa.nomeFantasia ?? widget.empresa.razaoSocial,
      appBarBottom: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
              '${widget.empresa.cnpj} · ${widget.empresa.ambienteLabel}',
              style: const TextStyle(fontSize: 12, color: AppColors.gray)),
        ),
      ),
      body: pages[_index],
      floatingActionButton: _index == 1
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              onPressed: () async {
                final criada = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                        builder: (_) => NfeFormScreen(
                            api: widget.api, empresaId: widget.empresa.id)));
                if (criada == true) setState(() {});
              },
              icon: const Icon(Icons.add),
              label: const Text('Nova NF-e'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.scaffoldBg,
        indicatorColor: AppColors.secondary.withValues(alpha: 0.4),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.cloud_outlined), label: 'SEFAZ'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined), label: 'Notas'),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

Run: `flutter analyze lib/src/screens/empresa_dashboard.dart`
Expected: sem erros.

- [ ] **Step 3: Commit**

```bash
git add lib/src/screens/empresa_dashboard.dart
git commit -m "feat(ui): painel da empresa repaginado"
```

---

### Task 15: Lista de NF-e restilizada

**Files:**
- Modify: `lib/src/screens/nfe_list_screen.dart` (reescrever)

**Interfaces:**
- Consumes: `AppCard`, `AppButton`, `StatusBadge`, `AppColors`, `NfeApi` (`listarNfe`, `emitir`, `danfeUrl`), `Nfe`.
- Produces: `NfeListScreen({required NfeApi api, required int empresaId})` (assinatura inalterada).

- [ ] **Step 1: Reescrever a tela**

```dart
// lib/src/screens/nfe_list_screen.dart
import 'package:flutter/material.dart';

import '../api/nfe_api.dart';
import '../models/nfe.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/status_badge.dart';

class NfeListScreen extends StatefulWidget {
  final NfeApi api;
  final int empresaId;
  const NfeListScreen(
      {super.key, required this.api, required this.empresaId});

  @override
  State<NfeListScreen> createState() => _NfeListScreenState();
}

class _NfeListScreenState extends State<NfeListScreen> {
  late Future<List<Nfe>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.listarNfe(widget.empresaId);
  }

  void _reload() =>
      setState(() => _future = widget.api.listarNfe(widget.empresaId));

  Future<void> _emitir(Nfe nfe) async {
    _snack('Emitindo NF-e ${nfe.numero}...');
    try {
      await widget.api.emitir(widget.empresaId, nfe.id);
      _snack('NF-e ${nfe.numero} autorizada!');
      _reload();
    } catch (e) {
      _snack('$e', erro: true);
    }
  }

  void _snack(String msg, {bool erro = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: erro ? AppColors.danger : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _reload(),
      child: FutureBuilder<List<Nfe>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ListView(children: [
              Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Erro ao carregar: ${snap.error}',
                      style: const TextStyle(color: AppColors.danger)))
            ]);
          }
          final notas = snap.data ?? [];
          if (notas.isEmpty) {
            return ListView(children: const [
              Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                    child: Text('Nenhuma NF-e ainda. Toque em "Nova NF-e".',
                        style: TextStyle(color: AppColors.gray))),
              ),
            ]);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: notas.length,
            itemBuilder: (context, i) {
              final n = notas[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('NF-e ${n.numero}/${n.serie}',
                              style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          StatusBadge.nfe(n.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(n.destNome,
                          style: const TextStyle(color: AppColors.text)),
                      Text('R\$ ${n.valorTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: AppColors.gray, fontSize: 13)),
                      if (n.motivo != null) ...[
                        const SizedBox(height: 4),
                        Text(n.motivo!,
                            style: const TextStyle(
                                color: AppColors.gray, fontSize: 12)),
                      ],
                      if (n.status == 'rascunho' || n.status == 'autorizada') ...[
                        const SizedBox(height: 10),
                        if (n.status == 'rascunho')
                          AppButton(
                            label: 'Emitir',
                            icon: Icons.send,
                            expand: false,
                            onPressed: () => _emitir(n),
                          )
                        else
                          AppButton(
                            label: 'DANFE',
                            icon: Icons.picture_as_pdf_outlined,
                            variant: AppButtonVariant.outline,
                            expand: false,
                            onPressed: () => _snack(
                                'DANFE: ${widget.api.danfeUrl(widget.empresaId, n.id)}'),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

Run: `flutter analyze lib/src/screens/nfe_list_screen.dart`
Expected: sem erros.

- [ ] **Step 3: Commit**

```bash
git add lib/src/screens/nfe_list_screen.dart
git commit -m "feat(ui): lista de NF-e repaginada com StatusBadge"
```

---

### Task 16: Nova NF-e — múltiplos itens, restilizada

**Files:**
- Modify: `lib/src/screens/nfe_form_screen.dart` (reescrever, usando `NfeItemInput` do modelo)

**Interfaces:**
- Consumes: `AppScaffold`, `AppCard`, `AppButton`, `AppTextField`, `AppColors`, `NfeApi` (`criarNfe`), `NfeItemInput` (de `models/nfe.dart`).
- Produces: `NfeFormScreen({required NfeApi api, required int empresaId})` (assinatura inalterada). Retorna `true` via `Navigator.pop` ao salvar.

- [ ] **Step 1: Reescrever a tela (gerência de lista de itens)**

```dart
// lib/src/screens/nfe_form_screen.dart
import 'package:flutter/material.dart';

import '../api/nfe_api.dart';
import '../models/nfe.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text_field.dart';

class NfeFormScreen extends StatefulWidget {
  final NfeApi api;
  final int empresaId;
  const NfeFormScreen(
      {super.key, required this.api, required this.empresaId});

  @override
  State<NfeFormScreen> createState() => _NfeFormScreenState();
}

class _NfeFormScreenState extends State<NfeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destNome = TextEditingController();
  final _destDoc = TextEditingController();
  String _tipoDoc = 'cnpj';

  final List<NfeItemInput> _itens = [NfeItemInput(codigo: 'P001')];
  bool _salvando = false;

  @override
  void dispose() {
    _destNome.dispose();
    _destDoc.dispose();
    super.dispose();
  }

  void _addItem() => setState(
      () => _itens.add(NfeItemInput(codigo: 'P${_itens.length + 1}'.padLeft(4, '0'))));

  void _removeItem(int i) => setState(() => _itens.removeAt(i));

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Obrigatório' : null;

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final payload = {
      'natureza_operacao': 'Venda de mercadoria',
      'destinatario': {
        'nome': _destNome.text,
        'tipo_documento': _tipoDoc,
        'documento': _destDoc.text.replaceAll(RegExp(r'\D'), ''),
        'indicador_ie': 9,
      },
      'pagamento': {'forma': '01'},
      'itens': _itens.map((e) => e.toJson()).toList(),
    };

    try {
      await widget.api.criarNfe(widget.empresaId, payload);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Nova NF-e',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Destinatário'),
            AppCard(
              child: Column(
                children: [
                  AppTextField(
                      controller: _destNome,
                      label: 'Nome / Razão social',
                      icon: Icons.person_outline,
                      validator: _req),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _tipoDoc,
                          decoration: const InputDecoration(labelText: 'Tipo'),
                          dropdownColor: AppColors.scaffoldBg,
                          items: const [
                            DropdownMenuItem(value: 'cnpj', child: Text('CNPJ')),
                            DropdownMenuItem(value: 'cpf', child: Text('CPF')),
                          ],
                          onChanged: (v) =>
                              setState(() => _tipoDoc = v ?? 'cnpj'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: AppTextField(
                            controller: _destDoc,
                            label: 'Documento',
                            keyboardType: TextInputType.number,
                            validator: _req),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _sectionTitle('Itens (${_itens.length})')),
                AppButton(
                    label: 'Item',
                    icon: Icons.add,
                    variant: AppButtonVariant.outline,
                    expand: false,
                    onPressed: _addItem),
              ],
            ),
            for (var i = 0; i < _itens.length; i++) _itemCard(i),
            const SizedBox(height: 24),
            AppButton(
              label: 'Salvar rascunho',
              icon: Icons.save,
              loading: _salvando,
              onPressed: _salvar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(t,
            style: const TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      );

  Widget _itemCard(int i) {
    final item = _itens[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Item ${i + 1}',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                if (_itens.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.danger, size: 20),
                    onPressed: () => _removeItem(i),
                  ),
              ],
            ),
            AppTextField(
                label: 'Descrição do produto',
                validator: _req,
                icon: Icons.inventory_2_outlined,
                controller: TextEditingController(text: item.descricao)
                  ..selection = TextSelection.collapsed(
                      offset: item.descricao.length),
                keyboardType: TextInputType.text),
            // NOTA: os campos abaixo escrevem direto no NfeItemInput via onChanged
            _itemField('NCM (8 díg.)', item.ncm, (v) => item.ncm = v,
                validator: (v) => (v == null || v.length != 8) ? '8 dígitos' : null),
            _itemField('CFOP', item.cfop, (v) => item.cfop = v,
                validator: (v) => (v == null || v.length != 4) ? '4 dígitos' : null),
            Row(
              children: [
                Expanded(
                  child: _itemField('Qtd.', '${item.quantidade}',
                      (v) => item.quantidade =
                          double.tryParse(v.replaceAll(',', '.')) ?? 1,
                      keyboardType: TextInputType.number),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _itemField('Valor unit. (R\$)', '',
                      (v) => item.valorUnitario =
                          double.tryParse(v.replaceAll(',', '.')) ?? 0,
                      keyboardType: TextInputType.number, validator: _req),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemField(String label, String initial, ValueChanged<String> onChanged,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return _ItemField(
      label: label,
      initial: initial,
      onChanged: onChanged,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}

/// Campo controlado por callback, para escrever direto no NfeItemInput.
class _ItemField extends StatefulWidget {
  final String label;
  final String initial;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const _ItemField({
    required this.label,
    required this.initial,
    required this.onChanged,
    this.keyboardType,
    this.validator,
  });

  @override
  State<_ItemField> createState() => _ItemFieldState();
}

class _ItemFieldState extends State<_ItemField> {
  late final TextEditingController _c =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _c,
      label: widget.label,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      // encaminha cada mudança para o modelo
      suffix: null,
    )..hashCode; // no-op para manter const-free
  }
}
```

> **Correção de acoplamento (aplicar neste passo):** o `_ItemField` acima precisa propagar `onChanged`. Como `AppTextField` não expõe `onChanged`, adicione ao `AppTextField` (Task 5) o parâmetro opcional `final ValueChanged<String>? onChanged;` e repasse-o a `TextFormField(onChanged: onChanged, ...)`. Depois, em `_ItemFieldState.build`, use `AppTextField(controller: _c, label: widget.label, keyboardType: widget.keyboardType, validator: widget.validator, onChanged: widget.onChanged)` e remova a linha `..hashCode`. Para a descrição, troque o `TextEditingController` inline por um `_ItemField(label: 'Descrição do produto', initial: item.descricao, onChanged: (v) => item.descricao = v, validator: _req)`.

- [ ] **Step 2: Ajustar `AppTextField` para aceitar `onChanged`**

Em `lib/src/widgets/app_text_field.dart`, adicionar o campo `final ValueChanged<String>? onChanged;` ao construtor e passar `onChanged: onChanged` ao `TextFormField`. Rodar o teste da Task 5 de novo:

Run: `flutter test test/widgets/app_text_field_test.dart`
Expected: PASS (continua verde).

- [ ] **Step 3: Simplificar o formulário usando `_ItemField` em todos os campos de item**

Reescrever `_itemCard` para usar `_ItemField` (com `onChanged` gravando no `NfeItemInput`) em todos os campos, inclusive descrição, removendo os `TextEditingController` inline e a linha `..hashCode`. Garantir que `_ItemField.build` retorne diretamente o `AppTextField` com `onChanged: widget.onChanged`.

- [ ] **Step 4: Analyze**

Run: `flutter analyze lib/src/screens/nfe_form_screen.dart lib/src/widgets/app_text_field.dart`
Expected: sem erros.

- [ ] **Step 5: Commit**

```bash
git add lib/src/screens/nfe_form_screen.dart lib/src/widgets/app_text_field.dart
git commit -m "feat(ui): formulario de NF-e com multiplos itens repaginado"
```

---

### Task 17: Telas de Certificado e Status SEFAZ restilizadas

**Files:**
- Modify: `lib/src/screens/certificado_screen.dart` (reescrever)
- Modify: `lib/src/screens/status_screen.dart` (reescrever)

**Interfaces:**
- Consumes: `AppScaffold`, `AppCard`, `AppButton`, `AppTextField`, `AppColors`, `NfeApi` (`uploadCertificado`, `sefazStatus`), `Empresa`, `SefazStatus`.
- Produces: `CertificadoScreen({required NfeApi api, required Empresa empresa})` e `StatusScreen({required NfeApi api, required int empresaId})` (assinaturas inalteradas).

- [ ] **Step 1: Reescrever `certificado_screen.dart`**

```dart
// lib/src/screens/certificado_screen.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../api/nfe_api.dart';
import '../models/empresa.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text_field.dart';

class CertificadoScreen extends StatefulWidget {
  final NfeApi api;
  final Empresa empresa;
  const CertificadoScreen(
      {super.key, required this.api, required this.empresa});

  @override
  State<CertificadoScreen> createState() => _CertificadoScreenState();
}

class _CertificadoScreenState extends State<CertificadoScreen> {
  final _senha = TextEditingController();
  List<int>? _bytes;
  String? _fileName;
  bool _loading = false;

  @override
  void dispose() {
    _senha.dispose();
    super.dispose();
  }

  Future<void> _escolher() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pfx', 'p12'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _bytes = result.files.single.bytes;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _enviar() async {
    if (_bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione o arquivo .pfx')));
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.api.uploadCertificado(
          widget.empresa.id, _bytes!, _fileName ?? 'certificado.pfx', _senha.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Certificado cadastrado!'),
            backgroundColor: AppColors.success));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'), backgroundColor: AppColors.danger));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Certificado',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.empresa.razaoSocial,
                    style: const TextStyle(
                        color: AppColors.text, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text(
                    'Envie o certificado digital A1 (.pfx / e-CNPJ) desta empresa.',
                    style: TextStyle(color: AppColors.gray)),
                const SizedBox(height: 16),
                AppButton(
                  label: _fileName ?? 'Selecionar arquivo .pfx',
                  icon: Icons.attach_file,
                  variant: AppButtonVariant.outline,
                  onPressed: _escolher,
                ),
                const SizedBox(height: 8),
                AppTextField(
                    controller: _senha,
                    label: 'Senha do certificado',
                    icon: Icons.lock_outline,
                    obscureText: true),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Enviar certificado',
                  icon: Icons.upload,
                  loading: _loading,
                  onPressed: _enviar,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Reescrever `status_screen.dart`**

```dart
// lib/src/screens/status_screen.dart
import 'package:flutter/material.dart';

import '../api/nfe_api.dart';
import '../models/sefaz_status.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';

class StatusScreen extends StatefulWidget {
  final NfeApi api;
  final int empresaId;
  const StatusScreen({super.key, required this.api, required this.empresaId});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  Future<SefazStatus>? _future;

  @override
  void initState() {
    super.initState();
    _consultar();
  }

  void _consultar() =>
      setState(() => _future = widget.api.sefazStatus(widget.empresaId));

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _consultar(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FutureBuilder<SefazStatus>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) {
                return _StatusCard(
                  color: AppColors.danger,
                  icon: Icons.error_outline,
                  title: 'Não foi possível consultar',
                  subtitle: '${snap.error}',
                );
              }
              final s = snap.data!;
              return _StatusCard(
                color: s.online ? AppColors.success : AppColors.warning,
                icon: s.online
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_outlined,
                title: s.online ? 'SEFAZ em operação' : 'SEFAZ indisponível',
                subtitle: '[${s.cStat}] ${s.motivo}\n'
                    'UF ${s.uf} · Ambiente: ${s.ambienteLabel}',
              );
            },
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Consultar status',
            icon: Icons.refresh,
            onPressed: _consultar,
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  const _StatusCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      background: color.withValues(alpha: 0.12),
      border: color.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: AppColors.gray)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Analyze**

Run: `flutter analyze lib/src/screens/certificado_screen.dart lib/src/screens/status_screen.dart`
Expected: sem erros.

- [ ] **Step 4: Commit**

```bash
git add lib/src/screens/certificado_screen.dart lib/src/screens/status_screen.dart
git commit -m "feat(ui): certificado e status SEFAZ repaginados"
```

---

### Task 18: Verificação ponta a ponta

**Files:**
- Nenhum arquivo novo (verificação + eventuais correções).

- [ ] **Step 1: Análise estática limpa**

Run: `flutter analyze`
Expected: `No issues found!`. Corrigir qualquer erro (em especial renames `*Theme`→`*ThemeData` dependentes da versão do SDK).

- [ ] **Step 2: Suíte de testes completa**

Run: `flutter test`
Expected: todos os testes PASS.

- [ ] **Step 3: Subir o backend (WSL)**

No WSL, na pasta do backend:
```bash
cd ~/jean/emissos/backend && docker compose up -d
curl -s http://localhost:8080/api/auth/login -X POST -H 'Accept: application/json' | head
```
Expected: a API responde (ex.: 422/401 com JSON) — confirma que está no ar na porta 8080.

- [ ] **Step 4: Rodar o app no Chrome contra a API**

Run: `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api`
Verificar manualmente o fluxo:
1. Criar conta → cai no wizard.
2. Passo 1: buscar um CNPJ → dados aparecem → cadastrar empresa.
3. Passo 2: enviar um `.pfx` de teste + senha.
4. Passo 3: "Tudo pronto" → ir para emissão.
5. Criar uma NF-e (destinatário + item) → salvar rascunho → Emitir.
6. Sair e entrar de novo → deve abrir direto na lista/painel (não no wizard).
Expected: visual escuro dourado/roxo com Montserrat em todas as telas; fluxo completo sem travar.

- [ ] **Step 5: Commit final (se houve correções)**

```bash
git add -A
git commit -m "chore: ajustes finais da verificacao ponta a ponta"
```

---

## Self-Review (preenchido)

**Cobertura do spec:**
- Design system (cores/tema/Montserrat) → Tasks 1, 2. ✅
- Widgets reutilizáveis (AppScaffold/Button/TextField/Card/StatusBadge/StepIndicator) → Tasks 3–8. ✅
- Navegação híbrida + wizard → Tasks 10, 12. ✅
- `GET /auth/me` + 401 → Task 9 (validarSessao) + uso no RootGate (Task 10). ✅
- Todas as telas repaginadas (auth, empresas, painel, NF-e lista, nova NF-e, certificado, status) → Tasks 11, 13, 14, 15, 16, 17. ✅
- Emissão simplificada com múltiplos itens → Task 16. ✅
- Erros/estados/loading → embutidos nos widgets e telas. ✅
- Testes + verificação (analyze/test/run) → Tasks + Task 18. ✅

**Placeholders:** nenhum "TBD/TODO". A Task 16 contém uma correção explícita de acoplamento (adicionar `onChanged` ao `AppTextField`) com passos concretos — não é placeholder.

**Consistência de tipos:** assinaturas de telas mantidas (`LoginScreen`, `EmpresasScreen`, `EmpresaDashboard`, `NfeListScreen`, `NfeFormScreen`, `CertificadoScreen`, `StatusScreen`); `EmpresaForm.onCreated(Empresa)`; `OnboardingFlow(onDone, onLogout)`; `NfeApi.validarSessao()→Future<bool>`; `AppButtonVariant` usado consistentemente. ✅

**Ponto de atenção de ordem:** Task 10 referencia `OnboardingFlow` (Task 12). Executar 10 e 12 em sequência; o teste do RootGate que depende do wizard só fica verde após a Task 12 (nota registrada na Task 10).
