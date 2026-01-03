import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zar360/theme/app_theme.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/products_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../models/product_response.dart';
import '../services/storage_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/product_pricing_bottom_sheet.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SearchPageContent();
  }
}

// محتوای صفحه جستجو بدون Provider (چون در MainNavigationPage تعریف شده)
class SearchPageContent extends StatelessWidget {
  const SearchPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SearchPageContent();
  }
}

class _SearchPageContent extends StatefulWidget {
  const _SearchPageContent();

  @override
  State<_SearchPageContent> createState() => _SearchPageContentState();
}

class _SearchPageContentState extends State<_SearchPageContent> {
  @override
  void initState() {
    super.initState();
    // بعد از لود شدن صفحه، بررسی کن که آیا ProductsViewModel محصولات را لود کرده
    // اگر بله، SearchViewModel را به‌روزرسانی کن
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final searchViewModel = Provider.of<SearchViewModel>(context, listen: false);
      
      // اگر ProductsViewModel محصولات را لود کرده، SearchViewModel را به‌روزرسانی کن
      if (ProductsViewModel.globalProducts != null && 
          ProductsViewModel.globalProducts!.isNotEmpty) {
        searchViewModel.refreshFromGlobalProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SearchViewModel>(context);
    // استفاده از Consumer برای گوش دادن به تغییرات ProductsViewModel
    return Consumer<ProductsViewModel>(
      builder: (context, productsViewModel, child) {
        // اگر ProductsViewModel محصولات را لود کرده، SearchViewModel را به‌روزرسانی کن
        final cached = ProductsViewModel.globalProducts;
        if (cached != null && cached.isNotEmpty && viewModel.searchResults.isEmpty && !viewModel.hasSearched) {
          // فقط یک‌بار بعد از build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              viewModel.refreshFromGlobalProducts();
            }
          });
        }
        return _buildContent(context, viewModel);
      },
    );
  }

  Widget _buildContent(BuildContext context, SearchViewModel viewModel) {

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE0E7FF).withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
            border: const Border(
              bottom: BorderSide(
                color: AppColors.appBarDivider,
                width: 0.5,
              ),
            ),
          ),
          child: AppBar(
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text('جستجو'),
            ),
            centerTitle: false,
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.gold,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: viewModel.searchController,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(
                        hintText: 'جستجو...',
                        hintStyle: TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Iranyekan',
                        fontSize: 14,
                        color: AppColors.textPrimaryAlt,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: AppColors.dividerSoft,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: viewModel.searchController,
                    builder: (context, value, child) {
                      final hasText = value.text.isNotEmpty;
                      return GestureDetector(
                        onTap: hasText
                            ? () {
                                viewModel.clearSearch();
                              }
                            : null,
                        child: hasText
                            ? const Icon(
                                Icons.close,
                                size: 24,
                                color: AppColors.iconBrown,
                              )
                            : Image.asset(
                                'assets/images/search.png',
                                width: 24,
                                height: 24,
                                color: AppColors.iconBrown,
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Search Results
            Expanded(
              child: viewModel.isLoading
                  ? const Center(
                      child: SpinKitFoldingCube(
                        color: AppColors.gold,
                        size: 50.0,
                      ),
                    )
                  : viewModel.errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  viewModel.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Iranyekan',
                                    fontSize: 16,
                                    color: AppColors.error,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: viewModel.isLoading
                                      ? null
                                      : () async {
                                          await viewModel.retryLoad();
                                        },
                                  child: viewModel.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text('تلاش مجدد'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : !viewModel.hasSearched
                          ? const Center(
                              child: Text(
                                'برای جستجو، متن مورد نظر را وارد کنید',
                                style: TextStyle(
                                  fontFamily: 'Iranyekan',
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : viewModel.hasResults
                              ? ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: viewModel.searchResults.length,
                                  itemBuilder: (context, index) {
                                    final product = viewModel.searchResults[index];
                                    return _buildProductCard(context, product);
                                  },
                                )
                              : _buildNoResults(context),
            ),
          ],
        ),
      ),
      // bottomNavigationBar حذف شد چون در MainNavigationPage تعریف شده
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_results.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          const Text(
            'محصول مورد نظر یافت نشد.',
            style: TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderSoft,
          width: 0.25,
        ),
        boxShadow: [
          AppShadows.softDown(AppColors.gold, opacity: 0.08),
        ],
      ),
      child: Row(
        children: [
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontFamily: 'Iranyekan',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryAlt,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.category.name,
                  style: const TextStyle(
                    fontFamily: 'Iranyekan',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Icon with Gradient Background
          GestureDetector(
            onTap: () async {
              final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => ProductPricingBottomSheet(
                  product: product,
                  cartViewModel: cartViewModel,
                ),
              );
              // بعد از بسته شدن bottom sheet، سبد خرید رو refresh کن
              if (mounted) {
                cartViewModel.loadItems();
              }
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                gradient: AppGradients.softGoldCircle,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/add_shopping_cart.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}

