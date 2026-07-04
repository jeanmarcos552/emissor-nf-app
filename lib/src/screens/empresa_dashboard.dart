// lib/src/screens/empresa_dashboard.dart
import 'package:flutter/material.dart';

import '../api/nfe_api.dart';
import '../models/empresa.dart';
import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import 'nfe_form_screen.dart';
import 'nfe_list_screen.dart';
import 'status_screen.dart';

/// Painel de uma empresa: status da SEFAZ + notas.
class EmpresaDashboard extends StatefulWidget {
  final NfeApi api;
  final Empresa empresa;
  const EmpresaDashboard(
      {super.key, required this.api, required this.empresa});

  @override
  State<EmpresaDashboard> createState() => _EmpresaDashboardState();
}

class _EmpresaDashboardState extends State<EmpresaDashboard> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      StatusScreen(api: widget.api, empresaId: widget.empresa.id),
      NfeListScreen(api: widget.api, empresaId: widget.empresa.id),
    ];

    return AppScaffold(
      title: widget.empresa.nomeFantasia ?? widget.empresa.razaoSocial,
      appBarBottom: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
              '${widget.empresa.cnpj} · ${widget.empresa.ambienteLabel}',
              style: const TextStyle(fontSize: 12, color: AppColors.gray)),
        ),
      ),
      body: pages[_index],
      floatingActionButton: _index == 1
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              onPressed: () async {
                final criada = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                        builder: (_) => NfeFormScreen(
                            api: widget.api, empresaId: widget.empresa.id)));
                if (criada == true) setState(() {});
              },
              icon: const Icon(Icons.add),
              label: const Text('Nova NF-e'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.scaffoldBg,
        indicatorColor: AppColors.secondary.withValues(alpha: 0.4),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.cloud_outlined), label: 'SEFAZ'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined), label: 'Notas'),
        ],
      ),
    );
  }
}
