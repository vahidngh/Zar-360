import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zar360/theme/app_theme.dart';
import '../viewmodels/otp_viewmodel.dart';
import '../widgets/app_loading_widget.dart';
import '../utils/app_config.dart';
import 'main_navigation_page.dart';

class OtpPage extends StatelessWidget {
  final String mobile;

  const OtpPage({
    super.key,
    required this.mobile,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OtpViewModel(),
      child: _OtpPageContent(mobile: mobile),
    );
  }
}

class _OtpPageContent extends StatefulWidget {
  final String mobile;

  const _OtpPageContent({required this.mobile});

  @override
  State<_OtpPageContent> createState() => _OtpPageContentState();
}

class _OtpPageContentState extends State<_OtpPageContent> {
  bool _callbackSet = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_callbackSet) {
      final viewModel = Provider.of<OtpViewModel>(context);
      // تنظیم callback برای verify خودکار وقتی OTP کامل می‌شود
      viewModel.setOtpCompleteCallback(() async {
        if (!viewModel.isLoading && mounted) {
          final success = await viewModel.verifyOtp(widget.mobile);
          if (success && mounted && viewModel.accessToken != null) {
            // هدایت به صفحه محصولات
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => MainNavigationPage(
                  accessToken: viewModel.accessToken!,
                ),
              ),
              (route) => false,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ورود با موفقیت انجام شد'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            }
          }
        }
      });
      _callbackSet = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<OtpViewModel>(context);

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
                            if (AppConfig.app == App.maaher)
                              Center(
                                child: Image.asset(
                                  AppConfig.getLogoPath(),
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.contain,
                                ),
                              ),

                            if (AppConfig.app == App.zar360)
                              Center(
                                child: Image.asset(
                                  AppConfig.getLogoPath(),
                                  width: 190,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            const SizedBox(height: 24),
                            // Title
                            const Text(
                              'کد تایید دریافتی',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Iranyekan',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.titleBrown,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // OTP Input Fields
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  4,
                                  (index) => SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: TextField(
                                      controller: viewModel.otpControllers[index],
                                      focusNode: viewModel.focusNodes[index],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.ltr,
                                      maxLength: 1,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[۰-۹0-9]')),
                                      ],
                                      style: const TextStyle(
                                        fontFamily: 'Iranyekan',
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.titleBrown,
                                      ),
                                      decoration: InputDecoration(
                                        counterText: '',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(
                                            color: AppColors.dividerSoft,
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(
                                            color: AppColors.dividerSoft,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(
                                            color: AppColors.gold,
                                            width: 2,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      onChanged: (value) {
                                        viewModel.onOtpChanged(index, value, context);
                                        viewModel.clearError();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Timer/Resend Message
                            const SizedBox(height: 16),
                            Consumer<OtpViewModel>(
                              builder: (context, viewModel, child) {
                                return InkWell(
                                  onTap: viewModel.isLoading || !viewModel.canResend
                                      ? null
                                      : () async {
                                          await viewModel.resendOtp(widget.mobile);
                                        },
                                  child: Text(
                                    viewModel.canResend ? 'ارسال مجدد کد' : '(ارسال مجدد کد: ${viewModel.resendTimer} ثانیه)',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Iranyekan',
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                );
                              },
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

                            // Submit Button
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: viewModel.isLoading
                                    ? null
                                    : () async {
                                        final success = await viewModel.verifyOtp(widget.mobile);
                                        if (success && context.mounted && viewModel.accessToken != null) {
                                          // هدایت به صفحه محصولات
                                          Navigator.of(context).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) => MainNavigationPage(
                                                accessToken: viewModel.accessToken!,
                                              ),
                                            ),
                                            (route) => false,
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('ورود با موفقیت انجام شد'),
                                              backgroundColor: Color(0xFF10B981),
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
                                        'ثبت کد تایید',
                                        style: TextStyle(
                                          fontFamily: 'Iranyekan',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),

                            // Resend Button
                            // SizedBox(
                            //   height: 56,
                            //   child: OutlinedButton(
                            //     onPressed: viewModel.isLoading || !viewModel.canResend
                            //         ? null
                            //         : () async {
                            //             await viewModel.resendOtp(mobile);
                            //           },
                            //     style: OutlinedButton.styleFrom(
                            //       side: const BorderSide(
                            //         color: Color(0xFFE5E7EB),
                            //         width: 1,
                            //       ),
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(16),
                            //       ),
                            //     ),
                            //     child: const Text(
                            //       'ارسال مجدد کد',
                            //       style: TextStyle(
                            //         fontFamily: 'Iranyekan',
                            //         fontSize: 16,
                            //         fontWeight: FontWeight.w500,
                            //         color: Color(0xFF6B7280),
                            //       ),
                            //     ),
                            //   ),
                            // ),
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
