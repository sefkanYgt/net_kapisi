import 'package:flutter/material.dart';

/// Soft Pastel - Sky Blue & Peach
class AppColors {
  static const bgTop = Color(0xFFF0F9FF);
  static const bgBottom = Color(0xFFE0F2FE);

  static const peach = Color(0xFFFB923C);
  static const peachLight = Color(0xFFFDBA74);
  static const peachSoft = Color(0xFFFFEDD5);

  static const blue = Color(0xFF60A5FA);
  static const blueSoft = Color(0xFFDBEAFE);

  static const textDark = Color(0xFF1E293B);
  static const textSoft = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);

  static const background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgBottom],
  );

  static const accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [peachLight, blue],
  );

  static const softShadow = [
    BoxShadow(color: Color(0x14607D8B), blurRadius: 15, spreadRadius: 2),
  ];
}

/// Gökyüzü mavisi gradient arka planlı Scaffold.
class GradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  const GradientScaffold({super.key, this.appBar, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.background),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
      ),
    );
  }
}

class AppTheme {
  static OutlineInputBorder _outline(Color c, [double w = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: c, width: w),
      );

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.peach,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.peach,
      onPrimary: Colors.white,
      primaryContainer: AppColors.peachSoft,
      onPrimaryContainer: const Color(0xFF9A3412),
      secondary: AppColors.blue,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.blueSoft,
      onSecondaryContainer: const Color(0xFF1E3A8A),
      tertiary: AppColors.blue,
      surface: Colors.white,
      onSurface: AppColors.textDark,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Colors.white,
      surfaceContainer: Colors.white,
      surfaceContainerHigh: Colors.white,
      surfaceContainerHighest: const Color(0xFFF1F5F9),
      outline: AppColors.textSoft,
      outlineVariant: AppColors.border,
      error: const Color(0xFFEF4444),
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgTop,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textDark,
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x33607D8B),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: AppColors.textSoft),
        border: _outline(AppColors.border),
        enabledBorder: _outline(AppColors.border),
        disabledBorder: _outline(AppColors.border),
        focusedBorder: _outline(AppColors.peach, 1.8),
        errorBorder: _outline(const Color(0xFFEF4444)),
        focusedErrorBorder: _outline(const Color(0xFFEF4444), 1.8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle:
          const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textDark,
          side: const BorderSide(color: AppColors.peachLight),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.peachSoft,
          selectedForegroundColor: const Color(0xFF9A3412),
          side: const BorderSide(color: AppColors.peachLight),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.peach,
        linearTrackColor: AppColors.peachSoft,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textDark,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}