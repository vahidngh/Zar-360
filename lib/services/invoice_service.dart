import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import '../models/cart_item.dart';
import '../models/invoice_response.dart';
import '../utils/error_handler.dart';

class InvoiceService {
  static const String baseUrl = 'https://api.zar-360.ir/v1';


  // بررسی خطای 401 و force logout در صورت نیاز
  void _checkUnauthorized(int statusCode) {
    if (statusCode == 401) {
      debugPrint('🔒 [InvoiceService] دریافت خطای 401 - انجام forceLogout...');
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
    debugPrint("headers: "+headers.toString());
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

  Future<int> createInvoice({
    required String description,
    required List<CartItem> items,
    required double totalAmount,
    required double totalWage,
    required double totalProfit,
    required double totalCommission,
    required double totalTax,
    String? customerType,
    String? customerMobile,
    String? customerName,
    String? customerNationalCode,
    String? invoiceType,
    String? sellerInvoiceNumber,
  }) async {
    final stopwatch = Stopwatch()..start();
    final token = await StorageService.getAccessToken();
    if (token == null) {
      throw Exception('دسترسی غیرمجاز');
    }

    final url = '$baseUrl/invoices';
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // ساخت customer object
    Map<String, dynamic>? customer;
    if (customerType != null && customerMobile != null && customerName != null) {
      customer = {
        'type': customerType,
        'mobile': customerMobile,
        'name': customerName,
      };
      
      if (customerNationalCode != null && customerNationalCode.isNotEmpty) {
        customer['national_code'] = customerNationalCode;
      }
    }

    // ساخت invoice object
    final invoice = {
      'type': invoiceType ?? 'normal',
      'total_amount': totalAmount.round(),
      'total_wage': totalWage.round(),
      'total_profit': totalProfit.round(),
      'total_commission': totalCommission.round(),
      'total_tax': totalTax.round(),
    };

    if (sellerInvoiceNumber != null && sellerInvoiceNumber.isNotEmpty) {
      invoice['seller_invoice_number'] = sellerInvoiceNumber;
    }

    // ساخت invoice_items
    final invoiceItems = items.map((item) => item.toInvoiceItemJson()).toList();

    final body = jsonEncode({
      'description': description,
      if (customer != null) 'customer': customer,
      'invoice': invoice,
      'invoice_items': invoiceItems,
    });

    try {
      debugPrint('🚀 Starting createInvoice API call...');
      debugPrint('   Items count: ${items.length}');
      debugPrint('   Total amount: $totalAmount');

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
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final data = jsonResponse['data'] as Map<String, dynamic>?;
        final invoiceId = data?['invoice_id'] as int?;
        
        if (invoiceId != null) {
          debugPrint('✅ createInvoice SUCCESS - Invoice ID: $invoiceId');
          return invoiceId;
        } else {
          debugPrint('❌ createInvoice FAILED: invoice_id not found in response');
          throw Exception('شناسه فاکتور در پاسخ یافت نشد');
        }
      } else {
        debugPrint('❌ createInvoice FAILED: ${response.statusCode}');
        try {
          final errorBody = jsonDecode(response.body) as Map<String, dynamic>?;
          final errorMessage = ErrorHandler.extractErrorFromResponse(errorBody) ??
              ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          throw Exception(errorMessage);
        } catch (parseError) {
          final errorMessage = ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          throw Exception(errorMessage);
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

      debugPrint('❌ createInvoice EXCEPTION: $e');
      debugPrint('Stack Trace: $stackTrace');
      
      // اگر خطا از نوع Exception است و پیام فارسی دارد، همان را برمی‌گردانیم
      if (e is Exception) {
        final message = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        if (message.isNotEmpty && !_isEnglishMessage(message)) {
          rethrow;
        }
      }
      
      throw Exception(ErrorHandler.getFarsiErrorMessage(e));
    }
  }

  Future<InvoiceListResponse> getInvoices({
    String? status,
    int page = 1,
    int? perPage,
  }) async {
    final stopwatch = Stopwatch()..start();
    final token = await StorageService.getAccessToken();
    if (token == null) {
      throw Exception('دسترسی غیرمجاز');
    }

    // ساخت URL با query parameters
    final uri = Uri.parse('$baseUrl/invoices');
    final queryParameters = <String, String>{};
    
    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }
    
    queryParameters['page'] = page.toString();
    
    if (perPage != null) {
      queryParameters['per_page'] = perPage.toString();
    }
    
    final url = uri.replace(queryParameters: queryParameters);

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    try {
      debugPrint('🚀 Starting getInvoices API call...');
      if (status != null) {
        debugPrint('   Status: $status');
      }
      debugPrint('   Page: $page');
      if (perPage != null) {
        debugPrint('   Per Page: $perPage');
      }

      final response = await http.get(url, headers: headers);

      stopwatch.stop();
      
      // بررسی خطای 401
      _checkUnauthorized(response.statusCode);
      
      _logApiCall(
        method: 'GET',
        url: url.toString(),
        headers: headers,
        requestBody: null,
        statusCode: response.statusCode,
        responseHeaders: response.headers,
        responseBody: response.body,
        error: null,
        duration: stopwatch.elapsed,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final result = InvoiceListResponse.fromJson(jsonResponse);
        debugPrint('✅ getInvoices SUCCESS - Found ${result.data.length} invoices');
        return result;
      } else {
        debugPrint('❌ getInvoices FAILED: ${response.statusCode}');
        try {
          final errorBody = jsonDecode(response.body) as Map<String, dynamic>?;
          final errorMessage = ErrorHandler.extractErrorFromResponse(errorBody) ??
              ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          throw Exception(errorMessage);
        } catch (parseError) {
          final errorMessage = ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          throw Exception(errorMessage);
        }
      }
    } catch (e, stackTrace) {
      stopwatch.stop();

      _logApiCall(
        method: 'GET',
        url: url.toString(),
        headers: headers,
        requestBody: null,
        statusCode: null,
        responseHeaders: null,
        responseBody: null,
        error: '$e\nStack Trace:\n$stackTrace',
        duration: stopwatch.elapsed,
      );

      debugPrint('❌ getInvoices EXCEPTION: $e');
      debugPrint('Stack Trace: $stackTrace');
      
      // اگر خطا از نوع Exception است و پیام فارسی دارد، همان را برمی‌گردانیم
      if (e is Exception) {
        final message = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        if (message.isNotEmpty && !_isEnglishMessage(message)) {
          rethrow;
        }
      }
      
      throw Exception(ErrorHandler.getFarsiErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> getInvoice(int invoiceId) async {
    final stopwatch = Stopwatch()..start();
    final token = await StorageService.getAccessToken();
    if (token == null) {
      throw Exception('دسترسی غیرمجاز');
    }

    final url = '$baseUrl/invoices/$invoiceId';
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    try {
      debugPrint('🚀 Starting getInvoice API call...');
      debugPrint('   Invoice ID: $invoiceId');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      stopwatch.stop();
      
      // بررسی خطای 401
      _checkUnauthorized(response.statusCode);
      
      _logApiCall(
        method: 'GET',
        url: url,
        headers: headers,
        requestBody: null,
        statusCode: response.statusCode,
        responseHeaders: response.headers,
        responseBody: response.body,
        error: null,
        duration: stopwatch.elapsed,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final data = jsonResponse['data'] as Map<String, dynamic>?;
        
        if (data != null) {
          debugPrint('✅ getInvoice SUCCESS - Invoice ID: ${data['id']}');
          return data;
        } else {
          debugPrint('❌ getInvoice FAILED: data not found in response');
          throw Exception('اطلاعات فاکتور در پاسخ یافت نشد');
        }
      } else {
        debugPrint('❌ getInvoice FAILED: ${response.statusCode}');
        try {
          final errorBody = jsonDecode(response.body) as Map<String, dynamic>?;
          final errorMessage = ErrorHandler.extractErrorFromResponse(errorBody) ??
              ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          throw Exception(errorMessage);
        } catch (parseError) {
          final errorMessage = ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          throw Exception(errorMessage);
        }
      }
    } catch (e, stackTrace) {
      stopwatch.stop();

      _logApiCall(
        method: 'GET',
        url: url,
        headers: headers,
        requestBody: null,
        statusCode: null,
        responseHeaders: null,
        responseBody: null,
        error: '$e\nStack Trace:\n$stackTrace',
        duration: stopwatch.elapsed,
      );

      debugPrint('❌ getInvoice EXCEPTION: $e');
      debugPrint('Stack Trace: $stackTrace');
      
      // اگر خطا از نوع Exception است و پیام فارسی دارد، همان را برمی‌گردانیم
      if (e is Exception) {
        final message = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        if (message.isNotEmpty && !_isEnglishMessage(message)) {
          rethrow;
        }
      }
      
      throw Exception(ErrorHandler.getFarsiErrorMessage(e));
    }
  }

  Future<void> cancelInvoice(int invoiceId) async {
    final stopwatch = Stopwatch()..start();
    final token = await StorageService.getAccessToken();
    if (token == null) {
      throw Exception('دسترسی غیرمجاز');
    }

    final url = '$baseUrl/invoices/$invoiceId/cancel';
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    try {
      debugPrint('🚀 Starting cancelInvoice API call...');
      debugPrint('   Invoice ID: $invoiceId');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      stopwatch.stop();
      
      // بررسی خطای 401
      _checkUnauthorized(response.statusCode);

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final data = jsonResponse['data'] as Map<String, dynamic>?;
        final message = data?['message'] as String?;

        if (message != null) {
          debugPrint('✅ cancelInvoice SUCCESS - Message: $message');
        } else {
          debugPrint('✅ cancelInvoice SUCCESS');
        }
      } else {
        debugPrint('❌ cancelInvoice FAILED: ${response.statusCode}');
        try {
          final errorBody = jsonDecode(response.body) as Map<String, dynamic>?;
          final errorMessage = ErrorHandler.extractErrorFromResponse(errorBody) ??
              ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          throw Exception(errorMessage);
        } catch (parseError) {
          final errorMessage = ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          throw Exception(errorMessage);
        }
      }
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

      debugPrint('❌ cancelInvoice EXCEPTION: $e');
      debugPrint('Stack Trace: $stackTrace');
      
      // اگر خطا از نوع Exception است و پیام فارسی دارد، همان را برمی‌گردانیم
      if (e is Exception) {
        final message = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        if (message.isNotEmpty && !_isEnglishMessage(message)) {
          rethrow;
        }
      }
      
      throw Exception(ErrorHandler.getFarsiErrorMessage(e));
    }
  }

  Future<bool> submitTax(int invoiceId) async {
    final stopwatch = Stopwatch()..start();
    final token = await StorageService.getAccessToken();
    if (token == null) {
      throw Exception('دسترسی غیرمجاز');
    }

    final url = '$baseUrl/invoices/$invoiceId/tax-submit';
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    try {
      debugPrint('🚀 Starting submitTax API call...');
      debugPrint('   Invoice ID: $invoiceId');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      stopwatch.stop();
      
      // بررسی خطای 401
      _checkUnauthorized(response.statusCode);
      
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final data = jsonResponse['data'] as Map<String, dynamic>?;
        final message = data?['message'] as String?;

        if (message != null) {
          debugPrint('✅ submitTax SUCCESS - Message: $message');
        } else {
          debugPrint('✅ submitTax SUCCESS');
        }
        return true;
      } else {
        debugPrint('❌ submitTax FAILED: ${response.statusCode}');
        try {
          final errorBody = jsonDecode(response.body) as Map<String, dynamic>?;
          final errorMessage = ErrorHandler.extractErrorFromResponse(errorBody) ??
              ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          throw Exception(errorMessage);
        } catch (parseError) {
          final errorMessage = ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          throw Exception(errorMessage);
        }
      }
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

      debugPrint('❌ submitTax EXCEPTION: $e');
      debugPrint('Stack Trace: $stackTrace');
      
      // اگر خطا از نوع Exception است و پیام فارسی دارد، همان را برمی‌گردانیم
      if (e is Exception) {
        final message = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        if (message.isNotEmpty && !_isEnglishMessage(message)) {
          rethrow;
        }
      }
      
      throw Exception(ErrorHandler.getFarsiErrorMessage(e));
    }
  }

  // بررسی اینکه آیا پیام انگلیسی است یا نه
  bool _isEnglishMessage(String message) {
    // بررسی وجود کاراکترهای فارسی
    final persianRegex = RegExp(r'[\u0600-\u06FF]');
    return !persianRegex.hasMatch(message);
  }
}

