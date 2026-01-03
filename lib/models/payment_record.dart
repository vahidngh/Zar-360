class PaymentRecord {
  final String type; // 'cash', 'gold', 'card'
  final double amount;
  final Map<String, dynamic> details;

  PaymentRecord({
    required this.type,
    required this.amount,
    this.details = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount.round(),
      'details': details,
    };
  }

  String get typeLabel {
    switch (type) {
      case 'cash':
        return 'پرداخت نقدی';
      case 'gold':
        return 'پرداخت با طلا';
      case 'card':
        return 'پرداخت با کارت';
      default:
        return type;
    }
  }
}

