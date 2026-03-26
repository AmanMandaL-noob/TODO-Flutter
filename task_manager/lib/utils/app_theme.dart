// lib/utils/app_theme.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const primary = Color(0xFF6C63FF);
  static const primaryDark = Color(0xFF4A44C6);
  static const primaryLight = Color(0xFFEEEDFF);
  static const accent = Color(0xFFFF6584);

  // Backgrounds
  static const background = Color(0xFFF5F6FA);
  static const surface = Color(0xFFFFFFFF);
  static const cardBg = Color(0xFFFFFFFF);

  // Status colors
  static const todo = Color(0xFF94A3B8);
  static const todoLight = Color(0xFFF1F5F9);
  static const inProgress = Color(0xFF3B82F6);
  static const inProgressLight = Color(0xFFEFF6FF);
  static const done = Color(0xFF22C55E);
  static const doneLight = Color(0xFFF0FDF4);

  // Semantic
  static const overdue = Color(0xFFEF4444);
  static const overdueLight = Color(0xFFFEF2F2);
  static const blocked = Color(0xFFB0B8C1);
  static const blockedBg = Color(0xFFF8F9FA);

  // Text
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const textDisabled = Color(0xFFB0B8C1);
  static const textOnPrimary = Color(0xFFFFFFFF);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        background: AppColors.background,
        surface: AppColors.surface,
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.overdue, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.overdue, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textDisabled),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
      ),
      fontFamily: 'Inter',
    );
  }
}

// ── Status helpers ──────────────────────────────────────────────────────────
extension TaskStatusStyle on String {
  Color get statusColor {
    switch (this) {
      case 'todo':
        return AppColors.todo;
      case 'in_progress':
        return AppColors.inProgress;
      case 'done':
        return AppColors.done;
      default:
        return AppColors.todo;
    }
  }

  Color get statusBgColor {
    switch (this) {
      case 'todo':
        return AppColors.todoLight;
      case 'in_progress':
        return AppColors.inProgressLight;
      case 'done':
        return AppColors.doneLight;
      default:
        return AppColors.todoLight;
    }
  }
}
