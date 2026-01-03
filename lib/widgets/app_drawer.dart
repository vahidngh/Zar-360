import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zar360/theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../pages/login_page.dart';
import '../pages/product_management_page.dart';
import '../pages/notifications_page.dart';
import '../pages/support_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Header با اطلاعات کاربر
          Container(
            height: 170,
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/menu_background.png'),
                fit: BoxFit.cover,
              ),
              color: const Color(0xFF4A4A4A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اطلاعات کاربر (راست)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Image.asset(
                                'assets/images/maaher.png',
                                height: 55,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          //   decoration: BoxDecoration(
                          //     color: const Color(0xFFD4AF37),
                          //     borderRadius: BorderRadius.circular(50),
                          //   ),
                          //   child: const Text(
                          //     'اشتراک ویژه',
                          //     style: TextStyle(
                          //       fontFamily: 'Iranyekan',
                          //       fontSize: 12,
                          //       fontWeight: FontWeight.bold,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<String?>(
                        future: StorageService.getMobile(),
                        builder: (context, snapshot) {

                          final userName = snapshot.data ?? '';
                          return Text(
                            userName,
                            style: const TextStyle(
                              fontFamily: 'Iranyekan',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.3,
                            ),
                            textDirection: TextDirection.ltr,
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<String?>(
                        future: StorageService.getUserName(),
                        builder: (context, snapshot) {
                          final mobile = snapshot.data ?? '';
                          return Text(
                            mobile,
                            style: const TextStyle(
                              fontFamily: 'Iranyekan',
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // منوها
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildMenuItem(
                    context,
                    icon: 'assets/images/campaign.png',
                    title: 'اعلانات',
                    isHighlighted: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  // _buildMenuItem(
                  //   context,
                  //   icon: 'assets/images/table_chart_view.png',
                  //   title: 'گزارش فروش',
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                  // const SizedBox(height: 8),
                  _buildMenuItem(
                    context,
                    icon: 'assets/images/add_business.png',
                    title: 'مدیریت محصولات',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductManagementPage(),
                        ),
                      );
                    },
                  ),
                  Divider(
                    height: 32,
                    color: const Color(0xFFE9E9EA),
                    thickness: 1,
                  ),
                  // _buildMenuItem(
                  //   context,
                  //   icon: 'assets/images/settings.png',
                  //   title: 'تنظیمات',
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                  // const SizedBox(height: 8),
                  _buildMenuItem(
                    context,
                    icon: 'assets/images/call.png',
                    title: 'تماس با پشتیبانی',
                    iconSize: 20,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SupportPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context,
                    icon: 'assets/images/logout.png',
                    title: 'خروج',
                    isLogout: true,
                    iconSize: 20,
                    onTap: () async {
                      // بررسی اینکه آیا سبد خرید خالی است یا نه (قبل از بستن drawer)
                      bool hasItems = false;
                      try {
                        final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
                        hasItems = !cartViewModel.isEmpty;
                      } catch (e) {
                        debugPrint('خطا در بررسی سبد خرید: $e');
                      }
                      
                      // بستن drawer قبل از نمایش دیالوگ
                      Navigator.pop(context);
                      
                      // نمایش دیالوگ تایید برای خروج
                      if (!context.mounted) return;
                      
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text(
                            'تأیید خروج',
                            style: TextStyle(
                              fontFamily: 'Iranyekan',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            hasItems
                                ? 'با خروج از حساب کاربری، تمام اطلاعات سبد خرید شما پاک خواهد شد. آیا مطمئن هستید که می‌خواهید خارج شوید؟'
                                : 'آیا مطمئن هستید که می‌خواهید از حساب کاربری خود خارج شوید؟',
                            style: const TextStyle(
                              fontFamily: 'Iranyekan',
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(false),
                              child: const Text(
                                'انصراف',
                                style: TextStyle(
                                  fontFamily: 'Iranyekan',
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(dialogContext).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'خروج',
                                style: TextStyle(
                                  fontFamily: 'Iranyekan',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                      
                      // اگر کاربر تایید نکرد، از متد خارج شو
                      if (confirmed != true) {
                        return;
                      }
                      
                      // دریافت توکن و فراخوانی سرویس logout (بدون وابستگی به نتیجه)
                      final accessToken = await StorageService.getAccessToken();
                      if (accessToken != null && accessToken.isNotEmpty) {
                        try {
                          final authService = AuthService();
                          await authService.logout(accessToken);
                        } catch (e) {
                          // حتی در صورت خطا، ادامه می‌دهیم
                          debugPrint('خطا در فراخوانی سرویس logout: $e');
                        }
                      }

                      // استفاده از forceLogout که همه کارها را انجام می‌دهد
                      // و از navigatorKey برای navigation استفاده می‌کند
                      await StorageService.forceLogout();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isHighlighted = false,
    bool isLogout = false,
    double? iconSize,
  }) {
    final double finalIconSize = iconSize ?? 24;
    return Container(
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFEDEBDF) : Colors.transparent,
        borderRadius: BorderRadius.circular(50),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: SizedBox(
          width: finalIconSize,
          height: finalIconSize,
          child: Image.asset(
            icon,
            width: finalIconSize,
            height: finalIconSize,
            fit: BoxFit.contain,
            color: isLogout ? AppColors.error : AppColors.iconBrown,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Iranyekan',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isLogout ? AppColors.error : AppColors.textPrimaryAlt,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

