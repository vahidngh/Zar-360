import 'package:flutter/material.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  final List<Map<String, dynamic>> _messages = [
    {
      'name': 'احمد محمدی',
      'message': 'سلام، چطور می‌تونم کمکتون کنم؟',
      'time': '۱۰:۳۰',
      'isRead': false,
      'avatar': 'ا',
    },
    {
      'name': 'فاطمه احمدی',
      'message': 'ممنون از پیامتون، خیلی مفید بود',
      'time': '۰۹:۱۵',
      'isRead': true,
      'avatar': 'ف',
    },
    {
      'name': 'علی رضایی',
      'message': 'آیا می‌تونم قرار ملاقات تنظیم کنم؟',
      'time': 'دیروز',
      'isRead': false,
      'avatar': 'ع',
    },
    {
      'name': 'مریم حسینی',
      'message': 'لطفاً فایل‌های مورد نیاز رو ارسال کنید',
      'time': 'دیروز',
      'isRead': true,
      'avatar': 'م',
    },
  ];

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'سفارش جدید',
      'description': 'شما یک سفارش جدید دریافت کرده‌اید',
      'time': '۲ دقیقه پیش',
      'icon': Icons.shopping_cart,
      'color': Colors.blue,
    },
    {
      'title': 'پیام جدید',
      'description': 'پیام جدیدی از احمد محمدی دریافت کردید',
      'time': '۱۵ دقیقه پیش',
      'icon': Icons.message,
      'color': Colors.green,
    },
    {
      'title': 'تخفیف ویژه',
      'description': 'تخفیف ۵۰٪ برای تمام محصولات',
      'time': '۱ ساعت پیش',
      'icon': Icons.local_offer,
      'color': Colors.orange,
    },
    {
      'title': 'بروزرسانی سیستم',
      'description': 'سیستم با موفقیت بروزرسانی شد',
      'time': '۲ ساعت پیش',
      'icon': Icons.system_update,
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لیست محصولات طلا'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: const Color(0xFFD4AF37),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Jewelry Categories
            _buildSectionTitle('دسته‌بندی محصولات'),
            const SizedBox(height: 16),
            Card(
              elevation: 8,
              shadowColor: const Color(0xFFD4AF37).withOpacity(0.2),
              child: Column(
                children: [
                  _buildJewelryCategoryTile(
                    Icons.diamond,
                    'انگشتر',
                    'انگشترهای طلا و الماس',
                    const Color(0xFFD4AF37),
                    '۱۵ محصول',
                  ),
                  const Divider(height: 1),
                  _buildJewelryCategoryTile(
                    Icons.circle,
                    'گردنبند',
                    'گردنبندهای طلا و جواهر',
                    const Color(0xFFC0C0C0),
                    '۲۳ محصول',
                  ),
                  const Divider(height: 1),
                  _buildJewelryCategoryTile(
                    Icons.circle_outlined,
                    'دستبند',
                    'دستبندهای طلا و نقره',
                    const Color(0xFFD4AF37),
                    '۱۸ محصول',
                  ),
                  const Divider(height: 1),
                  _buildJewelryCategoryTile(
                    Icons.radio_button_checked,
                    'گوشواره',
                    'گوشواره‌های طلا و جواهر',
                    const Color(0xFFC0C0C0),
                    '۲۷ محصول',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Messages List
            _buildSectionTitle('لیست پیام‌ها'),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: _messages.map((message) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: message['isRead'] ? Colors.grey : Colors.blue,
                      child: Text(
                        message['avatar'],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      message['name'],
                      style: TextStyle(
                        fontWeight: message['isRead'] ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      message['message'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          message['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: message['isRead'] ? Colors.grey : Colors.blue,
                          ),
                        ),
                        if (!message['isRead'])
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        message['isRead'] = true;
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Notifications List
            _buildSectionTitle('لیست اعلان‌ها'),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: _notifications.map((notification) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: notification['color'].withOpacity(0.1),
                      child: Icon(
                        notification['icon'],
                        color: notification['color'],
                      ),
                    ),
                    title: Text(notification['title']),
                    subtitle: Text(notification['description']),
                    trailing: Text(
                      notification['time'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () {},
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Expandable List
            _buildSectionTitle('لیست قابل گسترش'),
            const SizedBox(height: 16),
            Card(
              child: ExpansionTile(
                leading: const Icon(Icons.info, color: Colors.blue),
                title: const Text('اطلاعات بیشتر'),
                subtitle: const Text('برای مشاهده جزئیات کلیک کنید'),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'این یک متن نمونه است که در بخش قابل گسترش نمایش داده می‌شود. می‌توانید هر نوع محتوایی را در اینجا قرار دهید.',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('انصراف'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('تأیید'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Swipeable List
            _buildSectionTitle('لیست قابل حذف'),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  Dismissible(
                    key: const Key('آیتم۱'),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('آیتم حذف شد')),
                      );
                    },
                    child: const ListTile(
                      leading: Icon(Icons.star, color: Colors.amber),
                      title: Text('آیتم قابل حذف ۱'),
                      subtitle: Text('برای حذف به سمت چپ بکشید'),
                    ),
                  ),
                  const Divider(height: 1),
                  Dismissible(
                    key: const Key('آیتم۲'),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('آیتم حذف شد')),
                      );
                    },
                    child: const ListTile(
                      leading: Icon(Icons.favorite, color: Colors.red),
                      title: Text('آیتم قابل حذف ۲'),
                      subtitle: Text('برای حذف به سمت چپ بکشید'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Custom List Items
            _buildSectionTitle('آیتم‌های سفارشی'),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _buildCustomListItem(
                    'محصولات',
                    'مدیریت محصولات و موجودی',
                    Icons.inventory,
                    Colors.blue,
                    '۱۲',
                  ),
                  const Divider(height: 1),
                  _buildCustomListItem(
                    'سفارشات',
                    'مشاهده و مدیریت سفارشات',
                    Icons.shopping_bag,
                    Colors.green,
                    '۵',
                  ),
                  const Divider(height: 1),
                  _buildCustomListItem(
                    'مشتریان',
                    'لیست مشتریان و اطلاعات',
                    Icons.people,
                    Colors.orange,
                    '۲۳۴',
                  ),
                  const Divider(height: 1),
                  _buildCustomListItem(
                    'گزارشات',
                    'گزارش‌های فروش و مالی',
                    Icons.analytics,
                    Colors.purple,
                    'جدید',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJewelryCategoryTile(IconData icon, String title, String subtitle, Color color, String count) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            count,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildCustomListItem(String title, String subtitle, IconData icon, Color color, String badge) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          badge,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: () {},
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
