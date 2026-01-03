import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as persian_date;
import '../models/payment_record.dart';
import '../services/payment_service.dart';
import '../services/invoice_service.dart';
import '../utils/tax_id_generator.dart';
import '../utils/error_handler.dart';
import 'add_payment_page.dart';

enum CustomerType {
  individual, // حقیقی
  legal, // حقوقی
  civic, // مشارکت مدنی
  foreigner, // اتباع
}


class PaymentPage extends StatefulWidget {
  final CartViewModel cartViewModel;
  final int? invoiceId; // برای پرداخت فاکتور موجود
  final double? invoiceTotalAmount; // مبلغ کل فاکتور موجود
  final Map<String, dynamic>? invoiceData; // اطلاعات فاکتور برای ایجاد (اگر invoiceId null باشد)
  
  const PaymentPage({
    super.key,
    required this.cartViewModel,
    this.invoiceId,
    this.invoiceTotalAmount,
    this.invoiceData,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
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
  
  // لیست رکوردهای پرداخت
  List<PaymentRecord> _paymentRecords = [];
  bool _isSubmitting = false;
  bool _isInvoiceCreated = false; // برای track کردن اینکه invoice ایجاد شده یا نه
  int? _createdInvoiceId; // شناسه فاکتور ایجاد شده
  bool _isLoadingInvoice = false; // برای track کردن بارگذاری فاکتور موجود
  double? _loadedInvoiceTotalAmount; // مبلغ کل فاکتور بارگذاری شده
  
  // اطلاعات اضافی فاکتور موجود
  String? _invoiceTypeLabel;
  String? _invoiceStatusLabel;
  String? _invoiceStatusLabelFromApi; // status_label از API
  String? _taxAppStatusLabel; // app_status_label از tax object
  bool? _isOfficial;
  double? _paidAmount;
  double? _remainingAmountFromApi;
  double? _totalWage;
  double? _totalProfit;
  double? _totalCommission;
  double? _totalTax;
  String? _issuedAt;
  String? _sellerInvoiceNumber; // شماره یکتا فاکتور (مثل INV-000011)
  String? _maherTaxId; // شماره مالیاتی از سرویس (maher_tax_id)
  List<Map<String, dynamic>> _invoiceItems = [];
  
  final _paymentService = PaymentService();
  final _invoiceService = InvoiceService();
  final _currencyFormat = NumberFormat.decimalPattern();

  String _format(double value) {
    if (value == 0) return '0';
    return _currencyFormat.format(value.round());
  }


  // فرمت کردن درصد بدون اعشار
  String _formatPercent(String? percentString) {
    if (percentString == null || percentString.isEmpty) return '0';
    final percentValue = double.tryParse(percentString);
    if (percentValue == null) return '0';
    return percentValue.round().toString();
  }

  // فرمت کردن وزن - اگر اعشار 0 باشد، حذف می‌شود
  String _formatWeight(String? weightString) {
    if (weightString == null || weightString.isEmpty) return '0';
    final weightValue = double.tryParse(weightString);
    if (weightValue == null) return '0';
    // اگر اعشار 0 است، بدون اعشار نمایش بده
    if (weightValue == weightValue.roundToDouble()) {
      return weightValue.round().toString();
    }
    // در غیر این صورت، با اعشار نمایش بده
    return weightString;
  }

  // محاسبه مجموع پرداخت‌ها
  double get _totalPaid {
    return _paymentRecords.fold(0.0, (sum, record) => sum + record.amount);
  }

  // محاسبه باقیمانده
  double get _remainingAmount {
    // اولویت: loadedInvoiceTotalAmount > widget.invoiceTotalAmount > cartViewModel.totalAmount
    final totalAmount = _loadedInvoiceTotalAmount ?? 
        widget.invoiceTotalAmount ?? 
        widget.cartViewModel.totalAmount;
    return totalAmount - _totalPaid;
  }

  // محاسبه شماره مالیاتی
  String get _taxId {
    // اگر maher_tax_id از سرویس موجود است، از آن استفاده کن
    if (_maherTaxId != null && _maherTaxId!.isNotEmpty) {
      return _maherTaxId!;
    }
    
    // در غیر این صورت، شماره مالیاتی را محاسبه کن
    try {
      final invoiceId = _createdInvoiceId ?? widget.invoiceId;
      final issuedAt = _issuedAt;
      
      if (invoiceId == null || issuedAt == null) {
        return 'N/A';
      }

      return TaxIdGenerator.buildTaxIdWithCheckDigit(
        memoryId6: 'A12894', // Fiscal ID ثابت
        jalaliDateTime: issuedAt,
        invoiceNo: invoiceId,
      );
    } catch (e) {
      return 'N/A';
    }
  }
  
  // بررسی اینکه آیا این پرداخت برای فاکتور موجود است یا فاکتور جدید
  bool get _isExistingInvoice => widget.invoiceId != null;

  // بررسی امکان ثبت پرداخت‌ها
  bool get _canSubmit {
    return _paymentRecords.isNotEmpty &&
        _remainingAmount == 0 &&
        !_isSubmitting;
  }

  // بررسی اعتبارسنجی فیلدهای اجباری فاکتور رسمی
  bool _validateOfficialInvoiceFields() {
    // برای فاکتور موجود، validation لازم نیست
    if (_isExistingInvoice) {
      return true;
    }
    
    if (!_isOfficialInvoiceEnabled) {
      return true; // اگر فاکتور رسمی فعال نیست، validation لازم نیست
    }

    // بررسی شماره تماس (همیشه اجباری)
    final mobile = _mobileController.text.trim();
    if (mobile.isEmpty) {
      return false;
    }

    // بررسی نام (همیشه اجباری)
    final firstName = _firstNameController.text.trim();
    if (firstName.isEmpty) {
      return false;
    }

    // بررسی بر اساس نوع مشتری
    switch (_customerType) {
      case CustomerType.individual:
        // حقیقی: نام خانوادگی اجباری است
        final lastName = _lastNameController.text.trim();
        if (lastName.isEmpty) {
          return false;
        }
        break;
      case CustomerType.legal:
        // حقوقی: فقط نام و شماره تماس اجباری است
        break;
      case CustomerType.civic:
        // مشارکت مدنی: فقط نام و شماره تماس اجباری است
        break;
      case CustomerType.foreigner:
        // اتباع: نام خانوادگی اجباری است
        final lastName = _lastNameController.text.trim();
        if (lastName.isEmpty) {
          return false;
        }
        break;
    }

    // بررسی کد اقتصادی (اگر وارد شده، باید 11 رقم باشد)
    final economicCode = _economicCodeController.text.trim();
    if (economicCode.isNotEmpty && economicCode.length != 11) {
      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    // اگر فاکتور موجود است، اطلاعات را بارگذاری کن
    if (_isExistingInvoice && widget.invoiceId != null) {
      _loadInvoiceData();
    } else if (widget.invoiceData != null) {
      // اگر invoiceData وجود دارد، seller_invoice_number را استخراج کن
      _sellerInvoiceNumber = widget.invoiceData!['sellerInvoiceNumber'] as String?;
    }
  }

  // باز کردن خودکار صفحه افزودن پرداخت
  Future<void> _openAddPaymentPage() async {
    if (_remainingAmount <= 0) return;
    
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddPaymentPage(
          remainingAmount: _remainingAmount,
          invoiceId: widget.invoiceId ?? _createdInvoiceId,
          invoiceData: widget.invoiceData,
          onInvoiceCreated: () async {
            // خالی کردن سبد خرید بعد از ثبت فاکتور
            await widget.cartViewModel.clear();
          },
          // onPaymentAdded را ارسال نمی‌کنیم چون بعد از بازگشت، اطلاعات از API بارگذاری می‌شود
        ),
      ),
    );
    
    // بعد از بازگشت از صفحه افزودن پرداخت، اگر invoiceId برگردانده شد، اطلاعات فاکتور را از API بارگذاری کن
    if (result != null && result is int) {
      final returnedInvoiceId = result as int;
      // اگر این اولین بار است که فاکتور ایجاد شده، invoiceId را ذخیره کن
      if (_createdInvoiceId == null && widget.invoiceId == null) {
        _createdInvoiceId = returnedInvoiceId;
      }
      // بارگذاری اطلاعات فاکتور از API (شامل همه پرداخت‌ها)
      await _loadInvoiceDataById(returnedInvoiceId);
    }
  }

  // بارگذاری اطلاعات فاکتور موجود از API با استفاده از invoiceId مشخص
  Future<void> _loadInvoiceDataById(int invoiceId) async {
    try {
      setState(() {
        _isLoadingInvoice = true;
      });

      final invoiceData = await _invoiceService.getInvoice(invoiceId);
      
      // استخراج اطلاعات اصلی فاکتور
      final totalAmount = (invoiceData['total_amount'] as num?)?.toDouble();
      if (totalAmount != null) {
        _loadedInvoiceTotalAmount = totalAmount;
      }
      
      _invoiceTypeLabel = invoiceData['type_label'] as String?;
      _invoiceStatusLabelFromApi = invoiceData['status_label'] as String?;
      // استفاده از app_status_label از tax object اگر موجود باشد، در غیر این صورت status_label
      final taxData = invoiceData['tax'] as Map<String, dynamic>?;
      _taxAppStatusLabel = taxData?['app_status_label'] as String?;
      _invoiceStatusLabel = _taxAppStatusLabel ?? _invoiceStatusLabelFromApi;
      _isOfficial = invoiceData['is_official'] as bool?;
      _paidAmount = (invoiceData['paid_amount'] as num?)?.toDouble();
      _remainingAmountFromApi = (invoiceData['remaining_amount'] as num?)?.toDouble();
      _totalWage = (invoiceData['total_wage'] as num?)?.toDouble();
      _totalProfit = (invoiceData['total_profit'] as num?)?.toDouble();
      _totalCommission = (invoiceData['total_commission'] as num?)?.toDouble();
      _totalTax = (invoiceData['total_tax'] as num?)?.toDouble();
      _issuedAt = invoiceData['issued_at'] as String?;
      
      // استخراج maher_tax_id از tax object
      _maherTaxId = taxData?['maher_tax_id'] as String?;
      
      // استخراج آیتم‌های فاکتور
      final invoiceItems = invoiceData['invoice_items'] as List<dynamic>?;
      if (invoiceItems != null) {
        _invoiceItems = invoiceItems.map((item) {
          return item as Map<String, dynamic>;
        }).toList();
      }

      // استخراج اطلاعات مشتری
      Map<String, dynamic>? customer;
      final customerValue = invoiceData['customer'];
      if (customerValue != null) {
        if (customerValue is Map<String, dynamic>) {
          customer = customerValue;
        } else if (customerValue is List && customerValue.isEmpty) {
          customer = null;
        }
      }
      
      if (customer != null && customer.isNotEmpty) {
        final customerName = customer['name'] as String? ?? '';
        final customerMobile = customer['mobile'] as String? ?? '';
        final customerType = customer['type'] as String?;
        final nationalCode = customer['national_code'] as String?;
        final economyCode = customer['economy_code'] as String?;
        final branchCode = customer['branch_code'] as String?;

        // پر کردن فیلدهای مشتری
        _mobileController.text = customerMobile;
        
        // تبدیل customer type string به CustomerType enum
        if (customerType != null) {
          switch (customerType) {
            case 'natural':
              _customerType = CustomerType.individual;
              break;
            case 'legal':
              _customerType = CustomerType.legal;
              break;
            case 'civic':
              _customerType = CustomerType.civic;
              break;
            case 'foreigner':
              _customerType = CustomerType.foreigner;
              break;
          }
        }

        // تقسیم نام مشتری به نام و نام خانوادگی
        if (customerName.isNotEmpty) {
          final nameParts = customerName.split(' ');
          if (nameParts.isNotEmpty) {
            _firstNameController.text = nameParts[0];
            if (nameParts.length > 1) {
              _lastNameController.text = nameParts.sublist(1).join(' ');
            }
          }
        }

        if (nationalCode != null) {
          _nationalCodeController.text = nationalCode;
        }
        if (economyCode != null) {
          _economicCodeController.text = economyCode;
        }
        if (branchCode != null) {
          _branchCodeController.text = branchCode;
        }

        // اگر customer وجود دارد، فاکتور رسمی فعال است
        _isOfficialInvoiceEnabled = true;
      }

      // استخراج اطلاعات فاکتور
      final sellerInvoiceNumber = invoiceData['seller_invoice_number'] as String?;
      if (sellerInvoiceNumber != null) {
        _sellerInvoiceNumber = sellerInvoiceNumber;
        _uniqueInvoiceNumberController.text = sellerInvoiceNumber;
      }

      final description = invoiceData['description'] as String?;
      if (description != null) {
        _notesController.text = description;
      }

      // استخراج لیست پرداخت‌ها از API و جایگزینی با لیست فعلی
      final payments = invoiceData['payments'] as List<dynamic>?;
      if (payments != null) {
        _paymentRecords = payments.map((payment) {
          final type = payment['type'] as String? ?? 'cash';
          final amount = (payment['amount'] as num?)?.toDouble() ?? 0.0;
          
          // تبدیل details: اگر لیست است، به Map خالی تبدیل کن
          Map<String, dynamic> details = {};
          final detailsValue = payment['details'];
          if (detailsValue != null) {
            if (detailsValue is Map<String, dynamic>) {
              details = detailsValue;
            } else if (detailsValue is List && detailsValue.isEmpty) {
              // لیست خالی را به Map خالی تبدیل کن
              details = {};
            }
          }
          
          // اگر نوع طلا است و purity در root object موجود است، به details اضافه کن
          if (type == 'gold' && payment['purity'] != null) {
            details['purity'] = payment['purity'];
          }
          
          return PaymentRecord(
            type: type,
            amount: amount,
            details: details,
          );
        }).toList();
      }

      // علامت‌گذاری که invoice ایجاد شده است
      setState(() {
        _isInvoiceCreated = true;
        _createdInvoiceId = invoiceId;
        _isLoadingInvoice = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingInvoice = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در بارگذاری اطلاعات فاکتور: ${ErrorHandler.getFarsiErrorMessage(e)}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // بارگذاری اطلاعات فاکتور موجود از API
  Future<void> _loadInvoiceData() async {
    try {
      setState(() {
        _isLoadingInvoice = true;
      });

      final invoiceData = await _invoiceService.getInvoice(widget.invoiceId!);
      
      // استخراج اطلاعات اصلی فاکتور
      final totalAmount = (invoiceData['total_amount'] as num?)?.toDouble();
      if (totalAmount != null) {
        _loadedInvoiceTotalAmount = totalAmount;
      }
      
      _invoiceTypeLabel = invoiceData['type_label'] as String?;
      _invoiceStatusLabelFromApi = invoiceData['status_label'] as String?;
      // استفاده از app_status_label از tax object اگر موجود باشد، در غیر این صورت status_label
      final taxData = invoiceData['tax'] as Map<String, dynamic>?;
      _taxAppStatusLabel = taxData?['app_status_label'] as String?;
      _invoiceStatusLabel = _taxAppStatusLabel ?? _invoiceStatusLabelFromApi;
      _isOfficial = invoiceData['is_official'] as bool?;
      _paidAmount = (invoiceData['paid_amount'] as num?)?.toDouble();
      _remainingAmountFromApi = (invoiceData['remaining_amount'] as num?)?.toDouble();
      _totalWage = (invoiceData['total_wage'] as num?)?.toDouble();
      _totalProfit = (invoiceData['total_profit'] as num?)?.toDouble();
      _totalCommission = (invoiceData['total_commission'] as num?)?.toDouble();
      _totalTax = (invoiceData['total_tax'] as num?)?.toDouble();
      _issuedAt = invoiceData['issued_at'] as String?;
      
      // استخراج maher_tax_id از tax object
      _maherTaxId = taxData?['maher_tax_id'] as String?;
      
      // استخراج آیتم‌های فاکتور
      final invoiceItems = invoiceData['invoice_items'] as List<dynamic>?;
      if (invoiceItems != null) {
        _invoiceItems = invoiceItems.map((item) {
          return item as Map<String, dynamic>;
        }).toList();
      }

      // استخراج اطلاعات مشتری
      // customer می‌تواند یک Map یا یک List خالی باشد
      Map<String, dynamic>? customer;
      final customerValue = invoiceData['customer'];
      if (customerValue != null) {
        if (customerValue is Map<String, dynamic>) {
          customer = customerValue;
        } else if (customerValue is List && customerValue.isEmpty) {
          // اگر لیست خالی است، customer را null در نظر بگیر
          customer = null;
        }
      }
      
      if (customer != null && customer.isNotEmpty) {
        final customerName = customer['name'] as String? ?? '';
        final customerMobile = customer['mobile'] as String? ?? '';
        final customerType = customer['type'] as String?;
        final nationalCode = customer['national_code'] as String?;
        final economyCode = customer['economy_code'] as String?;
        final branchCode = customer['branch_code'] as String?;

        // پر کردن فیلدهای مشتری
        _mobileController.text = customerMobile;
        
        // تبدیل customer type string به CustomerType enum
        if (customerType != null) {
          switch (customerType) {
            case 'natural':
              _customerType = CustomerType.individual;
              break;
            case 'legal':
              _customerType = CustomerType.legal;
              break;
            case 'civic':
              _customerType = CustomerType.civic;
              break;
            case 'foreigner':
              _customerType = CustomerType.foreigner;
              break;
          }
        }

        // تقسیم نام مشتری به نام و نام خانوادگی
        if (customerName.isNotEmpty) {
          final nameParts = customerName.split(' ');
          if (nameParts.isNotEmpty) {
            _firstNameController.text = nameParts[0];
            if (nameParts.length > 1) {
              _lastNameController.text = nameParts.sublist(1).join(' ');
            }
          }
        }

        if (nationalCode != null) {
          _nationalCodeController.text = nationalCode;
        }
        if (economyCode != null) {
          _economicCodeController.text = economyCode;
        }
        if (branchCode != null) {
          _branchCodeController.text = branchCode;
        }

        // اگر customer وجود دارد، فاکتور رسمی فعال است
        _isOfficialInvoiceEnabled = true;
      }

      // استخراج اطلاعات فاکتور
      final sellerInvoiceNumber = invoiceData['seller_invoice_number'] as String?;
      if (sellerInvoiceNumber != null) {
        _sellerInvoiceNumber = sellerInvoiceNumber;
        _uniqueInvoiceNumberController.text = sellerInvoiceNumber;
      }

      final description = invoiceData['description'] as String?;
      if (description != null) {
        _notesController.text = description;
      }

      // استخراج لیست پرداخت‌ها
      final payments = invoiceData['payments'] as List<dynamic>?;
      if (payments != null) {
        _paymentRecords = payments.map((payment) {
          final type = payment['type'] as String? ?? 'cash';
          final amount = (payment['amount'] as num?)?.toDouble() ?? 0.0;
          
          // تبدیل details: اگر لیست است، به Map خالی تبدیل کن
          Map<String, dynamic> details = {};
          final detailsValue = payment['details'];
          if (detailsValue != null) {
            if (detailsValue is Map<String, dynamic>) {
              details = detailsValue;
            } else if (detailsValue is List && detailsValue.isEmpty) {
              // لیست خالی را به Map خالی تبدیل کن
              details = {};
            }
          }
          
          // اگر نوع طلا است و purity در root object موجود است، به details اضافه کن
          if (type == 'gold' && payment['purity'] != null) {
            details['purity'] = payment['purity'];
          }
          
          return PaymentRecord(
            type: type,
            amount: amount,
            details: details,
          );
        }).toList();
      }

      // علامت‌گذاری که invoice ایجاد شده است
      setState(() {
        _isInvoiceCreated = true;
        _createdInvoiceId = widget.invoiceId;
        _isLoadingInvoice = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingInvoice = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در بارگذاری اطلاعات فاکتور: ${ErrorHandler.getFarsiErrorMessage(e)}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
                width: 1.5,
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
              child: Text('پرداخت فاکتور'),
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
      body: _isLoadingInvoice && _isExistingInvoice
          ? const Center(
              child: SpinKitFoldingCube(
                color: AppColors.gold,
                size: 80.0,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // بخش اطلاعات فاکتور (expandable)
                  _buildInvoiceInfoCard(widget.cartViewModel),

                  // بخش آیتم‌های فاکتور (expandable)
                  if (_invoiceItems.isNotEmpty || widget.cartViewModel.items.isNotEmpty)
                    _buildInvoiceItemsCard(),

                  // بخش پرداخت ها
                  _buildPaymentCard(widget.cartViewModel),
                ],
              ),
            ),
    );
  }

  Widget _buildInvoiceInfoCard(CartViewModel cartViewModel) {
    // اگر در حال بارگذاری است، loading نمایش بده
    if (_isLoadingInvoice && _isExistingInvoice) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: SpinKitFoldingCube(
            color: AppColors.gold,
            size: 50.0,
          ),
        ),
      );
    }
    
    // تعیین مبلغ کل: اولویت با اطلاعات بارگذاری شده، سپس invoiceTotalAmount، سپس cartViewModel
    final totalAmount = _loadedInvoiceTotalAmount ?? 
        widget.invoiceTotalAmount ?? 
        cartViewModel.totalAmount;
    
    // تعیین سایر مبالغ: اگر فاکتور موجود است از API، وگرنه از cartViewModel
    final totalWage = _isExistingInvoice 
        ? (_totalWage ?? 0)
        : cartViewModel.totalWage;
    final totalProfit = _isExistingInvoice 
        ? (_totalProfit ?? 0)
        : cartViewModel.totalProfit;
    final totalCommission = _isExistingInvoice 
        ? (_totalCommission ?? 0)
        : cartViewModel.totalCommission;
    final totalTax = _isExistingInvoice 
        ? (_totalTax ?? 0)
        : cartViewModel.totalTax;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        backgroundColor: AppColors.white,
        collapsedBackgroundColor: AppColors.white,
        iconColor: AppColors.gold,
        collapsedIconColor: AppColors.textSecondary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        collapsedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        title: const Text(
          'اطلاعات فاکتور',
          style: TextStyle(
            fontFamily: 'Iranyekan',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryAlt,
          ),
        ),
        subtitle: _sellerInvoiceNumber != null && _sellerInvoiceNumber!.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _sellerInvoiceNumber!,
                  style: const TextStyle(
                    fontFamily: 'Iranyekan',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryAlt,
                  ),
                ),
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // نوع فاکتور
                if (_invoiceTypeLabel != null) ...[
                  _buildDetailRow('نوع فاکتور', _invoiceTypeLabel!, ''),
                  const SizedBox(height: 12),
                ],
                // وضعیت فاکتور
                if (_invoiceStatusLabelFromApi != null) ...[
                  _buildDetailRow('وضعیت فاکتور', _invoiceStatusLabelFromApi!, ''),
                  const SizedBox(height: 12),
                ],
                // وضعیت ارسال به دارایی
                if (_taxAppStatusLabel != null) ...[
                  _buildDetailRow('وضعیت ارسال به دارایی', _taxAppStatusLabel!, ''),
                  const SizedBox(height: 12),
                ],
                if (_issuedAt != null) ...[
                  _buildDetailRow('تاریخ صدور', _issuedAt!, ''),
          const SizedBox(height: 12),
                ],
                // شماره مالیاتی
                if ((_createdInvoiceId != null || widget.invoiceId != null) && _issuedAt != null) ...[
                  _buildDetailRow('شماره مالیاتی', _taxId, ''),
          const SizedBox(height: 12),
                ],
                _buildDetailRow('مبلغ کل فاکتور', '${_format(totalAmount)}', 'ریال'),
                if (totalWage > 0) ...[
          const SizedBox(height: 12),
                  _buildDetailRow('مجموع مبالغ اجرت', '${_format(totalWage)}', 'ریال'),
                ],
                if (totalProfit > 0) ...[
          const SizedBox(height: 12),
                  _buildDetailRow('مجموع مبالغ سود فروش', '${_format(totalProfit)}', 'ریال'),
                ],
                if (totalCommission > 0) ...[
          const SizedBox(height: 12),
                  _buildDetailRow('مجموع مبالغ حق العمل', '${_format(totalCommission)}', 'ریال'),
                ],
                if (totalTax > 0) ...[
          const SizedBox(height: 12),
                  _buildDetailRow('مجموع مبالغ مالیات', '${_format(totalTax)}', 'ریال'),
                ],
              ],
            ),
          ),
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

