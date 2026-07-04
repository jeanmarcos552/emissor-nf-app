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

  void _addItem() => setState(() => _itens.add(
      NfeItemInput(codigo: 'P${(_itens.length + 1).toString().padLeft(3, '0')}')));

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
      key: ObjectKey(item),
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
            _itemField('Descrição do produto', item.descricao,
                (v) => item.descricao = v,
                icon: Icons.inventory_2_outlined, validator: _req),
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
      {IconData? icon,
      TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    return _ItemField(
      label: label,
      initial: initial,
      onChanged: onChanged,
      icon: icon,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}

/// Campo de item controlado por callback, gravando direto no NfeItemInput.
class _ItemField extends StatefulWidget {
  final String label;
  final String initial;
  final ValueChanged<String> onChanged;
  final IconData? icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const _ItemField({
    required this.label,
    required this.initial,
    required this.onChanged,
    this.icon,
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
      icon: widget.icon,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
    );
  }
}
