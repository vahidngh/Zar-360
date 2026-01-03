import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class ThousandsSeparatorFormatter extends TextInputFormatter {
  // تبدیل اعداد فارسی به انگلیسی
  String _persianToEnglish(String text) {
    return text
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
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // تبدیل اعداد فارسی به انگلیسی
    final englishText = _persianToEnglish(newValue.text);
    final raw = englishText.replaceAll(',', '');
    if (raw.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // اجازه نقطه برای اعشار
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

class FormInputField extends StatelessWidget {
  final String label;
  final String? suffix;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool isNumeric;
  final bool isRequired;
  final String? Function(String?)? validator;

  const FormInputField({
    super.key,
    required this.label,
    this.suffix,
    this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.isNumeric = false,
    this.isRequired = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textAlign: isNumeric ? TextAlign.left : TextAlign.right,
      decoration: InputDecoration(
        labelText: isRequired ? '$label*' : label,
        alignLabelWithHint: maxLines > 1,
        suffix: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  suffix!,
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
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(
            color: AppColors.gold,
            width: 1.2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      style: const TextStyle(
        fontFamily: 'Iranyekan',
        fontSize: 14,
        color: AppColors.textPrimaryAlt,
      ),
      inputFormatters:
          isNumeric ? <TextInputFormatter>[ThousandsSeparatorFormatter()] : null,
    );
  }
}

