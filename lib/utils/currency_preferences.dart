import 'package:shared_preferences/shared_preferences.dart';

class CurrencyPreferences {
  static const String _currencyKey = 'default_currency';
  static const String _defaultCurrency = 'Rial';

  // Save currency preference (Rial or Toman)
  static Future<void> saveCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    if (currency == 'Rial' || currency == 'Toman') {
      await prefs.setString(_currencyKey, currency);
    } else {
      throw ArgumentError('Invalid currency: must be "Rial" or "Toman"');
    }
  }

  // Get saved currency preference (defaults to Rial)
  static Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? _defaultCurrency;
  }

  // Check if currency is valid (optional helper method)
  static bool _isValidCurrency(String currency) {
    return currency == 'Rial' || currency == 'Toman';
  }

  static Future<void> toggleCurrency() async {
    final current = await getCurrency();
    await saveCurrency(current == 'Rial' ? 'Toman' : 'Rial');
  }


  String getCurrencyLabel(String currentCurrency){
    if(currentCurrency=="Rial")return"ریال";
    else if(currentCurrency=="Toman")return"تومان";
    else return "نامشخص";
  }
}