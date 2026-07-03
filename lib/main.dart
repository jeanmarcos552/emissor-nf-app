import 'package:flutter/material.dart';

import 'src/api/nfe_api.dart';
import 'src/auth_store.dart';
import 'src/screens/empresas_screen.dart';
import 'src/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthStore();
  await auth.load();
  runApp(EmissorApp(api: NfeApi(auth: auth)));
}

class EmissorApp extends StatefulWidget {
  final NfeApi api;
  const EmissorApp({super.key, required this.api});

  @override
  State<EmissorApp> createState() => _EmissorAppState();
}

class _EmissorAppState extends State<EmissorApp> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emissor NF-e',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B6E4F)),
        useMaterial3: true,
      ),
      home: widget.api.auth.isLoggedIn
          ? EmpresasScreen(api: widget.api, onLogout: _refresh)
          : LoginScreen(api: widget.api, onAuthenticated: _refresh),
    );
  }
}
