import 'package:flutter/material.dart';
import 'form_input_field.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as persian_date;

class InvoiceFormSection extends StatelessWidget {
  final TextEditingController invoiceTypeController;
  final TextEditingController sellerInvoiceNumberController;
  final String issuedAt;

  const InvoiceFormSection({
    super.key,
    required this.invoiceTypeController,
    required this.sellerInvoiceNumberController,
    this.issuedAt = '',
  });

  @override
  Widget build(BuildContext context) {
    final currentDate = issuedAt.isEmpty ? persian_date.PersianDateUtils.getCurrentPersianDate() : issuedAt;

    return Card(
      color: AppColors.backgroundAlt,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'اطلاعات فاکتور',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Iranyekan',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryAlt,
              ),
            ),
            const SizedBox(height: 16),
            FormInputField(
              label: 'نوع فاکتور',
              controller: invoiceTypeController,
              isRequired: true,
            ),
            const SizedBox(height: 12),
            FormInputField(
              label: 'شماره فاکتور فروشنده',
              controller: sellerInvoiceNumberController,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.dividerSoft,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'تاریخ صدور',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Iranyekan',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    currentDate,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontFamily: 'Iranyekan',
                      fontSize: 14,
                      color: AppColors.textPrimaryAlt,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

