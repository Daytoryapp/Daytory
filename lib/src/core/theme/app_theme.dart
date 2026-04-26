import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // ── v2.0 색상 토큰 (웜톤 핑크 팔레트) ─────────────────────────────────────
  static const Color _pink          = Color(0xFFFF5A8A); // 로즈핑크 (기존 #FF4D8D → 덜 형광)
  static const Color _pinkLight     = Color(0xFFFFEAF2); // 연핑크 배경
  static const Color _pinkMid       = Color(0xFFFFCEDF); // 중간톤
  static const Color _surface       = Color(0xFFF8F5F2); // 크림베이지 (기존 #F6F6F9 웜톤)
  static const Color _white         = Color(0xFFFFFFFF);
  static const Color _textPrimary   = Color(0xFF1E1A1D); // 따뜻한 블랙
  static const Color _textSecondary = Color(0xFF9A8E96); // 따뜻한 그레이
  static const Color _textHint      = Color(0xFFBFB5BB); // placeholder
  static const Color _border        = Color(0xFFEDEAEC);
  static const Color _error         = Color(0xFFFF4040);

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
          error: _error,
        ),
        scaffoldBackgroundColor: _white,

        // ── AppBar ──────────────────────────────────────────────────────────
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

        // ── Card ────────────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          elevation: 0,
          color: _white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _border),
          ),
          margin: EdgeInsets.zero,
        ),

        // ── InputDecoration ─────────────────────────────────────────────────
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
            borderSide: const BorderSide(color: _error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _error, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: const TextStyle(color: _textSecondary, fontSize: 14),
          floatingLabelStyle: const TextStyle(color: _pink, fontSize: 13),
          hintStyle: const TextStyle(color: _textHint, fontSize: 14),
        ),

        // ── FilledButton ────────────────────────────────────────────────────
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _pink,
            foregroundColor: _white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2),
            elevation: 0,
          ),
        ),

        // ── OutlinedButton ──────────────────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _textSecondary,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: const BorderSide(color: _border),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),

        // ── NavigationBar ───────────────────────────────────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _white,
          elevation: 0,
          height: 64,
          indicatorColor: _pinkLight,
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

        // ── Chip ────────────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: _surface,
          selectedColor: _pinkLight,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _textPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),

        // ── Slider ──────────────────────────────────────────────────────────
        sliderTheme: SliderThemeData(
          activeTrackColor: _pink,
          thumbColor: _pink,
          inactiveTrackColor: _pinkMid,
          overlayColor: _pink.withAlpha(26), // 0x1A
        ),

        // ── Divider ─────────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: Color(0xFFF2EEF0), // divider
          space: 1,
          thickness: 1,
        ),

        // ── SnackBar ─────────────────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _textPrimary,
          contentTextStyle: const TextStyle(color: _white, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),

        // ── BottomSheet ──────────────────────────────────────────────────────
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: _white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          elevation: 0,
        ),

        // ── Dialog ───────────────────────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: _white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          titleTextStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: -0.3,
          ),
          contentTextStyle: const TextStyle(
            fontSize: 14,
            color: _textSecondary,
            height: 1.5,
          ),
        ),

        // ── TextTheme ────────────────────────────────────────────────────────
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _textPrimary, letterSpacing: -0.8),
          headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _textPrimary, letterSpacing: -0.5),
          titleLarge:    TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textPrimary, letterSpacing: -0.3),
          titleMedium:   TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary),
          titleSmall:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary),
          bodyLarge:     TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textPrimary, height: 1.6),
          bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: _textSecondary, height: 1.5),
          bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: _textSecondary, height: 1.4),
          labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _textPrimary),
          labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _textSecondary, letterSpacing: 0.2),
        ),
      );
}
