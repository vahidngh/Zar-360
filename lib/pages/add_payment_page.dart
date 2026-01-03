import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../theme/app_theme.dart';
import '../models/payment_record.dart';
import '../utils/pay_util.dart';
import '../widgets/form_input_field.dart';
import '../services/payment_service.dart';
import '../services/invoice_service.dart';
import '../models/cart_item.dart';
import '../utils/error_handler.dart';

class AddPaymentPage extends StatefulWidget {
  final double remainingAmount;
  final Function(PaymentRecord)? onPaymentAdded; // اختیاری - اگر null باشد، بعد از بازگشت اطلاعات از API بارگذاری می‌شود
  final int? invoiceId; // برای فراخوانی API (اگر null باشد، باید فاکتور ایجاد شود)
  final Map<String, dynamic>? invoiceData; // اطلاعات فاکتور برای ایجاد (اگر invoiceId null باشد)
  final VoidCallback? onInvoiceCreated; // callback برای وقتی که فاکتور برای اولین بار ایجاد شد

  const AddPaymentPage({
    super.key,
    required this.remainingAmount,
    this.onPaymentAdded,
    this.invoiceId,
    this.invoiceData,
    this.onInvoiceCreated,
  });

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  String? selectedType;
  final amountController = TextEditingController();
  final weightController = TextEditingController(); // برای پرداخت با طلا
  final unitAmountController = TextEditingController(); // برای پرداخت با طلا
  final purityController = TextEditingController(text: '740'); // عیار کالا با مقدار پیش‌فرض 740
  final _currencyFormat = NumberFormat.decimalPattern();
  final _paymentService = PaymentService();
  final _invoiceService = InvoiceService();
  bool _isSubmitting = false;

  String _format(double value) {
    if (value == 0) return '0';
    return _currencyFormat.format(value.round());
  }


  // دریافت اطلاعات دستگاه برای بررسی سازنده
  Future<String?> _getDeviceManufacturer() async {
    const platform = MethodChannel('my_channel');
    try {
      final String? deviceInfoJson = await platform.invokeMethod('getDeviceInfo');
      if (deviceInfoJson != null) {
        final Map<String, dynamic> deviceInfo = jsonDecode(deviceInfoJson);
        return deviceInfo['brand'] as String?;
      }
    } catch (e) {
      debugPrint('خطا در دریافت اطلاعات دستگاه: $e');
    }
    return null;
  }

  @override
  void dispose() {
    amountController.dispose();
    weightController.dispose();
    unitAmountController.dispose();
    purityController.dispose();
    super.dispose();
  }

