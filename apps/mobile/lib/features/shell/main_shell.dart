import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    (icon: Icons.radar, label: 'Radar'),
    (icon: Icons.groups, label: 'Communities'),
    (icon: Icons.chat_bubble, label: 'Chats'),
    (icon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final onRadar = navigationShell.currentIndex == 0;
    return Scaffold(
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(bottom: onRadar ? 0 : 88),
        child: navigationShell,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 10 + MediaQuery.paddingOf(context).bottom),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: PsiColors.black,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: PsiColors.red, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  _PsiTab(
                    icon: _tabs[i].icon,
                    label: _tabs[i].label,
                    selected: navigationShell.currentIndex == i,
                    onTap: () => navigationShell.goBranch(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PsiTab extends StatelessWidget {
  const _PsiTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: selected ? PsiColors.red : PsiColors.white,
        shape: const CircleBorder(
          side: BorderSide(color: PsiColors.black, width: 1.5),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              icon,
              color: selected ? PsiColors.white : PsiColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
