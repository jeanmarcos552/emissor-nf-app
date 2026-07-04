import 'package:flutter/material.dart';

import 'src/api/nfe_api.dart';
import 'src/auth_store.dart';
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
          empresas.isEmpty || !empresas.any((e) => e.certificadoOk);
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
