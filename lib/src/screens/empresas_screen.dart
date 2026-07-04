// lib/src/screens/empresas_screen.dart
import 'package:flutter/material.dart';

import '../api/nfe_api.dart';
import '../models/empresa.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/empresa_form.dart';
import '../widgets/status_badge.dart';
import 'certificado_screen.dart';
import 'empresa_dashboard.dart';

class EmpresasScreen extends StatefulWidget {
  final NfeApi api;
  final VoidCallback onLogout;
  const EmpresasScreen(
      {super.key, required this.api, required this.onLogout});

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
    final criada = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.scaffoldBg,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Adicionar empresa',
                    style: TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                EmpresaForm(
                  api: widget.api,
                  onCreated: (_) => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (criada == true) _reload();
  }

  Future<void> _sair() async {
    await widget.api.logout();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Minhas empresas',
      actions: [
        IconButton(
            onPressed: _sair,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair'),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionar,
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
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
              return ListView(children: [
                Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Erro: ${snap.error}',
                        style: const TextStyle(color: AppColors.danger)))
              ]);
            }
            final empresas = snap.data ?? [];
            if (empresas.isEmpty) {
              return ListView(children: const [
                Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(
                      child: Text(
                          'Nenhuma empresa. Toque em "Adicionar CNPJ".',
                          style: TextStyle(color: AppColors.gray))),
                ),
              ]);
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: empresas.length,
              itemBuilder: (context, i) {
                final e = empresas[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            EmpresaDashboard(api: widget.api, empresa: e))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(e.nomeFantasia ?? e.razaoSocial,
                                  style: const TextStyle(
                                      color: AppColors.text,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                            const Icon(Icons.chevron_right,
                                color: AppColors.gray),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${e.cnpj} · ${e.uf ?? ''} · ${e.ambienteLabel}',
                            style: const TextStyle(
                                color: AppColors.gray, fontSize: 12)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            StatusBadge.certificado(e.certificadoOk),
                            const Spacer(),
                            if (!e.certificadoOk)
                              TextButton(
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) => CertificadoScreen(
                                              api: widget.api, empresa: e)));
                                  _reload();
                                },
                                child: const Text('Enviar certificado',
                                    style:
                                        TextStyle(color: AppColors.primary)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
