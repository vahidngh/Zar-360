import 'package:flutter/material.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ناوبری پایین'),
        backgroundColor: const Color(0xFF111827),
        foregroundColor: const Color(0xFFD4AF37),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Classic Bottom Navigation
            _buildSectionTitle('ناوبری کلاسیک'),
            const SizedBox(height: 16),
            _buildClassicBottomNavigation(),

            const SizedBox(height: 32),

            // Modern Bottom Navigation
            _buildSectionTitle('ناوبری مدرن'),
            const SizedBox(height: 16),
            _buildModernBottomNavigation(),

            const SizedBox(height: 32),

            // Floating Bottom Navigation
            _buildSectionTitle('ناوبری شناور'),
            const SizedBox(height: 16),
            _buildFloatingBottomNavigation(),

            const SizedBox(height: 32),

            // Glass Bottom Navigation
            _buildSectionTitle('ناوبری شیشه‌ای'),
            const SizedBox(height: 16),
            _buildGlassBottomNavigation(),

            const SizedBox(height: 32),

            // Gradient Bottom Navigation
            _buildSectionTitle('ناوبری گرادیانتی'),
            const SizedBox(height: 16),
            _buildGradientBottomNavigation(),

            const SizedBox(height: 32),

            // Animated Bottom Navigation
            _buildSectionTitle('ناوبری انیمیشنی'),
            const SizedBox(height: 16),
            _buildAnimatedBottomNavigation(),

            const SizedBox(height: 32),

            // Minimal Bottom Navigation
            _buildSectionTitle('ناوبری مینیمال'),
            const SizedBox(height: 16),
            _buildMinimalBottomNavigation(),

            const SizedBox(height: 32),

            // Card Bottom Navigation
            _buildSectionTitle('ناوبری کارتی'),
            const SizedBox(height: 16),
            _buildCardBottomNavigation(),

            const SizedBox(height: 32),

            // Neon Bottom Navigation
            _buildSectionTitle('ناوبری نئونی'),
            const SizedBox(height: 16),
            _buildNeonBottomNavigation(),

            const SizedBox(height: 32),

            // Rounded Bottom Navigation
            _buildSectionTitle('ناوبری گرد'),
            const SizedBox(height: 16),
            _buildRoundedBottomNavigation(),

            const SizedBox(height: 32),

            // Pill Bottom Navigation
            _buildSectionTitle('ناوبری قرصی'),
            const SizedBox(height: 16),
            _buildPillBottomNavigation(),

            const SizedBox(height: 32),

            // Segmented Bottom Navigation
            _buildSectionTitle('ناوبری بخش‌بندی شده'),
            const SizedBox(height: 16),
            _buildSegmentedBottomNavigation(),

            const SizedBox(height: 32),

            // Badge Bottom Navigation
            _buildSectionTitle('ناوبری با نشان'),
            const SizedBox(height: 16),
            _buildBadgeBottomNavigation(),

            const SizedBox(height: 32),

            // Tab Bottom Navigation
            _buildSectionTitle('ناوبری تب‌دار'),
            const SizedBox(height: 16),
            _buildTabBottomNavigation(),

            const SizedBox(height: 32),

            // Icon Only Bottom Navigation
            _buildSectionTitle('ناوبری فقط آیکون'),
            const SizedBox(height: 16),
            _buildIconOnlyBottomNavigation(),

            const SizedBox(height: 32),

            // Text Only Bottom Navigation
            _buildSectionTitle('ناوبری فقط متن'),
            const SizedBox(height: 16),
            _buildTextOnlyBottomNavigation(),

            const SizedBox(height: 32),

            // Compact Bottom Navigation
            _buildSectionTitle('ناوبری فشرده'),
            const SizedBox(height: 16),
            _buildCompactBottomNavigation(),

            const SizedBox(height: 32),

            // Large Bottom Navigation
            _buildSectionTitle('ناوبری بزرگ'),
            const SizedBox(height: 16),
            _buildLargeBottomNavigation(),

            const SizedBox(height: 32),

            // Curved Bottom Navigation
            _buildSectionTitle('ناوبری منحنی'),
            const SizedBox(height: 16),
            _buildCurvedBottomNavigation(),

            const SizedBox(height: 32),

            // Wave Bottom Navigation
            _buildSectionTitle('ناوبری موجی'),
            const SizedBox(height: 16),
            _buildWaveBottomNavigation(),

            const SizedBox(height: 32),

            // Diamond Bottom Navigation
            _buildSectionTitle('ناوبری الماسی'),
            const SizedBox(height: 16),
            _buildDiamondBottomNavigation(),

            const SizedBox(height: 32),

            // Hexagon Bottom Navigation
            _buildSectionTitle('ناوبری شش‌ضلعی'),
            const SizedBox(height: 16),
            _buildHexagonBottomNavigation(),

            const SizedBox(height: 32),

            // Star Bottom Navigation
            _buildSectionTitle('ناوبری ستاره‌ای'),
            const SizedBox(height: 16),
            _buildStarBottomNavigation(),

            const SizedBox(height: 32),

            // Heart Bottom Navigation
            _buildSectionTitle('ناوبری قلبی'),
            const SizedBox(height: 16),
            _buildHeartBottomNavigation(),

            const SizedBox(height: 32),

            // Crown Bottom Navigation
            _buildSectionTitle('ناوبری تاجی'),
            const SizedBox(height: 16),
            _buildCrownBottomNavigation(),

            const SizedBox(height: 32),

            // Lightning Bottom Navigation
            _buildSectionTitle('ناوبری برقی'),
            const SizedBox(height: 16),
            _buildLightningBottomNavigation(),

            const SizedBox(height: 32),

            // Fire Bottom Navigation
            _buildSectionTitle('ناوبری آتشی'),
            const SizedBox(height: 16),
            _buildFireBottomNavigation(),

            const SizedBox(height: 32),

            // Ice Bottom Navigation
            _buildSectionTitle('ناوبری یخی'),
            const SizedBox(height: 16),
            _buildIceBottomNavigation(),

            const SizedBox(height: 32),

            // Rainbow Bottom Navigation
            _buildSectionTitle('ناوبری رنگین‌کمانی'),
            const SizedBox(height: 16),
            _buildRainbowBottomNavigation(),

            const SizedBox(height: 32),

            // Galaxy Bottom Navigation
            _buildSectionTitle('ناوبری کهکشانی'),
            const SizedBox(height: 16),
            _buildGalaxyBottomNavigation(),

            const SizedBox(height: 32),

            // Ocean Bottom Navigation
            _buildSectionTitle('ناوبری اقیانوسی'),
            const SizedBox(height: 16),
            _buildOceanBottomNavigation(),

            const SizedBox(height: 32),

            // Forest Bottom Navigation
            _buildSectionTitle('ناوبری جنگلی'),
            const SizedBox(height: 16),
            _buildForestBottomNavigation(),

            const SizedBox(height: 32),

            // Sunset Bottom Navigation
            _buildSectionTitle('ناوبری غروب'),
            const SizedBox(height: 16),
            _buildSunsetBottomNavigation(),
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

  // Classic Bottom Navigation
  Widget _buildClassicBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildClassicNavItem(Icons.home, 'خانه', 0),
          _buildClassicNavItem(Icons.search, 'جستجو', 1),
          _buildClassicNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildClassicNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildClassicNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modern Bottom Navigation
  Widget _buildModernBottomNavigation() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildModernNavItem(Icons.home_outlined, Icons.home, 'خانه', 0),
          _buildModernNavItem(Icons.search_outlined, Icons.search, 'جستجو', 1),
          _buildModernNavItem(Icons.favorite_outline, Icons.favorite, 'علاقه‌مندی', 2),
          _buildModernNavItem(Icons.person_outline, Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildModernNavItem(IconData outlineIcon, IconData filledIcon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSelected ? filledIcon : outlineIcon,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Floating Bottom Navigation
  Widget _buildFloatingBottomNavigation() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildFloatingNavItem(Icons.home, 'خانه', 0),
          _buildFloatingNavItem(Icons.search, 'جستجو', 1),
          _buildFloatingNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildFloatingNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildFloatingNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Glass Bottom Navigation
  Widget _buildGlassBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildGlassNavItem(Icons.home, 'خانه', 0),
          _buildGlassNavItem(Icons.search, 'جستجو', 1),
          _buildGlassNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildGlassNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildGlassNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 1) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Gradient Bottom Navigation
  Widget _buildGradientBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildGradientNavItem(Icons.home, 'خانه', 0),
          _buildGradientNavItem(Icons.search, 'جستجو', 1),
          _buildGradientNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildGradientNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildGradientNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Animated Bottom Navigation
  Widget _buildAnimatedBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAnimatedNavItem(Icons.home, 'خانه', 0),
          _buildAnimatedNavItem(Icons.search, 'جستجو', 1),
          _buildAnimatedNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildAnimatedNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildAnimatedNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 40 : 24,
                height: isSelected ? 40 : 24,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  size: isSelected ? 20 : 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Minimal Bottom Navigation
  Widget _buildMinimalBottomNavigation() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          _buildMinimalNavItem(Icons.home, 'خانه', 0),
          _buildMinimalNavItem(Icons.search, 'جستجو', 1),
          _buildMinimalNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildMinimalNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildMinimalNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Card Bottom Navigation
  Widget _buildCardBottomNavigation() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildCardNavItem(Icons.home, 'خانه', 0),
          _buildCardNavItem(Icons.search, 'جستجو', 1),
          _buildCardNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildCardNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildCardNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected ? [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Neon Bottom Navigation
  Widget _buildNeonBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNeonNavItem(Icons.home, 'خانه', 0),
          _buildNeonNavItem(Icons.search, 'جستجو', 1),
          _buildNeonNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildNeonNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildNeonNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: const Color(0xFFD4AF37), width: 1) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF9CA3AF),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Rounded Bottom Navigation
  Widget _buildRoundedBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildRoundedNavItem(Icons.home, 'خانه', 0),
          _buildRoundedNavItem(Icons.search, 'جستجو', 1),
          _buildRoundedNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildRoundedNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildRoundedNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pill Bottom Navigation - قرصی
  Widget _buildPillBottomNavigation() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildPillNavItem(Icons.home, 'خانه', 0),
          _buildPillNavItem(Icons.search, 'جستجو', 1),
          _buildPillNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildPillNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildPillNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Segmented Bottom Navigation - بخش‌بندی شده
  Widget _buildSegmentedBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          _buildSegmentedNavItem(Icons.home, 'خانه', 0),
          _buildSegmentedNavItem(Icons.search, 'جستجو', 1),
          _buildSegmentedNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildSegmentedNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildSegmentedNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Badge Bottom Navigation - با نشان
  Widget _buildBadgeBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildBadgeNavItem(Icons.home, 'خانه', 0, false),
          _buildBadgeNavItem(Icons.search, 'جستجو', 1, false),
          _buildBadgeNavItem(Icons.favorite, 'علاقه‌مندی', 2, true),
          _buildBadgeNavItem(Icons.person, 'پروفایل', 3, false),
        ],
      ),
    );
  }

  Widget _buildBadgeNavItem(IconData icon, String label, int index, bool hasBadge) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Iranyekan',
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              if (hasBadge)
                Positioned(
                  top: 8,
                  right: 20,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Tab Bottom Navigation - تب‌دار
  Widget _buildTabBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabNavItem(Icons.home, 'خانه', 0),
          _buildTabNavItem(Icons.search, 'جستجو', 1),
          _buildTabNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildTabNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildTabNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border(
              bottom: BorderSide(color: const Color(0xFFD4AF37), width: 3),
            ) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Icon Only Bottom Navigation - فقط آیکون
  Widget _buildIconOnlyBottomNavigation() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildIconOnlyNavItem(Icons.home, 0),
          _buildIconOnlyNavItem(Icons.search, 1),
          _buildIconOnlyNavItem(Icons.favorite, 2),
          _buildIconOnlyNavItem(Icons.person, 3),
        ],
      ),
    );
  }

  Widget _buildIconOnlyNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  // Text Only Bottom Navigation - فقط متن
  Widget _buildTextOnlyBottomNavigation() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTextOnlyNavItem('خانه', 0),
          _buildTextOnlyNavItem('جستجو', 1),
          _buildTextOnlyNavItem('علاقه‌مندی', 2),
          _buildTextOnlyNavItem('پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildTextOnlyNavItem(String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Iranyekan',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Compact Bottom Navigation - فشرده
  Widget _buildCompactBottomNavigation() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildCompactNavItem(Icons.home, 'خانه', 0),
          _buildCompactNavItem(Icons.search, 'جستجو', 1),
          _buildCompactNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildCompactNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildCompactNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                size: 18,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 8,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Large Bottom Navigation - بزرگ
  Widget _buildLargeBottomNavigation() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildLargeNavItem(Icons.home, 'خانه', 0),
          _buildLargeNavItem(Icons.search, 'جستجو', 1),
          _buildLargeNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildLargeNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildLargeNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  size: 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Curved Bottom Navigation - منحنی
  Widget _buildCurvedBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildCurvedNavItem(Icons.home, 'خانه', 0),
          _buildCurvedNavItem(Icons.search, 'جستجو', 1),
          _buildCurvedNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildCurvedNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildCurvedNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Wave Bottom Navigation - موجی
  Widget _buildWaveBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildWaveNavItem(Icons.home, 'خانه', 0),
          _buildWaveNavItem(Icons.search, 'جستجو', 1),
          _buildWaveNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildWaveNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildWaveNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Diamond Bottom Navigation - الماسی
  Widget _buildDiamondBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildDiamondNavItem(Icons.home, 'خانه', 0),
          _buildDiamondNavItem(Icons.search, 'جستجو', 1),
          _buildDiamondNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildDiamondNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildDiamondNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hexagon Bottom Navigation - شش‌ضلعی
  Widget _buildHexagonBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildHexagonNavItem(Icons.home, 'خانه', 0),
          _buildHexagonNavItem(Icons.search, 'جستجو', 1),
          _buildHexagonNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildHexagonNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildHexagonNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Star Bottom Navigation - ستاره‌ای
  Widget _buildStarBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStarNavItem(Icons.home, 'خانه', 0),
          _buildStarNavItem(Icons.search, 'جستجو', 1),
          _buildStarNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildStarNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildStarNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Heart Bottom Navigation - قلبی
  Widget _buildHeartBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildHeartNavItem(Icons.home, 'خانه', 0),
          _buildHeartNavItem(Icons.search, 'جستجو', 1),
          _buildHeartNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildHeartNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildHeartNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Crown Bottom Navigation - تاجی
  Widget _buildCrownBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildCrownNavItem(Icons.home, 'خانه', 0),
          _buildCrownNavItem(Icons.search, 'جستجو', 1),
          _buildCrownNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildCrownNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildCrownNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Lightning Bottom Navigation - برقی
  Widget _buildLightningBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildLightningNavItem(Icons.home, 'خانه', 0),
          _buildLightningNavItem(Icons.search, 'جستجو', 1),
          _buildLightningNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildLightningNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildLightningNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fire Bottom Navigation - آتشی
  Widget _buildFireBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildFireNavItem(Icons.home, 'خانه', 0),
          _buildFireNavItem(Icons.search, 'جستجو', 1),
          _buildFireNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildFireNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildFireNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ice Bottom Navigation - یخی
  Widget _buildIceBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF74B9FF), Color(0xFF0984E3)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF74B9FF).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildIceNavItem(Icons.home, 'خانه', 0),
          _buildIceNavItem(Icons.search, 'جستجو', 1),
          _buildIceNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildIceNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildIceNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Rainbow Bottom Navigation - رنگین‌کمانی
  Widget _buildRainbowBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4), Color(0xFF45B7D1), Color(0xFF96CEB4)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildRainbowNavItem(Icons.home, 'خانه', 0),
          _buildRainbowNavItem(Icons.search, 'جستجو', 1),
          _buildRainbowNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildRainbowNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildRainbowNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Galaxy Bottom Navigation - کهکشانی
  Widget _buildGalaxyBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildGalaxyNavItem(Icons.home, 'خانه', 0),
          _buildGalaxyNavItem(Icons.search, 'جستجو', 1),
          _buildGalaxyNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildGalaxyNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildGalaxyNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ocean Bottom Navigation - اقیانوسی
  Widget _buildOceanBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF74B9FF), Color(0xFF0984E3)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF74B9FF).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildOceanNavItem(Icons.home, 'خانه', 0),
          _buildOceanNavItem(Icons.search, 'جستجو', 1),
          _buildOceanNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildOceanNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildOceanNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Forest Bottom Navigation - جنگلی
  Widget _buildForestBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00B894), Color(0xFF00A085)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B894).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildForestNavItem(Icons.home, 'خانه', 0),
          _buildForestNavItem(Icons.search, 'جستجو', 1),
          _buildForestNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildForestNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildForestNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sunset Bottom Navigation - غروب
  Widget _buildSunsetBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7675), Color(0xFFE17055)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7675).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSunsetNavItem(Icons.home, 'خانه', 0),
          _buildSunsetNavItem(Icons.search, 'جستجو', 1),
          _buildSunsetNavItem(Icons.favorite, 'علاقه‌مندی', 2),
          _buildSunsetNavItem(Icons.person, 'پروفایل', 3),
        ],
      ),
    );
  }

  Widget _buildSunsetNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
