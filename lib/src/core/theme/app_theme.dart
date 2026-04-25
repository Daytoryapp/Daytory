import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color _pink = Color(0xFFFF4D8D);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8A8A9A);
  static const Color _surface = Color(0xFFF6F6F9);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _border = Color(0xFFEEEEF2);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _pink,
          brightness: Brightness.light,
          surface: _white,
        ).copyWith(
          primary: _pink,
          surface: _white,
          surfaceContainerLow: _surface,
          surfaceContainerHighest: _surface,
          onSurface: _textPrimary,
          onSurfaceVariant: _textSecondary,
          outline: _border,
        ),
        scaffoldBackgroundColor: _white,
        appBarTheme: const AppBarTheme(
          backgroundColor: _white,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          iconTheme: IconThemeData(color: _textPrimary),
          titleTextStyle: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: _white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _border),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _pink, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: const TextStyle(color: _textSecondary, fontSize: 14),
          floatingLabelStyle: const TextStyle(color: _pink, fontSize: 13),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _pink,
            foregroundColor: _white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            elevation: 0,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _white,
          elevation: 0,
          height: 64,
          indicatorColor: const Color(0xFFFFE4EF),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: _pink, size: 22);
            }
            return const IconThemeData(color: _textSecondary, size: 22);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _pink);
            }
            return const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: _textSecondary);
          }),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: _surface,
          selectedColor: const Color(0xFFFFE4EF),
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _textPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: _pink,
          thumbColor: _pink,
          inactiveTrackColor: Color(0xFFFFD6E7),
          overlayColor: Color(0x1AFF4D8D),
        ),
        dividerTheme: const DividerThemeData(color: _border, space: 1, thickness: 1),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _textPrimary,
          contentTextStyle: const TextStyle(color: _white, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _textPrimary, letterSpacing: -0.8),
          headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _textPrimary, letterSpacing: -0.5),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textPrimary, letterSpacing: -0.3),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary),
          titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary),
          bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textPrimary, height: 1.5),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: _textSecondary, height: 1.5),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: _textSecondary, height: 1.4),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _textPrimary),
          labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _textSecondary, letterSpacing: 0.2),
        ),
      );
}
