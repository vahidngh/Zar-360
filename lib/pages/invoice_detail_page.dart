import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../services/invoice_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_loading_widget.dart';
import '../utils/tax_id_generator.dart';
import '../utils/error_handler.dart';
import '../utils/app_config.dart';
import 'package:intl/intl.dart';

class InvoiceDetailPage extends StatefulWidget {
  final int invoiceId;

  const InvoiceDetailPage({
    super.key,
    required this.invoiceId,
  });

  @override
  State<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends State<InvoiceDetailPage> {
  final _invoiceService = InvoiceService();
  Map<String, dynamic>? _invoiceData;
  bool _isLoading = true;
  String? _errorMessage;
  final _currencyFormat = NumberFormat.decimalPattern();
  final GlobalKey _printKey = GlobalKey();
  String? _sellerName;
  String? _sellerMobile;
  String deviceBrand = "";
  String deviceModel = "";
  @override
  void initState() {
    super.initState();
    _loadSellerInfo();
    _loadInvoiceDetails();
    _getDeviceInfo();
  }

  Future<void> _loadSellerInfo() async {
    final name = await StorageService.getUserName();
    final mobile = await StorageService.getMobile();
    setState(() {
      _sellerName = name;
      _sellerMobile = mobile;
    });
  }

  Future<void> _loadInvoiceDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _invoiceService.getInvoice(widget.invoiceId);
      setState(() {
        _invoiceData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = ErrorHandler.getFarsiErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  String _format(double value) {
    if (value == 0) return '0';
    // اگر عدد صحیح است (بدون اعشار)، به صورت عدد صحیح نمایش بده
    if (value == value.roundToDouble()) {
      return _currencyFormat.format(value.round());
    }
    // در غیر این صورت، اعشار را نمایش بده اما اعشارهای 0 را حذف کن
    final formatted = _currencyFormat.format(value);
    // حذف اعشارهای 0 از انتها
    if (formatted.contains('.')) {
      return formatted.replaceAll(RegExp(r'\.?0+$'), '');
    }
    return formatted;
  }

  String _getStringValue(dynamic value) {
    if (value == null) return '-';
    return value.toString();
  }

  // فرمت کردن درصد - حذف اعشارهای صفر
  String _formatPercent(dynamic percentValue) {
    if (percentValue == null) return '0';
    
    String percentStr = percentValue.toString();
    
    // اگر عدد است، به double تبدیل کن
    final doubleValue = double.tryParse(percentStr);
    if (doubleValue != null) {
      // اگر عدد صحیح است، بدون اعشار نمایش بده
      if (doubleValue == doubleValue.roundToDouble()) {
        return doubleValue.round().toString();
      }
      // در غیر این صورت، اعشارهای صفر را حذف کن
      percentStr = doubleValue.toString();
      if (percentStr.contains('.')) {
        percentStr = percentStr.replaceAll(RegExp(r'\.?0+$'), '');
      }
    }
    
    return percentStr;
  }


  String _getTaxId() {
    if (_invoiceData == null) return '';
    
    // اگر maher_tax_id از سرویس موجود است، از آن استفاده کن
    if (_invoiceData!['tax'] != null &&
        _invoiceData!['tax'] is Map<String, dynamic> &&
        (_invoiceData!['tax'] as Map<String, dynamic>)['maher_tax_id'] != null &&
        (_invoiceData!['tax'] as Map<String, dynamic>)['maher_tax_id'].toString().isNotEmpty) {
      return (_invoiceData!['tax'] as Map<String, dynamic>)['maher_tax_id'].toString();
    }
    
    // در غیر این صورت، شماره مالیاتی را محاسبه کن
    try {
      const fiscalId = 'A12894'; // Fiscal ID (memoryId6)
      final invoiceId = _invoiceData!['id'] as int? ?? 0;
      final issuedAt = _invoiceData!['issued_at'] as String? ?? '';
      
      return TaxIdGenerator.buildTaxIdWithCheckDigit(
        memoryId6: fiscalId,
        jalaliDateTime: issuedAt,
        invoiceNo: invoiceId,
      );
    } catch (e) {
      // در صورت خطا، یک مقدار پیش‌فرض برگردان
      return 'N/A';
    }
  }

  Future<void> _printInvoice() async {
    try {
      // await Future.delayed(const Duration(seconds: 1));
      // Capture widget as bitmap
      final RenderRepaintBoundary boundary =
          _printKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final imageEncoded = base64.encode(pngBytes);
      
      if (byteData != null) {
        _print(imageEncoded);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('در حال چاپ فاکتور...'),
              duration: Duration(seconds: 1),
            ),
          );
        }
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در چاپ: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<String> _print(String image) async {
    const platform = MethodChannel("my_channel");
    try {
      final String result = await platform.invokeMethod('print', {"image": image});
      return result;
    } on PlatformException catch (e) {
      return 'Error: ${e.message}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'جزئیات فاکتور',
          style: TextStyle(
            fontFamily: 'Iranyekan',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (_invoiceData != null)
            IconButton(
              icon: const Icon(Icons.print, color: Colors.black),
              onPressed: _printInvoice,
              tooltip: 'پرینت',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: AppLoadingWidget(size: 80),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadInvoiceDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'تلاش مجدد',
                          style: TextStyle(fontFamily: 'Iranyekan'),
                        ),
                      ),
                    ],
                  ),
                )
              : _invoiceData == null
                  ? const Center(
                      child: Text(
                        'اطلاعاتی یافت نشد',
                        style: TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: RepaintBoundary(
                        key: _printKey,
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                            // لوگو
                            const SizedBox(height: 6),
                            Center(
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Colors.black,
                                  BlendMode.srcIn,
                                ),
                                child: Column(
                                  children: [
                                    if (AppConfig.app == App.maaher)
                                      Center(
                                        child: Image.asset(
                                          AppConfig.getLogoPath(),
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.contain,
                                        ),
                                      ),

                                    if (AppConfig.app == App.zar360)
                                      Center(
                                        child: Image.asset(
                                          AppConfig.getLogoPath(),
                                          width: 190,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // هدر فاکتور
                            const Center(
                              child: Text(
                                'فاکتور فروش',
                                style: TextStyle(
                                  fontFamily: 'Iranyekan',
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // شماره مالیاتی
                            Center(
                              child: Text(
                                _getTaxId(),
                                style: const TextStyle(
                                  fontFamily: 'Tahoma',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // اطلاعات فروشنده
                            if (_sellerName != null || _sellerMobile != null) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // عنوان کادر
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(6),
                                          topRight: Radius.circular(6),
                                        ),
                                      ),
                                      child: const Text(
                                        'اطلاعات فروشنده',
                                        style: TextStyle(
                                          fontFamily: 'Iranyekan',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child:  Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _sellerName ?? '-',
                                                  style: const TextStyle(
                                                    fontFamily: 'Iranyekan',
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // شماره موبایل (سمت چپ)
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  _sellerMobile ?? '-',
                                                  style: const TextStyle(
                                                    fontFamily: 'Iranyekan',
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            const Divider(color: Colors.black, thickness: 2),
                            const SizedBox(height: 6),

                            // شماره فاکتور
                            if (_invoiceData!['seller_invoice_number'] != null &&
                                _invoiceData!['seller_invoice_number'].toString().isNotEmpty)
                              _buildInfoRow('شماره فاکتور:', _getStringValue(_invoiceData!['seller_invoice_number'])),

                            // تاریخ
                            _buildInfoRow('تاریخ:', _getStringValue(_invoiceData!['issued_at'])),

                            // نوع فاکتور
                            _buildInfoRow('نوع فاکتور:', _invoiceData!['type_label']),

                            // شماره مالیاتی
                            if (_invoiceData!['tax'] != null &&
                                _invoiceData!['tax'] is Map<String, dynamic> &&
                                (_invoiceData!['tax'] as Map<String, dynamic>)['maher_tax_id'] != null)
                              _buildInfoRow('شماره مالیاتی:', _getStringValue((_invoiceData!['tax'] as Map<String, dynamic>)['maher_tax_id'])),

                            // وضعیت پرداخت
                            _buildInfoRow('وضعیت پرداخت:', _invoiceData!['status_label']),

                            // وضعیت ارسال به دارایی
                            if (_invoiceData!['tax'] != null &&
                                _invoiceData!['tax'] is Map<String, dynamic> &&
                                (_invoiceData!['tax'] as Map<String, dynamic>)['app_status_label'] != null)
                              _buildInfoRow('ارسال به دارایی:', _getStringValue((_invoiceData!['tax'] as Map<String, dynamic>)['app_status_label'])),

                            // اطلاعات مشتری
                            ..._buildCustomerInfo(),

                            const SizedBox(height: 20),

                            // لیست محصولات
                            const Text(
                              'محصولات',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Iranyekan',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Divider(color: Colors.black, thickness: 2),
                            const SizedBox(height: 4),
                            if (_invoiceData!['invoice_items'] != null &&
                                _invoiceData!['invoice_items'] is List)
                              ...(_invoiceData!['invoice_items'] as List).map((item) {
                                return _buildInvoiceItem(item);
                              }),

                            const SizedBox(height: 6),
                            const Divider(color: Colors.black, thickness: 2),
                            const SizedBox(height: 6),

                            // مبالغ
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // عنوان کادر
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        topRight: Radius.circular(6),
                                      ),
                                    ),
                                    child: const Text(
                                      'خلاصه مبالغ',
                                      style: TextStyle(
                                        fontFamily: 'Iranyekan',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        _buildInfoRow(
                                          'جمع کل:',
                                          '${_format((_invoiceData!['total_amount'] as num?)?.toDouble() ?? 0)} ریال',
                                          isBold: true,
                                        ),
                                        if (_invoiceData!['paid_amount'] != null)
                                          _buildInfoRow(
                                            'مبلغ پرداخت شده:',
                                            '${_format((_invoiceData!['paid_amount'] as num).toDouble())} ریال',
                                          ),
                                        if (_invoiceData!['remaining_amount'] != null)
                                          _buildInfoRow(
                                            'مبلغ باقیمانده:',
                                            '${_format((_invoiceData!['remaining_amount'] as num).toDouble())} ریال',
                                          ),
                                        if (_invoiceData!['total_wage'] != null)
                                          _buildInfoRow(
                                            'اجرت:',
                                            '${_format((_invoiceData!['total_wage'] as num).toDouble())} ریال',
                                          ),
                                        if (_invoiceData!['total_profit'] != null)
                                          _buildInfoRow(
                                            'سود:',
                                            '${_format((_invoiceData!['total_profit'] as num).toDouble())} ریال',
                                          ),
                                        if (_invoiceData!['total_commission'] != null)
                                          _buildInfoRow(
                                            'حق العمل:',
                                            '${_format((_invoiceData!['total_commission'] as num).toDouble())} ریال',
                                          ),
                                        if (_invoiceData!['total_tax'] != null)
                                          _buildInfoRow(
                                            'مالیات:',
                                            '${_format((_invoiceData!['total_tax'] as num).toDouble())} ریال',
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 6),

                            // پرداخت‌ها
                            if (_invoiceData!['payments'] != null &&
                                _invoiceData!['payments'] is List &&
                                (_invoiceData!['payments'] as List).isNotEmpty) ...[
                              const SizedBox(height: 6),
                              const Divider(color: Colors.black, thickness: 2),
                              const SizedBox(height: 6),
                              Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // عنوان کادر
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(6),
                                          topRight: Radius.circular(6),
                                        ),
                                      ),
                                      child: const Text(
                                        'پرداخت‌ها',
                                        style: TextStyle(
                                          fontFamily: 'Iranyekan',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          ...(_invoiceData!['payments'] as List).asMap().entries.map((entry) {
                                            final index = entry.key;
                                            final payment = entry.value;
                                            return _buildPaymentItem(index, payment);
                                          }),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 6),
                            const Divider(color: Colors.black, thickness: 2),
                            const SizedBox(height: 6),
                            // پاورقی
                            const Center(
                              child: Text(
                                'با تشکر از خرید شما',
                                style: TextStyle(
                                  fontFamily: 'Iranyekan',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                              if(deviceBrand == "Urovo" && deviceModel == "i9100/W")
                                SizedBox(height: 150,),
                          ],
                          ),
                        ),
                      ),
                    ),
    );
  }

  Future<void> _getDeviceInfo() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        setState(() {
          deviceBrand = androidInfo.brand;
          deviceModel = androidInfo.model;
        });
        debugPrint("deviceBrand $deviceBrand deviceModel $deviceModel");
      }
    } catch (e) {
      // در صورت خطا، مقادیر پیش‌فرض باقی می‌مانند
    }
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Iranyekan',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Expanded(
              child: (value.length>20)?FittedBox(
                fit: BoxFit.fitWidth,
                child: Directionality(
                textDirection: ui.TextDirection.ltr,
                  child: Text(
                    value,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Iranyekan',
                      fontSize: 18,
                      fontWeight: isBold ? FontWeight.bold : FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                )
              ):Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Text(
                  value,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'Iranyekan',
                    fontSize: 18,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCustomerInfo() {
    // فقط اگر فاکتور رسمی باشد (is_official == true)
    // if (_invoiceData!['is_official'] != true) {
    //   return [];
    // }
    
    if (_invoiceData!['customer'] == null || 
        _invoiceData!['customer'] is! Map<String, dynamic>) {
      return [];
    }
    
    final customer = _invoiceData!['customer'] as Map<String, dynamic>;
    return [
      const SizedBox(height: 6),
      const Divider(color: Colors.black, thickness: 2),
      const SizedBox(height: 6),



        Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // عنوان کادر
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
                child: const Text(
                  'اطلاعات مشتری',
                  style: TextStyle(
                    fontFamily: 'Iranyekan',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child:  Column(
                  children: [
                    if (customer['name'] != null)
                      _buildInfoRow('نام:', _getStringValue(customer['name'])),
                    if (customer['mobile'] != null)
                      _buildInfoRow('موبایل:', _getStringValue(customer['mobile'])),
                    if (customer['national_code'] != null)
                      _buildInfoRow('کد ملی:', _getStringValue(customer['national_code'])),
                  ],
                )
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

    ];
  }

  Widget _buildInvoiceItem(Map<String, dynamic> item) {
    final productName = item['product_name'] != null 
        ? _getStringValue(item['product_name']) 
        : 'محصول';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان کادر (نام محصول)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: Text(
              productName,
              style: const TextStyle(
                fontFamily: 'Iranyekan',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // عیار محصول
                if (item['product_purity'] != null)
                  _buildInfoRow('عیار:', _getStringValue(item['product_purity'])),
                
                // وزن و اجرت به ازای گرم
                if (item['weight'] != null && 
                    item['weight'].toString().isNotEmpty &&
                    double.tryParse(item['weight'].toString()) != null &&
                    double.parse(item['weight'].toString()) > 0) ...[
                  _buildInfoRow('وزن:', '${_format(double.parse(item['weight'].toString()))} گرم'),
                  if (item['wage_per_gram'] != null)
                    _buildInfoRow('اجرت به ازای گرم:', '${_format((item['wage_per_gram'] as num?)?.toDouble() ?? 0)} ریال'),
                ],
                
                // تعداد و اجرت به ازای عدد
                if (item['count'] != null && 
                    item['count'].toString().isNotEmpty &&
                    (item['count'] as num).toDouble() > 0) ...[
                  _buildInfoRow('تعداد:', _getStringValue(item['count'])),
                  if (item['wage_per_count'] != null)
                    _buildInfoRow('اجرت به ازای عدد:', '${_format((item['wage_per_count'] as num?)?.toDouble() ?? 0)} ریال'),
                ],
                
                // مبلغ واحد
                if (item['unit_amount'] != null)
                  _buildInfoRow('مبلغ واحد:', '${_format((item['unit_amount'] as num?)?.toDouble() ?? 0)} ریال'),
                
                // مبلغ کل واحد
                if (item['total_unit_amount'] != null)
                  _buildInfoRow('مبلغ کل واحد:', '${_format((item['total_unit_amount'] as num?)?.toDouble() ?? 0)} ریال'),
                
                // درصد اجرت
                if (item['wage_percent'] != null)
                  _buildInfoRow('درصد اجرت:', '${_formatPercent(item['wage_percent'])}%'),
                
                // مبلغ اجرت
                if (item['total_wage_amount'] != null)
                  _buildInfoRow('مبلغ اجرت:', '${_format((item['total_wage_amount'] as num?)?.toDouble() ?? 0)} ریال'),
                
                // درصد سود
                if (item['profit_percent'] != null)
                  _buildInfoRow('درصد سود:', '${_formatPercent(item['profit_percent'])}%'),
                
                // مبلغ سود
                if (item['profit_amount'] != null)
                  _buildInfoRow('مبلغ سود:', '${_format((item['profit_amount'] as num?)?.toDouble() ?? 0)} ریال'),
                
                // درصد حق العمل
                if (item['commission_percent'] != null)
                  _buildInfoRow('درصد حق العمل:', '${_formatPercent(item['commission_percent'])}%'),
                
                // مبلغ حق العمل
                if (item['commission_amount'] != null)
                  _buildInfoRow('مبلغ حق العمل:', '${_format((item['commission_amount'] as num?)?.toDouble() ?? 0)} ریال'),
                
                // مالیات
                if (item['tax'] != null)
                  _buildInfoRow('مالیات:', '${_format((item['tax'] as num?)?.toDouble() ?? 0)} ریال'),
                
                // توضیحات
                if (item['description'] != null && item['description'].toString().isNotEmpty)
                  _buildInfoRow('توضیحات:', _getStringValue(item['description'])),
                
                // تاریخ ایجاد
                if (item['created_at'] != null)
                  _buildInfoRow('تاریخ ایجاد:', _getStringValue(item['created_at'])),
                
                const SizedBox(height: 4),
                const Divider(color: Colors.black, thickness: 2),
                const SizedBox(height: 4),
                // مبلغ کل
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'مبلغ کل:',
                      style: TextStyle(
                        fontFamily: 'Iranyekan',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${_format((item['total_amount'] as num?)?.toDouble() ?? 0)} ریال',
                      style: const TextStyle(
                        fontFamily: 'Iranyekan',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(int index, Map<String, dynamic> payment) {
    final type = payment['type'] as String? ?? '';
    final typeLabel = payment['type_label'] as String? ?? '';
    final amount = (payment['amount'] as num?)?.toDouble() ?? 0;
    final status = payment['status'] as String?;
    final statusLabel = payment['status_label'] as String?;
    final createdAt = payment['created_at'] as String?;
    
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
    
    return Container(
      margin: EdgeInsets.only(bottom: index < ((_invoiceData!['payments'] as List).length - 1) ? 4 : 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // نوع پرداخت و مبلغ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                typeLabel,
                style: const TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                '${_format(amount)} ریال',
                style: const TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: Colors.black, thickness: 2),
          const SizedBox(height: 4),
          
          // وضعیت پرداخت
          if (statusLabel != null)
            _buildInfoRow('وضعیت:', statusLabel),
          
          // تاریخ ایجاد
          if (createdAt != null)
            _buildInfoRow('تاریخ:', createdAt),
          
          // جزئیات پرداخت
          if (type == 'card') ...[
            if (details['transaction_id'] != null)
              _buildInfoRow('شماره تراکنش:', _getStringValue(details['transaction_id'])),
            if (details['card_number'] != null && details['card_number'].toString().isNotEmpty)
              _buildInfoRow('شماره کارت:', _getStringValue(details['card_number'])),
          ],
          
          if (type == 'gold') ...[
            if (details['weight'] != null)
              _buildInfoRow('وزن:', '${_formatWeight(details['weight']?.toString())} گرم'),
            if (details['unit_amount'] != null)
              _buildInfoRow('مبلغ واحد:', '${_format((details['unit_amount'] as num).toDouble())} ریال'),
            if (details['purity'] != null)
              _buildInfoRow('عیار:', _getStringValue(details['purity'])),
          ],
        ],
      ),
    );
  }

  String _formatWeight(String? weightString) {
    if (weightString == null || weightString.isEmpty) return '0';
    final weightValue = double.tryParse(weightString);
    if (weightValue == null) return '0';
    // اگر اعشار 0 است، بدون اعشار نمایش بده
    if (weightValue == weightValue.roundToDouble()) {
      return weightValue.round().toString();
    }
    // در غیر این صورت، اعشارهای صفر را حذف کن
    String formatted = weightValue.toString();
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'\.?0+$'), '');
    }
    return formatted;
  }
}
