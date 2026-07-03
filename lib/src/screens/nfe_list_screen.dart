import 'package:flutter/material.dart';

import '../api/nfe_api.dart';
import '../models/nfe.dart';

class NfeListScreen extends StatefulWidget {
  final NfeApi api;
  final int empresaId;
  const NfeListScreen({super.key, required this.api, required this.empresaId});

  @override
  State<NfeListScreen> createState() => _NfeListScreenState();
}

class _NfeListScreenState extends State<NfeListScreen> {
  late Future<List<Nfe>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.listarNfe(widget.empresaId);
  }

  void _reload() => setState(() => _future = widget.api.listarNfe(widget.empresaId));

  Color _statusColor(String status) {
    switch (status) {
      case 'autorizada':
        return Colors.green;
      case 'cancelada':
        return Colors.grey;
      case 'rejeitada':
      case 'denegada':
      case 'erro':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> _emitir(Nfe nfe) async {
    _snack('Emitindo NF-e ${nfe.numero}...');
    try {
      await widget.api.emitir(widget.empresaId, nfe.id);
      _snack('NF-e ${nfe.numero} autorizada!');
      _reload();
    } catch (e) {
      _snack('$e', erro: true);
    }
  }

  void _snack(String msg, {bool erro = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: erro ? Colors.red : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _reload(),
      child: FutureBuilder<List<Nfe>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ListView(children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Erro ao carregar: ${snap.error}'),
              ),
            ]);
          }
          final notas = snap.data ?? [];
          if (notas.isEmpty) {
            return ListView(children: const [
              Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: Text('Nenhuma NF-e ainda. Toque em "Nova NF-e".')),
              ),
            ]);
          }
          return ListView.separated(
            itemCount: notas.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final n = notas[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _statusColor(n.status).withValues(alpha: 0.15),
                  child: Text('${n.numero}',
                      style: TextStyle(color: _statusColor(n.status), fontSize: 12)),
                ),
                title: Text(n.destNome),
                subtitle: Text('R\$ ${n.valorTotal.toStringAsFixed(2)} · ${n.status}'
                    '${n.motivo != null ? '\n${n.motivo}' : ''}'),
                isThreeLine: n.motivo != null,
                trailing: n.status == 'rascunho'
                    ? FilledButton(onPressed: () => _emitir(n), child: const Text('Emitir'))
                    : (n.status == 'autorizada'
                        ? IconButton(
                            icon: const Icon(Icons.picture_as_pdf_outlined),
                            tooltip: 'DANFE',
                            onPressed: () => _snack('DANFE: ${widget.api.danfeUrl(widget.empresaId, n.id)}'),
                          )
                        : null),
              );
            },
          );
        },
      ),
    );
  }
}
