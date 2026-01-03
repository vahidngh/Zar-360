import '../utils/tax_id_generator.dart';

class InvoiceItem {
  final String productName;
  final double totalAmount;

  InvoiceItem({
    required this.productName,
    required this.totalAmount,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      productName: json['product_name'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
    );
  }
}

class Invoice {
  final int id;
  final String issuedAt;
  final double totalAmount;
  final String status;
  final String statusLabel;
  final String? sellerInvoiceNumber;
  final List<InvoiceItem> invoiceItems;
  final TaxInfo? tax;

  // Fiscal ID (memoryId6) - فعلا مقدار ثابت
  static const String fiscalId = 'A12894';

  Invoice({
    required this.id,
    required this.issuedAt,
    required this.totalAmount,
    required this.status,
    required this.statusLabel,
    this.sellerInvoiceNumber,
    required this.invoiceItems,
    this.tax,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as int,
      issuedAt: json['issued_at'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] as String,
      statusLabel: json['status_label'] as String,
      sellerInvoiceNumber: json['seller_invoice_number'] as String?,
      invoiceItems: (json['invoice_items'] as List<dynamic>)
          .map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      tax: json['tax'] != null
          ? TaxInfo.fromJson(json['tax'] as Map<String, dynamic>)
          : null,
    );
  }

  /// شماره مالیاتی (22 کاراکتر - با check digit)
  /// اگر maher_tax_id از سرویس موجود باشد، از آن استفاده می‌کند
  /// در غیر این صورت، شماره مالیاتی را محاسبه می‌کند
  String get taxId {
    // اگر maher_tax_id از سرویس موجود است، از آن استفاده کن
    if (tax?.maherTaxId != null && tax!.maherTaxId!.isNotEmpty) {
      return tax!.maherTaxId!;
    }
    
    // در غیر این صورت، شماره مالیاتی را محاسبه کن
    try {
      return TaxIdGenerator.buildTaxIdWithCheckDigit(
        memoryId6: fiscalId,
        jalaliDateTime: issuedAt,
        invoiceNo: id,
      );
    } catch (e) {
      // در صورت خطا، یک مقدار پیش‌فرض برگردان
      return 'N/A';
    }
  }
}

class TaxInfo {
  final bool allowSubmit;
  final bool allowCancel;
  final String status;
  final String statusLabel;
  final String? appStatusLabel;
  final String? maherTaxId;

  TaxInfo({
    required this.allowSubmit,
    required this.allowCancel,
    required this.status,
    required this.statusLabel,
    this.appStatusLabel,
    this.maherTaxId,
  });

  factory TaxInfo.fromJson(Map<String, dynamic> json) {
    return TaxInfo(
      allowSubmit: json['allow_submit'] as bool? ?? false,
      allowCancel: json['allow_cancel'] as bool? ?? false,
      status: json['status'] as String,
      statusLabel: json['status_label'] as String,
      appStatusLabel: json['app_status_label'] as String?,
      maherTaxId: json['maher_tax_id'] as String?,
    );
  }
}

class InvoiceListResponse {
  final List<Invoice> data;
  final Pagination pagination;
  final List<String> errors;

  InvoiceListResponse({
    required this.data,
    required this.pagination,
    required this.errors,
  });

  factory InvoiceListResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceListResponse(
      data: (json['data'] as List<dynamic>)
          .map((item) => Invoice.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class Pagination {
  final int currentPage;
  final int perPage;
  final int total;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
    );
  }
}

