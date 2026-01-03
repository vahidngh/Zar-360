import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zar360/models/product_response.dart';
import 'package:zar360/models/cart_item.dart';
import 'package:zar360/viewmodels/cart_viewmodel.dart';
import 'package:zar360/theme/app_theme.dart';

enum PricingInputMode {
  viaUnitAmount, // واردکردن مبلغ واحد
  viaMoezneh, // محاسبه از طریق مظنه
}

enum ProfitInputMode {
  viaPercent, // واردکردن درصد سود فروش
  viaAmount, // واردکردن مبلغ سود فروش
}

class ProductPricingBottomSheet extends StatefulWidget {
  final Product product;
  final CartViewModel? cartViewModel;
  final CartItem? existingCartItem; // برای حالت ویرایش

  const ProductPricingBottomSheet({
    super.key,
    required this.product,
    this.cartViewModel,
    this.existingCartItem,
  });

  @override
  State<ProductPricingBottomSheet> createState() => _ProductPricingBottomSheetState();
}

class _ProductPricingBottomSheetState extends State<ProductPricingBottomSheet> {
  final _weightController = TextEditingController();
  final _countController = TextEditingController();
  late final TextEditingController _purityController;
  final _unitAmountController = TextEditingController();
  final _moeznehController = TextEditingController();
  final _wagePercentController = TextEditingController();
  final _wagePerGramController = TextEditingController();
  final _wagePerCountController = TextEditingController();
  final _profitPercentController = TextEditingController();
  final _profitAmountController = TextEditingController();
  final _commissionPercentController = TextEditingController();
  final _extraDescriptionController = TextEditingController();

  // FocusNode ها برای همه فیلدها
  final _weightFocusNode = FocusNode();
  final _countFocusNode = FocusNode();
  final _purityFocusNode = FocusNode();
  final _moeznehFocusNode = FocusNode();
  final _unitAmountFocusNode = FocusNode();
  final _wagePercentFocusNode = FocusNode();
  final _wagePerGramFocusNode = FocusNode();
  final _wagePerCountFocusNode = FocusNode();
  final _profitPercentFocusNode = FocusNode();
  final _profitAmountFocusNode = FocusNode();
  final _commissionPercentFocusNode = FocusNode();
  final _extraDescriptionFocusNode = FocusNode();

  final _scrollController = ScrollController();
  bool _isFinalAmountVisible = false;

  PricingInputMode _mode = PricingInputMode.viaUnitAmount;
  ProfitInputMode _profitMode = ProfitInputMode.viaPercent;

  // مقادیر محاسبه‌شده
  double _unitAmount = 0; // مبلغ واحد (هر گرم یا هر عدد)
  double _unitTotalAmount = 0; // مبلغ واحد کل
  double _wagePerGram = 0;
  double _wagePerCount = 0;
  double _wageTotal = 0;
  double _profitAmount = 0;
  double _taxAmount = 0; // مالیات
  double _commissionAmount = 0;
  double _finalAmount = 0;
  double _profitPercentFromAmount = 0;

  // نوع محصول
  bool get _isWeightBased => widget.product.type == 'weight';

  bool get _isCountBased => widget.product.type == 'count';

  final _currencyFormat = NumberFormat.decimalPattern();

  // تبدیل اعداد فارسی به انگلیسی
  String _persianToEnglish(String text) {
    return text.replaceAll('۰', '0').replaceAll('۱', '1').replaceAll('۲', '2').replaceAll('۳', '3').replaceAll('۴', '4').replaceAll('۵', '5').replaceAll('۶', '6').replaceAll('۷', '7').replaceAll('۸', '8').replaceAll('۹', '9');
  }

  double _parseController(TextEditingController c) {
    // تبدیل اعداد فارسی به انگلیسی قبل از parse
    final raw = _persianToEnglish(c.text).replaceAll(',', '').trim();
    if (raw.isEmpty) return 0;
    return double.tryParse(raw) ?? 0;
  }

  String _format(double value) {
    if (value == 0) return '0';
    return _currencyFormat.format(value.round());
  }

  // حذف کلمه Exception از پیام خطا (case-insensitive)
  String _cleanErrorMessage(dynamic error) {
    String message = error.toString();
    // حذف "Exception: " از ابتدای پیام (case-insensitive)
    message = message.replaceFirst(RegExp(r'^[Ee][Xx][Cc][Ee][Pp][Tt][Ii][Oo][Nn]:\s*', caseSensitive: false), '');
    // حذف "Exception" از ابتدای پیام (case-insensitive)
    message = message.replaceFirst(RegExp(r'^[Ee][Xx][Cc][Ee][Pp][Tt][Ii][Oo][Nn]\s+', caseSensitive: false), '');
    return message.trim();
  }

