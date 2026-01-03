import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../models/cart_item.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as persian_date;
import '../widgets/app_drawer.dart';
import '../widgets/product_pricing_bottom_sheet.dart';
import 'invoice_info_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Map<int, bool> _expandedItems = {}; // برای نگهداری وضعیت expand/collapse هر محصول
  final _currencyFormat = NumberFormat.decimalPattern();

  @override
  void initState() {
    super.initState();
    // بارگذاری آیتم‌ها از دیتابیس هنگام باز شدن صفحه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartViewModel>(context, listen: false).loadItems();
    });
  }

  String _format(double value) {
    if (value == 0) return '0';
    return _currencyFormat.format(value.round());
  }

  void _toggleExpand(int itemId) {
    setState(() {
      _expandedItems[itemId] = !(_expandedItems[itemId] ?? false);
    });
  }

  Future<void> _clearCart() async {
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    await cartViewModel.clear();
    await cartViewModel.clearMetadata();
    setState(() {
      _expandedItems.clear();
    });
  }

  Future<void> _showClearCartDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تأیید حذف',
          style: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید تمام محصولات سبد خرید را حذف کنید؟',
          style: TextStyle(
            fontFamily: 'Iranyekan',
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'انصراف',
              style: TextStyle(
                fontFamily: 'Iranyekan',
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'حذف',
              style: TextStyle(
                fontFamily: 'Iranyekan',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await _clearCart();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('سبد خرید با موفقیت پاک شد'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _showDeleteItemDialog(CartItem item, CartViewModel cartViewModel) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تأیید حذف',
          style: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'آیا مطمئن هستید که می‌خواهید "${item.product.name}" را از سبد خرید حذف کنید؟',
          style: const TextStyle(
            fontFamily: 'Iranyekan',
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'انصراف',
              style: TextStyle(
                fontFamily: 'Iranyekan',
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'حذف',
              style: TextStyle(
                fontFamily: 'Iranyekan',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final itemId = item.id;
      if (itemId != null) {
        await cartViewModel.removeItem(itemId);
        setState(() {
          _expandedItems.remove(itemId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('محصول با موفقیت حذف شد'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _submitOrder() async {
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    
    if (cartViewModel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('سبد خرید خالی است'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // هدایت به صفحه اطلاعات فاکتور
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InvoiceInfoPage(
          cartViewModel: cartViewModel,
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _buildOrderJson(CartViewModel cartViewModel) async {
    final invoiceItems = cartViewModel.items
        .map((item) => item.toInvoiceItemJson())
        .toList();

    // دریافت metadata از دیتابیس
    final metadata = await cartViewModel.getMetadata();
    
    return {
      'description': metadata?['description'],
      'customer': {
        'type': metadata?['customer_type'],
        'mobile': metadata?['customer_mobile'],
        'name': metadata?['customer_name'],
        'national_code': metadata?['customer_national_code'],
      },
      'invoice': {
        'type': metadata?['invoice_type'],
        'seller_invoice_number': metadata?['seller_invoice_number'],
        'issued_at': metadata?['issued_at'] ?? persian_date.PersianDateUtils.getCurrentPersianDate(),
        'total_amount': cartViewModel.totalAmount.round(),
        'total_wage': cartViewModel.totalWage.round(),
        'total_profit': cartViewModel.totalProfit.round(),
        'total_commission': cartViewModel.totalCommission.round(),
        'total_tax': cartViewModel.totalTax.round(),
      },
      'invoice_items': invoiceItems,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      drawer: const AppDrawer(),
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
              child: Text('سبد خرید'),
            ),
            centerTitle: true,
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
      body: Consumer<CartViewModel>(
        builder: (context, cartViewModel, child) {
          if (cartViewModel.isEmpty) {
            return const Center(
              child: Text(
                'سبد خرید خالی است',
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // بخش خلاصه سبد خرید
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'جمع کل',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Iranyekan',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimaryAlt,
                          ),
                        ),
                        Text(
                          '${_format(cartViewModel.totalAmount)} ریال',
                          style: const TextStyle(
                            fontFamily: 'Iranyekan',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'پرداخت فاکتور',
                              style: TextStyle(
                                fontFamily: 'Iranyekan',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showClearCartDialog(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.titleBrown,
                                width: 1,
                              ),
                              foregroundColor: AppColors.titleBrown,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'حذف سبد خرید',
                              style: TextStyle(
                                fontFamily: 'Iranyekan',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // لیست محصولات
              ...cartViewModel.items.map((item) {
                return _buildCartItemCard(item, cartViewModel);
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item, CartViewModel cartViewModel) {
    final itemId = item.id ?? 0;
    final isExpanded = _expandedItems[itemId] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dividerSoft,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // هدر محصول (قابل کلیک برای expand/collapse)
          InkWell(
            onTap: () => _toggleExpand(itemId),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.product.name,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Iranyekan',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimaryAlt,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.iconBrown,
                  ),
                ],
              ),
            ),
          ),
          
          // بخش قیمت (فقط در حالت collapse نمایش داده می‌شود)
          if (!isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'مبلغ نهایی محصول',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Iranyekan',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${_format(item.totalAmount)}',
                        style: const TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryAlt,
                        ),
                      ),
                      Text(
                        ' ریال',
                        style: const TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // جزئیات محصول (فقط وقتی expand شده نمایش داده می‌شود)
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.dividerSoft),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // نمایش وزن یا تعداد بر اساس نوع محصول
                  if (item.product.type == 'count')
                    _buildDetailRow('تعداد', '${item.count}','عدد')
                  else
                    _buildDetailRow('وزن کل', '${_format(item.weight)}','گرم'),
                  const SizedBox(height: 12),
                  _buildDetailRow('عیار کالا', item.purity,''),
                  const SizedBox(height: 12),
                  _buildDetailRow('مبلغ واحد كل', '${_format(item.totalUnitAmount)}','ریال'),
                  const SizedBox(height: 12),
                  _buildDetailRow('مبلغ اجرت كل', '${_format(item.totalWageAmount)}','ریال'),
                  const SizedBox(height: 12),
                  _buildDetailRow('سود فروش', '${_format(item.profitAmount)}','ریال'),
                  const SizedBox(height: 12),
                  _buildDetailRow('مالیات', '${_format(item.taxAmount)}','ریال'),
                  const SizedBox(height: 12),
                  _buildDetailRow('حق العمل', '${_format(item.commissionAmount)}','ریال'),
                  const SizedBox(height: 16),
                  // خط جداکننده قبل از مبلغ نهایی
                  const Divider(height: 1, color: AppColors.dividerSoft),
                  const SizedBox(height: 16),
                  // مبلغ نهایی محصول (بزرگ و بولد)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'مبلغ نهایی محصول',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryAlt,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${_format(item.totalAmount)}',
                            style: const TextStyle(
                              fontFamily: 'Iranyekan',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryAlt,
                            ),
                          ),
                          Text(
                            ' ریال',
                            style: const TextStyle(
                              fontFamily: 'Iranyekan',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // دکمه‌های ویرایش و حذف
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ProductPricingBottomSheet(
                                product: item.product,
                                cartViewModel: cartViewModel,
                                existingCartItem: item,
                              ),
                            );
                            // بعد از بسته شدن bottom sheet، سبد خرید رو refresh کن
                            if (mounted) {
                              cartViewModel.loadItems();
                            }
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.gold,
                            size: 18,
                          ),
                          label: const Text(
                            'ویرایش',
                            style: TextStyle(
                              fontFamily: 'Iranyekan',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.gold,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showDeleteItemDialog(item, cartViewModel),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.iconBrown,
                            size: 18,
                          ),
                          label: const Text(
                            'حذف',
                            style: TextStyle(
                              fontFamily: 'Iranyekan',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.titleBrown,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.titleBrown,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,String suffix) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontFamily: 'Iranyekan',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: 'Iranyekan',
                fontSize: 14,
                color: AppColors.textPrimaryAlt,
              ),
            ),
            SizedBox(width: 5,),
            Text(
              suffix,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: 'Iranyekan',
                fontSize: 14,
                color: AppColors.titleBrown,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
