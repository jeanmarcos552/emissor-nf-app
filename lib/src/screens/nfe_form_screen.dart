import 'package:flutter/material.dart';

import '../api/nfe_api.dart';

class NfeFormScreen extends StatefulWidget {
  final NfeApi api;
  final int empresaId;
  const NfeFormScreen({super.key, required this.api, required this.empresaId});

  @override
  State<NfeFormScreen> createState() => _NfeFormScreenState();
}

class _NfeFormScreenState extends State<NfeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _destNome = TextEditingController();
  final _destDoc = TextEditingController();
  String _tipoDoc = 'cnpj';

  final _itemDesc = TextEditingController();
  final _itemNcm = TextEditingController();
  final _itemCfop = TextEditingController(text: '5102');
  final _itemQtd = TextEditingController(text: '1');
  final _itemVlr = TextEditingController();

  bool _salvando = false;

  @override
  void dispose() {
    for (final c in [_destNome, _destDoc, _itemDesc, _itemNcm, _itemCfop, _itemQtd, _itemVlr]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final payload = {
      'natureza_operacao': 'Venda de mercadoria',
      'destinatario': {
        'nome': _destNome.text,
        'tipo_documento': _tipoDoc,
        'documento': _destDoc.text,
        'indicador_ie': 9,
      },
      'pagamento': {'forma': '01'},
      'itens': [
        {
          'codigo': 'P001',
          'descricao': _itemDesc.text,
          'ncm': _itemNcm.text,
          'cfop': _itemCfop.text,
          'unidade': 'UN',
          'quantidade': double.tryParse(_itemQtd.text.replaceAll(',', '.')) ?? 1,
          'valor_unitario': double.tryParse(_itemVlr.text.replaceAll(',', '.')) ?? 0,
          'icms_csosn': '102',
        }
      ],
    };

    try {
      await widget.api.criarNfe(widget.empresaId, payload);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova NF-e')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Destinatário', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _destNome,
              decoration: const InputDecoration(labelText: 'Nome / Razão social'),
              validator: _req,
            ),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _tipoDoc,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: const [
                    DropdownMenuItem(value: 'cnpj', child: Text('CNPJ')),
                    DropdownMenuItem(value: 'cpf', child: Text('CPF')),
                  ],
                  onChanged: (v) => setState(() => _tipoDoc = v ?? 'cnpj'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _destDoc,
                  decoration: const InputDecoration(labelText: 'Documento'),
                  validator: _req,
                ),
              ),
            ]),
            const SizedBox(height: 24),
            Text('Item', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _itemDesc,
              decoration: const InputDecoration(labelText: 'Descrição do produto'),
              validator: _req,
            ),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _itemNcm,
                  decoration: const InputDecoration(labelText: 'NCM (8 díg.)'),
                  validator: (v) => (v == null || v.length != 8) ? '8 dígitos' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _itemCfop,
                  decoration: const InputDecoration(labelText: 'CFOP'),
                  validator: (v) => (v == null || v.length != 4) ? '4 dígitos' : null,
                ),
              ),
            ]),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _itemQtd,
                  decoration: const InputDecoration(labelText: 'Qtd.'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _itemVlr,
                  decoration: const InputDecoration(labelText: 'Valor unit. (R\$)'),
                  keyboardType: TextInputType.number,
                  validator: _req,
                ),
              ),
            ]),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _salvando ? null : _salvar,
              icon: _salvando
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: const Text('Salvar rascunho'),
            ),
          ],
        ),
      ),
    );
  }
}
