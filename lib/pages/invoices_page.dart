import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/invoice_service.dart';
import '../models/invoice_response.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_loading_widget.dart';
import '../utils/error_handler.dart';
import 'payment_page.dart';
import 'invoice_detail_page.dart';
import 'package:provider/provider.dart';
import '../viewmodels/cart_viewmodel.dart';
import 'package:intl/intl.dart';

class InvoicesPage extends StatefulWidget {
  final Function(int)? onInvoiceListChanged; // تعداد partial_paid را می‌فرستد
  
  const InvoicesPage({
    super.key,
    this.onInvoiceListChanged,
  });

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  final _invoiceService = InvoiceService();
  
  // لیست‌های جداگانه برای هر تب
  List<Invoice> _partialPaidInvoices = [];
  List<Invoice> _paidInvoices = [];
  List<Invoice> _cancelledInvoices = [];
  
  // Pagination state برای هر تب
  int _partialPaidPage = 1;
  int _paidPage = 1;
  int _cancelledPage = 1;
  bool _partialPaidHasMore = true;
  bool _paidHasMore = true;
  bool _cancelledHasMore = true;
  bool _partialPaidLoadingMore = false;
  bool _paidLoadingMore = false;
  bool _cancelledLoadingMore = false;
  int _partialPaidTotal = 0; // تعداد کل partial_paid
  int _paidTotal = 0;
  int _cancelledTotal = 0;
  
  int _selectedTabIndex = 0; // پیش‌فرض: تسویه ناتمام (اول)
  bool _isLoading = true;
  String? _errorMessage;
  final _currencyFormat = NumberFormat.decimalPattern();
  final ScrollController _scrollController = ScrollController();

  
  static const int _perPage = 20;

