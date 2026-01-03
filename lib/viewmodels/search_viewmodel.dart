import 'package:flutter/material.dart';
import '../models/product_response.dart';
import 'products_viewmodel.dart';
import '../services/storage_service.dart';
import '../services/product_service.dart';

class SearchViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  final ProductService _productService = ProductService();
  
  bool _isLoading = false;
  String? _errorMessage;
  List<Product> _allProducts = [];
  List<Product> _searchResults = [];
  bool _hasSearched = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Product> get searchResults => _searchResults;
  bool get hasSearched => _hasSearched;
  bool get hasResults => _searchResults.isNotEmpty;

  SearchViewModel() {
    searchController.addListener(_onSearchChanged);
  }

  /// مقداردهی اولیه لیست محصولات از کش سراسری محصولات.
  /// اگر محصولات موجود نباشد، خودش محصولات را لود می‌کند.
  void initFromGlobalProducts({ProductsViewModel? productsViewModel}) {
    final cached = ProductsViewModel.globalProducts;
    if (cached != null && cached.isNotEmpty) {
      _allProducts = cached;
      _errorMessage = null;
      notifyListeners();
    } else if (productsViewModel != null && productsViewModel.isLoading) {
      // اگر ProductsViewModel در حال لود است، منتظر بمان
      // بعداً refreshFromGlobalProducts فراخوانی شود
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();
    } else {
      // اگر محصولات موجود نیست و ProductsViewModel هم در حال لود نیست، خودمان لود کنیم
      _loadProducts();
    }
  }

  /// لود محصولات از سرور
  Future<void> _loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        _isLoading = false;
        _errorMessage = 'دسترسی غیرمجاز';
        notifyListeners();
        return;
      }

      final response = await _productService.getProducts(token);
      
      _isLoading = false;
      
      if (response.isSuccess) {
        _allProducts = response.data;
        _errorMessage = null;
        // اگر لیست خالی است، این یک وضعیت عادی است (هیچ محصولی وجود ندارد)
        // پیغام خطا نشان نده
      } else {
        _errorMessage = response.errors.isNotEmpty 
            ? response.errors.first 
            : 'خطا در دریافت محصولات';
      }
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'خطا در ارتباط با سرور';
      notifyListeners();
    }
  }

  /// تلاش مجدد برای لود محصولات
  Future<void> retryLoad() async {
    await _loadProducts();
  }

  void _onSearchChanged() {
    _performSearch(searchController.text);
  }

  // دیگر در این ViewModel، لیست محصولات را از وب‌سرویس لود نمی‌کنیم.

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _hasSearched = false;
      notifyListeners();
      return;
    }

    _hasSearched = true;
    final searchQuery = query.trim().toLowerCase();
    
    _searchResults = _allProducts.where((product) {
      final productName = product.name.toLowerCase();
      final categoryName = product.category.name.toLowerCase();
      return productName.contains(searchQuery) || categoryName.contains(searchQuery);
    }).toList();
    
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    _searchResults = [];
    _hasSearched = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  /// به‌روزرسانی لیست محصولات از کش سراسری (مثلاً بعد از لود شدن در ProductsViewModel)
  void refreshFromGlobalProducts() {
    final cached = ProductsViewModel.globalProducts;
    if (cached != null) {
      _allProducts = cached;
      _errorMessage = null;
      _isLoading = false;
      // اگر کاربر قبلاً جستجو کرده بود، دوباره جستجو کن
      if (_hasSearched && searchController.text.isNotEmpty) {
        _performSearch(searchController.text);
      } else {
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}