  Widget _buildInvoiceItemsCard() {
    // تعیین لیست آیتم‌ها: اگر فاکتور موجود است از _invoiceItems، وگرنه از cartViewModel
    final List<Map<String, dynamic>> items;
    if (_invoiceItems.isNotEmpty) {
      items = _invoiceItems;
    } else {
      // تبدیل CartItem به Map برای نمایش
      items = widget.cartViewModel.items.map((cartItem) {
        return {
          'product_name': cartItem.product.name,
          'product_code': null, // Product class doesn't have code field
          'product_purity': cartItem.purity,
          'weight': cartItem.weight > 0 ? cartItem.weight.toStringAsFixed(3) : null,
          'count': cartItem.count > 0 ? cartItem.count : 0,
          'unit_amount': cartItem.unitAmount,
          'total_unit_amount': cartItem.totalUnitAmount,
          'total_amount': cartItem.totalAmount,
          'description': null,
          'wage_percent': cartItem.wagePercent > 0 ? cartItem.wagePercent.toString() : null,
          'wage_per_gram': cartItem.wagePerGram > 0 ? cartItem.wagePerGram : 0.0,
          'wage_per_count': cartItem.wagePerCount > 0 ? cartItem.wagePerCount : 0.0,
          'total_wage_amount': cartItem.totalWageAmount,
          'profit_percent': cartItem.profitPercent > 0 ? cartItem.profitPercent.toString() : null,
          'profit_amount': cartItem.profitAmount,
          'commission_percent': cartItem.commissionPercent > 0 ? cartItem.commissionPercent.toString() : null,
          'commission_amount': cartItem.commissionAmount,
          'tax': cartItem.taxAmount,
          'created_at': null,
        };
      }).toList();
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        backgroundColor: AppColors.white,
        collapsedBackgroundColor: AppColors.white,
        iconColor: AppColors.gold,
        collapsedIconColor: AppColors.textSecondary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        collapsedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        title: const Text(
          'اقلام فاکتور',
          style: TextStyle(
            fontFamily: 'Iranyekan',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryAlt,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${items.length} مورد',
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        children: [
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < items.length - 1 ? 12 : 0),
              child: _buildInvoiceItemRow(index, item),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInvoiceItemRow(int index, Map<String, dynamic> item) {
    final productName = item['product_name'] as String? ?? 'نامشخص';
    final productCode = item['product_code'] as String?;
    final productPurity = item['product_purity'] as String?;
    final weight = item['weight'] as String?;
    final count = item['count'] as int? ?? 0;
    final unitAmount = (item['unit_amount'] as num?)?.toDouble() ?? 0.0;
    final totalUnitAmount = (item['total_unit_amount'] as num?)?.toDouble() ?? 0.0;
    final totalAmount = (item['total_amount'] as num?)?.toDouble() ?? 0.0;
    final description = item['description'] as String?;
    final wagePercent = item['wage_percent'] as String?;
    final wagePerGram = (item['wage_per_gram'] as num?)?.toDouble() ?? 0.0;
    final wagePerCount = (item['wage_per_count'] as num?)?.toDouble() ?? 0.0;
    final totalWageAmount = (item['total_wage_amount'] as num?)?.toDouble() ?? 0.0;
    final profitPercent = item['profit_percent'] as String?;
    final profitAmount = (item['profit_amount'] as num?)?.toDouble() ?? 0.0;
    final commissionPercent = item['commission_percent'] as String?;
    final commissionAmount = (item['commission_amount'] as num?)?.toDouble() ?? 0.0;
    final tax = (item['tax'] as num?)?.toDouble() ?? 0.0;
    final createdAt = item['created_at'] as String?;
    
    String quantityText = '';
    if (count != null && count > 0) {
      quantityText = 'تعداد: $count';
    } else if (weight != null && weight != '0.000' && weight != '0') {
      quantityText = 'وزن: ${_formatWeight(weight)} گرم';
    }
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        backgroundColor: AppColors.cardSoft,
        collapsedBackgroundColor: AppColors.cardSoft,
        iconColor: AppColors.gold,
        collapsedIconColor: AppColors.textSecondary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        collapsedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                productName,
                style: const TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryAlt,
                ),
              ),
            ),
            Text(
              '${_format(totalAmount)} ریال',
              style: const TextStyle(
                fontFamily: 'Iranyekan',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        subtitle: quantityText.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  quantityText,
                  style: const TextStyle(
                    fontFamily: 'Iranyekan',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (productCode != null && productCode.isNotEmpty) ...[
                  _buildItemDetailRow('کد محصول', productCode),
                  const SizedBox(height: 8),
                ],
                if (productPurity != null && productPurity.isNotEmpty) ...[
                  _buildItemDetailRow('عیار', productPurity),
                  const SizedBox(height: 8),
                ],
                if (weight != null && weight != '0.000' && weight != '0') ...[
                  _buildItemDetailRow('وزن', '${_formatWeight(weight)} گرم'),
                  const SizedBox(height: 8),
                ],
                if (count != null && count > 0) ...[
                  _buildItemDetailRow('تعداد', count.toString()),
                  const SizedBox(height: 8),
                ],
                if (unitAmount > 0) ...[
                  _buildItemDetailRow('مبلغ واحد', '${_format(unitAmount)} ریال'),
                  const SizedBox(height: 8),
                ],
                if (totalUnitAmount > 0) ...[
                  _buildItemDetailRow('مبلغ کل واحد', '${_format(totalUnitAmount)} ریال'),
                  const SizedBox(height: 8),
                ],
                if (wagePercent != null && wagePercent.isNotEmpty) ...[
                  _buildItemDetailRow('درصد اجرت', '${_formatPercent(wagePercent)}%'),
                  const SizedBox(height: 8),
                ],
                if (wagePerGram > 0) ...[
                  _buildItemDetailRow('اجرت به ازای هر گرم', '${_format(wagePerGram)} ریال'),
                  const SizedBox(height: 8),
                ],
                if (wagePerCount > 0) ...[
                  _buildItemDetailRow('اجرت به ازای هر عدد', '${_format(wagePerCount)} ریال'),
                  const SizedBox(height: 8),
                ],
                if (totalWageAmount > 0) ...[
                  _buildItemDetailRow('مجموع اجرت', '${_format(totalWageAmount)} ریال'),
                  const SizedBox(height: 8),
                ],
                if (profitPercent != null && profitPercent.isNotEmpty) ...[
                  _buildItemDetailRow('درصد سود', '${_formatPercent(profitPercent)}%'),
                  const SizedBox(height: 8),
                ],
                if (profitAmount > 0) ...[
                  _buildItemDetailRow('مبلغ سود', '${_format(profitAmount)} ریال'),
                  const SizedBox(height: 8),
                ],
                if (commissionPercent != null && commissionPercent.isNotEmpty) ...[
                  _buildItemDetailRow('درصد حق العمل', '${_formatPercent(commissionPercent)}%'),
                  const SizedBox(height: 8),
                ],
                if (commissionAmount > 0) ...[
                  _buildItemDetailRow('مبلغ حق العمل', '${_format(commissionAmount)} ریال'),
                  const SizedBox(height: 8),
                ],
                if (tax > 0) ...[
                  _buildItemDetailRow('مالیات', '${_format(tax)} ریال'),
                  const SizedBox(height: 8),
                ],
                if (description != null && description.isNotEmpty) ...[
                  _buildItemDetailRow('توضیحات', description),
                  const SizedBox(height: 8),
                ],
                if (createdAt != null && createdAt.isNotEmpty) ...[
                  _buildItemDetailRow('تاریخ ایجاد', createdAt),
                  const SizedBox(height: 8),
                ],
                const Divider(height: 20, thickness: 1.5),
                const SizedBox(height: 4),
                _buildItemDetailRow(
                  'مبلغ کل',
                  '${_format(totalAmount)} ریال',
                  isBold: true,
                  valueColor: AppColors.gold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetailRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? AppColors.textPrimaryAlt,
            ),
          ),
        ),
      ],
    );
  }

