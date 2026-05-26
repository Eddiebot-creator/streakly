import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFFF8FAFC);
  static const bg2 = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);
  static const card2 = Color(0xFFF1F5F9);
  static const primary = Color(0xFF4F46E5);
  static const primaryDark = Color(0xFF4338CA);
  static const secondary = Color(0xFF10B981);
  static const accent = Color(0xFFF59E0B);
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);
  static const text = Color(0xFF1E293B);
  static const textStrong = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const hint = Color(0xFF94A3B8);
  static const divider = Color(0xFFE2E8F0);

  static const purple = primary;
  static const purple2 = primaryDark;
  static const cyan = secondary;
  static const green = success;
  static const yellow = accent;
  static const pink = Color(0xFFF472B6);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textStrong,
        error: AppColors.danger,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Inter',
        bodyColor: AppColors.text,
        displayColor: AppColors.textStrong,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.textStrong,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textStrong),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 10,
        indicatorColor: AppColors.primary.withValues(alpha: .12),
        labelTextStyle: WidgetStateProperty.all(const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text)),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
              color: selected ? AppColors.primary : AppColors.muted);
        }),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        selectedIconTheme: IconThemeData(color: AppColors.primary),
        unselectedIconTheme: IconThemeData(color: AppColors.muted),
        selectedLabelTextStyle:
            TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
        unselectedLabelTextStyle:
            TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card2,
        labelStyle: const TextStyle(color: AppColors.muted),
        prefixIconColor: AppColors.muted,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.3)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.card2,
        selectedColor: AppColors.primary.withValues(alpha: .12),
        labelStyle:
            const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textStrong,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get dark => light;
}
