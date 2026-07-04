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
      if (mounted) setState(() => _info = info);
    } catch (e) {
      if (mounted) {
        setState(() {
          _info = null;
          _erro = '$e';
        });
      }
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
