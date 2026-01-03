import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

Future<Map<String, String>> pay({
  required BuildContext context,
  required String amount,
  required String currentCurrency,
}) async {
  const platform = MethodChannel('my_channel');
  try {
    final String result = await platform.invokeMethod('intentToPaymentApp', {
      'amount': (currentCurrency == "Rial")?amount:"${amount}0",
      'currency': currentCurrency,
    });

    // Parse the result JSON
    final Map<String, dynamic> paymentResult = jsonDecode(result);
    
    return {
      'Status': paymentResult['Status'] as String? ?? '',
      'RRN': paymentResult['RRN'] as String? ?? '',
      'CustomerCardNO': paymentResult['CustomerCardNO'] as String? ?? '',
    };
  } on PlatformException catch (e) {
    await showPersianDialog(
      context: context,
      title: "خطا",
      message: "خطا: ${e.message}",
    );
    return {
      'Status': 'ERROR',
      'RRN': '',
      'CustomerCardNO': '',
    };
  } catch (e) {
    await showPersianDialog(
      context: context,
      title: "خطا",
      message: "خطای غیر منتظره در پرداخت",
    );
    return {
      'Status': 'ERROR',
      'RRN': '',
      'CustomerCardNO': '',
    };
  }
}

bool isValidAmount(String amount) {
  if (amount.isEmpty) return false;
  final numericAmount = double.tryParse(amount.replaceAll(',', ''));
  return numericAmount != null && numericAmount > 0;
}

bool amountIsEnough(String originalNumber) {
  // print("amountIsEnough $originalNumber");
  // if (int.parse(originalNumber) >= 100000) {
  if (int.parse(originalNumber) >= 20000) {
    return true;
  } else {
    return false;
  }
}

String formatWithCommas(String originalNumber) {
  // Remove negative sign if exists
  String processed = originalNumber.startsWith('-') ? originalNumber.substring(1) : originalNumber;

  // Split into integer and decimal parts
  final parts = processed.split('.');
  String integerPart = parts[0].replaceAll(',', ''); // Remove existing commas

  // Add commas as thousand separators manually
  String result = '';
  int counter = 0;
  for (int i = integerPart.length - 1; i >= 0; i--) {
    result = integerPart[i] + result;
    counter++;
    if (counter % 3 == 0 && i != 0) {
      result = ',$result';
    }
  }

  return result;
}

String formatWithoutCommas(String amount) {
  return amount.replaceAll(',', '');
}

Future<void> callMethodChannel(String totalAmount, BuildContext context) async {
  //print(totalAmount+" is sending for ..");
  try {
    const platform = MethodChannel('ir.zar360.maaher/intent');
    final String result = await platform.invokeMethod('intentToPaymentApp', {
      'amount': totalAmount, // Example amount
    });
    debugPrint('Payment Result: $result');
  } on PlatformException catch (e) {
    debugPrint('Payment Error: ${e.message}');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در اتصال به درگاه پرداخت: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    debugPrint('Unexpected Error: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطا در اتصال به درگاه پرداخت'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

String formatCurrency({required String amount, required String currentCurrency}) {
  if (amount.isEmpty) return '';
  
  final numericAmount = double.tryParse(amount.replaceAll(',', ''));
  if (numericAmount == null) return amount;

  final parts = amount.split('.');
  String integerPart = parts[0].replaceAll(',', '');
  String result = '';

  for (int i = integerPart.length - 1, count = 0; i >= 0; i--, count++) {
    if (count > 0 && count % 3 == 0) {
      result = ',' + result;
    }
    result = integerPart[i] + result;
  }

  if (parts.length > 1) {
    result += '.' + parts[1];
  }

  return result;
}

Future<bool?> showPersianDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmText,
  String? cancelText,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          if (cancelText != null)
            TextButton(
              child: Text(cancelText),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          TextButton(
            child: Text(confirmText ?? 'تایید'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

Future<bool> showMinimumPaymentAmountError(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('خطا'),
      content: const Text('مبلغ وارد شده کمتر از حداقل مبلغ مجاز است'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('تایید'),
        ),
      ],
    ),
  ) ?? false;
}