  String _format(double value) {
    if (value == 0) return '0';
    return _currencyFormat.format(value.round());
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadAllTabs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreForCurrentTab();
    }
  }

  Future<void> _loadAllTabs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _loadTabInvoices(0, reset: true),
        _loadTabInvoices(1, reset: true),
        _loadTabInvoices(2, reset: true),
      ]);

      setState(() {
        _isLoading = false;
      });
      
      // اطلاع دادن به parent که لیست تغییر کرده و ارسال تعداد کل partial_paid
      if (widget.onInvoiceListChanged != null) {
        widget.onInvoiceListChanged!(_partialPaidTotal);
      }
    } catch (e) {
      setState(() {
        _errorMessage = ErrorHandler.getFarsiErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTabInvoices(int tabIndex, {bool reset = false}) async {
    String? status;
    int page;
    
    switch (tabIndex) {
      case 0: // تسویه ناتمام
        status = 'partial_paid';
        if (reset) {
          _partialPaidPage = 1;
          _partialPaidInvoices.clear();
          _partialPaidHasMore = true;
        }
        page = _partialPaidPage;
        if (_partialPaidLoadingMore || (!_partialPaidHasMore && !reset)) {
          return;
        }
        _partialPaidLoadingMore = true;
        break;
      case 1: // پرداخت شده
        status = 'paid';
        if (reset) {
          _paidPage = 1;
          _paidInvoices.clear();
          _paidHasMore = true;
        }
        page = _paidPage;
        if (_paidLoadingMore || (!_paidHasMore && !reset)) {
          return;
        }
        _paidLoadingMore = true;
        break;
      case 2: // ابطال شده
        status = 'cancelled';
        if (reset) {
          _cancelledPage = 1;
          _cancelledInvoices.clear();
          _cancelledHasMore = true;
        }
        page = _cancelledPage;
        if (_cancelledLoadingMore || (!_cancelledHasMore && !reset)) {
          return;
        }
        _cancelledLoadingMore = true;
        break;
      default:
        return;
    }

    try {
      final response = await _invoiceService.getInvoices(
        status: status,
        page: page,
        perPage: _perPage,
      );

      setState(() {
        switch (tabIndex) {
          case 0:
            if (reset) {
              _partialPaidInvoices = response.data;
            } else {
              _partialPaidInvoices.addAll(response.data);
            }
            _partialPaidTotal = response.pagination.total;
            _partialPaidHasMore = response.data.length >= _perPage;
            if (_partialPaidHasMore) {
              _partialPaidPage++;
            }
            _partialPaidLoadingMore = false;
            break;
          case 1:
            if (reset) {
              _paidInvoices = response.data;
            } else {
              _paidInvoices.addAll(response.data);
            }
            _paidTotal = response.pagination.total;
            _paidHasMore = response.data.length >= _perPage;
            if (_paidHasMore) {
              _paidPage++;
            }
            _paidLoadingMore = false;
            break;
          case 2:
            if (reset) {
              _cancelledInvoices = response.data;
            } else {
              _cancelledInvoices.addAll(response.data);
            }
            _cancelledTotal = response.pagination.total;
            _cancelledHasMore = response.data.length >= _perPage;
            if (_cancelledHasMore) {
              _cancelledPage++;
            }
            _cancelledLoadingMore = false;
            break;
        }
      });
    } catch (e) {
      setState(() {
        switch (tabIndex) {
          case 0:
            _partialPaidLoadingMore = false;
            break;
          case 1:
            _paidLoadingMore = false;
            break;
          case 2:
            _cancelledLoadingMore = false;
            break;
        }
      });
      if (reset) {
        setState(() {
          _errorMessage = ErrorHandler.getFarsiErrorMessage(e);
        });
      }
    }
  }

  Future<void> _loadMoreForCurrentTab() async {
    await _loadTabInvoices(_selectedTabIndex, reset: false);
  }

  Future<void> _loadInvoices() async {
    await _loadAllTabs();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
      case 'completed':
        return Colors.green;
      case 'partial_paid':
        return AppColors.gold;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  // محاسبه تعداد فاکتورها بر اساس status
  int _getInvoiceCount(String status) {
    switch (status) {
      case 'partial_paid':
        return _partialPaidInvoices.length;
      case 'paid':
        return _paidInvoices.length;
      case 'cancelled':
        return _cancelledInvoices.length;
      default:
        return 0;
    }
  }

  // دریافت فاکتورهای فیلتر شده بر اساس تب انتخاب شده
  List<Invoice> get _filteredInvoices {
    switch (_selectedTabIndex) {
      case 0:
        return _partialPaidInvoices;
      case 1:
        return _paidInvoices;
      case 2:
        return _cancelledInvoices;
      default:
        return [];
    }
  }

  bool get _isLoadingMore {
    switch (_selectedTabIndex) {
      case 0:
        return _partialPaidLoadingMore;
      case 1:
        return _paidLoadingMore;
      case 2:
        return _cancelledLoadingMore;
      default:
        return false;
    }
  }

  bool get _hasMore {
    switch (_selectedTabIndex) {
      case 0:
        return _partialPaidHasMore;
      case 1:
        return _paidHasMore;
      case 2:
        return _cancelledHasMore;
      default:
        return false;
    }
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
              child: Text(
                'فاکتورها',
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                onPressed: _loadInvoices,
                tooltip: 'به‌روزرسانی',
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // تب‌های فیلتر
          _buildStatusTabs(),
          // محتوای فاکتورها
          Expanded(
            child: _isLoading
          ? const Center(
              child: AppLoadingWidget(
                size: 100,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadInvoices,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.white,
                        ),
                        child: const Text(
                          'تلاش مجدد',
                          style: TextStyle(fontFamily: 'Iranyekan'),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                      onRefresh: () async {
                        await _loadTabInvoices(_selectedTabIndex, reset: true);
                      },
                      color: AppColors.gold,
                      child: _filteredInvoices.isEmpty && !_isLoading
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.receipt_long,
                                    size: 64,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'هیچ فاکتوری یافت نشد',
                                    style: TextStyle(
                                      fontFamily: 'Iranyekan',
                                      fontSize: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredInvoices.length + (_hasMore && _filteredInvoices.isNotEmpty ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _filteredInvoices.length) {
                                  // نمایش loading indicator برای صفحه بعدی
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                      child: AppSmallLoadingWidget(
                                        size: 20,
                                      ),
                                    ),
                                  );
                                }
                                final invoice = _filteredInvoices[index];
                                return _buildInvoiceCard(invoice);
                              },
                            ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(30),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // تب تسویه ناتمام (اول)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildStatusTab(
                title: 'تسویه ناتمام',
                count: _partialPaidInvoices.length,
                index: 0,
                badgeColor: const Color(0xFF8B6914), // قهوه‌ای تیره
              ),
            ),
            // تب پرداخت شده
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildStatusTab(
                title: 'پرداخت شده',
                count: _paidInvoices.length,
                index: 1,
                badgeColor: const Color(0xFF10B981), // سبز روشن
              ),
            ),
            // تب ابطال شده
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildStatusTab(
                title: 'ابطال شده',
                count: _cancelledInvoices.length,
                index: 2,
                badgeColor: const Color(0xFFF87171), // صورتی
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTab({
    required String title,
    required int count,
    required int index,
    required Color badgeColor,
  }) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
        // اگر تب انتخاب شده خالی است، داده‌های آن را لود کن
        if ((index == 0 && _partialPaidInvoices.isEmpty) ||
            (index == 1 && _paidInvoices.isEmpty) ||
            (index == 2 && _cancelledInvoices.isEmpty)) {
          _loadTabInvoices(index, reset: true);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.softGoldChip : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Iranyekan',
                color: isSelected ? AppColors.textPrimaryAlt : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            // فقط برای تب تسویه ناتمام (index 0) و فقط اگر تعداد بیشتر از 0 باشد
            if (index == 0 && count > 0) ...[
              const SizedBox(width: 6),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      fontFamily: 'Iranyekan',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => InvoiceDetailPage(invoiceId: invoice.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // هدر فاکتور
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (invoice.sellerInvoiceNumber != null && invoice.sellerInvoiceNumber!.isNotEmpty)
                    Text(
                      invoice.sellerInvoiceNumber!,
                      style: const TextStyle(
                        fontFamily: 'Iranyekan',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryAlt,
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  // دکمه ابطال فاکتور - فقط اگر allow_cancel = true باشد
                  if (invoice.tax?.allowCancel == true) ...[
                    OutlinedButton.icon(
                      onPressed: () => _cancelInvoice(invoice),
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text(
                        'ابطال',
                        style: TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                          color: AppColors.error.withOpacity(0.5),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // status_label در گوشه بالا
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(invoice.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(invoice.status).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      invoice.statusLabel,
                      style: TextStyle(
                        fontFamily: 'Iranyekan',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(invoice.status),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // تاریخ و مبلغ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    invoice.issuedAt,
                    style: const TextStyle(
                      fontFamily: 'Iranyekan',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                '${_format(invoice.totalAmount)} ریال',
                style: const TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // شماره مالیاتی
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'شماره مالیاتی:',
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                invoice.taxId,
                style: const TextStyle(
                  fontFamily: 'Tahoma',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryAlt,
                ),
              ),
            ],
          ),
          // وضعیت ارسال به دارایی (tax.app_status_label)
          if (invoice.tax?.appStatusLabel != null && invoice.tax!.appStatusLabel!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'وضعیت ارسال به دارایی:',
                  style: TextStyle(
                    fontFamily: 'Iranyekan',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    invoice.tax!.appStatusLabel!,
                    style: const TextStyle(
                      fontFamily: 'Iranyekan',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          // لیست محصولات
          Text(
            'محصولات:',
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ...invoice.invoiceItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.productName,
                      style: const TextStyle(
                        fontFamily: 'Iranyekan',
                        fontSize: 12,
                        color: AppColors.textPrimaryAlt,
                      ),
                    ),
                  ),
                  Text(
                    '${_format(item.totalAmount)} ریال',
                    style: const TextStyle(
                      fontFamily: 'Iranyekan',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
          
          // دکمه‌های عملیات
          if (_selectedTabIndex == 0 || _selectedTabIndex == 1 || (invoice.tax != null && invoice.tax!.allowSubmit)) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                // دکمه پرداخت فاکتور - فقط برای تب تسویه ناتمام (index 0)
                if (_selectedTabIndex == 0) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _navigateToPayment(invoice),
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
                  const SizedBox(width: 8),
                ],
                // دکمه ارسال به دارایی - اگر allow_submit = true باشد
                if (invoice.tax != null && invoice.tax!.allowSubmit) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _submitTax(invoice),
                      icon: const Icon(Icons.send, size: 16),
                      label: const Text(
                        'ارسال به دارایی',
                        style: TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
      ),
    );
  }

  Future<void> _navigateToPayment(Invoice invoice) async {
    // دریافت CartViewModel از Provider
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    
    // Navigate to payment page
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          cartViewModel: cartViewModel,
          invoiceId: invoice.id
        ),
      ),
    );
    
    // اگر پرداخت موفق بود، لیست فاکتورها را به‌روزرسانی کن
    if (result == true && mounted) {
      // فقط تب‌های مربوطه را به‌روزرسانی کن
      await Future.wait([
        _loadTabInvoices(0, reset: true), // تسویه ناتمام
        _loadTabInvoices(1, reset: true), // پرداخت شده
      ]);
      // اطلاع دادن به parent که لیست تغییر کرده و ارسال تعداد کل partial_paid
      if (widget.onInvoiceListChanged != null) {
        widget.onInvoiceListChanged!(_partialPaidTotal);
      }
    }
  }

  Future<void> _cancelInvoice(Invoice invoice) async {
    // نمایش دیالوگ تایید
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'ابطال فاکتور',
          style: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'آیا از ابطال فاکتور ${invoice.sellerInvoiceNumber ?? invoice.id.toString()} اطمینان دارید؟',
          style: const TextStyle(
            fontFamily: 'Iranyekan',
          ),
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
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text(
              'ابطال',
              style: TextStyle(
                fontFamily: 'Iranyekan',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // نمایش loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: AppLoadingWidget(
            size: 80,
          ),
        ),
      );
    }

    try {
      await _invoiceService.cancelInvoice(invoice.id);

      // بستن loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      // نمایش پیام موفقیت
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'فاکتور با موفقیت ابطال شد',
              style: TextStyle(
                fontFamily: 'Iranyekan',
              ),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // به‌روزرسانی لیست‌های فاکتور
      if (mounted) {
        await Future.wait([
          _loadTabInvoices(0, reset: true), // تسویه ناتمام
          _loadTabInvoices(1, reset: true), // پرداخت شده
          _loadTabInvoices(2, reset: true), // ابطال شده
        ]);
        
        // اطلاع دادن به parent که لیست تغییر کرده
        if (widget.onInvoiceListChanged != null) {
          widget.onInvoiceListChanged!(_partialPaidTotal);
        }
      }
    } catch (e) {
      // بستن loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      // نمایش پیام خطا
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطا در ابطال فاکتور: ${ErrorHandler.getFarsiErrorMessage(e)}',
              style: const TextStyle(
                fontFamily: 'Iranyekan',
              ),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _submitTax(Invoice invoice) async {
    // نمایش دیالوگ تایید
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'ارسال به دارایی',
          style: TextStyle(
            fontFamily: 'Iranyekan',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید این فاکتور را به دارایی ارسال کنید؟',
          style: TextStyle(
            fontFamily: 'Iranyekan',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'انصراف',
              style: TextStyle(
                fontFamily: 'Iranyekan',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: AppColors.white,
            ),
            child: const Text(
              'تایید',
              style: TextStyle(
                fontFamily: 'Iranyekan',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // نمایش loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: AppLoadingWidget(
            size: 80,
          ),
        ),
      );
    }

    try {
      await _invoiceService.submitTax(invoice.id);

      // بستن loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      // نمایش پیام موفقیت
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'فاکتور با موفقیت به دارایی ارسال شد',
              style: TextStyle(
                fontFamily: 'Iranyekan',
              ),
            ),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // به‌روزرسانی لیست فاکتورها
      if (mounted) {
        await Future.wait([
          _loadTabInvoices(0, reset: true), // تسویه ناتمام
          _loadTabInvoices(1, reset: true), // پرداخت شده
          _loadTabInvoices(2, reset: true), // ابطال شده
        ]);
        
        // اطلاع دادن به parent که لیست تغییر کرده
        if (widget.onInvoiceListChanged != null) {
          widget.onInvoiceListChanged!(_partialPaidTotal);
        }
      }
    } catch (e) {
      // بستن loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      // نمایش پیام خطا
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطا در ارسال فاکتور به دارایی: ${ErrorHandler.getFarsiErrorMessage(e)}',
              style: const TextStyle(
                fontFamily: 'Iranyekan',
              ),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}


