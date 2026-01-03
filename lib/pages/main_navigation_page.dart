import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zar360/theme/app_theme.dart';
import '../viewmodels/products_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/search_viewmodel.dart';
import '../services/invoice_service.dart';
import 'products_home_page.dart';
import 'search_page.dart';
import 'cart_page.dart';
import 'invoices_page.dart';

class MainNavigationPage extends StatefulWidget {
  final String accessToken;
  final int initialIndex;

  const MainNavigationPage({
    super.key,
    required this.accessToken,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with TickerProviderStateMixin {
  late int _currentIndex;
  List<AnimationController>? _iconControllers;
  int _partialPaidInvoiceCount = 0;
  final _invoiceService = InvoiceService();

  List<AnimationController> get iconControllers {
    if (_iconControllers == null) {
      // استفاده از widget.initialIndex به عنوان fallback
      final selectedIndex = widget.initialIndex;
      _iconControllers = List.generate(
        4,
        (index) => AnimationController(
          duration: const Duration(milliseconds: 250),
          vsync: this,
          value: index == selectedIndex ? 1.0 : 0.0,
        ),
      );
    }
    return _iconControllers!;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // مقداردهی اولیه iconControllers برای اطمینان از ساخت آن
    // و تنظیم انیمیشن برای تب انتخاب شده اولیه
    final controllers = iconControllers;
    if (_currentIndex < controllers.length) {
      controllers[_currentIndex].value = 1.0;
    }
    // بارگذاری تعداد فاکتورهای تسویه ناتمام
    _loadPartialPaidInvoiceCount();
  }

  // به‌روزرسانی تعداد از callback بدون نیاز به کال API
  void _updatePartialPaidInvoiceCount(int count) {
    if (mounted) {
      setState(() {
        _partialPaidInvoiceCount = count;
      });
    }
  }

  // فقط برای لود اولیه در initState استفاده می‌شود
  Future<void> _loadPartialPaidInvoiceCount() async {
    try {
      final response = await _invoiceService.getInvoices(
        status: 'partial_paid',
        page: 1,
        perPage: 1, // فقط برای شمارش، یک آیتم کافی است
      );
      if (mounted) {
        setState(() {
          // استفاده از total از pagination برای نمایش تعداد کل
          _partialPaidInvoiceCount = response.pagination.total;
        });
      }
    } catch (e) {
      // در صورت خطا، تعداد را 0 نگه دار
      if (mounted) {
        setState(() {
          _partialPaidInvoiceCount = 0;
        });
      }
    }
  }

  @override
  void dispose() {
    _iconControllers?.forEach((controller) {
      controller.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsViewModel()),
        ChangeNotifierProvider(
          create: (_) {
            final cartViewModel = CartViewModel();
            // لود خودکار سبد خرید در شروع برنامه
            WidgetsBinding.instance.addPostFrameCallback((_) {
              cartViewModel.loadItems();
            });
            return cartViewModel;
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final searchViewModel = SearchViewModel();
            // بعد از ساخت، از کش یا سرور لود کن
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final productsViewModel = Provider.of<ProductsViewModel>(context, listen: false);
              searchViewModel.initFromGlobalProducts(productsViewModel: productsViewModel);
            });
            return searchViewModel;
          },
        ),
      ],
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
                child: child,
            );
          },
          child: _buildPageContent(),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildPageContent() {
    switch (_currentIndex) {
      case 0:
        return ProductsHomePageContent(
          key: const ValueKey<int>(0),
          accessToken: widget.accessToken,
        );
      case 1:
        return const SearchPageContent(
          key: ValueKey<int>(1),
        );
      case 2:
        return const CartPage(
          key: ValueKey<int>(2),
        );
      case 3:
        return InvoicesPage(
          key: ValueKey<int>(3),
          onInvoiceListChanged: _updatePartialPaidInvoiceCount,
        );
      default:
        return ProductsHomePageContent(
          key: const ValueKey<int>(0),
          accessToken: widget.accessToken,
        );
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Consumer<CartViewModel>(
        builder: (context, cartViewModel, child) {
          return SafeArea(
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  _buildAnimatedNavItem(
                    icon: 'assets/images/storefront.png',
                    label: 'محصولات',
                    index: 0,
                    context: context,
                  ),
                  _buildAnimatedNavItem(
                    icon: 'assets/images/search.png',
                    label: 'جستجو',
                    index: 1,
                    context: context,
                  ),
                  _buildAnimatedNavItemWithBadge(
                    icon: 'assets/images/shopping_cart.png',
                    label: 'سبد خرید',
                    index: 2,
                    itemCount: cartViewModel.itemCount,
                    context: context,
                  ),
                  _partialPaidInvoiceCount > 0
                      ? _buildAnimatedNavItemWithBadge(
                          icon: 'assets/images/receipt_long.png',
                          label: 'فاکتورها',
                          index: 3,
                          itemCount: _partialPaidInvoiceCount,
                          context: context,
                        )
                      : _buildAnimatedNavItem(
                          icon: 'assets/images/receipt_long.png',
                          label: 'فاکتورها',
                          index: 3,
                          context: context,
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onNavItemTapped(int index, BuildContext context) {
    if (index == _currentIndex) return;
    
    // متوقف کردن انیمیشن قبلی
    if (_currentIndex < iconControllers.length) {
      iconControllers[_currentIndex].reverse();
    }
    
    setState(() {
      _currentIndex = index;
    });
    
    // شروع انیمیشن جدید
    if (index < iconControllers.length) {
      iconControllers[index].forward();
    }
    
    // اگر تب سبد خرید باز شد، آیتم‌ها رو لود کن
    if (index == 2) {
      final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
      cartViewModel.loadItems();
    }
    // اگر تب فاکتورها باز شد، تعداد از طریق callback به‌روزرسانی می‌شود
    // نیازی به کال اضافی نیست
  }

  Widget _buildAnimatedNavItem({
    required String icon,
    required String label,
    required int index,
    required BuildContext context,
  }) {
    final isSelected = _currentIndex == index;
    final animation = iconControllers[index];
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavItemTapped(index, context),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final scale = Tween<double>(begin: 1.0, end: 1.1).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            ).value;
            
            final backgroundColor = Color.lerp(
              Colors.transparent,
              const Color(0xFFEDEBDF),
              animation.value,
            );
            
            return Transform.scale(
              scale: scale,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Image.asset(
                        icon,
                        width: 22,
                        height: 22,
                        color: Color.lerp(
                          const Color(0xFF6B7280),
                          const Color(0xFF1C1B1F),
                          animation.value,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      style: TextStyle(
                        fontFamily: 'Iranyekan',
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: Color.lerp(
                          const Color(0xFF6B7280),
                          const Color(0xFF1C1B1F),
                          animation.value,
                        ),
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedNavItemWithBadge({
    required String icon,
    required String label,
    required int index,
    required int itemCount,
    required BuildContext context,
  }) {
    // فقط اگر تعداد بیشتر از 0 باشد badge نمایش داده می‌شود
    if (itemCount <= 0) {
      return _buildAnimatedNavItem(
        icon: icon,
        label: label,
        index: index,
        context: context,
      );
    }
    final isSelected = _currentIndex == index;
    final animation = iconControllers[index];
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavItemTapped(index, context),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final scale = Tween<double>(begin: 1.0, end: 1.1).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            ).value;
            
            final backgroundColor = Color.lerp(
              Colors.transparent,
              const Color(0xFFEDEBDF),
              animation.value,
            );
            
            return Transform.scale(
              scale: scale,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: Image.asset(
                            icon,
                            width: 22,
                            height: 22,
                            color: Color.lerp(
                              const Color(0xFF6B7280),
                              const Color(0xFF1C1B1F),
                              animation.value,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          style: TextStyle(
                            fontFamily: 'Iranyekan',
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: Color.lerp(
                              const Color(0xFF6B7280),
                              const Color(0xFF1C1B1F),
                              animation.value,
                            ),
                          ),
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right:10,
                      top: 0,
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                          maxWidth: itemCount > 99 ? 28 : 20,
                          maxHeight: itemCount > 99 ? 28 : 20,
                        ),
                        padding: itemCount > 99 
                            ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                            : EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            itemCount > 99 ? '99+' : itemCount.toString(),
                            style: TextStyle(
                              fontFamily: 'Iranyekan',
                              fontSize: itemCount > 99 ? 8 : 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

}

