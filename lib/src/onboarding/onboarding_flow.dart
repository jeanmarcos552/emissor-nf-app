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
      body: Center(
        child: SingleChildScrollView(
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
