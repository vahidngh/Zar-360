import 'package:flutter/material.dart';

class ButtonsPage extends StatefulWidget {
  const ButtonsPage({super.key});

  @override
  State<ButtonsPage> createState() => _ButtonsPageState();
}

class _ButtonsPageState extends State<ButtonsPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دکمه‌ها'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary Buttons
            _buildSectionTitle('دکمه‌های اصلی'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('دکمه اصلی'),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('دکمه با آیکون'),
                ),
                FilledButton(
                  onPressed: () {},
                  child: const Text('دکمه پر شده'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('دکمه حاشیه‌دار'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('دکمه متنی'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Button Sizes
            _buildSectionTitle('اندازه‌های مختلف'),
            const SizedBox(height: 16),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('دکمه بزرگ (عرض کامل)'),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('متوسط'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('متوسط'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 40),
                  ),
                  child: const Text('کوچک'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Button States
            _buildSectionTitle('حالت‌های مختلف'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('فعال'),
                ),
                ElevatedButton(
                  onPressed: null,
                  child: const Text('غیرفعال'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = !_isLoading;
                    });
                  },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('در حال بارگذاری'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Floating Action Buttons
            _buildSectionTitle('دکمه‌های شناور'),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: () {},
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton.extended(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('افزودن'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Icon Buttons
            _buildSectionTitle('دکمه‌های آیکون'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                  ),
                ),
                IconButton.filled(
                  onPressed: () {},
                  icon: const Icon(Icons.star),
                ),
                IconButton.outlined(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Modern Action Buttons
            _buildSectionTitle('دکمه‌های عملیات'),
            const SizedBox(height: 16),
            Column(
              children: [
                // Primary Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {},
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'افزودن به سبد خرید',
                              style: TextStyle(
                                fontFamily: 'Iranyekan',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Secondary Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {},
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flash_on, color: Color(0xFF111827), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'خرید فوری',
                              style: TextStyle(
                                fontFamily: 'Iranyekan',
                                color: Color(0xFF111827),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Tertiary Button
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {},
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_border, color: Color(0xFF6B7280), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'افزودن به علاقه‌مندی‌ها',
                              style: TextStyle(
                                fontFamily: 'Iranyekan',
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
