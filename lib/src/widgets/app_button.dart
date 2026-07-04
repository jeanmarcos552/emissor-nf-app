// lib/src/widgets/app_button.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, outline, success, link }

/// Botão do design system, com variantes e estado de carregamento.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final onTap = loading ? null : onPressed;
    late final Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = FilledButton(onPressed: onTap, child: child);
      case AppButtonVariant.success:
        button = FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white),
          child: child,
        );
      case AppButtonVariant.outline:
        button = OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.text,
            side: const BorderSide(color: AppColors.secondary),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
          child: child,
        );
      case AppButtonVariant.link:
        button = TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          child: child,
        );
    }
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
