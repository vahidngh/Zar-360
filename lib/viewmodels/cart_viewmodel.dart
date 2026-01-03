import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/database_service.dart';

class CartViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  bool get isLoading => _isLoading;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalAmount);
  }

  double get totalWage {
    return _items.fold(0.0, (sum, item) => sum + item.totalWageAmount);
  }

  double get totalProfit {
    return _items.fold(0.0, (sum, item) => sum + item.profitAmount);
  }

  double get totalCommission {
    return _items.fold(0.0, (sum, item) => sum + item.commissionAmount);
  }

  double get totalTax {
    return _items.fold(0.0, (sum, item) => sum + item.taxAmount);
  }

  bool get isEmpty => _items.isEmpty;

  // بارگذاری آیتم‌ها از دیتابیس
  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _databaseService.getAllCartItems();
      notifyListeners();
    } catch (e) {
      debugPrint('خطا در بارگذاری سبد خرید: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // افزودن آیتم به سبد خرید
  Future<void> addItem(CartItem item) async {
    try {
      debugPrint('💾 [CartViewModel] شروع افزودن CartItem به دیتابیس...');
      debugPrint('  - Product ID: ${item.product.id}');
      debugPrint('  - Weight: ${item.weight}');
      debugPrint('  - Total Amount: ${item.totalAmount}');
      
      final id = await _databaseService.insertCartItem(item);
      debugPrint('✅ [CartViewModel] CartItem با ID $id به دیتابیس اضافه شد');
      
      final newItem = CartItem(
        id: id,
        product: item.product,
        weight: item.weight,
        count: item.count,
        purity: item.purity,
        unitAmount: item.unitAmount,
        totalUnitAmount: item.totalUnitAmount,
        wagePercent: item.wagePercent,
        wagePerGram: item.wagePerGram,
        wagePerCount: item.wagePerCount,
        totalWageAmount: item.totalWageAmount,
        profitPercent: item.profitPercent,
        profitAmount: item.profitAmount,
        commissionPercent: item.commissionPercent,
        commissionAmount: item.commissionAmount,
        taxAmount: item.taxAmount,
        totalAmount: item.totalAmount,
      );
      
      _items.add(newItem);
      debugPrint('✅ [CartViewModel] CartItem به لیست محلی اضافه شد. تعداد کل: ${_items.length}');
      notifyListeners();
      debugPrint('✅ [CartViewModel] Listeners اطلاع‌رسانی شدند');
    } catch (e, stackTrace) {
      debugPrint('❌ [CartViewModel] خطا در افزودن محصول به سبد خرید:');
      debugPrint('  Error: $e');
      debugPrint('  StackTrace: $stackTrace');
      rethrow;
    }
  }

  // حذف آیتم از سبد خرید
  Future<void> removeItem(int id) async {
    try {
      await _databaseService.deleteCartItem(id);
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('خطا در حذف محصول از سبد خرید: $e');
      rethrow;
    }
  }

  // حذف همه آیتم‌ها
  Future<void> clear() async {
    try {
      await _databaseService.clearCartItems();
      _items.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('خطا در پاک کردن سبد خرید: $e');
      rethrow;
    }
  }

  // به‌روزرسانی metadata سبد خرید
  Future<void> updateMetadata({
    String? description,
    String? customerType,
    String? customerMobile,
    String? customerName,
    String? customerNationalCode,
    String? invoiceType,
    String? sellerInvoiceNumber,
  }) async {
    try {
      await _databaseService.updateCartMetadata(
        description: description,
        customerType: customerType,
        customerMobile: customerMobile,
        customerName: customerName,
        customerNationalCode: customerNationalCode,
        invoiceType: invoiceType,
        sellerInvoiceNumber: sellerInvoiceNumber,
      );
    } catch (e) {
      debugPrint('خطا در به‌روزرسانی اطلاعات سبد خرید: $e');
      rethrow;
    }
  }

  // دریافت metadata سبد خرید
  Future<Map<String, dynamic>?> getMetadata() async {
    try {
      return await _databaseService.getCartMetadata();
    } catch (e) {
      debugPrint('خطا در دریافت اطلاعات سبد خرید: $e');
      return null;
    }
  }

  // پاک کردن metadata بعد از ارسال سفارش
  Future<void> clearMetadata() async {
    try {
      await _databaseService.clearCartMetadata();
    } catch (e) {
      debugPrint('خطا در پاک کردن اطلاعات سبد خرید: $e');
      rethrow;
    }
  }
}
