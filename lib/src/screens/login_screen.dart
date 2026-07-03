import 'package:flutter/material.dart';

import '../api/nfe_api.dart';

class LoginScreen extends StatefulWidget {
  final NfeApi api;
  final VoidCallback onAuthenticated;
  const LoginScreen({super.key, required this.api, required this.onAuthenticated});

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
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long, size: 64, color: Color(0xFF0B6E4F)),
                  const SizedBox(height: 8),
                  Text('Emissor NF-e', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  if (_isRegister)
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Informe seu nome' : null,
                    ),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
                  ),
                  TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    obscureText: true,
                    validator: (v) => (v == null || v.length < 8) ? 'Mínimo 8 caracteres' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_isRegister ? 'Criar conta' : 'Entrar'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isRegister = !_isRegister),
                    child: Text(_isRegister ? 'Já tenho conta' : 'Criar uma conta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
