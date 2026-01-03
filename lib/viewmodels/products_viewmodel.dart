import 'package:flutter/material.dart';
import '../models/product_response.dart';
import '../services/product_service.dart';

class ProductsViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();

  // کش سراسری برای جلوگیری از لود مجدد غیرضروری بین ساختن‌های مختلف ViewModel
  static List<Product>? _cachedProducts;
  static List<String>? _cachedCategories;
  
  bool _isLoading = false;
  String? _errorMessage;
  List<Product> _allProducts = [];
  int _selectedTabIndex = 0;
  List<String> _categories = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Product> get allProducts => _allProducts;
  int get selectedTabIndex => _selectedTabIndex;
  List<String> get categories => _categories;

  ProductsViewModel() {
    // اگر قبلاً داده‌ای کش شده، از آن استفاده کن
    if (_cachedProducts != null && _cachedProducts!.isNotEmpty) {
      _allProducts = _cachedProducts!;
      _categories = _cachedCategories ?? ['سنجاق شده', ..._extractCategoryNames(_cachedProducts!)];
    } else {
      // تا زمانی که products لود نشده، تب‌ها را نمایش نده
      _categories = [];
    }
  }

  List<String> _extractCategoryNames(List<Product> products) {
    final categoryNames = products
        .map((product) => product.category.name)
        .toSet()
        .toList();
    categoryNames.sort();
    return categoryNames;
  }

  // دسترسی فقط‌خواندنی به کش سراسری برای سایر ViewModelها (مثل جستجو)
  static List<Product>? get globalProducts => _cachedProducts;

  List<Product> get filteredProducts {
    // اگر هنوز دسته‌بندی‌ها لود نشده‌اند، لیست خالی برگردان
    if (_categories.isEmpty) {
      return [];
    }
    
    if (_selectedTabIndex == 0) {
      // تب سنجاق شده
      return _allProducts.where((product) => product.pinned).toList();
    } else if (_selectedTabIndex < _categories.length) {
      // تب‌های دسته‌بندی
      final categoryName = _categories[_selectedTabIndex];
      return _allProducts.where((product) => product.category.name == categoryName).toList();
    }
    
    return [];
  }

  Future<void> loadProducts(String accessToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _productService.getProducts(accessToken);
      
      _isLoading = false;
      
      if (response.isSuccess) {
        _allProducts = response.data;
        _cachedProducts = response.data;
        
        // استخراج دسته‌بندی‌های منحصر به فرد
        final categoryNames = _extractCategoryNames(response.data);
        
        // همه تب‌ها را همزمان اضافه کن (بعد از لود کامل محصولات)
        _categories = ['سنجاق شده', ...categoryNames];
        _cachedCategories = _categories;
        
        // اگر تب انتخاب شده معتبر نیست، تب اول را انتخاب کن
        if (_selectedTabIndex >= _categories.length) {
          _selectedTabIndex = 0;
        }
        
        _errorMessage = null;
        notifyListeners();
      } else {
        _errorMessage = response.errors.isNotEmpty 
            ? response.errors.first 
            : 'خطا در دریافت محصولات';
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'خطا در ارتباط با سرور';
      notifyListeners();
    }
  }

  void selectTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

