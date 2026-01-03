import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';
import '../services/storage_service.dart';
import '../utils/error_handler.dart';

class AuthService {
  static const String baseUrl = 'https://api.zar-360.ir/v1';

  // بررسی خطای 401 و force logout در صورت نیاز
  void _checkUnauthorized(int statusCode, {bool requiresAuth = true}) {
    if (requiresAuth && statusCode == 401) {
      debugPrint('🔒 [AuthService] دریافت خطای 401 - انجام forceLogout...');
      StorageService.forceLogout();
    }
  }


  void _logApiCall({
    required String method,
    required String url,
    required Map<String, String> headers,
    required String? requestBody,
    required int? statusCode,
    required Map<String, String>? responseHeaders,
    required String? responseBody,
    Object? error,
    required Duration duration,
  }) {
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('📡 API CALL: $method $url');
    debugPrint('⏱️  Duration: ${duration.inMilliseconds}ms');
    debugPrint('───────────────────────────────────────────────────────────');
    
    if (error != null) {
      debugPrint('❌ ERROR: $error');
      debugPrint('───────────────────────────────────────────────────────────');
    }
    
    debugPrint('📤 REQUEST:');
    debugPrint('   Headers:');
    headers.forEach((key, value) {
      if (key.toLowerCase() == 'authorization' && value.startsWith('Bearer ')) {
        final token = value.substring(7);
        debugPrint('     $key: Bearer ${token.length > 20 ? token.substring(0, 20) : token}...');
      } else {
        debugPrint('     $key: $value');
      }
    });
    if (requestBody != null) {
      debugPrint('   Body:');
      try {
        final formatted = const JsonEncoder.withIndent('   ').convert(jsonDecode(requestBody));
        debugPrint('   $formatted');
      } catch (e) {
        debugPrint('   $requestBody');
      }
    }
    
    if (statusCode != null) {
      debugPrint('───────────────────────────────────────────────────────────');
      debugPrint('📥 RESPONSE:');
      debugPrint('   Status Code: $statusCode');
      if (responseHeaders != null && responseHeaders.isNotEmpty) {
        debugPrint('   Headers:');
        responseHeaders.forEach((key, value) {
          debugPrint('     $key: $value');
        });
      }
      if (responseBody != null) {
        debugPrint('   Body:');
        try {
          final formatted = const JsonEncoder.withIndent('   ').convert(jsonDecode(responseBody));
          debugPrint('   $formatted');
        } catch (e) {
          debugPrint('   $responseBody');
        }
      }
    }
    
    debugPrint('═══════════════════════════════════════════════════════════');
  }

