import 'package:flutter/material.dart';

/// رنگ‌ها و استایل‌های اصلی برند زر۳۶۰
class AppColors {
  // طلایی برند
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldDark = Color(0xFFB8860B);

  // پس‌زمینه‌ها
  static const Color background = Color(0xFFF9FAFB);
  static const Color backgroundAlt = Color(0xFFF9FBFF);
  static const Color cardSoft = Color(0xFFFCFBF6);

  // متن‌ها
  static const Color textPrimary = Color(0xFF111827);
  static const Color textPrimaryAlt = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // آیکن‌ها و رنگ‌های تکمیلی
  static const Color iconBrown = Color(0xFF9B7A47);
  static const Color titleBrown = Color(0xFF8B6914);

  // خط و حاشیه
  static const Color dividerSoft = Color(0xFFE5E7EB);
  static const Color borderSoft = Color(0xFFD1D4DB);
  static const Color appBarDivider = Color(0xFFE0E2E9);

  // خطا و وضعیت‌ها
  static const Color error = Color(0xFFEF4444);

  // سایر
  static const Color white = Color(0xFFFFFFFF);
}

/// گرادیانت‌های برند – همه بر پایه طلایی
class AppGradients {
  /// گرادیانت اصلی طلایی (مورب)
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.gold, AppColors.goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// گرادیانت طلایی افقی
  static const LinearGradient primaryHorizontal = LinearGradient(
    colors: [AppColors.gold, AppColors.goldDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// گرادیانت طلایی عمودی
  static const LinearGradient primaryVertical = LinearGradient(
    colors: [AppColors.gold, AppColors.goldDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// گرادیانت ملایم برای تب‌ها/چیپ‌ها (کرم-طلایی)
  static const LinearGradient softGoldChip = LinearGradient(
    colors: [Color(0xFFFEE8C8), Color(0xFFD1AA31)],
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
  );

  /// گرادیانت ملایم دایره‌ای (برای آیکن‌های گرد مانند افزودن به سبد)
  static const LinearGradient softGoldCircle = LinearGradient(
    colors: [Color(0xFFD1AA31), Color(0xFFFEE8C8)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

/// سایه‌های متداول در طراحی
class AppShadows {
  /// سایه نرم رو به پایین (برای کارت‌ها)
  static BoxShadow softDown(Color color, {double opacity = 0.08}) {
    return BoxShadow(
      color: color.withOpacity(opacity),
      blurRadius: 8,
      offset: const Offset(0, 2),
    );
  }

  /// سایه نوار پایین
  static const BoxShadow bottomNav = BoxShadow(
    color: Colors.black26,
    blurRadius: 10,
    offset: Offset(0, -2),
  );
}


