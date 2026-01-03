import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zar360/theme/app_theme.dart';
import '../viewmodels/login_viewmodel.dart';
import '../widgets/app_loading_widget.dart';
import 'otp_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: const _LoginPageContent(),
    );
  }
}

class _LoginPageContent extends StatelessWidget {
  const _LoginPageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo
                            Center(
                              child: Image.asset(
                                // 'assets/images/zar360.png',
                                'assets/images/maaher.png',
                                width: 190,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Title
                            const Text(
                              'ورود',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Iranyekan',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.titleBrown,
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Mobile Input
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.dividerSoft,
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: viewModel.mobileController,
                                keyboardType: TextInputType.phone,
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.right,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[۰-۹0-9]')),
                                ],
                                style: const TextStyle(
                                  fontFamily: 'Iranyekan',
                                  fontSize: 16,
                                  color: AppColors.titleBrown,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'شماره موبایل',
                                  hintStyle: const TextStyle(
                                    fontFamily: 'Iranyekan',
                                    fontSize: 16,
                                    color: AppColors.textMuted,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                onChanged: (_) {
                                  viewModel.clearError();
                                },
                              ),
                            ),
                            
                            // Error Message
                            if (viewModel.errorMessage != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                viewModel.errorMessage!,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontFamily: 'Iranyekan',
                                  fontSize: 14,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 24),
                            
                            // Login Button
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: viewModel.isLoading
                                    ? null
                                    : () async {
                                        final success = await viewModel.sendOtp();
                                        if (success && context.mounted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => OtpPage(
                                                mobile: viewModel.mobileController.text.trim(),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gold,
                                  foregroundColor: AppColors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: viewModel.isLoading
                                    ? const AppSmallLoadingWidget(
                                        size: 24,
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'ورود',
                                        style: TextStyle(
                                          fontFamily: 'Iranyekan',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Powered by text - بیرون از کارت
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: const Text(
                    'قدرت گرفته از زر۳۶۰',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Iranyekan',
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

