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
          secondary: const Color(0xFFC0C0C0), // نقره‌ای
          surface: const Color(0xFFF8F8F8), // خاکستری روشن
          background: const Color(0xFFFFFFFF), // سفید
          error: const Color(0xFFB71C1C), // قرمز تیره
        ),
        useMaterial3: true,
        fontFamily: 'Vazir',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF1A1A1A), // مشکی تیره
          foregroundColor: Color(0xFFD4AF37), // طلایی
        ),
        cardTheme: CardTheme(
          elevation: 8,
          shadowColor: const Color(0xFFD4AF37).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: const Color(0xFF1A1A1A),
            elevation: 4,
            shadowColor: const Color(0xFFD4AF37).withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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