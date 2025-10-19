import 'package:flutter/material.dart';
import 'package:zar360/pages/buttons_page.dart';
import 'package:zar360/pages/inputs_page.dart';
import 'package:zar360/pages/navigation_page.dart';
import 'package:zar360/pages/cards_page.dart';
import 'package:zar360/pages/lists_page.dart';
import 'package:zar360/pages/dialogs_page.dart';

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
        title: const Text(
          'زر۳۶۰ - طلا و جواهر',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: const Color(0xFFD4AF37),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF2C2C2C),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.diamond,
                          color: Color(0xFFD4AF37),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'زر۳۶۰',
                              style: TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'طلا و جواهر لوکس',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'به فروشگاه آنلاین طلا و جواهر خوش آمدید',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'مجموعه‌ای از زیباترین و باکیفیت‌ترین طلا و جواهرات',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
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
    return Card(
      elevation: 8,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'مشاهده محصولات',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
