import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Psi Circle brand — white, red, black always visible together.
class PsiColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color red = Color(0xFFE31C23);
  static const Color redDark = Color(0xFFB8141A);
  static const Color black = Color(0xFF111111);
  static const Color muted = Color(0xFF5C5C5C);
}

/// Signature control: red fill, black border, white label.
class PsiButtons {
  static const BorderSide border = BorderSide(color: PsiColors.black, width: 2);

  static ButtonStyle filled({Size minimumSize = const Size(64, 48)}) {
    return FilledButton.styleFrom(
      backgroundColor: PsiColors.red,
      foregroundColor: PsiColors.white,
      disabledBackgroundColor: PsiColors.red.withValues(alpha: 0.4),
      disabledForegroundColor: PsiColors.white,
      minimumSize: minimumSize,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: border,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
    );
  }

  /// Inverse of [filled]: white fill, black border, red label.
  static ButtonStyle outlined({Size minimumSize = const Size(64, 48)}) {
    return OutlinedButton.styleFrom(
      backgroundColor: PsiColors.white,
      foregroundColor: PsiColors.red,
      minimumSize: minimumSize,
      side: border,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
    );
  }

  static ButtonStyle compact() => filled(minimumSize: const Size(72, 40));
}

class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: PsiColors.red,
      onPrimary: PsiColors.white,
      primaryContainer: PsiColors.red,
      onPrimaryContainer: PsiColors.white,
      secondary: PsiColors.black,
      onSecondary: PsiColors.white,
      secondaryContainer: PsiColors.white,
      onSecondaryContainer: PsiColors.black,
      tertiary: PsiColors.black,
      onTertiary: PsiColors.white,
      error: PsiColors.redDark,
      onError: PsiColors.white,
      surface: PsiColors.white,
      onSurface: PsiColors.black,
      onSurfaceVariant: PsiColors.muted,
      outline: PsiColors.black,
      outlineVariant: PsiColors.black,
      surfaceContainerHighest: PsiColors.offWhite,
      inverseSurface: PsiColors.black,
      onInverseSurface: PsiColors.white,
      inversePrimary: PsiColors.red,
      shadow: Colors.black26,
      scrim: Colors.black54,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: PsiColors.white,
      dividerColor: PsiColors.black,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: PsiColors.white,
        foregroundColor: PsiColors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: PsiColors.black,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: PsiColors.black),
      ),
      cardTheme: CardThemeData(
        color: PsiColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: PsiColors.black, width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PsiColors.white,
        labelStyle: const TextStyle(
          color: PsiColors.black,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: PsiButtons.border,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: PsiColors.red, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: PsiButtons.filled()),
      outlinedButtonTheme: OutlinedButtonThemeData(style: PsiButtons.outlined()),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PsiColors.red,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: PsiColors.white,
        selectedColor: PsiColors.red,
        checkmarkColor: PsiColors.white,
        labelStyle: const TextStyle(
          color: PsiColors.black,
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: const TextStyle(
          color: PsiColors.white,
          fontWeight: FontWeight.w700,
        ),
        side: PsiButtons.border,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return PsiColors.white;
          return PsiColors.black;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return PsiColors.red;
          return PsiColors.white;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(PsiColors.black),
        trackOutlineWidth: const WidgetStatePropertyAll(2),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: PsiColors.red,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: PsiColors.black,
        contentTextStyle: TextStyle(color: PsiColors.white),
        actionTextColor: PsiColors.red,
      ),
    );
  }
}
