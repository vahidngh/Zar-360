import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class OtpViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  final List<TextEditingController> otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  
  final List<FocusNode> focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  String? _errorMessage;
  int _resendTimer = 119;
  Timer? _timer;
  bool _canResend = false;
  String? _accessToken;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get resendTimer => _resendTimer;
  bool get canResend => _canResend;
  String? get accessToken => _accessToken;

  OtpViewModel() {
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _resendTimer = 119;
    notifyListeners();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        _resendTimer--;
        notifyListeners();
      } else {
        _canResend = true;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  // تبدیل اعداد فارسی به انگلیسی
  String _persianToEnglish(String text) {
    return text
        .replaceAll('۰', '0')
        .replaceAll('۱', '1')
        .replaceAll('۲', '2')
        .replaceAll('۳', '3')
        .replaceAll('۴', '4')
        .replaceAll('۵', '5')
        .replaceAll('۶', '6')
        .replaceAll('۷', '7')
        .replaceAll('۸', '8')
        .replaceAll('۹', '9');
  }

  Future<bool> verifyOtp(String mobile) async {
    final otp = _persianToEnglish(otpControllers.map((controller) => controller.text).join());
    
    if (otp.length != 4) {
      _errorMessage = 'لطفا کد تایید را کامل وارد کنید';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.verifyOtp(mobile, otp);
      
      _isLoading = false;
      
      if (response.isSuccess) {
        _accessToken = response.accessToken;
        
        // ذخیره access token، mobile و نام کاربر در SharedPreferences
        if (_accessToken != null) {
          await StorageService.saveAccessToken(_accessToken!);
          if (response.seller != null) {
            await StorageService.saveMobile(response.seller!.mobile);
            await StorageService.saveUserName(response.seller!.name);
          } else {
            // Fallback: استفاده از mobile که کاربر وارد کرده
            await StorageService.saveMobile(mobile);
          }
        }
        
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errors.isNotEmpty 
            ? response.errors.first 
            : 'کد تایید نامعتبر است';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'خطا در ارتباط با سرور';
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendOtp(String mobile) async {
    if (!_canResend) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.sendOtp(mobile);
      
      _isLoading = false;
      
      if (response.isSuccess) {
        // پاک کردن فیلدهای OTP
        for (var controller in otpControllers) {
          controller.clear();
        }
        focusNodes[0].requestFocus();
        
        // شروع تایمر مجدد
        _startTimer();
        
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errors.isNotEmpty 
            ? response.errors.first 
            : 'خطا در ارسال مجدد کد تایید';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'خطا در ارتباط با سرور';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  VoidCallback? _onOtpComplete;

  // تنظیم callback برای زمانی که OTP کامل می‌شود
  void setOtpCompleteCallback(VoidCallback callback) {
    _onOtpComplete = callback;
  }

  void onOtpChanged(int index, String value, BuildContext? context) {
    if (value.length == 1 && index < 3) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    
    // بررسی اینکه آیا همه فیلدها پر شده‌اند (رقم آخر وارد شده)
    if (value.length == 1 && index == 3) {
      // تأخیر کوتاه برای اطمینان از اینکه مقدار در controller ذخیره شده است
      Future.delayed(const Duration(milliseconds: 150), () {
        // بررسی مجدد اینکه همه 4 فیلد پر هستند
        final allFilled = otpControllers.every((controller) => controller.text.isNotEmpty);
        if (allFilled && _onOtpComplete != null && context != null && context.mounted) {
          _onOtpComplete?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}

