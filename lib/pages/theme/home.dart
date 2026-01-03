import 'package:flutter/material.dart';
import 'package:zar360/pages/theme/buttons_page.dart';
import 'package:zar360/pages/theme/inputs_page.dart';
import 'package:zar360/pages/theme/navigation_page.dart';
import 'package:zar360/pages/theme/cards_page.dart';
import 'package:zar360/pages/theme/lists_page.dart';
import 'package:zar360/pages/theme/dialogs_page.dart';
import 'package:zar360/pages/theme/bottom_navigation_page.dart';
import 'package:zar360/pages/theme/buttons_variations_page.dart';
import 'package:zar360/pages/theme/product_buttons_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زر۳۶۰'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFD4AF37).withOpacity(0.1),
              child: const Icon(
                Icons.person,
                color: Color(0xFFD4AF37),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.diamond,
                          color: Color(0xFFD4AF37),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'سلام! خوش آمدید',
                              style: TextStyle(
                                fontFamily: 'Iranyekan',
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Color(0xFF111827),
                              ),
                            ),
                            Text(
                              'صبح بخیر 👋',
                              style: TextStyle(
                                fontFamily: 'Iranyekan',
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'جواهراتی به منحصر به فردی داستان شما',
                    style: TextStyle(
                      fontFamily: 'Iranyekan',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'جواهرات عالی خود را بیابید و ظاهر خود را بدون زحمت ارتقا دهید',
                    style: TextStyle(
                      fontFamily: 'Iranyekan',
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'چه چیزی می‌خواهید بخرید؟',
                      style: TextStyle(
                        fontFamily: 'Iranyekan',
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Color(0xFF6B7280),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Categories Grid
            const Text(
              'دسته‌بندی محصولات',
              style: TextStyle(
                fontFamily: 'Iranyekan',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildJewelryCategoryCard(
                  context,
                  'انگشتر',
                  Icons.diamond,
                  const Color(0xFFD4AF37),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ButtonsPage()),
                  ),
                ),
                _buildJewelryCategoryCard(
                  context,
                  'گردنبند',
                  Icons.circle,
                  const Color(0xFFC0C0C0),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InputsPage()),
                  ),
                ),
                _buildJewelryCategoryCard(
                  context,
                  'دستبند',
                  Icons.circle_outlined,
                  const Color(0xFFD4AF37),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NavigationPage()),
                  ),
                ),
                _buildJewelryCategoryCard(
                  context,
                  'گوشواره',
                  Icons.radio_button_checked,
                  const Color(0xFFC0C0C0),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CardsPage()),
                  ),
                ),
                _buildJewelryCategoryCard(
                  context,
                  'ساعت',
                  Icons.watch,
                  const Color(0xFFD4AF37),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ListsPage()),
                  ),
                ),
                _buildJewelryCategoryCard(
                  context,
                  'سایر',
                  Icons.more_horiz,
                  const Color(0xFFC0C0C0),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DialogsPage()),
                  ),
                ),
                _buildJewelryCategoryCard(
                  context,
                  'ناوبری پایین',
                  Icons.navigation,
                  const Color(0xFFD4AF37),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BottomNavigationPage()),
                  ),
                ),
                _buildJewelryCategoryCard(
                  context,
                  'انواع دکمه‌ها',
                  Icons.touch_app,
                  const Color(0xFFC0C0C0),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ButtonsVariationsPage()),
                  ),
                ),
                _buildJewelryCategoryCard(
                  context,
                  'دکمه‌های محصول',
                  Icons.shopping_bag,
                  const Color(0xFFD4AF37),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProductButtonsPage()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJewelryCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Iranyekan',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
