// lib/src/widgets/app_card.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Card do design system: fundo roxo translúcido, raio 16, borda 1.5.
class AppCard extends StatelessWidget {
  final Widget child;
  final Color? background;
  final Color? border;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.background,
    this.border,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border ?? AppColors.cardBorder, width: 1.5),
      ),
      child: child,
    );
    if (onTap == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: content,
    );
  }
}
