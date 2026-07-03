import 'package:flutter/material.dart';

import '../api/nfe_api.dart';
import '../models/empresa.dart';
import 'nfe_form_screen.dart';
import 'nfe_list_screen.dart';
import 'status_screen.dart';

/// Painel de uma empresa selecionada: status da SEFAZ + notas.
class EmpresaDashboard extends StatefulWidget {
  final NfeApi api;
  final Empresa empresa;
  const EmpresaDashboard({super.key, required this.api, required this.empresa});

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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.empresa.nomeFantasia ?? widget.empresa.razaoSocial),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('${widget.empresa.cnpj} · ${widget.empresa.ambienteLabel}',
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ),
        ),
      ),
      body: pages[_index],
      floatingActionButton: _index == 1
          ? FloatingActionButton.extended(
              onPressed: () async {
                final criada = await Navigator.of(context).push<bool>(MaterialPageRoute(
                  builder: (_) => NfeFormScreen(api: widget.api, empresaId: widget.empresa.id),
                ));
                if (criada == true) setState(() {});
              },
              icon: const Icon(Icons.add),
              label: const Text('Nova NF-e'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.cloud_outlined), label: 'SEFAZ'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Notas'),
        ],
      ),
    );
  }
}
