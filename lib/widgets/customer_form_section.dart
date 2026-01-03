import 'package:flutter/material.dart';
import 'form_input_field.dart';
import '../theme/app_theme.dart';

class CustomerFormSection extends StatelessWidget {
  final TextEditingController customerTypeController;
  final TextEditingController customerMobileController;
  final TextEditingController customerNameController;
  final TextEditingController customerNationalCodeController;

  const CustomerFormSection({
    super.key,
    required this.customerTypeController,
    required this.customerMobileController,
    required this.customerNameController,
    required this.customerNationalCodeController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.backgroundAlt,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'اطلاعات مشتری',
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
              label: 'نوع مشتری',
              controller: customerTypeController,
              isRequired: true,
            ),
            const SizedBox(height: 12),
            FormInputField(
              label: 'موبایل',
              controller: customerMobileController,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              isNumeric: true,
              isRequired: true,
            ),
            const SizedBox(height: 12),
            FormInputField(
              label: 'نام',
              controller: customerNameController,
              isRequired: true,
            ),
            const SizedBox(height: 12),
            FormInputField(
              label: 'کد ملی',
              controller: customerNationalCodeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              isNumeric: true,
              isRequired: true,
            ),
          ],
        ),
      ),
    );
  }
}

