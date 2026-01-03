import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as persian_date;
import '../services/invoice_service.dart';
import '../utils/error_handler.dart';
import 'payment_page.dart';

enum CustomerType {
  individual, // حقیقی
  legal, // حقوقی
  civic, // مشارکت مدنی
  foreigner, // اتباع
}

class InvoiceInfoPage extends StatefulWidget {
  final CartViewModel cartViewModel;

  const InvoiceInfoPage({
    super.key,
    required this.cartViewModel,
  });

  @override
  State<InvoiceInfoPage> createState() => _InvoiceInfoPageState();
}

class _InvoiceInfoPageState extends State<InvoiceInfoPage> {
  final _notesController = TextEditingController();
  final _mobileController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nationalCodeController = TextEditingController();
  final _economicCodeController = TextEditingController();
  final _branchCodeController = TextEditingController();
  final _uniqueInvoiceNumberController = TextEditingController();

  bool _isOfficialInvoiceEnabled = false;
  CustomerType _customerType = CustomerType.individual;
  bool _isSubmitting = false;

  final _invoiceService = InvoiceService();
  final _currencyFormat = NumberFormat.decimalPattern();

  String _format(double value) {
    if (value == 0) return '0';
    return _currencyFormat.format(value.round());
  }


  // بررسی اعتبارسنجی فیلدهای اجباری فاکتور رسمی
  String? _validateOfficialInvoiceFields() {
    if (!_isOfficialInvoiceEnabled) {
      return null; // اگر فاکتور رسمی فعال نیست، validation لازم نیست
    }

    // بررسی شماره تماس (همیشه اجباری - باید 11 رقم باشد)
    final mobile = _mobileController.text.trim();
    if (mobile.isEmpty) {
      return 'شماره تماس خریدار الزامی است';
    }
    if (mobile.length != 11) {
      return 'شماره تماس باید 11 رقم باشد';
    }

    // بررسی نام (همیشه اجباری)
    final firstName = _firstNameController.text.trim();
    if (firstName.isEmpty) {
      return 'نام الزامی است';
    }

    // بررسی بر اساس نوع مشتری
    switch (_customerType) {
      case CustomerType.individual:
        // حقیقی: نام خانوادگی اجباری است
        final lastName = _lastNameController.text.trim();
        if (lastName.isEmpty) {
          return 'نام خانوادگی الزامی است';
        }
        // بررسی کد ملی (الزامی - باید 10 رقم باشد)
        final nationalCode = _nationalCodeController.text.trim();
        if (nationalCode.isEmpty) {
          return 'کد ملی الزامی است';
        }
        if (nationalCode.length != 10) {
          return 'کد ملی باید 10 رقم باشد';
        }
        break;
      case CustomerType.legal:
        // حقوقی: بررسی شناسه ملی (الزامی - باید 11 رقم باشد)
        final nationalId = _nationalCodeController.text.trim();
        if (nationalId.isEmpty) {
          return 'شناسه ملی الزامی است';
        }
        if (nationalId.length != 11) {
          return 'شناسه ملی باید 11 رقم باشد';
        }
        break;
      case CustomerType.civic:
        // مشارکت مدنی: بررسی کد ملی (الزامی - باید 10 رقم باشد)
        final nationalCode = _nationalCodeController.text.trim();
        if (nationalCode.isEmpty) {
          return 'کد ملی الزامی است';
        }
        if (nationalCode.length != 10) {
          return 'کد ملی باید 10 رقم باشد';
        }
        break;
      case CustomerType.foreigner:
        // اتباع: نام خانوادگی اجباری است
        final lastName = _lastNameController.text.trim();
        if (lastName.isEmpty) {
          return 'نام خانوادگی الزامی است';
        }
        // بررسی کد ملی (الزامی - باید 10 رقم باشد)
        final nationalCode = _nationalCodeController.text.trim();
        if (nationalCode.isEmpty) {
          return 'کد ملی الزامی است';
        }
        if (nationalCode.length != 10) {
          return 'کد ملی باید 10 رقم باشد';
        }
        break;
    }

    // بررسی کد اقتصادی (الزامی - باید 11 رقم باشد)
    final economicCode = _economicCodeController.text.trim();
    if (economicCode.isEmpty) {
      return 'کد اقتصادی الزامی است';
    }
    if (economicCode.length != 11) {
      return 'کد اقتصادی باید 11 رقم باشد';
    }

    return null; // همه چیز درست است
  }

  @override
  void dispose() {
    _notesController.dispose();
    _mobileController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nationalCodeController.dispose();
    _economicCodeController.dispose();
    _branchCodeController.dispose();
    _uniqueInvoiceNumberController.dispose();
    super.dispose();
  }

