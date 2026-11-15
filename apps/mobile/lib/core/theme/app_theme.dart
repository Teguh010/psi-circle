import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Psi Circle brand palette — clean white / red / black.
class PsiColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color red = Color(0xFFE31C23);
  static const Color redDark = Color(0xFFB8141A);
  static const Color redSoft = Color(0xFFFFEBEC);
  static const Color black = Color(0xFF111111);
  static const Color charcoal = Color(0xFF2A2A2A);
  static const Color muted = Color(0xFF6B6B6B);
  static const Color line = Color(0xFFE5E5E5);
}

class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: PsiColors.red,
      onPrimary: PsiColors.white,
      primaryContainer: PsiColors.redSoft,
      onPrimaryContainer: PsiColors.redDark,
      secondary: PsiColors.black,
      onSecondary: PsiColors.white,
      secondaryContainer: Color(0xFFF0F0F0),
      onSecondaryContainer: PsiColors.black,
      tertiary: PsiColors.charcoal,
      onTertiary: PsiColors.white,
      error: PsiColors.redDark,
      onError: PsiColors.white,
      surface: PsiColors.white,
      onSurface: PsiColors.black,
      onSurfaceVariant: PsiColors.muted,
      outline: PsiColors.muted,
      outlineVariant: PsiColors.line,
      surfaceContainerHighest: PsiColors.offWhite,
      inverseSurface: PsiColors.black,
      onInverseSurface: PsiColors.white,
      inversePrimary: Color(0xFFFF8A8E),
      shadow: Colors.black26,
      scrim: Colors.black54,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: PsiColors.white,
      dividerColor: PsiColors.line,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: PsiColors.white,
        foregroundColor: PsiColors.black,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: PsiColors.white,
        indicatorColor: PsiColors.redSoft,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? PsiColors.red : PsiColors.muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? PsiColors.red : PsiColors.muted,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: PsiColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: PsiColors.line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PsiColors.offWhite,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PsiColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PsiColors.red, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PsiColors.red,
          foregroundColor: PsiColors.white,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PsiColors.black,
          minimumSize: const Size(64, 48),
          side: const BorderSide(color: PsiColors.black, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: PsiColors.red),
      ),
      chipTheme: ChipThemeData(
        selectedColor: PsiColors.redSoft,
        checkmarkColor: PsiColors.red,
        labelStyle: const TextStyle(color: PsiColors.black),
        side: const BorderSide(color: PsiColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return PsiColors.white;
          return PsiColors.muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return PsiColors.red;
          return PsiColors.line;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: PsiColors.red,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: PsiColors.red,
        foregroundColor: PsiColors.white,
      ),
    );
  }
}