  Future<SendOtpResponse> sendOtp(String mobile) async {
    final stopwatch = Stopwatch()..start();
    final url = '$baseUrl/auth/send-otp';
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final requestBody = jsonEncode({
      'mobile': mobile,
    });

    try {
      debugPrint('🚀 Starting sendOtp API call...');
      debugPrint('   Mobile: $mobile');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: requestBody,
      );

      stopwatch.stop();
      
      // بررسی خطای 401
      _checkUnauthorized(response.statusCode, requiresAuth: false);
      
      // بررسی خطاهای HTTP
      if (response.statusCode >= 400) {
        try {
          final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
          final errorMessage = ErrorHandler.extractErrorFromResponse(jsonResponse) ??
              ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          
          _logApiCall(
            method: 'POST',
            url: url,
            headers: headers,
            requestBody: requestBody,
            statusCode: response.statusCode,
            responseHeaders: response.headers,
            responseBody: response.body,
            error: null,
            duration: stopwatch.elapsed,
          );
          
          return SendOtpResponse(
            errors: [errorMessage],
          );
        } catch (e) {
          final errorMessage = ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          
          _logApiCall(
            method: 'POST',
            url: url,
            headers: headers,
            requestBody: requestBody,
            statusCode: response.statusCode,
            responseHeaders: response.headers,
            responseBody: response.body,
            error: null,
            duration: stopwatch.elapsed,
          );
          
          return SendOtpResponse(
            errors: [errorMessage],
          );
        }
      }
      
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      
      _logApiCall(
        method: 'POST',
        url: url,
        headers: headers,
        requestBody: requestBody,
        statusCode: response.statusCode,
        responseHeaders: response.headers,
        responseBody: response.body,
        error: null,
        duration: stopwatch.elapsed,
      );

      final result = SendOtpResponse.fromJson(jsonResponse);
      
      if (result.isSuccess) {
        debugPrint('✅ sendOtp SUCCESS');
      } else {
        debugPrint('❌ sendOtp FAILED: ${result.errors.join(", ")}');
      }
      
      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      
      _logApiCall(
        method: 'POST',
        url: url,
        headers: headers,
        requestBody: requestBody,
        statusCode: null,
        responseHeaders: null,
        responseBody: null,
        error: '$e\nStack Trace:\n$stackTrace',
        duration: stopwatch.elapsed,
      );

      debugPrint('❌ sendOtp EXCEPTION: $e');
      debugPrint('Stack Trace: $stackTrace');
      
      return SendOtpResponse(
        errors: [ErrorHandler.getFarsiErrorMessage(e)],
      );
    }
  }

  Future<VerifyOtpResponse> verifyOtp(String mobile, String otp) async {
    final stopwatch = Stopwatch()..start();
    final url = '$baseUrl/auth/verify-otp';
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final requestBody = jsonEncode({
      'mobile': mobile,
      'otp': otp,
    });

    try {
      debugPrint('🚀 Starting verifyOtp API call...');
      debugPrint('   Mobile: $mobile');
      debugPrint('   OTP: ${otp.replaceAll(RegExp(r'.'), '*')}'); // نمایش OTP به صورت مخفی
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: requestBody,
      );

      stopwatch.stop();
      
      // بررسی خطای 401
      _checkUnauthorized(response.statusCode, requiresAuth: false);
      
      // بررسی خطاهای HTTP
      if (response.statusCode >= 400) {
        try {
          final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
          final errorMessage = ErrorHandler.extractErrorFromResponse(jsonResponse) ??
              ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          
          _logApiCall(
            method: 'POST',
            url: url,
            headers: headers,
            requestBody: requestBody,
            statusCode: response.statusCode,
            responseHeaders: response.headers,
            responseBody: response.body,
            error: null,
            duration: stopwatch.elapsed,
          );
          
          return VerifyOtpResponse(
            errors: [errorMessage],
          );
        } catch (e) {
          final errorMessage = ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          
          _logApiCall(
            method: 'POST',
            url: url,
            headers: headers,
            requestBody: requestBody,
            statusCode: response.statusCode,
            responseHeaders: response.headers,
            responseBody: response.body,
            error: null,
            duration: stopwatch.elapsed,
          );
          
          return VerifyOtpResponse(
            errors: [errorMessage],
          );
        }
      }
      
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      
      _logApiCall(
        method: 'POST',
        url: url,
        headers: headers,
        requestBody: requestBody,
        statusCode: response.statusCode,
        responseHeaders: response.headers,
        responseBody: response.body,
        error: null,
        duration: stopwatch.elapsed,
      );

      final result = VerifyOtpResponse.fromJson(jsonResponse);
      
      if (result.isSuccess) {
        debugPrint('✅ verifyOtp SUCCESS');
        debugPrint('   Access Token: ${result.accessToken?.substring(0, 20)}...'); // فقط 20 کاراکتر اول
      } else {
        debugPrint('❌ verifyOtp FAILED: ${result.errors.join(", ")}');
      }
      
      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      
      _logApiCall(
        method: 'POST',
        url: url,
        headers: headers,
        requestBody: requestBody,
        statusCode: null,
        responseHeaders: null,
        responseBody: null,
        error: '$e\nStack Trace:\n$stackTrace',
        duration: stopwatch.elapsed,
      );

      debugPrint('❌ verifyOtp EXCEPTION: $e');
      debugPrint('Stack Trace: $stackTrace');
      
      return VerifyOtpResponse(
        errors: [ErrorHandler.getFarsiErrorMessage(e)],
      );
    }
  }

  Future<AuthResponse> logout(String accessToken) async {
    final stopwatch = Stopwatch()..start();
    final url = '$baseUrl/auth/logout';
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      debugPrint('🚀 Starting logout API call...');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      stopwatch.stop();
      
      // بررسی خطای 401
      _checkUnauthorized(response.statusCode, requiresAuth: true);
      
      // بررسی خطاهای HTTP
      if (response.statusCode >= 400) {
        try {
          final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
          final errorMessage = ErrorHandler.extractErrorFromResponse(jsonResponse) ??
              ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          
          _logApiCall(
            method: 'POST',
            url: url,
            headers: headers,
            requestBody: null,
            statusCode: response.statusCode,
            responseHeaders: response.headers,
            responseBody: response.body,
            error: null,
            duration: stopwatch.elapsed,
          );
          
          return AuthResponse(
            data: null,
            errors: [errorMessage],
          );
        } catch (e) {
          final errorMessage = ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          
          _logApiCall(
            method: 'POST',
            url: url,
            headers: headers,
            requestBody: null,
            statusCode: response.statusCode,
            responseHeaders: response.headers,
            responseBody: response.body,
            error: null,
            duration: stopwatch.elapsed,
          );
          
          return AuthResponse(
            data: null,
            errors: [errorMessage],
          );
        }
      }
      
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      
      _logApiCall(
        method: 'POST',
        url: url,
        headers: headers,
        requestBody: null,
        statusCode: response.statusCode,
        responseHeaders: response.headers,
        responseBody: response.body,
        error: null,
        duration: stopwatch.elapsed,
      );

      final result = AuthResponse.fromJson(jsonResponse);
      
      if (result.isSuccess) {
        debugPrint('✅ logout SUCCESS');
      } else {
        debugPrint('❌ logout FAILED: ${result.errors.join(", ")}');
      }
      
      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      
      _logApiCall(
        method: 'POST',
        url: url,
        headers: headers,
        requestBody: null,
        statusCode: null,
        responseHeaders: null,
        responseBody: null,
        error: '$e\nStack Trace:\n$stackTrace',
        duration: stopwatch.elapsed,
      );

      debugPrint('❌ logout EXCEPTION: $e');
      debugPrint('Stack Trace: $stackTrace');
      
      return AuthResponse(
        data: null,
        errors: [ErrorHandler.getFarsiErrorMessage(e)],
      );
    }
  }
}

