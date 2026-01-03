import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  final TextEditingController mobileController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  Future<bool> sendOtp() async {
    final mobileText = _persianToEnglish(mobileController.text.trim());
    
    if (mobileText.isEmpty) {
      _errorMessage = 'لطفا شماره موبایل را وارد کنید';
      notifyListeners();
      return false;
    }

    if (!_isValidMobile(mobileText)) {
      _errorMessage = 'فرمت شماره موبایل نامعتبر است';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.sendOtp(mobileText);
      
      _isLoading = false;
      
      if (response.isSuccess) {
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errors.isNotEmpty 
            ? response.errors.first 
            : 'خطا در ارسال کد تایید';
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

  bool _isValidMobile(String mobile) {
    // بررسی فرمت شماره موبایل ایرانی (09xxxxxxxxx)
    final regex = RegExp(r'^09\d{9}$');
    return regex.hasMatch(mobile);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }
}

