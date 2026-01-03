import 'package:flutter/material.dart';
import 'package:zar360/theme/app_theme.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// ویجت لودینگ شیک با SpinKitFoldingCube
class AppLoadingWidget extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoadingWidget({
    super.key,
    this.size = 50.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? AppColors.gold;
    return SpinKitFoldingCube(
      color: color,
      size: size,
    );
  }
}

/// ویجت لودینگ ساده برای استفاده در دکمه‌ها و جاهای کوچک
class AppSmallLoadingWidget extends StatelessWidget {
  final double size;
  final Color? color;

  const AppSmallLoadingWidget({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? AppColors.gold;
    return SpinKitFoldingCube(
      color: color,
      size: size,
    );
  }
}
