class PersianDateUtils {
  /// تبدیل تاریخ میلادی به شمسی با فرمت 1404/08/10
  static String getCurrentPersianDate() {
    final now = DateTime.now();
    return gregorianToPersian(now.year, now.month, now.day);
  }

  /// تبدیل تاریخ میلادی به شمسی
  static String gregorianToPersian(int year, int month, int day) {
    // الگوریتم تبدیل میلادی به شمسی
    int gy = year;
    int gm = month;
    int gd = day;

    final List<int> g_d_m = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    int jy = (gy <= 1600) ? 0 : 979;
    gy -= (gy <= 1600) ? 621 : 1600;
    int gy2 = (gm > 2) ? (gy + 1) : gy;
    int days = (365 * gy) +
        ((gy2 + 3) ~/ 4) -
        ((gy2 + 99) ~/ 100) +
        ((gy2 + 399) ~/ 400) -
        80 +
        gd +
        g_d_m[gm - 1];
    jy += 33 * (days ~/ 12053);
    days %= 12053;
    jy += 4 * (days ~/ 1461);
    days %= 1461;
    jy += ((days - 1) ~/ 365);

    if (days > 365) days = (days - 1) % 365;
    int jm = (days < 186) ? 1 + (days ~/ 31) : 7 + ((days - 186) ~/ 30);
    int jd = 1 + ((days < 186) ? (days % 31) : ((days - 186) % 30));

    return '$jy/${jm.toString().padLeft(2, '0')}/${jd.toString().padLeft(2, '0')}';
  }
}

