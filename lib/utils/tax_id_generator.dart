/// Generates Iranian e-invoice TaxID (taxid) as:
/// [memoryId:6][dateCode:5][serial:10][checkDigit:1]
///
/// IMPORTANT:
/// - dateCode algorithm depends on official "epoch" (base date) used by the Tax Org.
/// - checkDigit algorithm is also official; without it, you can't generate a valid final taxid.
///
/// You can either:
/// 1) pass checkDigit directly, OR
/// 2) provide a checkDigitFn that computes it from the first 21 chars.
class TaxIdGenerator {
  /// Build full 22-char taxid.
  static String buildTaxId({
    required String memoryId6, // e.g. "A12894"
    required String jalaliDateTime, // e.g. "1404/09/23 21:03"
    required int invoiceNo, // e.g. 242
    String? checkDigit1, // e.g. "4"
    String Function(String first21)? checkDigitFn,
    // Epoch (base date) MUST match official spec. Placeholder default is not guaranteed.
    DateTime? officialEpochUtc,
  }) {
    final epoch = officialEpochUtc ?? DateTime.utc(1970, 1, 1);
    final mem = _mustBeLen(memoryId6.toUpperCase(), 6, field: 'memoryId6');

    final dt = _parseJalaliDateTime(jalaliDateTime);
    final dateCode5 = _encodeDateTo5Chars(dt, epoch);

    final serial10 = _encodeSerialTo10Chars(invoiceNo);

    final first21 = '$mem$dateCode5$serial10';
    if (first21.length != 21) {
      throw StateError('Internal error: first21 length is ${first21.length}, expected 21');
    }

    final cd = (checkDigit1 != null)
        ? _mustBeLen(checkDigit1.toUpperCase(), 1, field: 'checkDigit1')
        : (checkDigitFn != null)
            ? _mustBeLen(checkDigitFn(first21).toUpperCase(), 1, field: 'checkDigitFn output')
            : null;

    if (cd == null) {
      // You can return the 21-char base if you prefer; but taxid is invalid without check digit.
      throw ArgumentError(
        'You must provide either checkDigit1 or checkDigitFn. '
        'Without official check digit algorithm, final taxid cannot be valid.',
      );
    }

    return '$first21$cd';
  }

  /// Build only the first 21 chars (useful when you don't know check digit yet).
  static String buildTaxIdBase21({
    required String memoryId6,
    required String jalaliDateTime,
    required int invoiceNo,
    DateTime? officialEpochUtc,
  }) {
    final epoch = officialEpochUtc ?? DateTime.utc(1970, 1, 1);
    final mem = _mustBeLen(memoryId6.toUpperCase(), 6, field: 'memoryId6');
    final dt = _parseJalaliDateTime(jalaliDateTime);
    final dateCode5 = _encodeDateTo5Chars(dt, epoch);
    final serial10 = _encodeSerialTo10Chars(invoiceNo);
    return '$mem$dateCode5$serial10';
  }

  /// Build full 22-char taxid with computed check digit.
  static String buildTaxIdWithCheckDigit({
    required String memoryId6,
    required String jalaliDateTime,
    required int invoiceNo,
    DateTime? officialEpochUtc,
  }) {
    final first21 = buildTaxIdBase21(
      memoryId6: memoryId6,
      jalaliDateTime: jalaliDateTime,
      invoiceNo: invoiceNo,
      officialEpochUtc: officialEpochUtc,
    );
    final checkDigit = _computeCheckDigit(first21);
    return '$first21$checkDigit';
  }

  /// محاسبه رقم کنترلی با استفاده از الگوریتم Luhn برای Base36
  static String _computeCheckDigit(String first21) {
    if (first21.length != 21) {
      throw ArgumentError('first21 must be exactly 21 characters, got ${first21.length}');
    }

    // تبدیل هر کاراکتر به مقدار عددی در Base36
    final values = first21.split('').map((char) {
      final index = _digits.indexOf(char.toUpperCase());
      if (index == -1) {
        throw ArgumentError('Invalid character in first21: $char');
      }
      return index;
    }).toList();

    // الگوریتم Luhn برای Base36: از راست به چپ، وزن‌های 2 و 1 به صورت متناوب
    int sum = 0;
    bool doubleIt = true; // از راست به چپ شروع می‌کنیم
    
    for (int i = values.length - 1; i >= 0; i--) {
      int value = values[i];
      
      if (doubleIt) {
        value *= 2;
        // اگر نتیجه >= 36، رقم‌ها را جمع کن (مثل Luhn)
        if (value >= 36) {
          value = (value ~/ 36) + (value % 36);
        }
      }
      
      sum += value;
      doubleIt = !doubleIt;
    }

    // محاسبه check digit: (36 - (sum % 36)) % 36
    final remainder = sum % 36;
    final checkDigitValue = (36 - remainder) % 36;
    
    return _digits[checkDigitValue];
  }

  // -------------------------
  // Date: Jalali -> Gregorian -> "days since epoch" -> Base36 -> pad 5
  // -------------------------

