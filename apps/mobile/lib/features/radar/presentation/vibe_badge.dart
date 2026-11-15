import 'package:flutter/material.dart';

import '../../../core/models/vibe.dart';
import '../../../core/theme/app_theme.dart';

/// Small mark drawn on an avatar. The word sits beside it, not inside it.
class VibeBadge extends StatelessWidget {
  const VibeBadge({super.key, required this.vibe, this.size = 22});

  final Vibe vibe;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: vibe.label,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: PsiColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: PsiColors.red, width: 1.5),
        ),
        child: Icon(_icon, size: size * 0.62, color: PsiColors.black),
      ),
    );
  }

  IconData get _icon => switch (vibe) {
        Vibe.ngopi => Icons.coffee,
        Vibe.diskusi => Icons.forum,
        Vibe.kegiatan => Icons.celebration,
        Vibe.openToSayHi => Icons.waving_hand,
      };
}