  // این متد دیگر استفاده نمی‌شود - حذف شده
  Widget _buildOfficialInvoiceCard_DELETED(CartViewModel cartViewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان و toggle
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
                onChanged: _isInvoiceCreated
                    ? null // اگر invoice ایجاد شده، غیرفعال کن
                    : (value) {
                        setState(() {
                          _isOfficialInvoiceEnabled = value;
                          // اگر فاکتور رسمی غیرفعال شد، فیلدها را پاک کن
                          if (!value) {
                            _mobileController.clear();
                            _firstNameController.clear();
                            _lastNameController.clear();
                            _nationalCodeController.clear();
                            _economicCodeController.clear();
                            _branchCodeController.clear();
                            _uniqueInvoiceNumberController.clear();
                          }
                        });
                      },
                activeColor: AppColors.gold,
              ),
            ],
          ),

          // فیلدها فقط اگر toggle فعال باشد
          if (_isOfficialInvoiceEnabled) ...[
            const SizedBox(height: 16),
            // تب‌های نوع خریدار
            _buildCustomerTypeTabs(),
            const SizedBox(height: 16),
            // فیلدهای مربوط به نوع خریدار
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
              onTap: _isInvoiceCreated
                  ? null
                  : () {
                      setState(() {
                        _customerType = CustomerType.individual;
                        // پاک کردن فیلدهای غیرضروری
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
              onTap: _isInvoiceCreated
                  ? null
                  : () {
                      setState(() {
                        _customerType = CustomerType.legal;
                        // پاک کردن فیلدهای غیرضروری
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
              onTap: _isInvoiceCreated
                  ? null
                  : () {
                      setState(() {
                        _customerType = CustomerType.civic;
                        // پاک کردن فیلدهای غیرضروری
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
              onTap: _isInvoiceCreated
                  ? null
                  : () {
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
    required VoidCallback? onTap,
    bool isBold = false,
    bool isTwoLine = false,
  }) {
    Widget textWidget;
    
    if (isTwoLine && title == 'مشارکت مدنی') {
      // تقسیم متن به دو خط
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
      onTap: onTap ?? () {}, // اگر null باشد، تابع خالی
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
                  label: 'کد ملی',
                  controller: _nationalCodeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  isNumeric: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLabeledField(
                  label: 'کد اقتصادی',
                  controller: _economicCodeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  isNumeric: true,
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
          ),
        ];

      case CustomerType.legal:
        return [
          _buildLabeledField(
            label: 'شماره تماس خریدار*',
            controller: _mobileController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            isNumeric: true,
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
                  label: 'شناسه ملی',
                  controller: _nationalCodeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  isNumeric: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLabeledField(
                  label: 'کد اقتصادی',
                  controller: _economicCodeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  isNumeric: true,
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
          ),
        ];

      case CustomerType.civic:
        return [
          _buildLabeledField(
            label: 'شماره تماس خریدار*',
            controller: _mobileController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            isNumeric: true,
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
                  label: 'کد ملی',
                  controller: _nationalCodeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  isNumeric: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLabeledField(
                  label: 'کد اقتصادی',
                  controller: _economicCodeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  isNumeric: true,
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
          ),
        ];

      case CustomerType.foreigner:
        return [
          _buildLabeledField(
            label: 'شماره تماس خریدار*',
            controller: _mobileController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            isNumeric: true,
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
                  label: 'کد ملی',
                  controller: _nationalCodeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  isNumeric: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLabeledField(
                  label: 'کد اقتصادی',
                  controller: _economicCodeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  isNumeric: true,
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
          ),
        ];
    }
  }

  Widget _buildPaymentCard(CartViewModel cartViewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان بخش پرداخت‌ها
          const Text(
            'پرداخت ها',
            style: TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryAlt,
            ),
          ),
          const SizedBox(height: 12),
          
          // لیست رکوردهای پرداخت
          if (_paymentRecords.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: const Center(
                child: Text(
                  'هیچ پرداختی ثبت نشده است',
                  style: TextStyle(
                    fontFamily: 'Iranyekan',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ..._paymentRecords.asMap().entries.map((entry) {
              final index = entry.key;
              final record = entry.value;
              return _buildPaymentRecordItem(index, record);
            }),
          
          const SizedBox(height: 16),
          
          // خلاصه مبالغ - فقط اگر مقادیر معتبر هستند
          _buildPaymentSummary(cartViewModel),
          
          // دکمه افزودن پرداخت (فقط اگر باقیمانده بیشتر از صفر باشد)
          if (_remainingAmount > 0) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _openAddPaymentPage(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.add, size: 24),
                label: const Text(
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
        ],
      ),
    );
  }

  Widget _buildPaymentRecordItem(int index, PaymentRecord record) {
    IconData icon;
    
    switch (record.type) {
      case 'cash':
        icon = Icons.money;
        break;
      case 'gold':
        icon = Icons.diamond;
        break;
      case 'card':
        icon = Icons.credit_card;
        break;
      default:
        icon = Icons.payment;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerSoft, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.typeLabel,
                  style: const TextStyle(
                    fontFamily: 'Iranyekan',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryAlt,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_format(record.amount)} ریال',
                  style: const TextStyle(
                    fontFamily: 'Iranyekan',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                // نمایش transaction_id و card_number برای کارت
                if (record.type == 'card') ...[
                  if (record.details['transaction_id'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'شماره تراکنش: ${record.details['transaction_id']}',
                        style: const TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  if (record.details['card_number'] != null && record.details['card_number'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'شماره کارت: ${record.details['card_number']}',
                        style: const TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                ],
                // نمایش weight، unit_amount و purity برای طلا
                if (record.type == 'gold') ...[
                  if (record.details['weight'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'وزن: ${_formatWeight(record.details['weight']?.toString())} گرم',
                        style: const TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  if (record.details['unit_amount'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'مبلغ واحد: ${_format((record.details['unit_amount'] as num).toDouble())} ریال',
                        style: const TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  if (record.details['purity'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'عیار کالا: ${record.details['purity']}',
                        style: const TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(CartViewModel cartViewModel) {
    // تعیین مبلغ کل: اولویت با اطلاعات بارگذاری شده، سپس invoiceTotalAmount، سپس cartViewModel
    final totalAmount = _loadedInvoiceTotalAmount ?? 
        widget.invoiceTotalAmount ?? 
        cartViewModel.totalAmount;
    // همیشه از محاسبه محلی استفاده کن (جمع پرداخت‌ها)
    final totalPaid = _totalPaid;
    // همیشه از محاسبه محلی استفاده کن (تفاضل مبلغ کل از جمع پرداخت‌ها)
    final remaining = _remainingAmount;
    
    // اگر مقادیر 0 هستند و در حال loading هستیم، نمایش نده
    if (_isLoadingInvoice && _isExistingInvoice && totalAmount == 0 && totalPaid == 0 && remaining == 0) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (totalAmount > 0)
            _buildSummaryRow('مبلغ کل فاکتور', totalAmount, AppColors.textPrimaryAlt),
          if (totalAmount > 0 && totalPaid > 0)
            const SizedBox(height: 8),
          if (totalPaid > 0)
            _buildSummaryRow('مجموع پرداخت‌ها', totalPaid, AppColors.gold),
          if ((totalAmount > 0 || totalPaid > 0) && remaining >= 0)
            const Divider(height: 24, thickness: 1.5),
          if (remaining >= 0)
            _buildSummaryRow(
              'باقیمانده',
              remaining,
              remaining == 0 ? AppColors.gold : AppColors.error,
              isBold: true,
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Iranyekan',
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          '${_format(amount)} ریال',
          style: TextStyle(
            fontFamily: 'Iranyekan',
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textAlign: isNumeric ? TextAlign.left : TextAlign.right,
      enabled: !_isInvoiceCreated, // اگر invoice ایجاد شده، read-only کن
      readOnly: _isInvoiceCreated,
      onChanged: (_) {
        // به‌روزرسانی state برای validation
        if (_isOfficialInvoiceEnabled && !_isInvoiceCreated) {
          setState(() {});
        }
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.dividerSoft,
            width: 1.5,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(
            color: AppColors.dividerSoft,
            width: 1.5,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(
            color: AppColors.gold,
            width: 2,
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

}

