import 'package:flutter/material.dart';

import 'app_theme.dart';

/// White bar, black rule, red rule — the three brand colors on every screen.
class PsiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PsiAppBar({super.key, required this.title, this.actions});

  final Widget title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 5);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: actions,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(5),
        child: Column(
          children: [
            SizedBox(
              height: 2,
              width: double.infinity,
              child: ColoredBox(color: PsiColors.black),
            ),
            SizedBox(
              height: 3,
              width: double.infinity,
              child: ColoredBox(color: PsiColors.red),
            ),
          ],
        ),
      ),
    );
  }
}
