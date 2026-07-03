import 'package:flutter/material.dart';

import '../api/nfe_api.dart';
import '../models/sefaz_status.dart';

class StatusScreen extends StatefulWidget {
  final NfeApi api;
  final int empresaId;
  const StatusScreen({super.key, required this.api, required this.empresaId});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  Future<SefazStatus>? _future;

  @override
  void initState() {
    super.initState();
    _consultar();
  }

  void _consultar() {
    setState(() => _future = widget.api.sefazStatus(widget.empresaId));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _consultar(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FutureBuilder<SefazStatus>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) {
                return _Card(
                  color: Colors.red.shade50,
                  icon: Icons.error_outline,
                  iconColor: Colors.red,
                  title: 'Não foi possível consultar',
                  subtitle: '${snap.error}',
                );
              }
              final s = snap.data!;
              return _Card(
                color: s.online ? Colors.green.shade50 : Colors.orange.shade50,
                icon: s.online ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                iconColor: s.online ? Colors.green : Colors.orange,
                title: s.online ? 'SEFAZ em operação' : 'SEFAZ indisponível',
                subtitle: '[${s.cStat}] ${s.motivo}\n'
                    'UF ${s.uf} · Ambiente: ${s.ambienteLabel}',
              );
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _consultar,
            icon: const Icon(Icons.refresh),
            label: const Text('Consultar status'),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Color color;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;

  const _Card({
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(subtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
