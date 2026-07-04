// lib/src/widgets/status_badge.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Pill de status para NF-e e certificado.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  factory StatusBadge.nfe(String status) {
    switch (status) {
      case 'autorizada':
        return const StatusBadge(
            label: 'Autorizada',
            color: AppColors.success,
            icon: Icons.check_circle);
      case 'cancelada':
        return const StatusBadge(
            label: 'Cancelada', color: AppColors.gray, icon: Icons.block);
      case 'rejeitada':
      case 'denegada':
      case 'erro':
        return StatusBadge(
            label: status[0].toUpperCase() + status.substring(1),
            color: AppColors.danger,
            icon: Icons.error);
      case 'rascunho':
        return const StatusBadge(
            label: 'Rascunho', color: AppColors.info, icon: Icons.edit_note);
      default:
        return StatusBadge(label: status, color: AppColors.gray);
    }
  }

  factory StatusBadge.certificado(bool ok) => ok
      ? const StatusBadge(
          label: 'Certificado OK',
          color: AppColors.success,
          icon: Icons.verified_user)
      : const StatusBadge(
          label: 'Sem certificado',
          color: AppColors.warning,
          icon: Icons.gpp_maybe);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
