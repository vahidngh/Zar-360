import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product_response.dart';
import '../models/seller_product_response.dart';
import '../services/storage_service.dart';
import '../utils/error_handler.dart';

class ProductService {
  static const String baseUrl = 'https://api.zar-360.ir/v1';

  // بررسی خطای 401 و force logout در صورت نیاز
  void _checkUnauthorized(int statusCode) {
    if (statusCode == 401) {
      debugPrint('🔒 [ProductService] دریافت خطای 401 - انجام forceLogout...');
      StorageService.forceLogout();
    }
  }


  void _logApiCall({
    required String method,
    required String url,
    required Map<String, String> headers,
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
      if (key.toLowerCase() == 'authorization') {
        debugPrint('     $key: Bearer ${value.substring(0, 20)}...');
      } else {
        debugPrint('     $key: $value');
      }
    });
    
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

  Future<ProductResponse> getProducts(String accessToken) async {
    final stopwatch = Stopwatch()..start();
    final url = '$baseUrl/products';
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      debugPrint('🚀 Starting getProducts API call...');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      stopwatch.stop();
      
      // بررسی خطای 401
      _checkUnauthorized(response.statusCode);
      
      // بررسی خطاهای HTTP
      if (response.statusCode >= 400) {
        try {
          final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
          final errorMessage = ErrorHandler.extractErrorFromResponse(jsonResponse) ??
              ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          
          _logApiCall(
            method: 'GET',
            url: url,
            headers: headers,
            statusCode: response.statusCode,
            responseHeaders: response.headers,
            responseBody: response.body,
            error: null,
            duration: stopwatch.elapsed,
          );
          
          return ProductResponse(
            data: [],
            errors: [errorMessage],
          );
        } catch (e) {
          final errorMessage = ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          
          _logApiCall(
            method: 'GET',
            url: url,
            headers: headers,
            statusCode: response.statusCode,
            responseHeaders: response.headers,
            responseBody: response.body,
            error: null,
            duration: stopwatch.elapsed,
          );
          
          return ProductResponse(
            data: [],
            errors: [errorMessage],
          );
        }
      }
      
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      
      _logApiCall(
        method: 'GET',
        url: url,
        headers: headers,
        statusCode: response.statusCode,
        responseHeaders: response.headers,
        responseBody: response.body,
        error: null,
        duration: stopwatch.elapsed,
      );

      final result = ProductResponse.fromJson(jsonResponse);
      
      if (result.isSuccess) {
        debugPrint('✅ getProducts SUCCESS: ${result.data.length} products');
      } else {
        debugPrint('❌ getProducts FAILED: ${result.errors.join(", ")}');
      }
      
      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      
      _logApiCall(
        method: 'GET',
        url: url,
        headers: headers,
        statusCode: null,
        responseHeaders: null,
        responseBody: null,
        error: '$e\nStack Trace:\n$stackTrace',
        duration: stopwatch.elapsed,
      );

      debugPrint('❌ getProducts EXCEPTION: $e');
      debugPrint('Stack Trace: $stackTrace');
      
      return ProductResponse(
        data: [],
        errors: [ErrorHandler.getFarsiErrorMessage(e)],
      );
    }
  }

  Future<SellerProductResponse> getSellerProducts(String accessToken) async {
    final stopwatch = Stopwatch()..start();
    final url = '$baseUrl/seller-products';
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      debugPrint('🚀 Starting getSellerProducts API call...');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      stopwatch.stop();
      
      // بررسی خطای 401
      _checkUnauthorized(response.statusCode);
      
      // بررسی خطاهای HTTP
      if (response.statusCode >= 400) {
        try {
          final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
          final errorMessage = ErrorHandler.extractErrorFromResponse(jsonResponse) ??
              ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          
          _logApiCall(
            method: 'GET',
            url: url,
            headers: headers,
            statusCode: response.statusCode,
            responseHeaders: response.headers,
            responseBody: response.body,
            error: null,
            duration: stopwatch.elapsed,
          );
          
          return SellerProductResponse(
            data: [],
            errors: [errorMessage],
          );
        } catch (e) {
          final errorMessage = ErrorHandler.getFarsiErrorMessage(null, statusCode: response.statusCode);
          
          _logApiCall(
            method: 'GET',
            url: url,
            headers: headers,
            statusCode: response.statusCode,
            responseHeaders: response.headers,
            responseBody: response.body,
            error: null,
            duration: stopwatch.elapsed,
          );
          
          return SellerProductResponse(
            data: [],
            errors: [errorMessage],
          );
        }
      }
      
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      
      _logApiCall(
        method: 'GET',
        url: url,
        headers: headers,
        statusCode: response.statusCode,
        responseHeaders: response.headers,
        responseBody: response.body,
        error: null,
        duration: stopwatch.elapsed,
      );

      final result = SellerProductResponse.fromJson(jsonResponse);
      
      if (result.isSuccess) {
        debugPrint('✅ getSellerProducts SUCCESS: ${result.data.length} products');
      } else {
        debugPrint('❌ getSellerProducts FAILED: ${result.errors.join(", ")}');
      }
      
      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      
      _logApiCall(
        method: 'GET',
        url: url,
        headers: headers,
        statusCode: null,
        responseHeaders: null,
        responseBody: null,
        error: '$e\nStack Trace:\n$stackTrace',
        duration: stopwatch.elapsed,
      );

      debugPrint('❌ getSellerProducts EXCEPTION: $e');
      debugPrint('Stack Trace: $stackTrace');
      
      return SellerProductResponse(
        data: [],
        errors: [ErrorHandler.getFarsiErrorMessage(e)],
      );
    }
  }

  Future<bool> toggleProductPin(String accessToken, int productId) async {
    final stopwatch = Stopwatch()..start();
    final url = '$baseUrl/products/$productId/toggle-pin';
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    try {
      debugPrint('🚀 Starting toggleProductPin API call...');
      debugPrint('   Product ID: $productId');
      
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
      );

      stopwatch.stop();
      
      // بررسی خطای 401
      _checkUnauthorized(response.statusCode);
      
      _logApiCall(
        method: 'PATCH',
        url: url,
        headers: headers,
        statusCode: response.statusCode,
        responseHeaders: response.headers,
        responseBody: response.body,
        error: null,
        duration: stopwatch.elapsed,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ toggleProductPin SUCCESS');
        return true;
      } else {
        debugPrint('❌ toggleProductPin FAILED: Status ${response.statusCode}');
        return false;
      }
    } catch (e, stackTrace) {
      stopwatch.stop();
      
      _logApiCall(
        method: 'PATCH',
        url: url,
        headers: headers,
        statusCode: null,
        responseHeaders: null,
        responseBody: null,
        error: '$e\nStack Trace:\n$stackTrace',
        duration: stopwatch.elapsed,
      );

      debugPrint('❌ toggleProductPin EXCEPTION: $e');
      debugPrint('Stack Trace: $stackTrace');
      return false;
    }
  }

  Future<bool> toggleSellerProductStatus(String accessToken, int sellerProductId) async {
    final stopwatch = Stopwatch()..start();
    final url = '$baseUrl/seller-products/$sellerProductId/toggle-status';
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      debugPrint('🚀 Starting toggleSellerProductStatus API call...');
      debugPrint('   Seller Product ID: $sellerProductId');
      
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
      );

      stopwatch.stop();
      
      // بررسی خطای 401
      _checkUnauthorized(response.statusCode);
      
      _logApiCall(
        method: 'PATCH',
        url: url,
        headers: headers,
        statusCode: response.statusCode,
        responseHeaders: response.headers,
        responseBody: response.body,
        error: null,
        duration: stopwatch.elapsed,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ toggleSellerProductStatus SUCCESS');
        return true;
      } else {
        debugPrint('❌ toggleSellerProductStatus FAILED: Status ${response.statusCode}');
        return false;
      }
    } catch (e, stackTrace) {
      stopwatch.stop();
      
      _logApiCall(
        method: 'PATCH',
        url: url,
        headers: headers,
        statusCode: null,
        responseHeaders: null,
        responseBody: null,
        error: '$e\nStack Trace:\n$stackTrace',
        duration: stopwatch.elapsed,
      );

      debugPrint('❌ toggleSellerProductStatus EXCEPTION: $e');
      debugPrint('Stack Trace: $stackTrace');
      return false;
    }
  }
}

