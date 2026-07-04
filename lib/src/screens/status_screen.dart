// lib/src/screens/status_screen.dart
import 'package:flutter/material.dart';

import '../api/nfe_api.dart';
import '../models/sefaz_status.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';

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

  void _consultar() =>
      setState(() => _future = widget.api.sefazStatus(widget.empresaId));

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
                return _StatusCard(
                  color: AppColors.danger,
                  icon: Icons.error_outline,
                  title: 'Não foi possível consultar',
                  subtitle: '${snap.error}',
                );
              }
              final s = snap.data!;
              return _StatusCard(
                color: s.online ? AppColors.success : AppColors.warning,
                icon: s.online
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_outlined,
                title: s.online ? 'SEFAZ em operação' : 'SEFAZ indisponível',
                subtitle: '[${s.cStat}] ${s.motivo}\n'
                    'UF ${s.uf} · Ambiente: ${s.ambienteLabel}',
              );
            },
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Consultar status',
            icon: Icons.refresh,
            onPressed: _consultar,
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  const _StatusCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      background: color.withValues(alpha: 0.12),
      border: color.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: AppColors.gray)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
