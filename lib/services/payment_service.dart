import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import '../utils/error_handler.dart';

class PaymentService {
  static const String baseUrl = 'https://api.zar-360.ir/v1';

  // بررسی خطای 401 و force logout در صورت نیاز
  void _checkUnauthorized(int statusCode) {
    if (statusCode == 401) {
      debugPrint('🔒 [PaymentService] دریافت خطای 401 - انجام forceLogout...');
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

    debugPrint('📥 RESPONSE:');
    debugPrint('   Status Code: $statusCode');
    if (responseHeaders != null) {
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

    debugPrint('═══════════════════════════════════════════════════════════');
  }

  Future<Map<String, dynamic>> submitPayment({
    required int invoiceId,
    required String type,
    required double amount,
    required Map<String, dynamic> details,
  }) async {
    final stopwatch = Stopwatch()..start();
    final token = await StorageService.getAccessToken();
    if (token == null) {
      throw Exception('دسترسی غیرمجاز');
    }

    final url = '$baseUrl/invoices/$invoiceId/payments';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'type': type,
      'amount': amount.round(),
      'details': details,
    });

    try {
      debugPrint('🚀 Starting submitPayment API call...');
      debugPrint('   Invoice ID: $invoiceId');
      debugPrint('   Type: $type');
      debugPrint('   Amount: $amount');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      stopwatch.stop();
      
      // بررسی خطای 401
      _checkUnauthorized(response.statusCode);
      
      _logApiCall(
        method: 'POST',
        url: url,
        headers: headers,
        requestBody: body,
        statusCode: response.statusCode,
        responseHeaders: response.headers,
        responseBody: response.body,
        error: null,
        duration: stopwatch.elapsed,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
          final data = jsonResponse['data'] as Map<String, dynamic>?;
          final errors = jsonResponse['errors'] as List<dynamic>?;
          
          if (errors != null && errors.isNotEmpty) {
            final errorMessage = errors.first is String 
                ? errors.first as String
                : ErrorHandler.getFarsiErrorMessage(errors.first);
            debugPrint('❌ submitPayment FAILED: $errorMessage');
            return {
              'success': false,
              'message': errorMessage,
              'errors': errors,
            };
          }
          
          debugPrint('✅ submitPayment SUCCESS');
          return {
            'success': true,
            'data': data,
            'message': data?['message'] as String? ?? 'پرداخت با موفقیت ایجاد شد.',
            'status': data?['status'] as String?,
          };
        } catch (e) {
          debugPrint('❌ submitPayment: Error parsing response: $e');
          return {
            'success': false,
            'message': 'خطا در پردازش پاسخ سرور',
          };
        }
      } else {
        try {
          final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>?;
          final errorMessage = ErrorHandler.extractErrorFromResponse(jsonResponse) ??
              ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          
          debugPrint('❌ submitPayment FAILED: ${response.statusCode} - $errorMessage');
          return {
            'success': false,
            'message': errorMessage,
            'errors': jsonResponse?['errors'] as List<dynamic>? ?? [],
          };
        } catch (e) {
          debugPrint('❌ submitPayment FAILED: ${response.statusCode}');
          final errorMessage = ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          return {
            'success': false,
            'message': errorMessage,
          };
        }
      }
    } catch (e, stackTrace) {
      stopwatch.stop();

      _logApiCall(
        method: 'POST',
        url: url,
        headers: headers,
        requestBody: body,
        statusCode: null,
        responseHeaders: null,
        responseBody: null,
        error: '$e\nStack Trace:\n$stackTrace',
        duration: stopwatch.elapsed,
      );

      debugPrint('❌ submitPayment EXCEPTION: $e');
      debugPrint('Stack Trace: $stackTrace');
      return {
        'success': false,
        'message': ErrorHandler.getFarsiErrorMessage(e),
      };
    }
  }
}

