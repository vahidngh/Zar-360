import 'package:flutter/material.dart';

class ButtonsVariationsPage extends StatefulWidget {
  const ButtonsVariationsPage({super.key});

  @override
  State<ButtonsVariationsPage> createState() => _ButtonsVariationsPageState();
}

class _ButtonsVariationsPageState extends State<ButtonsVariationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('انواع دکمه‌ها'),
        backgroundColor: const Color(0xFF111827),
        foregroundColor: const Color(0xFFD4AF37),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Classic Buttons
            _buildSectionTitle('دکمه‌های کلاسیک'),
            const SizedBox(height: 16),
            _buildClassicButtons(),

            const SizedBox(height: 32),

            // Modern Buttons
            _buildSectionTitle('دکمه‌های مدرن'),
            const SizedBox(height: 16),
            _buildModernButtons(),

            const SizedBox(height: 32),

            // Luxury Buttons
            _buildSectionTitle('دکمه‌های لوکس'),
            const SizedBox(height: 16),
            _buildLuxuryButtons(),

            const SizedBox(height: 32),

            // Stroke Buttons
            _buildSectionTitle('دکمه‌های با حاشیه'),
            const SizedBox(height: 16),
            _buildStrokeButtons(),

            const SizedBox(height: 32),

            // Gradient Buttons
            _buildSectionTitle('دکمه‌های گرادیانتی'),
            const SizedBox(height: 16),
            _buildGradientButtons(),

            const SizedBox(height: 32),

            // Icon Buttons
            _buildSectionTitle('دکمه‌های آیکونی'),
            const SizedBox(height: 16),
            _buildIconButtons(),

            const SizedBox(height: 32),

            // Primary Secondary Buttons
            _buildSectionTitle('دکمه‌های اصلی و فرعی'),
            const SizedBox(height: 16),
            _buildPrimarySecondaryButtons(),

            const SizedBox(height: 32),

            // Form Buttons
            _buildSectionTitle('دکمه‌های فرم'),
            const SizedBox(height: 16),
            _buildFormButtons(),

            const SizedBox(height: 32),

            // Action Buttons
            _buildSectionTitle('دکمه‌های عملیاتی'),
            const SizedBox(height: 16),
            _buildActionButtons(),

            const SizedBox(height: 32),

            // Size Buttons
            _buildSectionTitle('دکمه‌های اندازه‌های مختلف'),
            const SizedBox(height: 16),
            _buildSizeButtons(),

            const SizedBox(height: 32),

            // State Buttons
            _buildSectionTitle('دکمه‌های حالت‌های مختلف'),
            const SizedBox(height: 16),
            _buildStateButtons(),

            const SizedBox(height: 32),

            // Special Purpose Buttons
            _buildSectionTitle('دکمه‌های کاربرد خاص'),
            const SizedBox(height: 16),
            _buildSpecialPurposeButtons(),

            const SizedBox(height: 32),

            // Divider Line
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFFD4AF37),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Rounded Buttons
            _buildSectionTitle('دکمه‌های کاملاً گرد'),
            const SizedBox(height: 16),
            _buildRoundedButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Iranyekan',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    );
  }

  // Classic Buttons
  Widget _buildClassicButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildClassicButton('کلاسیک ساده'),
        _buildClassicButton('کلاسیک با حاشیه'),
        _buildClassicButton('کلاسیک گرد'),
        _buildClassicButton('کلاسیک مربع'),
        _buildClassicButton('کلاسیک مستطیل'),
      ],
    );
  }

  Widget _buildClassicButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Iranyekan',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // Modern Buttons
  Widget _buildModernButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildModernButton('مدرن نرم'),
        _buildModernButton('مدرن تیز'),
        _buildModernButton('مدرن شفاف'),
        _buildModernButton('مدرن مات'),
        _buildModernButton('مدرن براق'),
      ],
    );
  }

  Widget _buildModernButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Iranyekan',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // Luxury Buttons
  Widget _buildLuxuryButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildLuxuryButton('لوکس طلایی'),
        _buildLuxuryButton('لوکس نقره‌ای'),
        _buildLuxuryButton('لوکس برنزی'),
        _buildLuxuryButton('لوکس مسی'),
        _buildLuxuryButton('لوکس پلاتینی'),
      ],
    );
  }

  Widget _buildLuxuryButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Iranyekan',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // Stroke Buttons
  Widget _buildStrokeButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildStrokeButton('حاشیه نازک', Icons.border_outer),
        _buildStrokeButton('حاشیه ضخیم', Icons.border_all),
        _buildStrokeButton('حاشیه نقطه‌ای', Icons.more_horiz),
        _buildStrokeButton('حاشیه خطی', Icons.horizontal_rule),
        _buildStrokeButton('حاشیه دوگانه', Icons.double_arrow),
      ],
    );
  }

  Widget _buildStrokeButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
            ),
          ),
        ],
      ),
    );
  }

  // Gradient Buttons
  Widget _buildGradientButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildGradientButton('عمودی', Icons.vertical_align_center),
        _buildGradientButton('افقی', Icons.horizontal_rule),
        _buildGradientButton('مورب', Icons.trending_up),
        _buildGradientButton('دایره‌ای', Icons.radio_button_unchecked),
        _buildGradientButton('چندگانه', Icons.gradient),
      ],
    );
  }

  Widget _buildGradientButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Icon Focus Buttons
  Widget _buildIconButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildIconFocusButton('فقط آیکون', Icons.diamond),
        _buildIconFocusButton('آیکون بزرگ', Icons.star),
        _buildIconFocusButton('آیکون دایره‌ای', Icons.circle),
        _buildIconFocusButton('آیکون مربع', Icons.crop_square),
        _buildIconFocusButton('آیکون شش‌ضلعی', Icons.hexagon),
      ],
    );
  }

  Widget _buildIconFocusButton(String text, IconData icon) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Primary Secondary Buttons
  Widget _buildPrimarySecondaryButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildPrimaryButton('اصلی', Icons.star),
        _buildSecondaryButton('فرعی', Icons.star_border),
        _buildTertiaryButton('سوم', Icons.star_half),
        _buildQuaternaryButton('چهارم', Icons.star_outline),
        _buildQuinaryButton('پنجم', Icons.star_purple500),
      ],
    );
  }

  Widget _buildPrimaryButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTertiaryButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF6B7280), size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuaternaryButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF6B7280),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuinaryButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Form Buttons
  Widget _buildFormButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildFormButton('ارسال', Icons.send),
        _buildFormButton('ذخیره', Icons.save),
        _buildFormButton('لغو', Icons.cancel),
        _buildFormButton('بازنشانی', Icons.refresh),
        _buildFormButton('پاک کردن', Icons.clear),
      ],
    );
  }

  Widget _buildFormButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Action Buttons
  Widget _buildActionButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildActionButton('افزودن', Icons.add_circle),
        _buildActionButton('حذف', Icons.delete_forever),
        _buildActionButton('ویرایش', Icons.edit_note),
        _buildActionButton('مشاهده', Icons.visibility_off),
        _buildActionButton('اشتراک', Icons.share_arrival_time),
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Size Buttons
  Widget _buildSizeButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildSizeButton('خیلی کوچک', 8, 4, Icons.minimize),
        _buildSizeButton('کوچک', 12, 6, Icons.remove),
        _buildSizeButton('متوسط', 16, 8, Icons.add),
        _buildSizeButton('بزرگ', 20, 10, Icons.add_circle),
        _buildSizeButton('خیلی بزرگ', 24, 12, Icons.add_circle_outline),
      ],
    );
  }

  Widget _buildSizeButton(String text, double horizontal, double vertical, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // State Buttons
  Widget _buildStateButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildStateButton('عادی', const Color(0xFFD4AF37), Icons.check_circle),
        _buildStateButton('غیرفعال', const Color(0xFF9CA3AF), Icons.cancel),
        _buildStateButton('هشدار', const Color(0xFFF59E0B), Icons.warning),
        _buildStateButton('خطا', const Color(0xFFEF4444), Icons.error),
        _buildStateButton('موفقیت', const Color(0xFF10B981), Icons.check),
      ],
    );
  }

  Widget _buildStateButton(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Special Purpose Buttons
  Widget _buildSpecialPurposeButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildSpecialPurposeButton('خرید', Icons.shopping_bag),
        _buildSpecialPurposeButton('فروش', Icons.sell),
        _buildSpecialPurposeButton('مشاوره', Icons.support_agent),
        _buildSpecialPurposeButton('تماس', Icons.phone),
        _buildSpecialPurposeButton('موقعیت', Icons.location_on),
      ],
    );
  }

  Widget _buildSpecialPurposeButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Rounded Buttons
  Widget _buildRoundedButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildRoundedClassicButton('کلاسیک گرد', Icons.circle),
        _buildRoundedModernButton('مدرن گرد', Icons.auto_awesome),
        _buildRoundedLuxuryButton('لوکس گرد', Icons.diamond),
        _buildRoundedStrokeButton('حاشیه گرد', Icons.border_outer),
        _buildRoundedGradientButton('گرادیانت گرد', Icons.gradient),
        _buildRoundedIconButton('آیکون گرد', Icons.star),
        _buildRoundedPrimaryButton('اصلی گرد', Icons.star),
        _buildRoundedSecondaryButton('فرعی گرد', Icons.star_border),
        _buildRoundedFormButton('فرم گرد', Icons.send),
        _buildRoundedActionButton('عملیاتی گرد', Icons.add_circle),
        _buildRoundedSizeButton('اندازه گرد', Icons.add),
        _buildRoundedStateButton('حالت گرد', Icons.check_circle),
        _buildRoundedSpecialButton('خاص گرد', Icons.shopping_bag),
      ],
    );
  }

  Widget _buildRoundedClassicButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedModernButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedLuxuryButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedStrokeButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedGradientButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedIconButton(String text, IconData icon) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedPrimaryButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedSecondaryButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedFormButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedActionButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedSizeButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedStateButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedSpecialButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Iranyekan',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

}