  static String _encodeDateTo5Chars(_JalaliDateTime jdt, DateTime epochUtc) {
    final gregorian = _jalaliToGregorian(jdt.year, jdt.month, jdt.day);

    // Use UTC midnight for a stable day index.
    final issuedUtc = DateTime.utc(gregorian.year, gregorian.month, gregorian.day);

    final epoch = DateTime.utc(epochUtc.year, epochUtc.month, epochUtc.day);
    final days = issuedUtc.difference(epoch).inDays;

    if (days < 0) {
      throw ArgumentError('Computed day index is negative. Epoch is probably wrong.');
    }

    final base36 = _toBase36(days).toUpperCase();
    return base36.padLeft(5, '0');
  }

  // -------------------------
  // Serial: invoiceNo -> Base36 -> pad 10
  // -------------------------

  static String _encodeSerialTo10Chars(int invoiceNo) {
    if (invoiceNo < 0) throw ArgumentError('invoiceNo must be >= 0');
    final s = _toBase36(invoiceNo).toUpperCase();
    if (s.length > 10) {
      throw ArgumentError('invoiceNo too large: base36 length ${s.length} exceeds 10');
    }
    return s.padLeft(10, '0');
  }

  // -------------------------
  // Parsers / Helpers
  // -------------------------

  static _JalaliDateTime _parseJalaliDateTime(String input) {
    // Expected: "YYYY/MM/DD HH:MM" or "YYYY/MM/DD"
    final trimmed = input.trim();
    
    // اگر فقط تاریخ دارد (بدون ساعت)، ساعت 00:00 را اضافه کن
    String dateTimeStr;
    if (trimmed.contains(' ')) {
      dateTimeStr = trimmed;
    } else {
      dateTimeStr = '$trimmed 00:00';
    }
    
    final parts = dateTimeStr.split(RegExp(r'\s+'));
    if (parts.length != 2) throw FormatException('Invalid jalaliDateTime: $input');

    final d = parts[0].split('/');
    final t = parts[1].split(':');
    if (d.length != 3 || t.length != 2) throw FormatException('Invalid jalaliDateTime: $input');

    final y = int.parse(d[0]);
    final m = int.parse(d[1]);
    final day = int.parse(d[2]);
    final hh = int.parse(t[0]);
    final mm = int.parse(t[1]);

    // Basic range checks (tighten if you want)
    if (m < 1 || m > 12) throw FormatException('Invalid Jalali month: $m');
    if (day < 1 || day > 31) throw FormatException('Invalid Jalali day: $day');
    if (hh < 0 || hh > 23) throw FormatException('Invalid hour: $hh');
    if (mm < 0 || mm > 59) throw FormatException('Invalid minute: $mm');

    return _JalaliDateTime(y, m, day, hh, mm);
  }

  static String _mustBeLen(String s, int len, {required String field}) {
    if (s.length != len) {
      throw ArgumentError('$field must be exactly $len characters, got ${s.length}');
    }
    return s;
  }

  static const String _digits = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  static String _toBase36(int value) {
    if (value == 0) return '0';
    var v = value;
    final buf = StringBuffer();
    while (v > 0) {
      final r = v % 36;
      buf.write(_digits[r]);
      v ~/= 36;
    }
    return buf.toString().split('').reversed.join();
  }

  /// Jalali (Persian) -> Gregorian conversion (well-known algorithm).
  static DateTime _jalaliToGregorian(int jy, int jm, int jd) {
    int gy;
    int gm;
    int gd;

    final jy2 = jy - 979;
    final jm2 = jm - 1;
    final jd2 = jd - 1;

    int jDayNo = 365 * jy2 + (jy2 ~/ 33) * 8 + ((jy2 % 33 + 3) ~/ 4);
    const jMonthDays = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29];
    for (var i = 0; i < jm2; ++i) {
      jDayNo += jMonthDays[i];
    }
    jDayNo += jd2;

    int gDayNo = jDayNo + 79;

    gy = 1600 + 400 * (gDayNo ~/ 146097);
    gDayNo %= 146097;

    bool leap = true;
    if (gDayNo >= 36525) {
      gDayNo--;
      gy += 100 * (gDayNo ~/ 36524);
      gDayNo %= 36524;

      if (gDayNo >= 365) gDayNo++;
      else leap = false;
    }

    gy += 4 * (gDayNo ~/ 1461);
    gDayNo %= 1461;

    if (gDayNo >= 366) {
      leap = false;
      gDayNo--;
      gy += gDayNo ~/ 365;
      gDayNo %= 365;
    }

    const gMonthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    for (gm = 0; gm < 12; gm++) {
      final daysInMonth = gMonthDays[gm] + ((gm == 1 && leap) ? 1 : 0);
      if (gDayNo < daysInMonth) break;
      gDayNo -= daysInMonth;
    }
    gd = gDayNo + 1;
    return DateTime(gy, gm + 1, gd);
  }
}

class _JalaliDateTime {
  final int year, month, day, hour, minute;
  _JalaliDateTime(this.year, this.month, this.day, this.hour, this.minute);
}