  // محاسبه مبلغ وارد شده و باقیمانده
  double get _enteredAmount {
    // اگر نوع طلا است، از وزن و مبلغ واحد محاسبه کن
    if (selectedType == 'gold') {
      try {
        final weightText = weightController.text.replaceAll(',', '');
        final unitAmountText = unitAmountController.text.replaceAll(',', '');
        final weight = double.tryParse(weightText) ?? 0;
        final unitAmount = double.tryParse(unitAmountText) ?? 0;
        return weight * unitAmount;
      } catch (e) {
        return 0;
      }
    }
    
    // برای سایر انواع، از فیلد مبلغ استفاده کن
    try {
      final amountText = amountController.text.replaceAll(',', '');
      return double.tryParse(amountText) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  double get _remainingAfterEntry {
    // استفاده از مقدار رند شده برای هر دو تا از مشکلات floating point precision جلوگیری کنیم
    final roundedRemaining = widget.remainingAmount.round();
    final roundedEntered = _enteredAmount.round();
    return (roundedRemaining - roundedEntered).toDouble();
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
                'افزودن پرداخت جدید',
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            centerTitle: true,
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Container مشترک برای همه فیلدها
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // انتخاب نوع پرداخت
                  const Text(
                    'نوع پرداخت',
                    style: TextStyle(
                      fontFamily: 'Iranyekan',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.dividerSoft,
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedType,
                      style: const TextStyle(
                        fontFamily: 'Iranyekan',
                        fontSize: 14,
                        color: AppColors.textPrimaryAlt,
                      ),
                      decoration: InputDecoration(
                        labelText: 'نوع پرداخت را انتخاب کنید',
                        labelStyle: const TextStyle(
                          fontFamily: 'Iranyekan',
                          color: AppColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.gold,
                            width: 1.2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      dropdownColor: AppColors.white,
                      items: [
                        DropdownMenuItem(
                          value: 'cash',
                          child: Row(
                            children: [
                              const Icon(Icons.money, color: AppColors.gold, size: 20),
                              const SizedBox(width: 12),
                              const Text(
                                'نقدی',
                                style: TextStyle(
                                  fontFamily: 'Iranyekan',
                                  color: AppColors.textPrimaryAlt,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'gold',
                          child: Row(
                            children: [
                              const Icon(Icons.diamond, color: AppColors.gold, size: 20),
                              const SizedBox(width: 12),
                              const Text(
                                'طلا',
                                style: TextStyle(
                                  fontFamily: 'Iranyekan',
                                  color: AppColors.textPrimaryAlt,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'card',
                          child: Row(
                            children: [
                              const Icon(Icons.credit_card, color: AppColors.gold, size: 20),
                              const SizedBox(width: 12),
                              const Text(
                                'کارت',
                                style: TextStyle(
                                  fontFamily: 'Iranyekan',
                                  color: AppColors.textPrimaryAlt,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedType = value;
                          // اگر نوع تغییر کرد، فیلدها را پاک کن
                          if (value != 'gold') {
                            weightController.clear();
                            unitAmountController.clear();
                            purityController.text = '740'; // بازگشت به مقدار پیش‌فرض
                          } else {
                            amountController.clear();
                          }
                        });
                      },
                    ),
                  ),
                  
                  // فیلدهای مخصوص پرداخت با طلا
                  if (selectedType == 'gold') ...[
                    const SizedBox(height: 16),
                    _buildLabeledField(
                      label: 'وزن کل',
                      suffix: 'گرم',
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      isNumeric: true,
                      onChanged: (value) {
                        setState(() {
                          // محاسبه خودکار مبلغ
                          _updateGoldAmount();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildLabeledField(
                      label: 'مبلغ واحد',
                      suffix: 'ریال',
                      controller: unitAmountController,
                      keyboardType: TextInputType.number,
                      isNumeric: true,
                      isNaturalNumberOnly: true, // فقط اعداد طبیعی بزرگتر از 0
                      onChanged: (value) {
                        setState(() {
                          // محاسبه خودکار مبلغ
                          _updateGoldAmount();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildLabeledField(
                      label: 'عیار کالا',
                      suffix: null,
                      controller: purityController,
                      keyboardType: TextInputType.number,
                      isNumeric: true,
                      isNaturalNumberOnly: true, // فقط اعداد طبیعی بزرگتر از 0
                    ),
                    const SizedBox(height: 16),
                    _buildLabeledField(
                      label: 'مبلغ کل',
                      suffix: 'ریال',
                      controller: amountController,
                      enabled: false,
                      hintText: 'مبلغ به صورت خودکار محاسبه می‌شود',
                      isNumeric: true,
              ),
                    if (_enteredAmount > 0) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          'باقیمانده: ${_format(_remainingAfterEntry)} ریال',
                    style: TextStyle(
                      fontFamily: 'Iranyekan',
                            fontSize: 12,
                            color: _remainingAfterEntry < 0
                                ? AppColors.error
                                : _remainingAfterEntry == 0
                                    ? AppColors.gold
                                    : AppColors.textSecondary,
                            fontWeight: _remainingAfterEntry <= 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                      ),
                    ],
                  ] else if (selectedType != null) ...[
                    // مبلغ (برای سایر انواع پرداخت)
                    const SizedBox(height: 16),
                    _buildLabeledField(
                      label: 'مبلغ',
                      suffix: 'ریال',
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      isNumeric: true,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        // استفاده از مقدار رند شده برای جلوگیری از مشکل اعشار
                        final roundedRemaining = widget.remainingAmount.round();
                        amountController.text = _format(roundedRemaining.toDouble());
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'حداکثر ${_format(widget.remainingAmount)} ریال',
                            style: TextStyle(
                              fontFamily: 'Iranyekan',
                              fontSize: 12,
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_upward,
                            size: 16,
                            color: AppColors.gold,
                          ),
                        ],
                      ),
                    ),
                  ),
                    if (_enteredAmount > 0) ...[
                      const SizedBox(height: 8),
                  Padding(
                        padding: const EdgeInsets.only(right: 4),
                      child: Text(
                          'باقیمانده: ${_format(_remainingAfterEntry)} ریال',
                        style: TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 12,
                          color: _remainingAfterEntry < 0
                              ? AppColors.error
                              : _remainingAfterEntry == 0
                                  ? AppColors.gold
                                  : AppColors.textSecondary,
                          fontWeight: _remainingAfterEntry <= 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // دکمه افزودن
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: (_isSubmitting || 
                    selectedType == null || 
                    (selectedType == 'gold' 
                        ? (weightController.text.isEmpty || unitAmountController.text.isEmpty || purityController.text.isEmpty)
                        : amountController.text.isEmpty))
                    ? null
                    : () => _handleAddPayment(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_isSubmitting || 
                      selectedType == null || 
                      (selectedType == 'gold' 
                          ? (weightController.text.isEmpty || unitAmountController.text.isEmpty)
                          : amountController.text.isEmpty))
                      ? AppColors.textMuted
                      : AppColors.gold,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: SpinKitFoldingCube(
                          color: AppColors.white,
                          size: 20.0,
                        ),
                      )
                    : const Text(
                        'افزودن پرداخت',
                        style: TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // محاسبه و به‌روزرسانی مبلغ برای پرداخت با طلا
  void _updateGoldAmount() {
    if (selectedType == 'gold') {
      try {
        final weightText = weightController.text.replaceAll(',', '');
        final unitAmountText = unitAmountController.text.replaceAll(',', '');
        final weight = double.tryParse(weightText) ?? 0;
        final unitAmount = double.tryParse(unitAmountText) ?? 0;
        final calculatedAmount = weight * unitAmount;
        amountController.text = calculatedAmount > 0 ? _format(calculatedAmount) : '';
      } catch (e) {
        amountController.text = '';
      }
    }
  }

  Future<void> _handleAddPayment() async {
    // بررسی فیلدهای اجباری
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفا نوع پرداخت را انتخاب کنید'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (selectedType == 'gold') {
      if (weightController.text.isEmpty || unitAmountController.text.isEmpty || purityController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لطفا وزن، مبلغ واحد و عیار کالا را وارد کنید'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    } else {
      if (amountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لطفا مبلغ را وارد کنید'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    final amount = _enteredAmount;

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('مبلغ نامعتبر است'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // استفاده از tolerance کوچک برای مقایسه به دلیل مشکلات floating point precision
    // مقدار parse شده را round می‌کنیم تا دقیقاً با مقدار formatted برابر باشد
    final roundedAmount = amount.round();
    final roundedRemaining = widget.remainingAmount.round();
    
    if (roundedAmount > roundedRemaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('مبلغ نمی‌تواند بیشتر از ${_format(widget.remainingAmount)} ریال باشد'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // بررسی سازنده دستگاه برای نمایش متن مناسب در دیالوگ
    final deviceManufacturer = await _getDeviceManufacturer();
    final isKozenDevice = deviceManufacturer != null && deviceManufacturer == 'Kozen';

    // نمایش دیالوگ تایید قبل از اضافه کردن پرداخت
    String typeLabel;
    IconData typeIcon;

    switch (selectedType) {
      case 'cash':
        typeLabel = 'نقدی';
        typeIcon = Icons.money;
        break;
      case 'gold':
        typeLabel = 'طلا';
        typeIcon = Icons.diamond;
        break;
      case 'card':
        typeLabel = 'کارت';
        typeIcon = Icons.credit_card;
        break;
      default:
        typeLabel = selectedType!;
        typeIcon = Icons.payment;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'تایید پرداخت',
          style: TextStyle(
            fontFamily: 'Iranyekan',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(typeIcon, color: AppColors.gold, size: 24),
                const SizedBox(width: 12),
                Text(
                  'نوع پرداخت: $typeLabel',
                  style: const TextStyle(
                    fontFamily: 'Iranyekan',
                    fontSize: 14,
                    color: AppColors.textPrimaryAlt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'مبلغ: ${_format(amount)} ریال',
              style: const TextStyle(
                fontFamily: 'Iranyekan',
                fontSize: 14,
                color: AppColors.textPrimaryAlt,
              ),
            ),
            if (selectedType == 'gold') ...[
              const SizedBox(height: 8),
              Text(
                'وزن: ${weightController.text} گرم',
                style: const TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'مبلغ واحد: ${_format(double.tryParse(unitAmountController.text.replaceAll(',', '')) ?? 0)} ریال',
                style: const TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'عیار کالا: ${purityController.text}',
                style: const TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (selectedType == 'card' && isKozenDevice) ...[
              const SizedBox(height: 8),
              const Text(
                'پس از تایید، به صفحه پرداخت کارتی منتقل خواهید شد.',
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
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
              backgroundColor: AppColors.gold,
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

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // اگر invoiceId نداریم، ابتدا فاکتور را ایجاد کن (قبل از انجام پرداخت)
      int? invoiceId = widget.invoiceId;
      bool isNewInvoice = false;
      if (invoiceId == null && widget.invoiceData != null) {
        try {
          invoiceId = await _invoiceService.createInvoice(
            description: widget.invoiceData!['description'] as String? ?? '',
            items: (widget.invoiceData!['items'] as List<dynamic>).map((item) => item as CartItem).toList(),
            totalAmount: (widget.invoiceData!['totalAmount'] as num).toDouble(),
            totalWage: (widget.invoiceData!['totalWage'] as num).toDouble(),
            totalProfit: (widget.invoiceData!['totalProfit'] as num).toDouble(),
            totalCommission: (widget.invoiceData!['totalCommission'] as num).toDouble(),
            totalTax: (widget.invoiceData!['totalTax'] as num).toDouble(),
            customerType: widget.invoiceData!['customerType'] as String?,
            customerMobile: widget.invoiceData!['customerMobile'] as String?,
            customerName: widget.invoiceData!['customerName'] as String?,
            customerNationalCode: widget.invoiceData!['customerNationalCode'] as String?,
            invoiceType: widget.invoiceData!['invoiceType'] as String?,
            sellerInvoiceNumber: widget.invoiceData!['sellerInvoiceNumber'] as String?,
          );
          isNewInvoice = true;
          // فراخوانی callback برای خالی کردن سبد خرید
          if (widget.onInvoiceCreated != null) {
            widget.onInvoiceCreated!();
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isSubmitting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطا در ایجاد فاکتور: ${ErrorHandler.getFarsiErrorMessage(e)}'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }

      if (invoiceId == null) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('خطا: شناسه فاکتور یافت نشد'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      Map<String, dynamic> paymentDetails = {};
      
      // اگر طلا است، وزن، مبلغ واحد و عیار کالا را در details ذخیره کن
      if (selectedType == 'gold') {
        final weightText = weightController.text.replaceAll(',', '');
        final unitAmountText = unitAmountController.text.replaceAll(',', '');
        final purityText = purityController.text.replaceAll(',', '');
        final weight = double.tryParse(weightText) ?? 0;
        final unitAmount = double.tryParse(unitAmountText) ?? 0;
        final purity = int.tryParse(purityText) ?? 740;
        
        paymentDetails = {
          'weight': weight.toStringAsFixed(3), // به صورت string با 3 رقم اعشار
          'unit_amount': unitAmount.round(), // به صورت number
          'purity': purity, // عیار کالا
        };
      }
      
      // اگر کارت است، باید پرداخت انجام شود
      if (selectedType == 'card') {
        // استفاده از همان متغیر deviceManufacturer که قبلاً برای دیالوگ دریافت کردیم
        // اگر سازنده دستگاه "Kozen" است، از کانال کاتلین استفاده کن
        if (isKozenDevice) {
          final result = await pay(
            context: context,
            amount: roundedAmount.toString(),
            currentCurrency: 'Rial',
          );

          if (!mounted) {
            setState(() {
              _isSubmitting = false;
            });
            return;
          }

          if (result['Status'] != 'OK') {
            setState(() {
              _isSubmitting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('پرداخت ناموفق بود'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }

          // استفاده از RRN به عنوان transaction_id و CustomerCardNO به عنوان card_number
          paymentDetails = {
            'transaction_id': result['RRN'] ?? '',
            'card_number': result['CustomerCardNO'] ?? '',
          };
        } else {
          // برای دستگاه‌های غیر Kozen، فقط تاییدیه بگیر و پرداخت را انجام بده
          // paymentDetails خالی می‌ماند یا می‌توانیم مقادیر پیش‌فرض بگذاریم
          paymentDetails = {
            'transaction_id': '',
            'card_number': '',
          };
        }
      }

      // فراخوانی API برای ثبت پرداخت (استفاده از roundedAmount)
      final apiResult = await _paymentService.submitPayment(
        invoiceId: invoiceId,
        type: selectedType!,
        amount: roundedAmount.toDouble(),
        details: paymentDetails,
      );

      if (!mounted) {
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // بررسی نتیجه API
      if (apiResult['success'] == true) {
        // اگر موفق بود، پرداخت را به لیست اضافه کن (استفاده از roundedAmount)
        final paymentRecord = PaymentRecord(
          type: selectedType!,
          amount: roundedAmount.toDouble(),
          details: paymentDetails,
        );

        if (widget.onPaymentAdded != null) {
          await widget.onPaymentAdded!(paymentRecord);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(apiResult['message'] as String? ?? 'پرداخت با موفقیت ثبت شد'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          // برگرداندن invoiceId برای بارگذاری مجدد اطلاعات فاکتور
          Navigator.of(context).pop(invoiceId);
        }
      } else {
        // اگر ناموفق بود، خطا را نمایش بده
        final errorMessage = apiResult['message'] as String? ?? 'خطا در ثبت پرداخت';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا: ${ErrorHandler.getFarsiErrorMessage(e)}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildLabeledField({
    required String label,
    String? suffix,
    TextEditingController? controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isNumeric = false,
    bool enabled = true,
    String? hintText,
    ValueChanged<String>? onChanged,
    bool isNaturalNumberOnly = false, // فقط اعداد طبیعی بزرگتر از 0
  }) {
    List<TextInputFormatter>? inputFormatters;
    if (isNumeric) {
      if (isNaturalNumberOnly) {
        // برای اعداد طبیعی بزرگتر از 0
        inputFormatters = <TextInputFormatter>[NaturalNumberFormatter()];
      } else {
        // برای سایر اعداد با فرمت هزارگان
        inputFormatters = <TextInputFormatter>[ThousandsSeparatorFormatter()];
      }
    }
    
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      readOnly: !enabled,
      textAlign: isNumeric ? TextAlign.left : TextAlign.right,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: enabled ? Colors.white : AppColors.cardSoft,
        labelText: label,
        hintText: hintText,
        alignLabelWithHint: maxLines > 1,
        suffix: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  suffix,
                  style: const TextStyle(
                    fontFamily: 'Iranyekan',
                    fontSize: 14,
                    color: AppColors.iconBrown,
                  ),
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.dividerSoft,
            width: 1,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(
            color: AppColors.dividerSoft,
            width: 1,
          ),
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(
            color: AppColors.dividerSoft,
            width: 1,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(
            color: AppColors.gold,
            width: 1.2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      style: const TextStyle(
        fontFamily: 'Iranyekan',
        fontSize: 14,
        color: AppColors.textPrimaryAlt,
      ),
    );
  }
}

// TextInputFormatter برای اعداد طبیعی بزرگتر از 0 (بدون اعشار، بدون 0، بدون علائم)
class NaturalNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // اگر خالی است، اجازه بده
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // تبدیل اعداد فارسی به انگلیسی
    String englishText = newValue.text
        .replaceAll('۰', '0')
        .replaceAll('۱', '1')
        .replaceAll('۲', '2')
        .replaceAll('۳', '3')
        .replaceAll('۴', '4')
        .replaceAll('۵', '5')
        .replaceAll('۶', '6')
        .replaceAll('۷', '7')
        .replaceAll('۸', '8')
        .replaceAll('۹', '9');

    // حذف کاماها
    englishText = englishText.replaceAll(',', '');

    // فقط اعداد مجاز هستند (بدون اعشار، بدون علائم)
    if (!RegExp(r'^[0-9]+$').hasMatch(englishText)) {
      return oldValue;
    }

    // اگر با 0 شروع می‌شود و بیشتر از یک رقم است، قبول نکن
    if (englishText.length > 1 && englishText.startsWith('0')) {
      return oldValue;
    }

    // فرمت کردن با کاما برای هزارگان
    final number = int.tryParse(englishText);
    if (number == null) {
      return oldValue;
    }

    // عدد باید بزرگتر از 0 باشد
    if (number <= 0) {
      return oldValue;
    }

    final formatted = NumberFormat.decimalPattern().format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// TextInputFormatter برای اعداد با فرمت هزارگان (با اعشار)
class ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // اگر خالی است، اجازه بده
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // تبدیل اعداد فارسی به انگلیسی
    String englishText = newValue.text
        .replaceAll('۰', '0')
        .replaceAll('۱', '1')
        .replaceAll('۲', '2')
        .replaceAll('۳', '3')
        .replaceAll('۴', '4')
        .replaceAll('۵', '5')
        .replaceAll('۶', '6')
        .replaceAll('۷', '7')
        .replaceAll('۸', '8')
        .replaceAll('۹', '9');

    // حذف کاماها
    englishText = englishText.replaceAll(',', '');

    // فقط اعداد مجاز هستند
    if (!RegExp(r'^[0-9]+$').hasMatch(englishText)) {
      return oldValue;
    }

    // اگر با 0 شروع می‌شود و بیشتر از یک رقم است، قبول نکن
    if (englishText.length > 1 && englishText.startsWith('0')) {
      return oldValue;
    }

    // فرمت کردن با کاما برای هزارگان
    final number = int.tryParse(englishText);
    if (number == null) {
      return oldValue;
    }

    final formatted = NumberFormat.decimalPattern().format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
