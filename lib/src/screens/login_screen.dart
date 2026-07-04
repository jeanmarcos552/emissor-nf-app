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
