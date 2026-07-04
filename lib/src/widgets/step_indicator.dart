// lib/src/widgets/step_indicator.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Barra de progresso do wizard: [current] de [total] (1-based).
class StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const StepIndicator({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final done = i < current;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: done
                  ? AppColors.primary
                  : AppColors.gray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
