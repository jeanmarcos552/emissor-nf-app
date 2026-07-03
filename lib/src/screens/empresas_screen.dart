import 'package:flutter/material.dart';

import '../api/nfe_api.dart';
import '../models/empresa.dart';
import 'certificado_screen.dart';
import 'empresa_dashboard.dart';

class EmpresasScreen extends StatefulWidget {
  final NfeApi api;
  final VoidCallback onLogout;
  const EmpresasScreen({super.key, required this.api, required this.onLogout});

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
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _NovaEmpresaDialog(api: widget.api),
    );
    if (ok == true) _reload();
  }

  Future<void> _sair() async {
    await widget.api.logout();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas empresas'),
        actions: [
          IconButton(onPressed: _sair, icon: const Icon(Icons.logout), tooltip: 'Sair'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionar,
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
              return ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text('Erro: ${snap.error}'))]);
            }
            final empresas = snap.data ?? [];
            if (empresas.isEmpty) {
              return ListView(children: const [
                Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: Text('Nenhuma empresa. Adicione um CNPJ para começar.')),
                ),
              ]);
            }
            return ListView.separated(
              itemCount: empresas.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final e = empresas[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: e.certificadoOk ? Colors.green.shade100 : Colors.orange.shade100,
                    child: Icon(e.certificadoOk ? Icons.verified_user : Icons.gpp_maybe,
                        color: e.certificadoOk ? Colors.green : Colors.orange),
                  ),
                  title: Text(e.razaoSocial),
                  subtitle: Text('${e.cnpj} · ${e.uf ?? ''} · ${e.ambienteLabel}\n'
                      '${e.certificadoOk ? 'Certificado OK' : 'Sem certificado válido'}'),
                  isThreeLine: true,
                  trailing: e.certificadoOk
                      ? const Icon(Icons.chevron_right)
                      : TextButton(
                          onPressed: () async {
                            await Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => CertificadoScreen(api: widget.api, empresa: e),
                            ));
                            _reload();
                          },
                          child: const Text('Certificado'),
                        ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => EmpresaDashboard(api: widget.api, empresa: e),
                  )),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NovaEmpresaDialog extends StatefulWidget {
  final NfeApi api;
  const _NovaEmpresaDialog({required this.api});

  @override
  State<_NovaEmpresaDialog> createState() => _NovaEmpresaDialogState();
}

class _NovaEmpresaDialogState extends State<_NovaEmpresaDialog> {
  final _cnpj = TextEditingController();
  final _ie = TextEditingController();
  int _crt = 1;
  bool _loading = false;
  String? _previa;

  Future<void> _buscar() async {
    setState(() => _loading = true);
    try {
      final info = await widget.api.buscarCnpj(_cnpj.text.replaceAll(RegExp(r'\D'), ''));
      setState(() => _previa = '${info.razaoSocial ?? '-'} · ${info.municipio ?? ''}/${info.uf ?? ''}');
    } catch (e) {
      setState(() => _previa = 'Não encontrado: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _salvar() async {
    setState(() => _loading = true);
    try {
      await widget.api.criarEmpresa({
        'cnpj': _cnpj.text.replaceAll(RegExp(r'\D'), ''),
        'ie': _ie.text,
        'crt': _crt,
        'ambiente': 2,
      });
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar CNPJ'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _cnpj,
            decoration: InputDecoration(
              labelText: 'CNPJ',
              suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _loading ? null : _buscar),
            ),
            keyboardType: TextInputType.number,
          ),
          if (_previa != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_previa!)),
          TextField(controller: _ie, decoration: const InputDecoration(labelText: 'Inscrição Estadual')),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: _crt,
            decoration: const InputDecoration(labelText: 'Regime (CRT)'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Simples Nacional')),
              DropdownMenuItem(value: 3, child: Text('Regime Normal')),
            ],
            onChanged: (v) => setState(() => _crt = v ?? 1),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
        FilledButton(onPressed: _loading ? null : _salvar, child: const Text('Salvar')),
      ],
    );
  }
}
