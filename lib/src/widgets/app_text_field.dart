// lib/src/widgets/app_text_field.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Campo de texto do design system (label dourado, ícone, estado de erro).
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final IconData? icon;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.icon,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.text),
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          prefixIcon: icon == null
              ? null
              : Icon(icon, size: 18, color: AppColors.primary),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
