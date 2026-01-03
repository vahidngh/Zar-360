import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zar360/pages/splash_screen.dart';
import 'package:zar360/pages/login_page.dart';
import 'package:zar360/theme/app_theme.dart';

// Global Navigator Key برای دسترسی به Navigator از هر جا
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سیستم طراحی زر۳۶۰',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.gold, // طلایی
          brightness: Brightness.light,
          primary: AppColors.gold, // طلایی اصلی
          secondary: AppColors.textSecondary, // خاکستری متوسط
          surface: AppColors.white, // سفید
          background: AppColors.background, // خاکستری خیلی روشن
          error: AppColors.error, // قرمز روشن
          onPrimary: AppColors.white,
          onSecondary: AppColors.white,
          onSurface: AppColors.textPrimary, // مشکی
          onBackground: AppColors.textPrimary, // مشکی
        ),
        useMaterial3: true,
        fontFamily: 'Iranyekan',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          titleTextStyle: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: AppColors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Iranyekan',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: AppColors.textPrimary,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: AppColors.textPrimary,
          ),
          displaySmall: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: AppColors.textPrimary,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColors.textPrimary,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          titleSmall: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.normal,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.normal,
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fa', 'IR'), // Persian Iran
        Locale('en', 'US'), // English US
      ],
      locale: const Locale('fa', 'IR'),
      navigatorKey: navigatorKey,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}