  // فرمت کردن با یک رقم اعشار (اگر اعشار 0 بود نمایش داده نمی‌شود)
  String _formatWithOneDecimal(double value) {
    if (value == 0) return '0';
    final formatted = value.toStringAsFixed(1);
    // اگر اعشار 0 بود، آن را حذف کن
    if (formatted.endsWith('.0')) {
      return formatted.substring(0, formatted.length - 2);
    }
    return formatted;
  }

  void _onAnyFieldChanged() {
    final weight = _parseController(_weightController); // گرم
    final count = _parseController(_countController).toInt(); // تعداد
    final wagePercent = _parseController(_wagePercentController);
    final wagePerGramInput = _parseController(_wagePerGramController);
    final wagePerCountInput = _parseController(_wagePerCountController);
    final commissionPercent = _parseController(_commissionPercentController);

    // محاسبه مبلغ واحد بر اساس حالت انتخابی
    if (_mode == PricingInputMode.viaMoezneh) {
      final moezneh = _parseController(_moeznehController);
      if (moezneh > 0) {
        _unitAmount = moezneh / 4.332;
        _unitAmountController.text = _format(_unitAmount);
      } else {
        _unitAmount = 0;
        _unitAmountController.text = '';
      }
    } else {
      _unitAmount = _parseController(_unitAmountController);
    }

    // مبلغ واحد کل - بر اساس نوع محصول
    if (_isWeightBased) {
      _unitTotalAmount = _unitAmount * weight;
    } else if (_isCountBased) {
      _unitTotalAmount = _unitAmount * count;
    } else {
      _unitTotalAmount = _unitAmount * weight; // fallback
    }

    // اجرت - بر اساس نوع محصول
    // مبلغ اجرت کل = (درصد اجرت × مبلغ واحد کل) + (مبلغ اجرت هر واحد × تعداد/وزن)
    final wageFromPercent = (_unitTotalAmount * wagePercent) / 100;

    if (_isWeightBased) {
      _wagePerGram = wagePerGramInput;
      _wagePerCount = 0;
      final wageFromPerGram = _wagePerGram * weight;
      _wageTotal = wageFromPercent + wageFromPerGram;
    } else if (_isCountBased) {
      _wagePerGram = 0;
      _wagePerCount = wagePerCountInput;
      final wageFromPerCount = _wagePerCount * count;
      _wageTotal = wageFromPercent + wageFromPerCount;
    } else {
      _wagePerGram = wagePerGramInput;
      _wagePerCount = 0;
      final wageFromPerGram = _wagePerGram * weight;
      _wageTotal = wageFromPercent + wageFromPerGram; // fallback
    }

    // سود فروش روی (مبلغ واحد کل + اجرت کل)
    final baseBeforeProfit = _unitTotalAmount + _wageTotal;
    if (_profitMode == ProfitInputMode.viaPercent) {
      final profitPercent = _parseController(_profitPercentController);
      _profitAmount = baseBeforeProfit * (profitPercent / 100);
      // فقط در حالت درصدی، مقدار را در اینپوت ننویس (بگذار کاربر بتواند مستقیماً مقدار را وارد کند)
      // مقدار فقط در نمایش نتیجه استفاده می‌شود
      _profitPercentFromAmount = profitPercent;
    } else {
      _profitAmount = _parseController(_profitAmountController);
      if (baseBeforeProfit > 0) {
        _profitPercentFromAmount = (_profitAmount / baseBeforeProfit) * 100;
      } else {
        _profitPercentFromAmount = 0;
      }
    }

    // حق‌العمل روی مجموع قبلی + سود
    final baseBeforeCommission = baseBeforeProfit + _profitAmount;
    _commissionAmount = baseBeforeCommission * (commissionPercent / 100);

    // مالیات بر (اجرت کل + سود فروش + حق‌العمل)
    final baseForTax = _wageTotal + _profitAmount + _commissionAmount;
    _taxAmount = baseForTax * (widget.product.taxPercent / 100);

    // مبلغ نهایی = مبلغ واحد کل + اجرت کل + سود فروش + حق‌العمل + مالیات
    _finalAmount = baseBeforeCommission + _commissionAmount + _taxAmount;

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // مقداردهی اولیه فیلد عیار
    String purityValue = '';
    if (widget.existingCartItem != null) {
      // اگر در حالت ویرایش هستیم، از مقدار موجود استفاده کن
      purityValue = widget.existingCartItem!.purity.isNotEmpty ? widget.existingCartItem!.purity : (widget.product.purity.isNotEmpty ? widget.product.purity : '');
    } else {
      // مقداردهی اولیه با مقدار purity محصول
      purityValue = widget.product.purity.isNotEmpty ? widget.product.purity : '';
    }

    _purityController = TextEditingController(text: purityValue);

    // مقداردهی اولیه فیلدهای اجرت و حق‌العمل با 0
    if (widget.existingCartItem == null) {
      _wagePerGramController.text = '0';
      _wagePerCountController.text = '0';
      _commissionPercentController.text = '0';
    }

    // اگر در حالت ویرایش هستیم، فیلدها را با مقادیر موجود پر کن
    if (widget.existingCartItem != null) {
      final item = widget.existingCartItem!;

      // پر کردن فیلدها با مقادیر موجود
      if (_isWeightBased && item.weight > 0) {
        _weightController.text = _format(item.weight);
      } else if (_isCountBased && item.count > 0) {
        _countController.text = item.count.toString();
      }

      _unitAmountController.text = _format(item.unitAmount);
      _wagePercentController.text = _format(item.wagePercent);

      if (_isWeightBased && item.wagePerGram > 0) {
        _wagePerGramController.text = _format(item.wagePerGram);
      } else if (_isCountBased && item.wagePerCount > 0) {
        _wagePerCountController.text = _format(item.wagePerCount);
      }

      // تعیین حالت سود فروش
      if (item.profitPercent > 0) {
        _profitMode = ProfitInputMode.viaPercent;
        _profitPercentController.text = _format(item.profitPercent);
      } else if (item.profitAmount > 0) {
        _profitMode = ProfitInputMode.viaAmount;
        _profitAmountController.text = _format(item.profitAmount);
      }

      _commissionPercentController.text = _format(item.commissionPercent);

      // محاسبه مقادیر
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onAnyFieldChanged();
      });
    }

    _weightController.addListener(_onAnyFieldChanged);
    _countController.addListener(_onAnyFieldChanged);
    _purityController.addListener(_onAnyFieldChanged);
    _unitAmountController.addListener(_onAnyFieldChanged);
    _moeznehController.addListener(_onAnyFieldChanged);
    _wagePercentController.addListener(_onAnyFieldChanged);
    _wagePerGramController.addListener(_onAnyFieldChanged);
    _wagePerCountController.addListener(_onAnyFieldChanged);
    _profitPercentController.addListener(_onAnyFieldChanged);
    _profitAmountController.addListener(_onAnyFieldChanged);
    _commissionPercentController.addListener(_onAnyFieldChanged);

    // اضافه کردن listener برای focus node ها - پاک کردن مقدار 0 هنگام focus و بازگرداندن 0 هنگام unfocus اگر خالی باشد
    _wagePerGramFocusNode.addListener(() {
      if (_wagePerGramFocusNode.hasFocus) {
        // هنگام focus: اگر مقدار 0 است، پاک کن
        if (_wagePerGramController.text == '0') {
          _wagePerGramController.clear();
        }
      } else {
        // هنگام unfocus: اگر خالی است، مقدار 0 را قرار بده
        if (_wagePerGramController.text.trim().isEmpty) {
          _wagePerGramController.text = '0';
        }
      }
    });
    _wagePerCountFocusNode.addListener(() {
      if (_wagePerCountFocusNode.hasFocus) {
        // هنگام focus: اگر مقدار 0 است، پاک کن
        if (_wagePerCountController.text == '0') {
          _wagePerCountController.clear();
        }
      } else {
        // هنگام unfocus: اگر خالی است، مقدار 0 را قرار بده
        if (_wagePerCountController.text.trim().isEmpty) {
          _wagePerCountController.text = '0';
        }
      }
    });
    _commissionPercentFocusNode.addListener(() {
      if (_commissionPercentFocusNode.hasFocus) {
        // هنگام focus: اگر مقدار 0 است، پاک کن
        if (_commissionPercentController.text == '0') {
          _commissionPercentController.clear();
        }
      } else {
        // هنگام unfocus: اگر خالی است، مقدار 0 را قرار بده
        if (_commissionPercentController.text.trim().isEmpty) {
          _commissionPercentController.text = '0';
        }
      }
    });

    // اضافه کردن listener برای اسکرول
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final viewportHeight = _scrollController.position.viewportDimension;

    // اگر کاربر به انتهای لیست رسیده یا نزدیک به انتهاست، مبلغ نهایی قابل مشاهده است
    final isVisible = (maxScroll - currentScroll) < viewportHeight * 0.3;

    if (_isFinalAmountVisible != isVisible) {
      setState(() {
        _isFinalAmountVisible = isVisible;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _weightController.dispose();
    _countController.dispose();
    _purityController.dispose();
    _unitAmountController.dispose();
    _moeznehController.dispose();
    _wagePercentController.dispose();
    _wagePerGramController.dispose();
    _wagePerCountController.dispose();
    _profitPercentController.dispose();
    _profitAmountController.dispose();
    _commissionPercentController.dispose();
    _extraDescriptionController.dispose();
    _weightFocusNode.dispose();
    _countFocusNode.dispose();
    _purityFocusNode.dispose();
    _moeznehFocusNode.dispose();
    _unitAmountFocusNode.dispose();
    _wagePercentFocusNode.dispose();
    _wagePerGramFocusNode.dispose();
    _wagePerCountFocusNode.dispose();
    _profitPercentFocusNode.dispose();
    _profitAmountFocusNode.dispose();
    _commissionPercentFocusNode.dispose();
    _extraDescriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    debugPrint('🛒 شروع افزودن محصول به سبد خرید...');
    debugPrint('  - نوع محصول: ${widget.product.type}');
    if (_isWeightBased) {
      debugPrint('  - مبلغ اجرت هر گرم: $_wagePerGram');
    } else if (_isCountBased) {
      debugPrint('  - مبلغ اجرت هر عدد: $_wagePerCount');
    }
    debugPrint('  - مبلغ اجرت کل: $_wageTotal');
    debugPrint('  - مبلغ سود: $_profitAmount');
    debugPrint('  - مبلغ حق‌العمل: $_commissionAmount');
    debugPrint('  - مبلغ نهایی: $_finalAmount');

    // بررسی اعتبار داده‌ها - فیلدهای ستاره‌دار
    
    // 1. وزن کل (اگر weight-based باشد)
    if (_isWeightBased) {
      final weightText = _weightController.text.trim();
      if (weightText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً وزن محصول را وارد کنید'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
      final weight = _parseController(_weightController);
      if (weight <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('وزن محصول باید بیشتر از صفر باشد'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    // 2. تعداد (اگر count-based باشد)
    if (_isCountBased) {
      final countText = _countController.text.trim();
      if (countText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً تعداد محصول را وارد کنید'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
      final count = _parseController(_countController).toInt();
      if (count <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعداد محصول باید بیشتر از صفر باشد'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    // 3. عیار کالا
    final purityText = _purityController.text.trim();
    if (purityText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً عیار کالا را وارد کنید'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final purityValue = _parseController(_purityController);
    if (purityValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('عیار کالا باید بیشتر از صفر باشد'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 4. مظنه یا مبلغ واحد (بر اساس mode)
    if (_mode == PricingInputMode.viaMoezneh) {
      final moeznehText = _moeznehController.text.trim();
      if (moeznehText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لطفاً مظنه را وارد کنید'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      final moezneh = _parseController(_moeznehController);
      if (moezneh <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('مظنه باید بیشتر از صفر باشد'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    } else {
      final unitAmountText = _unitAmountController.text.trim();
      if (unitAmountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً مبلغ واحد را وارد کنید'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
      if (_unitAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('مبلغ واحد باید بیشتر از صفر باشد'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    // 5. درصد اجرت
    final wagePercentText = _wagePercentController.text.trim();
    if (wagePercentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً درصد اجرت را وارد کنید'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final wagePercentValue = _parseController(_wagePercentController);
    if (wagePercentValue < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('درصد اجرت نمی‌تواند منفی باشد'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (wagePercentValue > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('درصد اجرت نمی‌تواند بیشتر از ۱۰۰ باشد'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 6. سود فروش (بر اساس mode)
    if (_profitMode == ProfitInputMode.viaPercent) {
      final profitPercentText = _profitPercentController.text.trim();
      if (profitPercentText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لطفاً سود فروش را وارد کنید'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      final profitPercent = _parseController(_profitPercentController);
      if (profitPercent < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('درصد سود فروش نمی‌تواند منفی باشد'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      if (profitPercent > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('درصد سود فروش نمی‌تواند بیشتر از ۱۰۰ باشد'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    } else {
      final profitAmountText = _profitAmountController.text.trim();
      if (profitAmountText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لطفاً مبلغ سود فروش را وارد کنید'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      final profitAmount = _parseController(_profitAmountController);
      if (profitAmount < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('مبلغ سود فروش نمی‌تواند منفی باشد'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    // بررسی مبلغ نهایی
    if (_finalAmount <= 0) {
      debugPrint('❌ مبلغ نهایی نامعتبر: $_finalAmount');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً اطلاعات قیمت را کامل کنید'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // محاسبه profit_percent و profit_amount
    double profitPercent = 0;
    if (_profitMode == ProfitInputMode.viaPercent) {
      profitPercent = _parseController(_profitPercentController);
    } else {
      // اگر از مبلغ استفاده شده، درصد را محاسبه می‌کنیم
      final baseBeforeProfit = _unitTotalAmount + _wageTotal;
      if (baseBeforeProfit > 0) {
        profitPercent = (_profitAmount / baseBeforeProfit) * 100;
      }
    }

    // 7. درصد حق‌العمل
    final commissionPercentText = _commissionPercentController.text.trim();
    if (commissionPercentText.isNotEmpty) {
      final commissionPercentValue = _parseController(_commissionPercentController);
      if (commissionPercentValue < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('درصد حق‌العمل نمی‌تواند منفی باشد'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      if (commissionPercentValue > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('درصد حق‌العمل نمی‌تواند بیشتر از ۱۰۰ باشد'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    // محاسبه مقادیر نهایی بعد از validation
    final finalWeight = _isWeightBased ? _parseController(_weightController) : 0.0;
    final finalCount = _isCountBased ? _parseController(_countController).toInt() : 0;
    final finalPurity = purityText;
    final finalWagePercent = wagePercentValue;
    final finalCommissionPercent = _parseController(_commissionPercentController);

    // ساخت CartItem
    final cartItem = CartItem(
      product: widget.product,
      weight: finalWeight,
      count: finalCount,
      purity: finalPurity,
      // به صورت string
      unitAmount: _unitAmount,
      totalUnitAmount: _unitTotalAmount,
      wagePercent: finalWagePercent,
      wagePerGram: _isWeightBased ? _wagePerGram : 0.0,
      wagePerCount: _isCountBased ? _wagePerCount : 0.0,
      totalWageAmount: _wageTotal,
      profitPercent: profitPercent,
      profitAmount: _profitAmount,
      commissionPercent: finalCommissionPercent,
      commissionAmount: _commissionAmount,
      taxAmount: _taxAmount,
      totalAmount: _finalAmount,
    );

    debugPrint('📦 CartItem ساخته شد:');
    debugPrint('  - محصول: ${cartItem.product.name} (ID: ${cartItem.product.id})');
    debugPrint('  - وزن: ${cartItem.weight}');
    debugPrint('  - عیار: ${cartItem.purity}');
    debugPrint('  - مبلغ نهایی: ${cartItem.totalAmount}');

    // افزودن به سبد خرید
    CartViewModel? cartViewModel = widget.cartViewModel;
    if (cartViewModel == null) {
      debugPrint('⚠️ cartViewModel از widget null است، استفاده از Provider...');
      // اگر cartViewModel پاس داده نشده، از Provider استفاده کن
      try {
        cartViewModel = Provider.of<CartViewModel>(context, listen: false);
        debugPrint('✅ CartViewModel از Provider دریافت شد');
      } catch (e) {
        debugPrint('❌ خطا در دریافت CartViewModel: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('خطا در دسترسی به سبد خرید'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
    } else {
      debugPrint('✅ CartViewModel از widget دریافت شد');
    }

    try {
      // اگر در حالت ویرایش هستیم، ابتدا آیتم قدیمی را حذف کن
      if (widget.existingCartItem != null && widget.existingCartItem!.id != null) {
        debugPrint('🔄 در حال به‌روزرسانی آیتم موجود...');
        await cartViewModel.removeItem(widget.existingCartItem!.id!);
        debugPrint('✅ آیتم قدیمی حذف شد');
      }

      debugPrint('💾 در حال افزودن به دیتابیس...');
      await cartViewModel.addItem(cartItem);
      debugPrint('✅ محصول با موفقیت به دیتابیس اضافه شد');

      // نمایش پیام موفقیت
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingCartItem != null ? 'تغییرات با موفقیت ثبت شد' : 'محصول به سبد خرید اضافه شد'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
        debugPrint('✅ Bottom sheet بسته شد');
      }
    } catch (error, stackTrace) {
      debugPrint('❌ خطا در افزودن محصول به سبد خرید:');
      debugPrint('  Error: $error');
      debugPrint('  StackTrace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در افزودن محصول: ${_cleanErrorMessage(error)}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // محتوای قابل اسکرول
              SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.dividerSoft,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.name,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'Iranyekan',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryAlt,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // وزن کل یا تعداد - بر اساس نوع محصول
                    if (_isWeightBased) ...[
                      _buildLabeledField(
                        label: 'وزن کل*',
                        suffix: 'گرم',
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        isNumeric: true,
                        focusNode: _weightFocusNode,
                        onSubmitted: () => _purityFocusNode.requestFocus(),
                      ),
                    ] else if (_isCountBased) ...[
                      _buildLabeledField(
                        label: 'تعداد*',
                        suffix: 'عدد',
                        controller: _countController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: false),
                        isNumeric: true,
                        focusNode: _countFocusNode,
                        onSubmitted: () => _purityFocusNode.requestFocus(),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // عیار کالا
                    _buildLabeledField(
                      label: 'عیار کالا*',
                      controller: _purityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      isNumeric: true,
                      focusNode: _purityFocusNode,
                      onSubmitted: () {
                        if (_mode == PricingInputMode.viaMoezneh) {
                          _moeznehFocusNode.requestFocus();
                        } else {
                          _unitAmountFocusNode.requestFocus();
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // تب‌ها: محاسبه از طریق مظنه / واردکردن مبلغ واحد
                    Card(
                      color: AppColors.backgroundAlt,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildModeTabs(),
                            const SizedBox(height: 16),

                            if (_mode == PricingInputMode.viaMoezneh) ...[
                              _buildLabeledField(
                                label: 'مظنه*',
                                suffix: 'ریال',
                                controller: _moeznehController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                isNumeric: true,
                                focusNode: _moeznehFocusNode,
                                onSubmitted: () => _wagePercentFocusNode.requestFocus(),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'مبلغ واحد = مظنه ÷ 4.332',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: 'Iranyekan',
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ] else ...[
                              _buildLabeledField(
                                label: 'مبلغ واحد*',
                                suffix: 'ریال',
                                controller: _unitAmountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                isNumeric: true,
                                focusNode: _unitAmountFocusNode,
                                onSubmitted: () => _wagePercentFocusNode.requestFocus(),
                              ),
                            ],
                            const SizedBox(height: 16),

                            // مبلغ واحد کل
                            _buildResultRow(
                              label: 'مبلغ واحد کل',
                              value: _format(_unitTotalAmount),
                              suffix: 'ریال',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Card(
                      color: AppColors.backgroundAlt,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildLabeledField(
                              label: 'درصد اجرت*',
                              suffix: '%',
                              controller: _wagePercentController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              isNumeric: true,
                              focusNode: _wagePercentFocusNode,
                              onSubmitted: () {
                                if (_isWeightBased) {
                                  _wagePerGramFocusNode.requestFocus();
                                } else if (_isCountBased) {
                                  _wagePerCountFocusNode.requestFocus();
                                } else {
                                  // اگر هیچکدام نبود، به سود فروش برو
                                  if (_profitMode == ProfitInputMode.viaPercent) {
                                    _profitPercentFocusNode.requestFocus();
                                  } else {
                                    _profitAmountFocusNode.requestFocus();
                                  }
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            const Center(
                              child: Icon(
                                Icons.add,
                                size: 30,
                                color: AppColors.iconBrown,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // مبلغ اجرت - بر اساس نوع محصول
                            if (_isWeightBased) ...[
                              _buildLabeledField(
                                label: 'مبلغ اجرت هر گرم',
                                suffix: 'ریال',
                                controller: _wagePerGramController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                isNumeric: true,
                                focusNode: _wagePerGramFocusNode,
                                onSubmitted: () {
                                  if (_profitMode == ProfitInputMode.viaPercent) {
                                    _profitPercentFocusNode.requestFocus();
                                  } else {
                                    _profitAmountFocusNode.requestFocus();
                                  }
                                },
                              ),
                            ] else if (_isCountBased) ...[
                              _buildLabeledField(
                                label: 'مبلغ اجرت هر عدد',
                                suffix: 'ریال',
                                controller: _wagePerCountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                isNumeric: true,
                                focusNode: _wagePerCountFocusNode,
                                onSubmitted: () {
                                  if (_profitMode == ProfitInputMode.viaPercent) {
                                    _profitPercentFocusNode.requestFocus();
                                  } else {
                                    _profitAmountFocusNode.requestFocus();
                                  }
                                },
                              ),
                            ],
                            const SizedBox(height: 12),

                            // مبلغ اجرت کل
                            _buildResultRow(
                              label: 'مبلغ اجرت کل',
                              value: _format(_wageTotal),
                              suffix: 'ریال',
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Card(
                      color: AppColors.backgroundAlt,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // تب‌های سود فروش: درصد / مبلغ
                            _buildProfitModeTabs(),
                            const SizedBox(height: 16),

                            if (_profitMode == ProfitInputMode.viaPercent) ...[
                              _buildLabeledField(
                                label: 'درصد سود فروش*',
                                suffix: '%',
                                controller: _profitPercentController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                isNumeric: true,
                                focusNode: _profitPercentFocusNode,
                                onSubmitted: () => _commissionPercentFocusNode.requestFocus(),
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                label: 'سود فروش',
                                value: _format(_profitAmount),
                                suffix: 'ریال',
                              ),
                            ] else ...[
                              _buildLabeledField(
                                label: 'مبلغ سود فروش*',
                                suffix: 'ریال',
                                controller: _profitAmountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                isNumeric: true,
                                focusNode: _profitAmountFocusNode,
                                onSubmitted: () => _commissionPercentFocusNode.requestFocus(),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'معادل ${_formatWithOneDecimal(_profitPercentFromAmount)}% سود فروش',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontFamily: 'Iranyekan',
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 8),

                    // مالیات (محاسبه خودکار بر اساس tax_percent محصول)
                    // همیشه مالیات را نمایش می‌دهیم (حتی اگر taxPercent 0 باشد)
                    ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardSoft,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'درصد مالیات',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontFamily: 'Iranyekan',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${_format(widget.product.taxPercent)}%',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontFamily: 'Iranyekan',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimaryAlt,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildResultRow(
                              label: 'مبلغ مالیات',
                              value: _format(_taxAmount),
                              suffix: 'ریال',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'مالیات بر (اجرت کل + سود فروش + حق‌العمل)',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'Iranyekan',
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                    ],

                    // درصد حق‌العمل
                    _buildLabeledField(
                      label: 'درصد حق‌العمل',
                      suffix: '%',
                      controller: _commissionPercentController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      isNumeric: true,
                      focusNode: _commissionPercentFocusNode,
                      onSubmitted: () => _extraDescriptionFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'مبلغ حق‌العمل: ${_format(_commissionAmount)} ریال',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Iranyekan',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // شرح اضافی محصول
                    _buildLabeledField(
                      label: 'شرح اضافی محصول',
                      controller: _extraDescriptionController,
                      maxLines: 2,
                      focusNode: _extraDescriptionFocusNode,
                      onSubmitted: () {
                        // در آخرین فیلد، کیبورد را ببند
                        _extraDescriptionFocusNode.unfocus();
                      },
                    ),
                    const SizedBox(height: 24),

                    // مبلغ نهایی محصول - با استایل بولد و متفاوت
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.gold,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'مبلغ نهایی محصول',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'Iranyekan',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryAlt,
                            ),
                          ),
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    _format(_finalAmount),
                                    textAlign: TextAlign.left,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Iranyekan',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'ریال',
                                  style: TextStyle(
                                    fontFamily: 'Iranyekan',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _finalAmount > 0 ? _onSubmit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            widget.existingCartItem != null
                                ? const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : Image.asset(
                              'assets/images/add_shopping_cart.png',
                              color: _finalAmount > 0 ? Colors.white : Colors.grey,
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.existingCartItem != null ? 'ثبت تغییرات' : 'افزودن به سبد خرید',
                              style: const TextStyle(
                                fontFamily: 'Iranyekan',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16), // فاصله پایین برای SafeArea
                  ],
                ),
              ),

              // بخش sticky پایین - فقط وقتی مبلغ نهایی قابل مشاهده نیست
              if (!_isFinalAmountVisible)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'مبلغ نهایی محصول',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'Iranyekan',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryAlt,
                            ),
                          ),
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    _format(_finalAmount),
                                    textAlign: TextAlign.left,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Iranyekan',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'ریال',
                                  style: TextStyle(
                                    fontFamily: 'Iranyekan',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildModeTab(
              title: 'مبلغ واحد',
              isSelected: _mode == PricingInputMode.viaUnitAmount,
              onTap: () {
                setState(() {
                  _mode = PricingInputMode.viaUnitAmount;
                });
                _onAnyFieldChanged();
              },
            ),
          ),
          Expanded(
            child: _buildModeTab(
              title: 'مظنه',
              isSelected: _mode == PricingInputMode.viaMoezneh,
              onTap: () {
                setState(() {
                  _mode = PricingInputMode.viaMoezneh;
                });
                _onAnyFieldChanged();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        constraints: const BoxConstraints(minHeight: 44),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.softGoldChip : null,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.textPrimaryAlt : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    String? suffix,
    TextEditingController? controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isNumeric = false,
    FocusNode? focusNode,
    VoidCallback? onSubmitted,
  }) {
    // تشخیص اینکه آیا فیلد اعشاری است یا نه
    final allowDecimal = keyboardType != null &&
        keyboardType == const TextInputType.numberWithOptions(decimal: true);
    
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textAlign: isNumeric ? TextAlign.left : TextAlign.right,
      textInputAction: onSubmitted != null ? TextInputAction.next : (maxLines > 1 ? TextInputAction.newline : TextInputAction.done),
      onSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        suffix: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  suffix,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      style: const TextStyle(
        fontFamily: 'Iranyekan',
        fontSize: 14,
        color: AppColors.textPrimaryAlt,
      ),
      inputFormatters: isNumeric ? <TextInputFormatter>[ThousandsSeparatorFormatter(allowDecimal: allowDecimal)] : null,
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontFamily: 'Iranyekan',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.dividerSoft,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Iranyekan',
                    fontSize: 14,
                    color: AppColors.textPrimaryAlt,
                  ),
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 12),
                Text(
                  suffix,
                  style: const TextStyle(
                    fontFamily: 'Iranyekan',
                    fontSize: 14,
                    color: AppColors.iconBrown,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfitModeTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildModeTab(
              title: 'درصد سود فروش',
              isSelected: _profitMode == ProfitInputMode.viaPercent,
              onTap: () {
                setState(() {
                  _profitMode = ProfitInputMode.viaPercent;
                  // در حالت درصدی، ورودی مبلغ سود را خالی می‌کنیم تا فقط از درصد استفاده شود
                  _profitAmountController.clear();
                });
                _onAnyFieldChanged();
              },
            ),
          ),
          Expanded(
            child: _buildModeTab(
              title: 'مبلغ سود فروش',
              isSelected: _profitMode == ProfitInputMode.viaAmount,
              onTap: () {
                setState(() {
                  final oldMode = _profitMode;
                  _profitMode = ProfitInputMode.viaAmount;

                  // اگر از حالت درصدی به مبلغی تغییر کردیم و فیلد مبلغ خالی است،
                  // مقدار محاسبه شده از درصد را در فیلد بگذار
                  if (oldMode == ProfitInputMode.viaPercent && _profitAmountController.text.trim().isEmpty && _profitAmount > 0) {
                    _profitAmountController.text = _format(_profitAmount);
                  }

                  // در حالت مبلغ، درصد سود فروش را خالی می‌کنیم تا فقط از مبلغ استفاده شود
                  _profitPercentController.clear();
                });
                _onAnyFieldChanged();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow({
    required String label,
    required String value,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
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
                if (suffix != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    suffix,
                    style: const TextStyle(
                      fontFamily: 'Iranyekan',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class ThousandsSeparatorFormatter extends TextInputFormatter {
  final bool allowDecimal;

  ThousandsSeparatorFormatter({this.allowDecimal = false});

  // تبدیل اعداد فارسی به انگلیسی
  String _persianToEnglish(String text) {
    return text.replaceAll('۰', '0').replaceAll('۱', '1').replaceAll('۲', '2').replaceAll('۳', '3').replaceAll('۴', '4').replaceAll('۵', '5').replaceAll('۶', '6').replaceAll('۷', '7').replaceAll('۸', '8').replaceAll('۹', '9');
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // تبدیل اعداد فارسی به انگلیسی
    final englishText = _persianToEnglish(newValue.text);
    
    // اگر خالی است، اجازه بده
    if (englishText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // حذف کاماها
    var raw = englishText.replaceAll(',', '');

    // فیلتر کردن کاراکترهای غیر عددی (به جز نقطه برای اعشار)
    if (allowDecimal) {
      // برای اعشار: فقط اعداد و یک نقطه
      if (!RegExp(r'^[0-9]*\.?[0-9]*$').hasMatch(raw)) {
        return oldValue;
      }
      // فقط یک نقطه مجاز است
      final dotCount = raw.split('.').length - 1;
      if (dotCount > 1) {
        return oldValue;
      }
    } else {
      // بدون اعشار: فقط اعداد
      if (!RegExp(r'^[0-9]+$').hasMatch(raw)) {
        return oldValue;
      }
    }

    // اگر اعشار مجاز است
    if (allowDecimal) {
      // تقسیم به قسمت صحیح و اعشاری
    final parts = raw.split('.');
    final intPart = parts[0];
      final decimalPart = parts.length > 1 ? parts[1] : '';

      // اگر فقط نقطه است، قبول نکن
      if (raw == '.' || (intPart.isEmpty && decimalPart.isEmpty)) {
        return oldValue;
    }

      // بررسی شروع با 0 - نباید با 0 شروع شود (مگر فقط "0" یا "0.")
      if (intPart.isNotEmpty && intPart.length > 1 && intPart.startsWith('0')) {
      return oldValue;
    }

      // فرمت کردن قسمت صحیح
      String result = '';
      if (intPart.isNotEmpty) {
        final intNumber = int.tryParse(intPart);
        if (intNumber == null) {
          return oldValue;
        }
        if (intNumber == 0 && parts.length == 1 && decimalPart.isEmpty) {
          // اگر فقط 0 است و اعشاری ندارد
          result = '0';
        } else {
          result = NumberFormat.decimalPattern().format(intNumber);
        }
      } else {
        // اگر قسمت صحیح خالی است اما اعشار داریم (نباید به اینجا برسد به خاطر بررسی بالا)
        result = '0';
      }

      // اضافه کردن اعشار
    if (parts.length > 1) {
        result += '.$decimalPart';
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
    } else {
      // بدون اعشار - فقط اعداد صحیح
      // بررسی شروع با 0 - نباید با 0 شروع شود (مگر فقط "0")
      if (raw.length > 1 && raw.startsWith('0')) {
        return oldValue;
      }

      final number = int.tryParse(raw);
      if (number == null) {
        return oldValue;
      }

      final formattedInt = NumberFormat.decimalPattern().format(number);
      return TextEditingValue(
        text: formattedInt,
        selection: TextSelection.collapsed(offset: formattedInt.length),
      );
    }
  }
}