  // تبدیل CustomerType به string برای API
  String _getCustomerTypeString(CustomerType type) {
    switch (type) {
      case CustomerType.individual:
        return 'natural';
      case CustomerType.legal:
        return 'legal';
      case CustomerType.civic:
        return 'civic';
      case CustomerType.foreigner:
        return 'foreigner';
    }
  }

  // ساخت نام کامل مشتری
  String _getCustomerFullName() {
    if (_customerType == CustomerType.legal || _customerType == CustomerType.civic) {
      return _firstNameController.text.trim();
    } else {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      if (lastName.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName;
    }
  }

  // ثبت موقت فاکتور
  Future<void> _saveTemporary() async {
    final validationError = _validateOfficialInvoiceFields();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? customerType;
      String? customerMobile;
      String? customerName;
      String? customerNationalCode;

      if (_isOfficialInvoiceEnabled) {
        customerMobile = _mobileController.text.trim();
        customerName = _getCustomerFullName();
        customerNationalCode = _nationalCodeController.text.trim();

        if (customerMobile.isEmpty || customerName.isEmpty) {
          throw Exception('لطفا اطلاعات مشتری را کامل کنید');
        }

        customerType = _getCustomerTypeString(_customerType);
      }

      final invoiceId = await _invoiceService.createInvoice(
        description: _notesController.text.trim().isEmpty
            ? ''
            : _notesController.text.trim(),
        items: widget.cartViewModel.items,
        totalAmount: widget.cartViewModel.totalAmount,
        totalWage: widget.cartViewModel.totalWage,
        totalProfit: widget.cartViewModel.totalProfit,
        totalCommission: widget.cartViewModel.totalCommission,
        totalTax: widget.cartViewModel.totalTax,
        customerType: customerType,
        customerMobile: customerMobile,
        customerName: customerName,
        customerNationalCode: customerNationalCode != null && customerNationalCode.isNotEmpty ? customerNationalCode : null,
        invoiceType: _isOfficialInvoiceEnabled ? 'official' : 'normal',
        sellerInvoiceNumber: _uniqueInvoiceNumberController.text.trim().isNotEmpty
            ? _uniqueInvoiceNumberController.text.trim()
            : null,
      );

      await widget.cartViewModel.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فاکتور با موفقیت ثبت شد'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // انتقال به تب فاکتورها -> تسویه نشده
        Navigator.of(context).popUntil((route) => route.isFirst);
        // TODO: Navigate to invoices tab -> unpaid
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

  // ثبت و انتقال به صفحه پرداخت (بدون ایجاد فاکتور)
  Future<void> _saveAndPay() async {
    final validationError = _validateOfficialInvoiceFields();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // آماده‌سازی اطلاعات فاکتور برای انتقال
    String? customerType;
    String? customerMobile;
    String? customerName;
    String? customerNationalCode;

    if (_isOfficialInvoiceEnabled) {
      customerMobile = _mobileController.text.trim();
      customerName = _getCustomerFullName();
      customerNationalCode = _nationalCodeController.text.trim();

      if (customerMobile.isEmpty || customerName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لطفا اطلاعات مشتری را کامل کنید'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      customerType = _getCustomerTypeString(_customerType);
    }

    // انتقال به صفحه پرداخت واقعی (بدون ایجاد فاکتور)
    if (mounted) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            cartViewModel: widget.cartViewModel,
            invoiceData: {
              'description': _notesController.text.trim().isEmpty
                  ? ''
                  : _notesController.text.trim(),
              'items': widget.cartViewModel.items,
              'totalAmount': widget.cartViewModel.totalAmount,
              'totalWage': widget.cartViewModel.totalWage,
              'totalProfit': widget.cartViewModel.totalProfit,
              'totalCommission': widget.cartViewModel.totalCommission,
              'totalTax': widget.cartViewModel.totalTax,
              'customerType': customerType,
              'customerMobile': customerMobile,
              'customerName': customerName,
              'customerNationalCode': customerNationalCode != null && customerNationalCode.isNotEmpty ? customerNationalCode : null,
              'invoiceType': _isOfficialInvoiceEnabled ? 'official' : 'normal',
              'sellerInvoiceNumber': _uniqueInvoiceNumberController.text.trim().isNotEmpty
                  ? _uniqueInvoiceNumberController.text.trim()
                  : null,
            },
          ),
        ),
      );
    }
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
              child: Text('اطلاعات فاکتور'),
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
            // بخش اطلاعات کلی فاکتور
            _buildInvoiceInfoCard(),
            const SizedBox(height: 16),

            // بخش صدور فاکتور رسمی
            _buildOfficialInvoiceCard(),
            const SizedBox(height: 16),

