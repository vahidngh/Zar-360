import 'package:flutter/material.dart';
import 'package:zar360/theme/app_theme.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/storage_service.dart';
import 'login_page.dart';
import 'main_navigation_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // کمی تاخیر برای نمایش splash screen
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    final isLoggedIn = await StorageService.isLoggedIn();
    
    if (!mounted) return;
    
    if (isLoggedIn) {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainNavigationPage(accessToken: accessToken),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // لوگو zar360
            Image.asset(
              'assets/images/maaher.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            // لودینگ FoldingCube
            const SpinKitFoldingCube(
              color: AppColors.gold,
              size: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}

