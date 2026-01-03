import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/cart_item.dart';
import '../models/product_response.dart' as product_model;
import '../utils/date_utils.dart' as persian_date;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'zar360.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // جدول cart_items
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        product_type TEXT NOT NULL DEFAULT 'weight',
        product_tax_percent REAL NOT NULL DEFAULT 0,
        product_purity TEXT NOT NULL,
        weight REAL NOT NULL DEFAULT 0,
        count INTEGER NOT NULL DEFAULT 0,
        unit_amount REAL NOT NULL,
        total_unit_amount REAL NOT NULL,
        wage_percent REAL NOT NULL,
        wage_per_gram REAL NOT NULL DEFAULT 0,
        wage_per_count REAL NOT NULL DEFAULT 0,
        total_wage_amount REAL NOT NULL,
        profit_percent REAL NOT NULL,
        profit_amount REAL NOT NULL,
        commission_percent REAL NOT NULL,
        commission_amount REAL NOT NULL,
        tax_amount REAL NOT NULL DEFAULT 0,
        total_amount REAL NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // جدول cart_metadata
    await db.execute('''
      CREATE TABLE cart_metadata (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        description TEXT,
        customer_type TEXT,
        customer_mobile TEXT,
        customer_name TEXT,
        customer_national_code TEXT,
        invoice_type TEXT,
        seller_invoice_number TEXT,
        issued_at TEXT,
        updated_at TEXT NOT NULL
      )
    ''');

    // درج ردیف اولیه برای cart_metadata
    await db.insert('cart_metadata', {
      'id': 1,
      'description': null,
      'customer_type': null,
      'customer_mobile': null,
      'customer_name': null,
      'customer_national_code': null,
      'invoice_type': null,
      'seller_invoice_number': null,
      'issued_at': persian_date.PersianDateUtils.getCurrentPersianDate(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('🔄 [DatabaseService] شروع migration از نسخه $oldVersion به $newVersion');
    
    if (oldVersion < 2) {
      debugPrint('📝 [DatabaseService] اجرای migration نسخه 2...');
      // اضافه کردن فیلدهای count و wage_per_count
      await db.execute('ALTER TABLE cart_items ADD COLUMN count INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE cart_items ADD COLUMN wage_per_count REAL NOT NULL DEFAULT 0');
      debugPrint('✅ [DatabaseService] migration نسخه 2 انجام شد');
    }
    if (oldVersion < 3) {
      debugPrint('📝 [DatabaseService] اجرای migration نسخه 3...');
      // اضافه کردن فیلد product_type
      await db.execute('ALTER TABLE cart_items ADD COLUMN product_type TEXT NOT NULL DEFAULT \'weight\'');
      debugPrint('✅ [DatabaseService] migration نسخه 3 انجام شد');
    }
    if (oldVersion < 4) {
      debugPrint('📝 [DatabaseService] اجرای migration نسخه 4...');
      // اضافه کردن فیلد product_tax_percent
      try {
        await db.execute('ALTER TABLE cart_items ADD COLUMN product_tax_percent REAL NOT NULL DEFAULT 0');
        debugPrint('✅ [DatabaseService] migration نسخه 4 انجام شد - ستون product_tax_percent اضافه شد');
      } catch (e) {
        debugPrint('⚠️ [DatabaseService] خطا در migration نسخه 4: $e');
        // اگر ستون از قبل وجود دارد، خطا را نادیده بگیر
        if (e.toString().contains('duplicate column')) {
          debugPrint('ℹ️ [DatabaseService] ستون product_tax_percent از قبل وجود دارد، نادیده گرفته شد');
        } else {
          rethrow;
        }
      }
    }
    
    debugPrint('✅ [DatabaseService] همه migration‌ها با موفقیت انجام شدند');
  }

  // بررسی و اضافه کردن ستون در صورت نبودن
  Future<void> _ensureColumnExists(Database db, String tableName, String columnName, String columnDefinition) async {
    try {
      // بررسی وجود ستون
      final result = await db.rawQuery(
        "PRAGMA table_info($tableName)"
      );
      
      final columnExists = result.any((column) => column['name'] == columnName);
      
      if (!columnExists) {
        debugPrint('⚠️ [DatabaseService] ستون $columnName در جدول $tableName وجود ندارد، در حال اضافه کردن...');
        await db.execute('ALTER TABLE $tableName ADD COLUMN $columnName $columnDefinition');
        debugPrint('✅ [DatabaseService] ستون $columnName با موفقیت اضافه شد');
      }
    } catch (e) {
      debugPrint('❌ [DatabaseService] خطا در بررسی/اضافه کردن ستون $columnName: $e');
      // اگر ستون از قبل وجود دارد، خطا را نادیده بگیر
      if (!e.toString().contains('duplicate column') && !e.toString().contains('already exists')) {
        rethrow;
      }
    }
  }

  // ==================== Cart Items ====================

  Future<int> insertCartItem(CartItem item) async {
    try {
      debugPrint('💾 [DatabaseService] شروع insertCartItem...');
      final db = await database;
      debugPrint('✅ [DatabaseService] دیتابیس دریافت شد');
      
      // بررسی و اضافه کردن ستون product_tax_percent در صورت نبودن
      await _ensureColumnExists(db, 'cart_items', 'product_tax_percent', 'REAL NOT NULL DEFAULT 0');
      
      final now = DateTime.now().toIso8601String();
      
      final data = {
        'product_id': item.product.id,
        'product_name': item.product.name,
        'product_type': item.product.type,
        'product_tax_percent': item.product.taxPercent,
        'product_purity': item.purity,
        'weight': item.weight,
        'count': item.count,
        'unit_amount': item.unitAmount,
        'total_unit_amount': item.totalUnitAmount,
        'wage_percent': item.wagePercent,
        'wage_per_gram': item.wagePerGram,
        'wage_per_count': item.wagePerCount,
        'total_wage_amount': item.totalWageAmount,
        'profit_percent': item.profitPercent,
        'profit_amount': item.profitAmount,
        'commission_percent': item.commissionPercent,
        'commission_amount': item.commissionAmount,
        'tax_amount': item.taxAmount,
        'total_amount': item.totalAmount,
        'created_at': now,
        'updated_at': now,
      };
      
      debugPrint('📝 [DatabaseService] داده‌ها آماده شدند:');
      debugPrint('  - product_id: ${data['product_id']}');
      debugPrint('  - product_name: ${data['product_name']}');
      debugPrint('  - weight: ${data['weight']}');
      debugPrint('  - total_amount: ${data['total_amount']}');
      
      final id = await db.insert('cart_items', data);
      debugPrint('✅ [DatabaseService] CartItem با ID $id به دیتابیس اضافه شد');
      return id;
    } catch (e, stackTrace) {
      debugPrint('❌ [DatabaseService] خطا در insertCartItem:');
      debugPrint('  Error: $e');
      debugPrint('  StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<List<CartItem>> getAllCartItems() async {
    final db = await database;
    final maps = await db.query(
      'cart_items',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => _cartItemFromMap(map)).toList();
  }

  Future<void> deleteCartItem(int id) async {
    final db = await database;
    await db.delete(
      'cart_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearCartItems() async {
    final db = await database;
    await db.delete('cart_items');
  }

  CartItem _cartItemFromMap(Map<String, dynamic> map) {
    // ساخت Product از اطلاعات ذخیره شده
    final product = product_model.Product(
      id: map['product_id'] as int,
      name: map['product_name'] as String,
      description: '',
      purity: map['product_purity'] as String,
      type: map['product_type'] as String? ?? 'weight',
      typeLabel: map['product_type'] == 'count' ? 'تعدادی' : 'وزنی',
      pinned: false,
      category: product_model.Category(id: 0, name: ''),
      taxPercent: (map['product_tax_percent'] as num?)?.toDouble() ?? 0.0,
    );

    return CartItem(
      id: map['id'] as int,
      product: product,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      count: map['count'] as int? ?? 0,
      purity: map['product_purity'] as String,
      unitAmount: map['unit_amount'] as double,
      totalUnitAmount: map['total_unit_amount'] as double,
      wagePercent: map['wage_percent'] as double,
      wagePerGram: (map['wage_per_gram'] as num?)?.toDouble() ?? 0.0,
      wagePerCount: (map['wage_per_count'] as num?)?.toDouble() ?? 0.0,
      totalWageAmount: map['total_wage_amount'] as double,
      profitPercent: map['profit_percent'] as double,
      profitAmount: map['profit_amount'] as double,
      commissionPercent: map['commission_percent'] as double,
      commissionAmount: map['commission_amount'] as double,
      taxAmount: (map['tax_amount'] as num).toDouble(),
      totalAmount: map['total_amount'] as double,
    );
  }

  // ==================== Cart Metadata ====================

  Future<Map<String, dynamic>?> getCartMetadata() async {
    final db = await database;
    final maps = await db.query(
      'cart_metadata',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<void> updateCartMetadata({
    String? description,
    String? customerType,
    String? customerMobile,
    String? customerName,
    String? customerNationalCode,
    String? invoiceType,
    String? sellerInvoiceNumber,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    final data = <String, dynamic>{
      'updated_at': now,
    };

    if (description != null) data['description'] = description;
    if (customerType != null) data['customer_type'] = customerType;
    if (customerMobile != null) data['customer_mobile'] = customerMobile;
    if (customerName != null) data['customer_name'] = customerName;
    if (customerNationalCode != null) data['customer_national_code'] = customerNationalCode;
    if (invoiceType != null) data['invoice_type'] = invoiceType;
    if (sellerInvoiceNumber != null) data['seller_invoice_number'] = sellerInvoiceNumber;

    // به‌روزرسانی تاریخ صدور
    data['issued_at'] = persian_date.PersianDateUtils.getCurrentPersianDate();

    await db.update(
      'cart_metadata',
      data,
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> clearCartMetadata() async {
    final db = await database;
    await db.update(
      'cart_metadata',
      {
        'description': null,
        'customer_type': null,
        'customer_mobile': null,
        'customer_name': null,
        'customer_national_code': null,
        'invoice_type': null,
        'seller_invoice_number': null,
        'issued_at': persian_date.PersianDateUtils.getCurrentPersianDate(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // پاک کردن کامل دیتابیس (حذف فایل دیتابیس)
  Future<void> deleteAllData() async {
    try {
      // بستن دیتابیس فعلی
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // حذف فایل دیتابیس
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'zar360.db');
      await sqflite.deleteDatabase(path);
      debugPrint('✅ [DatabaseService] دیتابیس با موفقیت حذف شد');
    } catch (e) {
      debugPrint('❌ [DatabaseService] خطا در حذف دیتابیس: $e');
      rethrow;
    }
  }
}

