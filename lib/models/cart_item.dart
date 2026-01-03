import 'package:zar360/models/product_response.dart';

class CartItem {
  final int? id; // شناسه دیتابیس (nullable برای آیتم‌های جدید)
  final Product product;
  final double weight; // وزن کل (گرم) - فقط برای type="weight"
  final int count; // تعداد - فقط برای type="count"
  final String purity; // عیار کالا (مثل "750")
  final double unitAmount; // مبلغ واحد (هر گرم یا هر عدد)
  final double totalUnitAmount; // مبلغ واحد کل
  final double wagePercent; // درصد اجرت
  final double wagePerGram; // مبلغ اجرت هر گرم - فقط برای type="weight"
  final double wagePerCount; // مبلغ اجرت هر عدد - فقط برای type="count"
  final double totalWageAmount; // مبلغ اجرت کل
  final double profitPercent; // درصد سود فروش (0 اگر از مبلغ استفاده شده)
  final double profitAmount; // مبلغ سود فروش
  final double commissionPercent; // درصد حق‌العمل
  final double commissionAmount; // مبلغ حق‌العمل
  final double taxAmount; // مبلغ مالیات
  final double totalAmount; // مبلغ نهایی محصول

  CartItem({
    this.id,
    required this.product,
    required this.weight,
    required this.count,
    required this.purity,
    required this.unitAmount,
    required this.totalUnitAmount,
    required this.wagePercent,
    required this.wagePerGram,
    required this.wagePerCount,
    required this.totalWageAmount,
    required this.profitPercent,
    required this.profitAmount,
    required this.commissionPercent,
    required this.commissionAmount,
    required this.taxAmount,
    required this.totalAmount,
  });

  // تبدیل به JSON برای invoice_items
  Map<String, dynamic> toInvoiceItemJson() {
    return {
      'product_id': product.id,
      'product_name': product.name,
      'product_purity': purity,
      'weight': weight,
      'count': count,
      'unit_amount': unitAmount.round(),
      'total_unit_amount': totalUnitAmount.round(),
      'wage_percent': wagePercent,
      'wage_per_gram': wagePerGram.round(),
      'wage_per_count': wagePerCount.round(),
      'total_wage_amount': totalWageAmount.round(),
      'profit_percent': profitPercent,
      'profit_amount': profitAmount.round(),
      'commission_percent': commissionPercent,
      'commission_amount': commissionAmount.round(),
      // 'tax_amount': taxAmount.round(),
      'tax': taxAmount.round(),
      'total_amount': totalAmount.round(),
    };
  }
}

