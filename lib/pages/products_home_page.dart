import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:zar360/theme/app_theme.dart';
import '../viewmodels/products_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../models/product_response.dart';
import '../services/storage_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/product_pricing_bottom_sheet.dart';

class ProductsHomePage extends StatelessWidget {
  final String accessToken;

  const ProductsHomePage({
    super.key,
    required this.accessToken,
  });

  @override
  Widget build(BuildContext context) {
    return ProductsHomePageContent(accessToken: accessToken);
  }
}

// محتوای صفحه محصولات بدون Provider (چون در MainNavigationPage تعریف شده)
class ProductsHomePageContent extends StatelessWidget {
  final String accessToken;
  
  const ProductsHomePageContent({
    super.key,
    required this.accessToken,
  });

  @override
  Widget build(BuildContext context) {
    return _ProductsHomePageContent(accessToken: accessToken);
  }
}

class _ProductsHomePageContent extends StatefulWidget {
  final String accessToken;
  
  const _ProductsHomePageContent({required this.accessToken});

  @override
  State<_ProductsHomePageContent> createState() => _ProductsHomePageContentState();
}

class _ProductsHomePageContentState extends State<_ProductsHomePageContent> {
  @override
  void initState() {
    super.initState();
    // لود خودکار محصولات در صورت خالی بودن
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final viewModel =
            Provider.of<ProductsViewModel>(context, listen: false);
        // اگر محصولات کش نشده یا خالی است و در حال لود نیست، لود کن
        if (!viewModel.isLoading && viewModel.allProducts.isEmpty) {
          viewModel.loadProducts(widget.accessToken);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProductsViewModel>(context);

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
              child: Text('محصولات'),
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
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'به‌روزرسانی محصولات',
                onPressed: () {
                  final viewModel = Provider.of<ProductsViewModel>(
                    context,
                    listen: false,
                  );
                  viewModel.loadProducts(widget.accessToken);
                },
              ),
            ],
          ),
        ),
      ),
        drawer: const AppDrawer(),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundAlt,
          ),
          child: Column(
          children: [
            // Rounded Tabs - فقط وقتی products لود شده‌اند نمایش بده
            if (viewModel.categories.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.cardSoft,
                borderRadius: BorderRadius.circular(30),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    viewModel.categories.length,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildRoundedTab(
                        context,
                        viewModel.categories[index],
                        index,
                        viewModel.selectedTabIndex == index,
                        () => viewModel.selectTab(index),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        
            // Products List / Loading
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                viewModel.errorMessage!,
                                style: const TextStyle(
                                  fontFamily: 'Iranyekan',
                                  fontSize: 16,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  viewModel.clearError();
                                  viewModel.loadProducts(widget.accessToken);
                                },
                                child: const Text('تلاش مجدد'),
                              ),
                            ],
                          ),
                        )
                      : viewModel.filteredProducts.isEmpty
                          ? const Center(
                              child: Text(
                                'محصولی یافت نشد',
                                style: TextStyle(
                                  fontFamily: 'Iranyekan',
                                  fontSize: 16,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: viewModel.filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = viewModel.filteredProducts[index];
                                return _buildProductCard(context, product);
                              },
                            ),
            ),
          ],
          ),
        ),
      ),
      // bottomNavigationBar حذف شد چون در MainNavigationPage تعریف شده
    );
  }


  Widget _buildRoundedTab(
    BuildContext context,
    String title,
    int index,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.softGoldChip : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Iranyekan',
            color: isSelected ? AppColors.textPrimaryAlt : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return InkWell(
      onTap: () => _showProductBottomSheet(context, product),
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
            // Icon with Gradient Background (moved to left/end)
            Container(
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
          ],
        ),
      ),
    );
  }

  Future<void> _showProductBottomSheet(BuildContext context, Product product) async {
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
  }


}

