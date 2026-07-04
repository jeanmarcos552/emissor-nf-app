// lib/src/screens/nfe_list_screen.dart
import 'package:flutter/material.dart';

import '../api/nfe_api.dart';
import '../models/nfe.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/status_badge.dart';

class NfeListScreen extends StatefulWidget {
  final NfeApi api;
  final int empresaId;
  const NfeListScreen(
      {super.key, required this.api, required this.empresaId});

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

  void _reload() =>
      setState(() => _future = widget.api.listarNfe(widget.empresaId));

  Future<void> _emitir(Nfe nfe) async {
    _snack('Emitindo NF-e ${nfe.numero}...');
    try {
      await widget.api.emitir(widget.empresaId, nfe.id);
      _snack('NF-e ${nfe.numero} autorizada!');
      if (mounted) _reload();
    } catch (e) {
      _snack('$e', erro: true);
    }
  }

  void _snack(String msg, {bool erro = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: erro ? AppColors.danger : null),
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
                  child: Text('Erro ao carregar: ${snap.error}',
                      style: const TextStyle(color: AppColors.danger)))
            ]);
          }
          final notas = snap.data ?? [];
          if (notas.isEmpty) {
            return ListView(children: const [
              Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                    child: Text('Nenhuma NF-e ainda. Toque em "Nova NF-e".',
                        style: TextStyle(color: AppColors.gray))),
              ),
            ]);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: notas.length,
            itemBuilder: (context, i) {
              final n = notas[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('NF-e ${n.numero}/${n.serie}',
                              style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          StatusBadge.nfe(n.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(n.destNome,
                          style: const TextStyle(color: AppColors.text)),
                      Text('R\$ ${n.valorTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: AppColors.gray, fontSize: 13)),
                      if (n.motivo != null) ...[
                        const SizedBox(height: 4),
                        Text(n.motivo!,
                            style: const TextStyle(
                                color: AppColors.gray, fontSize: 12)),
                      ],
                      if (n.status == 'rascunho' || n.status == 'autorizada') ...[
                        const SizedBox(height: 10),
                        if (n.status == 'rascunho')
                          AppButton(
                            label: 'Emitir',
                            icon: Icons.send,
                            expand: false,
                            onPressed: () => _emitir(n),
                          )
                        else
                          AppButton(
                            label: 'DANFE',
                            icon: Icons.picture_as_pdf_outlined,
                            variant: AppButtonVariant.outline,
                            expand: false,
                            onPressed: () => _snack(
                                'DANFE: ${widget.api.danfeUrl(widget.empresaId, n.id)}'),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
