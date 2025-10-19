import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zar360/home.dart';

void main() {
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
          seedColor: const Color(0xFFD4AF37), // طلایی
          brightness: Brightness.light,
          primary: const Color(0xFFD4AF37), // طلایی اصلی
          secondary: const Color(0xFF6B7280), // خاکستری متوسط
          surface: const Color(0xFFFFFFFF), // سفید
          background: const Color(0xFFF9FAFB), // خاکستری خیلی روشن
          error: const Color(0xFFEF4444), // قرمز روشن
          onPrimary: const Color(0xFFFFFFFF),
          onSecondary: const Color(0xFFFFFFFF),
          onSurface: const Color(0xFF111827), // مشکی
          onBackground: const Color(0xFF111827), // مشکی
        ),
        useMaterial3: true,
        fontFamily: 'Iranyekan',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF111827),
          titleTextStyle: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF111827),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: Colors.white,
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
            color: Color(0xFF111827),
          ),
          displayMedium: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Color(0xFF111827),
          ),
          displaySmall: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF111827),
          ),
          headlineLarge: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF111827),
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF111827),
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF111827),
          ),
          titleLarge: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF111827),
          ),
          titleMedium: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF111827),
          ),
          titleSmall: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.normal,
            fontSize: 16,
            color: Color(0xFF111827),
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
          bodySmall: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.normal,
            fontSize: 12,
            color: Color(0xFF9CA3AF),
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
      home: const Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}