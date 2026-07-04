// lib/src/widgets/app_scaffold.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Scaffold padrão: fundo escuro + AppBar transparente.
class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? leading;
  final PreferredSizeWidget? appBarBottom;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.leading,
    this.appBarBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              leading: leading,
              actions: actions,
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.text,
              elevation: 0,
              bottom: appBarBottom,
            ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
