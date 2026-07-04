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
