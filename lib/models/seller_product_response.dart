import 'product_response.dart';

class SellerProductResponse {
  final List<SellerProduct> data;
  final List<String> errors;

  SellerProductResponse({
    required this.data,
    required this.errors,
  });

  factory SellerProductResponse.fromJson(Map<String, dynamic> json) {
    return SellerProductResponse(
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => SellerProduct.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      errors: json['errors'] != null
          ? List<String>.from(json['errors'])
          : [],
    );
  }

  bool get isSuccess => errors.isEmpty;
}

class SellerProduct {
  final int id;
  final String name;
  final String? description;
  final String purity;
  final String type;
  final String typeLabel;
  final bool pinned;
  final bool isActive;
  final Category category;
  final double taxPercent;

  SellerProduct({
    required this.id,
    required this.name,
    this.description,
    required this.purity,
    required this.type,
    required this.typeLabel,
    required this.pinned,
    required this.isActive,
    required this.category,
    required this.taxPercent,
  });

  factory SellerProduct.fromJson(Map<String, dynamic> json) {
    return SellerProduct(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      purity: json['purity'] as String,
      type: json['type'] as String,
      typeLabel: json['type_label'] as String,
      pinned: json['pinned'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      taxPercent: (json['tax_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

