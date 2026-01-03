import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:zar360/services/database_service.dart';
import 'package:zar360/main.dart';
import 'package:zar360/pages/login_page.dart';

class StorageService {
  static const String _keyAccessToken = 'access_token';
  static const String _keyMobile = 'mobile';
  static const String _keyUserName = 'user_name';

  // ذخیره Access Token
  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, token);
  }

  // دریافت Access Token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  // حذف Access Token
  static Future<void> removeAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
  }

  // ذخیره شماره موبایل
  static Future<void> saveMobile(String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMobile, mobile);
  }

  // دریافت شماره موبایل
  static Future<String?> getMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMobile);
  }

  // ذخیره نام کاربر
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }

  // دریافت نام کاربر
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  // حذف تمام اطلاعات لاگین
  static Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyMobile);
    await prefs.remove(_keyUserName);
  }

  // حذف کامل تمام داده‌های کاربر (پاک کردن تمام SharedPreferences)
  static Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // چک کردن اینکه آیا کاربر لاگین کرده است یا نه
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Force Logout - پاک کردن تمام اطلاعات و هدایت به صفحه لاگین
  static Future<void> forceLogout() async {
    try {
      debugPrint('🔒 [StorageService] شروع forceLogout...');
      
      // پاک کردن سبد خرید و metadata از دیتابیس
      try {
        final databaseService = DatabaseService();
        await databaseService.clearCartItems();
        await databaseService.clearCartMetadata();
        await databaseService.deleteAllData();
        debugPrint('✅ [StorageService] دیتابیس پاک شد');
      } catch (e) {
        debugPrint('⚠️ [StorageService] خطا در پاک کردن دیتابیس: $e');
      }
      
      // پاک کردن تمام اطلاعات از SharedPreferences
      await clearAllUserData();
      debugPrint('✅ [StorageService] تمام اطلاعات کاربر از SharedPreferences پاک شد');
      
      // هدایت کاربر به صفحه لاگین با استفاده از navigatorKey
      // استفاده از Future.microtask برای اطمینان از اینکه navigation بعد از تمام async operations انجام شود
      Future.microtask(() {
        try {
          final navigator = navigatorKey.currentState;
          if (navigator != null) {
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
            debugPrint('✅ [StorageService] کاربر به صفحه لاگین هدایت شد');
          } else {
            debugPrint('⚠️ [StorageService] Navigator در دسترس نیست');
          }
        } catch (e) {
          debugPrint('❌ [StorageService] خطا در هدایت به صفحه لاگین: $e');
        }
      });
    } catch (e) {
      debugPrint('❌ [StorageService] خطا در forceLogout: $e');
      // حتی در صورت خطا، سعی کنیم به صفحه لاگین هدایت کنیم
      Future.microtask(() {
        try {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        } catch (e2) {
          debugPrint('❌ [StorageService] خطا در fallback navigation: $e2');
        }
      });
    }
  }
}

