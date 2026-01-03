import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zar360/theme/app_theme.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // اگر امکان launch نباشد، به clipboard کپی می‌کنیم
      await Clipboard.setData(ClipboardData(text: email));
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      // اگر امکان launch نباشد، به clipboard کپی می‌کنیم
      await Clipboard.setData(ClipboardData(text: phone));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: const Border(
              bottom: BorderSide(
                color: AppColors.appBarDivider,
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE0E7FF).withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: AppBar(
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'تماس با پشتیبانی',
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryAlt,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryAlt),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // کارت اصلی
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gold.withOpacity(0.15),
                    AppColors.gold.withOpacity(0.05),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.gold.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      size: 40,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'شرکت معتمد مالیاتی ماهر',
                    style: TextStyle(
                      fontFamily: 'Iranyekan',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryAlt,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // ایمیل
            _buildContactCard(
              icon: Icons.email_outlined,
              title: 'ایمیل',
              value: 'info@maahertsp.ir',
              onTap: () => _launchEmail('info@maahertsp.ir'),
            ),
            
            const SizedBox(height: 12),
            
            // شماره تماس
            _buildContactCard(
              icon: Icons.phone_outlined,
              title: 'شماره تماس',
              value: '02191002959',
              onTap: () => _launchPhone('02191002959'),
            ),
            
            const SizedBox(height: 12),
            
            // آدرس
            _buildContactCard(
              icon: Icons.location_on_outlined,
              title: 'آدرس',
              value: 'تهران - خیابان ولیعصر - بالاتر از میرداماد - خیابان ثمره (سرو) - پلاک ۶ - طبقه ۴',
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: onTap != null
                        ? AppGradients.primary
                        : null,
                    color: onTap == null
                        ? AppColors.textMuted.withOpacity(0.1)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: onTap != null ? Colors.white : AppColors.textMuted,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryAlt,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_left,
                    color: AppColors.gold,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
