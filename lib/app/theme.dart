import 'package:flutter/material.dart';

class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF5C4033), // 深棕
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  static const colors = _AppColors();
}

class _AppColors {
  const _AppColors();

  Color get wood => const Color(0xFF4CAF50);
  Color get fire => const Color(0xFFE53935);
  Color get earth => const Color(0xFFFF8F00);
  Color get metal => const Color(0xFF9E9E9E);
  Color get water => const Color(0xFF2196F3);

  Color forElement(String element) {
    switch (element) {
      case '木': return wood;
      case '火': return fire;
      case '土': return earth;
      case '金': return metal;
      case '水': return water;
      default: return Colors.grey;
    }
  }

  Color forTiYong(String relation) {
    switch (relation) {
      case '用生体': return const Color(0xFF2E7D32); // 深绿-大吉
      case '体用比和': return const Color(0xFF1565C0); // 深蓝-吉
      case '体克用': return const Color(0xFFF9A825); // 黄-小吉
      case '体生用': return const Color(0xFFE65100); // 橙-小凶
      case '用克体': return const Color(0xFFC62828); // 红-大凶
      default: return Colors.grey;
    }
  }
}
