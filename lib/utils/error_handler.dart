import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

/// کلاس مرکزی برای مدیریت و تبدیل خطاهای وب‌سرویس به پیام‌های فارسی
class ErrorHandler {
  /// تبدیل خطا به پیام فارسی مناسب
  static String getFarsiErrorMessage(dynamic error, {int? statusCode}) {
    // اگر status code داریم، ابتدا آن را بررسی می‌کنیم
    if (statusCode != null) {
      final statusMessage = _getStatusCodeMessage(statusCode);
      if (statusMessage != null) {
        return statusMessage;
      }
    }

    // بررسی نوع خطا
    if (error is SocketException) {
      return _handleSocketException(error);
    }

    if (error is HttpException) {
      return _handleHttpException(error);
    }

    if (error is FormatException) {
      return 'خطا در فرمت داده‌های دریافتی از سرور';
    }

    if (error is TimeoutException) {
      return 'زمان اتصال به سرور به پایان رسید. لطفا دوباره تلاش کنید';
    }

    if (error is http.ClientException) {
      return _handleClientException(error);
    }

    // بررسی پیام خطا برای خطاهای رایج شبکه
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('socketexception') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('no address associated with hostname')) {
      return 'امکان اتصال به سرور وجود ندارد. لطفا اتصال اینترنت خود را بررسی کنید';
    }

    if (errorString.contains('timeout') ||
        errorString.contains('timed out')) {
      return 'زمان اتصال به سرور به پایان رسید. لطفا دوباره تلاش کنید';
    }

    if (errorString.contains('connection refused') ||
        errorString.contains('connection reset')) {
      return 'اتصال به سرور برقرار نشد. لطفا دوباره تلاش کنید';
    }

    if (errorString.contains('network is unreachable')) {
      return 'شبکه در دسترس نیست. لطفا اتصال اینترنت خود را بررسی کنید';
    }

    // حذف کلمه Exception از پیام خطا
    String message = error.toString();
    message = message.replaceFirst(
      RegExp(r'^[Ee][Xx][Cc][Ee][Pp][Tt][Ii][Oo][Nn]:\s*', caseSensitive: false),
      '',
    );
    message = message.replaceFirst(
      RegExp(r'^[Ee][Xx][Cc][Ee][Pp][Tt][Ii][Oo][Nn]\s+', caseSensitive: false),
      '',
    );
    message = message.trim();

    // اگر پیام خالی شد یا هنوز انگلیسی است، پیام پیش‌فرض برگردان
    if (message.isEmpty || _isEnglishMessage(message)) {
      return 'خطا در ارتباط با سرور. لطفا دوباره تلاش کنید';
    }

    return message;
  }

  /// مدیریت SocketException
  static String _handleSocketException(SocketException error) {
    final message = error.message.toLowerCase();
    
    if (message.contains('failed host lookup') ||
        message.contains('no address associated with hostname')) {
      return 'امکان اتصال به سرور وجود ندارد. لطفا اتصال اینترنت خود را بررسی کنید';
    }

    if (message.contains('connection refused')) {
      return 'اتصال به سرور رد شد. لطفا دوباره تلاش کنید';
    }

    if (message.contains('connection reset')) {
      return 'اتصال به سرور قطع شد. لطفا دوباره تلاش کنید';
    }

    if (message.contains('network is unreachable')) {
      return 'شبکه در دسترس نیست. لطفا اتصال اینترنت خود را بررسی کنید';
    }

    return 'امکان اتصال به سرور وجود ندارد. لطفا اتصال اینترنت خود را بررسی کنید';
  }

  /// مدیریت HttpException
  static String _handleHttpException(HttpException error) {
    final message = error.message.toLowerCase();
    
    if (message.contains('connection closed') ||
        message.contains('connection terminated')) {
      return 'اتصال به سرور قطع شد. لطفا دوباره تلاش کنید';
    }

    return 'خطا در ارتباط با سرور. لطفا دوباره تلاش کنید';
  }

  /// مدیریت ClientException
  static String _handleClientException(http.ClientException error) {
    final message = error.message.toLowerCase();
    
    if (message.contains('socketexception') ||
        message.contains('failed host lookup')) {
      return 'امکان اتصال به سرور وجود ندارد. لطفا اتصال اینترنت خود را بررسی کنید';
    }

    if (message.contains('timeout')) {
      return 'زمان اتصال به سرور به پایان رسید. لطفا دوباره تلاش کنید';
    }

    return 'خطا در ارتباط با سرور. لطفا دوباره تلاش کنید';
  }

  /// تبدیل کد وضعیت HTTP به پیام فارسی
  static String? _getStatusCodeMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'درخواست نامعتبر است';
      case 401:
        return 'دسترسی غیرمجاز. لطفا دوباره وارد شوید';
      case 403:
        return 'شما دسترسی به این بخش را ندارید';
      case 404:
        return 'منبع درخواستی یافت نشد';
      case 408:
        return 'زمان درخواست به پایان رسید. لطفا دوباره تلاش کنید';
      case 429:
        return 'تعداد درخواست‌ها بیش از حد مجاز است. لطفا کمی صبر کنید';
      case 500:
        return 'خطای داخلی سرور. لطفا بعدا تلاش کنید';
      case 502:
        return 'خطا در ارتباط با سرور. لطفا دوباره تلاش کنید';
      case 503:
        return 'سرور در حال حاضر در دسترس نیست. لطفا بعدا تلاش کنید';
      case 504:
        return 'زمان پاسخ سرور به پایان رسید. لطفا دوباره تلاش کنید';
      default:
        if (statusCode >= 500) {
          return 'خطای سرور. لطفا بعدا تلاش کنید';
        }
        if (statusCode >= 400) {
          return 'خطا در درخواست. لطفا دوباره تلاش کنید';
        }
        return null;
    }
  }

  /// بررسی اینکه آیا پیام انگلیسی است یا نه
  static bool _isEnglishMessage(String message) {
    // بررسی وجود کاراکترهای فارسی
    final persianRegex = RegExp(r'[\u0600-\u06FF]');
    return !persianRegex.hasMatch(message);
  }

  /// استخراج خطاها از پاسخ JSON سرور
  static String? extractErrorFromResponse(Map<String, dynamic>? jsonResponse) {
    if (jsonResponse == null) return null;
    
    final errors = jsonResponse['errors'] as List<dynamic>?;
    if (errors != null && errors.isNotEmpty) {
      final firstError = errors.first;
      if (firstError is String) {
        return firstError;
      }
    }
    
    final message = jsonResponse['message'] as String?;
    if (message != null && message.isNotEmpty) {
      return message;
    }
    
    return null;
  }
}