            // بخش شماره یکتا و یادداشت
            _buildNotesCard(),
            const SizedBox(height: 24),

            // دکمه‌های ثبت موقت و پرداخت
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'تاریخ صدور صورت حساب',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                persian_date.PersianDateUtils.getCurrentPersianDate(),
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 14,
                  color: AppColors.textPrimaryAlt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow('مجموع مبالغ کل', '${_format(widget.cartViewModel.totalAmount)}', 'ریال'),
          const SizedBox(height: 12),
          _buildDetailRow('مجموع مبالغ اجرت', '${_format(widget.cartViewModel.totalWage)}', 'ریال'),
          const SizedBox(height: 12),
          _buildDetailRow('مجموع مبالغ سود فروش', '${_format(widget.cartViewModel.totalProfit)}', 'ریال'),
          const SizedBox(height: 12),
          _buildDetailRow('مجموع مبالغ حق العمل', '${_format(widget.cartViewModel.totalCommission)}', 'ریال'),
          const SizedBox(height: 12),
          _buildDetailRow('مجموع مبالغ مالیات', '${_format(widget.cartViewModel.totalTax)}', 'ریال'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, String suffix) {
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
            const SizedBox(width: 5),
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

  Widget _buildOfficialInvoiceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'صدور فاکتور رسمی',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryAlt,
                ),
              ),
              Switch(
                value: _isOfficialInvoiceEnabled,
                onChanged: (value) {
                  setState(() {
                    _isOfficialInvoiceEnabled = value;
                    if (!value) {
                      _mobileController.clear();
                      _firstNameController.clear();
                      _lastNameController.clear();
                      _nationalCodeController.clear();
                      _economicCodeController.clear();
                      _branchCodeController.clear();
                    }
                  });
                },
                activeColor: AppColors.gold,
              ),
            ],
          ),
          if (_isOfficialInvoiceEnabled) ...[
            const SizedBox(height: 16),
            _buildCustomerTypeTabs(),
            const SizedBox(height: 16),
            ..._buildCustomerFields(),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerTypeTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildCustomerTypeTab(
              title: 'حقیقی',
              isSelected: _customerType == CustomerType.individual,
              onTap: () {
                setState(() {
                  _customerType = CustomerType.individual;
                  _lastNameController.clear();
                });
              },
              isBold: true,
            ),
          ),
          Expanded(
            child: _buildCustomerTypeTab(
              title: 'حقوقی',
              isSelected: _customerType == CustomerType.legal,
              onTap: () {
                setState(() {
                  _customerType = CustomerType.legal;
                  _lastNameController.clear();
                });
              },
              isBold: true,
            ),
          ),
          Expanded(
            child: _buildCustomerTypeTab(
              title: 'مشارکت مدنی',
              isSelected: _customerType == CustomerType.civic,
              onTap: () {
                setState(() {
                  _customerType = CustomerType.civic;
                  _lastNameController.clear();
                });
              },
              isBold: true,
              isTwoLine: true,
            ),
          ),
          Expanded(
            child: _buildCustomerTypeTab(
              title: 'اتباع',
              isSelected: _customerType == CustomerType.foreigner,
              onTap: () {
                setState(() {
                  _customerType = CustomerType.foreigner;
                });
              },
              isBold: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerTypeTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    bool isBold = false,
    bool isTwoLine = false,
  }) {
    Widget textWidget;

    if (isTwoLine && title == 'مشارکت مدنی') {
      textWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'مشارکت',
            style: TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
              color: isSelected ? AppColors.textPrimaryAlt : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'مدنی',
            style: TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
              color: isSelected ? AppColors.textPrimaryAlt : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      textWidget = Text(
        title,
        style: TextStyle(
          fontFamily: 'Iranyekan',
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
          color: isSelected ? AppColors.textPrimaryAlt : AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        constraints: const BoxConstraints(minHeight: 40),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.softGoldChip : null,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: textWidget,
        ),
      ),
    );
  }

  List<Widget> _buildCustomerFields() {
    switch (_customerType) {
      case CustomerType.individual:
        return [
          _buildLabeledField(
            label: 'شماره تماس خریدار*',
            controller: _mobileController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            isNumeric: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 11,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  label: 'نام*',
                  controller: _firstNameController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLabeledField(
                  label: 'نام خانوادگی*',
                  controller: _lastNameController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  label: 'کد ملی*',
                  controller: _nationalCodeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  isNumeric: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 10,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLabeledField(
                  label: 'کد اقتصادی*',
                  controller: _economicCodeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  isNumeric: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLabeledField(
            label: 'کد شعبه',
            controller: _branchCodeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            isNumeric: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 10,
          ),
        ];

      case CustomerType.legal:
        return [
          _buildLabeledField(
            label: 'شماره تماس خریدار*',
            controller: _mobileController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            isNumeric: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 11,
          ),
          const SizedBox(height: 12),
          _buildLabeledField(
            label: 'نام*',
            controller: _firstNameController,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  label: 'شناسه ملی*',
                  controller: _nationalCodeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  isNumeric: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 11,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLabeledField(
                  label: 'کد اقتصادی*',
                  controller: _economicCodeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  isNumeric: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLabeledField(
            label: 'کد شعبه',
            controller: _branchCodeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            isNumeric: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 10,
          ),
        ];

      case CustomerType.civic:
        return [
          _buildLabeledField(
            label: 'شماره تماس خریدار*',
            controller: _mobileController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            isNumeric: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 11,
          ),
          const SizedBox(height: 12),
          _buildLabeledField(
            label: 'نام*',
            controller: _firstNameController,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  label: 'کد ملی*',
                  controller: _nationalCodeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  isNumeric: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 10,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLabeledField(
                  label: 'کد اقتصادی*',
                  controller: _economicCodeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  isNumeric: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLabeledField(
            label: 'کد شعبه',
            controller: _branchCodeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            isNumeric: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 10,
          ),
        ];

      case CustomerType.foreigner:
        return [
          _buildLabeledField(
            label: 'شماره تماس خریدار*',
            controller: _mobileController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            isNumeric: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 11,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  label: 'نام*',
                  controller: _firstNameController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLabeledField(
                  label: 'نام خانوادگی*',
                  controller: _lastNameController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  label: 'کد ملی*',
                  controller: _nationalCodeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  isNumeric: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 10,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLabeledField(
                  label: 'کد اقتصادی*',
                  controller: _economicCodeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  isNumeric: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLabeledField(
            label: 'کد شعبه',
            controller: _branchCodeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            isNumeric: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 10,
          ),
        ];
    }
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLabeledField(
            label: 'شماره یکتا فاکتور',
            controller: _uniqueInvoiceNumberController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            isNumeric: false, // بدون جدا کننده سه رقم
            inputFormatters: [FilteringTextInputFormatter.digitsOnly], // فقط اعداد 0-9
          ),
          const SizedBox(height: 16),
          _buildLabeledField(
            label: 'یادداشت',
            controller: _notesController,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _saveAndPay,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSubmitting ? AppColors.textMuted : AppColors.gold,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
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
              'پرداخت',
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
            onPressed: _isSubmitting ? null : _saveTemporary,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _isSubmitting ? AppColors.textMuted : AppColors.titleBrown,
                width: 1,
              ),
              foregroundColor: _isSubmitting ? AppColors.textMuted : AppColors.titleBrown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _isSubmitting
                ? const SizedBox(
              width: 20,
              height: 20,
              child: SpinKitFoldingCube(
                color: AppColors.titleBrown,
                size: 20.0,
              ),
            )
                : const Text(
              'ثبت موقت',
              style: TextStyle(
                fontFamily: 'Iranyekan',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField({
    required String label,
    TextEditingController? controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isNumeric = false,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    // اگر inputFormatters به صورت صریح ارسال شده، از آن استفاده کن
    // وگرنه اگر isNumeric باشد، ThousandsSeparatorFormatter را اضافه کن
    final formatters = inputFormatters ?? 
        (isNumeric ? <TextInputFormatter>[ThousandsSeparatorFormatter()] : null);
    
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      textAlign: isNumeric ? TextAlign.left : TextAlign.right,
      inputFormatters: formatters,
      onChanged: (_) {
        if (_isOfficialInvoiceEnabled) {
          setState(() {});
        }
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        counterText: '',
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

class ThousandsSeparatorFormatter extends TextInputFormatter {
  String _persianToEnglish(String text) {
    return text.replaceAll('۰', '0').replaceAll('۱', '1').replaceAll('۲', '2').replaceAll('۳', '3').replaceAll('۴', '4').replaceAll('۵', '5').replaceAll('۶', '6').replaceAll('۷', '7').replaceAll('۸', '8').replaceAll('۹', '9');
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final englishText = _persianToEnglish(newValue.text);
    final raw = englishText.replaceAll(',', '');
    if (raw.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final parts = raw.split('.');
    final intPart = parts[0];
    if (intPart.isEmpty) {
      return newValue;
    }

    final number = int.tryParse(intPart);
    if (number == null) {
      return oldValue;
    }

    final formattedInt = NumberFormat.decimalPattern().format(number);
    var result = formattedInt;
    if (parts.length > 1) {
      result += '.${parts[1]}';
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

