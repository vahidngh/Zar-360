import 'package:flutter/material.dart';
import 'package:zar360/theme/app_theme.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/seller_product_response.dart';
import '../services/product_service.dart';
import '../services/storage_service.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final ProductService _productService = ProductService();
  List<SellerProduct> _allProducts = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<int, bool> _expandedCategories = {};
  Map<int, bool> _togglingPins = {};
  Map<int, bool> _togglingStatus = {};

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'لطفا دوباره وارد شوید';
        });
        return;
      }

      final response = await _productService.getSellerProducts(accessToken);
      
      if (response.isSuccess) {
        setState(() {
          _allProducts = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.errors.isNotEmpty 
              ? response.errors.first 
              : 'خطا در دریافت محصولات';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطا در ارتباط با سرور';
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePin(SellerProduct product) async {
    setState(() {
      _togglingPins[product.id] = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) {
        _showErrorSnackBar('لطفا دوباره وارد شوید');
        setState(() {
          _togglingPins[product.id] = false;
        });
        return;
      }

      final success = await _productService.toggleProductPin(accessToken, product.id);
      
      if (success) {
        setState(() {
          final index = _allProducts.indexWhere((p) => p.id == product.id);
          if (index != -1) {
            _allProducts[index] = SellerProduct(
              id: product.id,
              name: product.name,
              description: product.description,
              purity: product.purity,
              type: product.type,
              typeLabel: product.typeLabel,
              pinned: !product.pinned,
              isActive: product.isActive,
              category: product.category,
              taxPercent: product.taxPercent,
            );
          }
        });
      } else {
        _showErrorSnackBar('خطا در تغییر وضعیت سنجاق');
      }
    } catch (e) {
      _showErrorSnackBar('خطا در ارتباط با سرور');
    } finally {
      setState(() {
        _togglingPins[product.id] = false;
      });
    }
  }

  Future<void> _toggleStatus(SellerProduct product) async {
    setState(() {
      _togglingStatus[product.id] = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) {
        _showErrorSnackBar('لطفا دوباره وارد شوید');
        setState(() {
          _togglingStatus[product.id] = false;
        });
        return;
      }

      final success = await _productService.toggleSellerProductStatus(accessToken, product.id);
      
      if (success) {
        setState(() {
          final index = _allProducts.indexWhere((p) => p.id == product.id);
          if (index != -1) {
            _allProducts[index] = SellerProduct(
              id: product.id,
              name: product.name,
              description: product.description,
              purity: product.purity,
              type: product.type,
              typeLabel: product.typeLabel,
              pinned: product.pinned,
              isActive: !product.isActive,
              category: product.category,
              taxPercent: product.taxPercent,
            );
          }
        });
      } else {
        _showErrorSnackBar('خطا در تغییر وضعیت محصول');
      }
    } catch (e) {
      _showErrorSnackBar('خطا در ارتباط با سرور');
    } finally {
      setState(() {
        _togglingStatus[product.id] = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Iranyekan',
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Map<int, List<SellerProduct>> _groupByCategory() {
    final Map<int, List<SellerProduct>> grouped = {};
    for (var product in _allProducts) {
      if (!grouped.containsKey(product.category.id)) {
        grouped[product.category.id] = [];
        _expandedCategories[product.category.id] = true;
      }
      grouped[product.category.id]!.add(product);
    }
    
    // مرتب‌سازی محصولات: اول سنجاق شده‌ها، سپس بر اساس نام
    for (var categoryId in grouped.keys) {
      grouped[categoryId]!.sort((a, b) {
        if (a.pinned != b.pinned) {
          return a.pinned ? -1 : 1;
        }
        return a.name.compareTo(b.name);
      });
    }
    
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: const Border(
              bottom: BorderSide(
                color: AppColors.appBarDivider,
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE0E7FF).withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: AppBar(
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'مدیریت محصولات',
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryAlt,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryAlt),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: SpinKitFoldingCube(
        color: AppColors.gold,
        size: 50.0,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage ?? 'خطا در دریافت اطلاعات',
              style: const TextStyle(
                fontFamily: 'Iranyekan',
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'تلاش مجدد',
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_allProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.textMuted.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'محصولی یافت نشد',
              style: TextStyle(
                fontFamily: 'Iranyekan',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return _buildProductsList();
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withOpacity(0.15),
            AppColors.gold.withOpacity(0.05),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline,
              color: AppColors.gold,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'در این صفحه می‌توانید محصولات دلخواه را سنجاق کنید تا همیشه در ابتدای فهرست نمایش داده شوند و همچنین در صورت نبود موجودی، محصولات را غیرفعال کنید.',
              style: TextStyle(
                fontFamily: 'Iranyekan',
                fontSize: 11,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    final groupedProducts = _groupByCategory();
    final categories = groupedProducts.keys.toList();
    
    // مرتب‌سازی دسته‌بندی‌ها بر اساس نام
    categories.sort((a, b) {
      final categoryA = _allProducts.firstWhere((p) => p.category.id == a).category;
      final categoryB = _allProducts.firstWhere((p) => p.category.id == b).category;
      return categoryA.name.compareTo(categoryB.name);
    });

    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: AppColors.gold,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildInfoCard();
          }
          final categoryId = categories[index - 1];
          final categoryName = _allProducts
              .firstWhere((p) => p.category.id == categoryId)
              .category
              .name;
          final products = groupedProducts[categoryId]!;

          return _buildCategoryCard(categoryId, categoryName, products, index - 1);
        },
      ),
    );
  }

  Widget _buildCategoryCard(int categoryId, String categoryName, List<SellerProduct> products, int index) {
    final isExpanded = _expandedCategories[categoryId] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding: EdgeInsets.zero,
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedCategories[categoryId] = expanded;
            });
          },
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.folder_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: const TextStyle(
                        fontFamily: 'Iranyekan',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryAlt,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${products.length} محصول',
                      style: const TextStyle(
                        fontFamily: 'Iranyekan',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.gold,
                size: 20,
              ),
            ),
          ),
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundAlt,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                itemCount: products.length,
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildProductCard(product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(SellerProduct product) {
    final isTogglingPin = _togglingPins[product.id] ?? false;
    final isTogglingStatus = _togglingStatus[product.id] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.borderSoft.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: null,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // اطلاعات محصول
                Expanded(
                  child: Text(
                    product.name,
                    style: TextStyle(
                      fontFamily: 'Iranyekan',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: product.isActive 
                          ? AppColors.textPrimaryAlt 
                          : AppColors.textMuted,
                      decoration: product.isActive 
                          ? TextDecoration.none 
                          : TextDecoration.lineThrough,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // دکمه سنجاق
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isTogglingPin ? null : () => _togglePin(product),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: product.pinned
                            ? AppGradients.primary
                            : null,
                        color: product.pinned
                            ? null
                            : AppColors.textMuted.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: product.pinned
                              ? Colors.transparent
                              : AppColors.textMuted.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: isTogglingPin
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: SpinKitFoldingCube(
                                color: Colors.white,
                                size: 14.0,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  product.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                                  size: 14,
                                  color: product.pinned ? Colors.white : AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'سنجاق',
                                  style: TextStyle(
                                    fontFamily: 'Iranyekan',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: product.pinned
                                        ? Colors.white
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // دکمه فعال/غیرفعال
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isTogglingStatus ? null : () => _toggleStatus(product),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: product.isActive
                            ? AppGradients.primary
                            : null,
                        color: product.isActive
                            ? null
                            : AppColors.textMuted.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: product.isActive
                              ? Colors.transparent
                              : AppColors.textMuted.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: isTogglingStatus
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: SpinKitFoldingCube(
                                color: Colors.white,
                                size: 14.0,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  product.isActive ? Icons.check_circle : Icons.cancel,
                                  size: 14,
                                  color: product.isActive ? Colors.white : AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product.isActive ? 'فعال' : 'غیرفعال',
                                  style: TextStyle(
                                    fontFamily: 'Iranyekan',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: product.isActive
                                        ? Colors.white
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

