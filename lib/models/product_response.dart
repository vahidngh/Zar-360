class ProductResponse {
  final List<Product> data;
  final List<String> errors;

  ProductResponse({
    required this.data,
    required this.errors,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      errors: json['errors'] != null
          ? List<String>.from(json['errors'])
          : [],
    );
  }

  bool get isSuccess => errors.isEmpty;
}

class Product {
  final int id;
  final String name;
  final String description;
  final String purity;
  final String type;
  final String typeLabel;
  final bool pinned;
  final Category category;
  final double taxPercent;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.purity,
    required this.type,
    required this.typeLabel,
    required this.pinned,
    required this.category,
    required this.taxPercent,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      purity: json['purity'] as String? ?? '',
      type: json['type'] as String,
      typeLabel: json['type_label'] as String,
      pinned: json['pinned'] as bool? ?? false,
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      taxPercent: (json['tax_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

